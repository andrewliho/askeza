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
    
    // Для создания Askeza из шаблона
    public func createAskeza() -> Askeza {
        let askezaDuration: AskezaDuration = duration == 0 ? .lifetime : .days(duration)
        
        return Askeza(
            title: title,
            intention: intention,
            startDate: Date(),
            duration: askezaDuration,
            progress: 0,
            isCompleted: false,
            category: category,
            templateID: id  // Связываем Askeza с шаблоном
        )
    }
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
    }
    
    public func status(templateDuration: Int) -> TemplateStatus {
        if timesCompleted >= 3 || daysCompleted >= 90 {
            return .mastered
        }
        if dateStarted == nil {
            return .notStarted
        }
        if templateDuration > 0 && daysCompleted >= templateDuration {
            return .completed
        }
        return .inProgress
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