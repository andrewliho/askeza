import Foundation
import SwiftUI
import SwiftData

@Model
public class PracticeTemplate {
    @Attribute(.unique) public var id: UUID
    public var templateId: String  // Уникальный строковой идентификатор для практики (например, "cold-shower-14")
    public var title: String
    public var category: AskezaCategory
    public var duration: Int       // дни (0 = lifetime)
    public var quote: String
    public var difficulty: Int     // 1-5
    public var practiceDescription: String
    public var intention: String
    public var courseID: UUID?     // Связь с курсом, если практика является частью курса
    
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
    
    /// Проверяет соответствие названия практики и ее продолжительности
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
                        print("⚠️ PracticeTemplate: В названии указано \(daysInTitle) дней, но в duration = \(durationValue) для практики \(title)")
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
            print("❌ PracticeTemplate: Ошибка при проверке названия практики: \(error)")
            return true // В случае ошибки разрешаем создание, чтобы не блокировать пользователя
        }
    }
    
    // Метод createAskeza удален, так как создание аскезы теперь полностью перенесено
    // в класс PracticeTemplateStore для лучшего контроля и избежания дублирования
}

public enum TemplateStatus: String, Codable {
    case notStarted = "active_today"
    case inProgress = "active_ongoing"
    case completed = "Завершена"
    case mastered = "Освоена"
    
    public var icon: String {
        switch self {
        case .notStarted: return "flame.fill"
        case .inProgress: return "flame.fill"
        case .completed: return "checkmark.circle.fill"
        case .mastered: return "star.fill"
        }
    }
    
    public var color: Color {
        switch self {
        case .notStarted: return .green
        case .inProgress: return .orange
        case .completed: return .green
        case .mastered: return .purple
        }
    }
    
    public var displayText: String {
        switch self {
        case .notStarted:
            return "Не начата"
        case .inProgress:
            return "Активная"
        default:
            return self.rawValue
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
        // Если практика еще не начата
        if dateStarted == nil {
            return .notStarted
        }
        
        // Проверка счетчика завершений - если практика была завершена хотя бы раз
        // и не в процессе выполнения (daysCompleted меньше продолжительности)
        // то она считается завершенной, а не активной
        if timesCompleted > 0 && daysCompleted < templateDuration && templateDuration > 0 {
            return .completed
        }
        
        // Проверяем, начата ли практика сегодня
        let calendar = Calendar.current
        let isStartedToday = calendar.isDateInToday(dateStarted!)
        
        // Пожизненные практики (templateDuration = 0) - всегда остаются в статусе "Активная"
        // если они были начаты
        if templateDuration == 0 {
            // Проверяем, не прошло ли больше 3 дней с последнего обновления
            let daysSinceLastUpdate = calendar.dateComponents([.day], from: dateStarted!, to: Date()).day ?? 0
            
            // Если начата сегодня или недавно - это активная практика
            if isStartedToday || daysSinceLastUpdate <= 3 {
                // Пожизненная активная практика
                return .inProgress
            } else if daysCompleted > 0 {
                // Если не обновлялась более 3 дней, но был прогресс - практика "Освоена"
                return .mastered
            } else {
                return .notStarted
            }
        }
        
        // Для обычных практик с конкретной длительностью
        // Если практика завершена (прогресс >= длительности)
        if daysCompleted >= templateDuration {
            return .completed
        }
        
        // Если практика освоена (завершена 3 или более раз)
        if timesCompleted >= 3 {
            return .mastered
        }
        
        // Если практика в процессе выполнения и не была ранее завершена
        if daysCompleted > 0 {
            // Проверяем, не прошло ли больше 3 дней с последнего обновления
            let daysSinceLastUpdate = calendar.dateComponents([.day], from: dateStarted!, to: Date()).day ?? 0
            
            // Если прогресс не обновлялся более 3 дней и не равен нулю, считаем практику завершенной
            if daysSinceLastUpdate > 3 {
                return .completed
            }
            
            return .inProgress
        }
        
        // По умолчанию считаем, что практика не начата
        return .notStarted
    }
}

// Модель для курсов (цепочек практик)
@Model
public class CoursePath {
    @Attribute(.unique) public var id: UUID
    public var title: String
    public var courseDescription: String
    public var templateIDs: [UUID]  // ID практик в порядке прохождения
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