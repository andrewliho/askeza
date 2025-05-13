import Foundation
import SwiftUI
import SwiftData

@Model
public class PracticeTemplate {
    @Attribute(.unique) public var id: UUID
    public var templateId: String  // Уникальный строковой идентификатор для шаблона (например, "cold-shower-14")
    public var title: String
    public var category: AskezaCategory
    public var duration: Int       // дни (0 = lifetime)
    public var quote: String
    public var difficulty: Int     // 1-5
    public var practiceDescription: String
    public var intention: String
    public var courseID: UUID?     // Связь с курсом, если шаблон является частью курса
    
    public init(
        id: UUID = UUID(),
        templateId: String,
        title: String,
        category: AskezaCategory,
        duration: Int,
        quote: String,
        difficulty: Int,
        description: String,
        intention: String,
        courseID: UUID? = nil
    ) {
        self.id = id
        self.templateId = templateId
        self.title = title
        self.category = category
        self.duration = duration
        self.quote = quote
        self.difficulty = difficulty
        self.practiceDescription = description
        self.intention = intention
        self.courseID = courseID
    }
    
    /// Проверяет соответствие названия шаблона и его продолжительности
    /// - Returns: true - если название соответствует продолжительности, false - если есть несоответствие
    public func validateDuration() -> Bool {
        let title = self.title
        let durationValue = self.duration
        
        // Регулярное выражение для поиска числа дней в названии (например, "7 дней", "14-дневный", "30 дней")
        let pattern = "(\\d+)[ -]*(дней|дня|день|дневный)"
        
        do {
            let regex = try NSRegularExpression(pattern: pattern, options: [])
            let nsString = title as NSString
            let matches = regex.matches(in: title, options: [], range: NSRange(location: 0, length: nsString.length))
            
            if !matches.isEmpty, let match = matches.first {
                let dayRange = match.range(at: 1)
                if dayRange.location != NSNotFound, let daysInTitle = Int(nsString.substring(with: dayRange)) {
                    // Если в названии указано количество дней, оно должно соответствовать значению duration
                    if daysInTitle != durationValue && durationValue != 0 { // 0 = lifetime
                        print("⚠️ PracticeTemplate: В названии указано \(daysInTitle) дней, но в duration = \(durationValue) для шаблона \(title)")
                        return false
                    }
                }
            }
            
            // Если у нас пожизненная аскеза (duration = 0)
            if durationValue == 0 && (title.contains("Пожизненно") || title.contains("пожизненно")) {
                return true
            }
            
            // Если в названии нет числа дней, или число соответствует duration, или это "Год" (365 дней)
            if title.contains("Год") && durationValue == 365 {
                return true
            }
            
            return true
        } catch {
            print("❌ PracticeTemplate: Ошибка при проверке названия шаблона: \(error)")
            return true // В случае ошибки разрешаем создание, чтобы не блокировать пользователя
        }
    }
    
    // Метод createAskeza удален, так как создание аскезы теперь полностью перенесено
    // в класс PracticeTemplateStore для лучшего контроля и избежания дублирования
}

public enum TemplateStatus: String, Codable {
    case notStarted = "Не начато"
    case inProgress = "Активная"
    case completed = "Завершено"
    case mastered = "Мастер"
    
    public var icon: String {
        switch self {
        case .notStarted: return "circle"
        case .inProgress: return "flame.fill"
        case .completed: return "checkmark.circle.fill"
        case .mastered: return "star.fill"
        }
    }
    
    public var color: Color {
        switch self {
        case .notStarted: return .gray
        case .inProgress: return .orange
        case .completed: return .green
        case .mastered: return .purple
        }
    }
}

@Model
public class TemplateProgress {
    @Attribute(.unique) public var id: UUID
    public var templateID: UUID
    public var dateStarted: Date?
    public var daysCompleted: Int
    public var timesCompleted: Int
    public var currentStreak: Int
    public var bestStreak: Int
    // Флаг для отслеживания текущего процесса завершения
    // Предотвращает двойное увеличение счетчика завершений
    public var isProcessingCompletion: Bool = false
    
    public init(
        id: UUID = UUID(),
        templateID: UUID,
        dateStarted: Date? = nil,
        daysCompleted: Int = 0,
        timesCompleted: Int = 0,
        currentStreak: Int = 0,
        bestStreak: Int = 0
    ) {
        self.id = id
        self.templateID = templateID
        self.dateStarted = dateStarted
        self.daysCompleted = daysCompleted
        self.timesCompleted = timesCompleted
        self.currentStreak = currentStreak
        self.bestStreak = bestStreak
        self.isProcessingCompletion = false
    }
    
    public func status(templateDuration: Int) -> TemplateStatus {
        // Если шаблон завершен 3 или более раз или пользователь накопил 90+ дней практики,
        // считаем его мастером
        if timesCompleted >= 3 || daysCompleted >= 90 {
            return .mastered
        }
        
        // Если шаблон еще не начат
        if dateStarted == nil {
            return .notStarted
        }
        
        // Если шаблон в процессе выполнения
        if let startDate = dateStarted {
            // Если это пожизненная практика или текущий прогресс меньше длительности шаблона
            if templateDuration == 0 || daysCompleted < templateDuration {
                // Проверяем, не прошло ли больше 3 дней с последнего обновления
                let calendar = Calendar.current
                let daysSinceLastUpdate = calendar.dateComponents([.day], from: startDate, to: Date()).day ?? 0
                
                // Если прогресс не обновлялся более 3 дней и не равен нулю, считаем шаблон завершенным
                if daysSinceLastUpdate > 3 && daysCompleted > 0 {
                    return .completed
                }
                
                return .inProgress
            }
        }
        
        // Если шаблон завершен (прогресс >= длительности)
        if templateDuration > 0 && daysCompleted >= templateDuration {
            return .completed
        }
        
        // По умолчанию считаем, что шаблон не начат
        return .notStarted
    }
}

// Модель для курсов (цепочек практик)
@Model
public class CoursePath {
    @Attribute(.unique) public var id: UUID
    public var title: String
    public var courseDescription: String
    public var templateIDs: [UUID]  // ID шаблонов в порядке прохождения
    public var category: AskezaCategory
    public var difficulty: Int     // 1-5
    
    public init(
        id: UUID = UUID(),
        title: String,
        description: String,
        templateIDs: [UUID],
        category: AskezaCategory,
        difficulty: Int
    ) {
        self.id = id
        self.title = title
        self.courseDescription = description
        self.templateIDs = templateIDs
        self.category = category
        self.difficulty = difficulty
    }
}

// Модель для профиля пользователя с геймификацией
@Model
public class UserProfile {
    @Attribute(.unique) public var id: UUID
    public var nickname: String
    public var avatarURL: URL?
    public var xp: Int
    public var level: Int
    
    public init(
        id: UUID = UUID(),
        nickname: String,
        avatarURL: URL? = nil,
        xp: Int = 0,
        level: Int = 1
    ) {
        self.id = id
        self.nickname = nickname
        self.avatarURL = avatarURL
        self.xp = xp
        self.level = level
    }
    
    // Вычисляем уровень на основе XP (каждые 100 XP = новый уровень)
    public func calculateLevel() -> Int {
        return max(1, xp / 100 + 1)
    }
    
    // Добавляем XP и обновляем уровень
    public func addXP(_ amount: Int) {
        let _ = level // Не используем сохраненное старое значение
        xp += amount
        level = calculateLevel()
        
        // TODO: Если произошло повышение уровня, запустить анимацию
    }
} 