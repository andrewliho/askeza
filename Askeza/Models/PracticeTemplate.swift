import Foundation
import SwiftUI

// Эта модель будет преобразована в SwiftData модель в будущем
// Сейчас используем обычную структуру для совместимости с текущим кодом
public struct PracticeTemplate: Identifiable, Codable {
    public let id: UUID
    public let templateId: String  // Уникальный строковой идентификатор для шаблона (например, "cold-shower-14")
    public let title: String
    public let category: AskezaCategory
    public let duration: Int       // дни (0 = lifetime)
    public let quote: String
    public let difficulty: Int     // 1-3
    public let description: String
    public let intention: String
    
    public init(
        id: UUID = UUID(),
        templateId: String,
        title: String,
        category: AskezaCategory,
        duration: Int,
        quote: String,
        difficulty: Int,
        description: String,
        intention: String
    ) {
        self.id = id
        self.templateId = templateId
        self.title = title
        self.category = category
        self.duration = duration
        self.quote = quote
        self.difficulty = difficulty
        self.description = description
        self.intention = intention
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
            category: category
        )
    }
}

public enum TemplateStatus: String, Codable {
    case notStarted = "Не начато"
    case inProgress = "В процессе"
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

public struct TemplateProgress: Identifiable, Codable {
    public let id: UUID
    public let templateID: UUID
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

// Опциональная модель для курсов (цепочек практик)
public struct CoursePath: Identifiable, Codable {
    public let id: UUID
    public let title: String
    public let description: String
    public let templateIDs: [UUID]  // ID шаблонов в порядке прохождения
    public let category: AskezaCategory
    public let difficulty: Int     // 1-3
    
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
        self.description = description
        self.templateIDs = templateIDs
        self.category = category
        self.difficulty = difficulty
    }
} 