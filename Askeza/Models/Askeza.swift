import Foundation
import SwiftUI

// MARK: - Notification Names
public extension Notification.Name {
    static let addAskeza = Notification.Name("AddAskezaNotification")
}

// Расширение для типа Int, добавляющее свойство daysString
extension Int {
    var daysString: String {
        let lastDigit = self % 10
        let lastTwoDigits = self % 100
        
        if lastTwoDigits >= 11 && lastTwoDigits <= 19 {
            return "дней"
        }
        
        switch lastDigit {
        case 1:
            return "день"
        case 2, 3, 4:
            return "дня"
        default:
            return "дней"
        }
    }
}

public enum AskezaDuration: Codable, Equatable {
    case days(Int)
    case lifetime
    
    public var description: String {
        switch self {
        case .days(let count):
            return "\(count) дней"
        case .lifetime:
            return "Пожизненно (∞)"
        }
    }
    
    // Явная реализация протокола Hashable
    public func hash(into hasher: inout Hasher) {
        switch self {
        case .days(let count):
            hasher.combine(0) // 0 - тег для case days
            hasher.combine(count)
        case .lifetime:
            hasher.combine(1) // 1 - тег для case lifetime
        }
    }
}

public enum WishStatus: String, Codable {
    case waiting = "Ожидает исполнения"
    case fulfilled = "Исполнилось"
    case unfulfilled = "Не исполнилось"
}

public struct Askeza: Identifiable, Codable, Hashable {
    public let id: UUID
    public let title: String
    public var intention: String?
    public var startDate: Date
    public var duration: AskezaDuration
    public var progress: Int
    public var isCompleted: Bool
    public var category: AskezaCategory
    public var wish: String?
    public var wishStatus: WishStatus?
    public var templateID: UUID?
    public var isInCompletedList: Bool = false
    
    public init(id: UUID = UUID(),
                title: String,
                intention: String? = nil,
                startDate: Date = Date(),
                duration: AskezaDuration,
                progress: Int = 0,
                isCompleted: Bool = false,
                category: AskezaCategory = .custom,
                wish: String? = nil,
                wishStatus: WishStatus? = nil,
                templateID: UUID? = nil,
                isInCompletedList: Bool = false) {
        self.id = id
        self.title = title
        self.intention = intention
        self.startDate = startDate
        self.duration = duration
        self.progress = progress
        self.isCompleted = isCompleted
        self.category = category
        self.wish = wish
        self.wishStatus = wishStatus
        self.templateID = templateID
        self.isInCompletedList = isInCompletedList
        
        // Печатаем информацию о создании для отладки
        print("📝 Askeza - Создана: \(title), ID: \(id), templateID: \(templateID?.uuidString ?? "нет")")
    }
    
    // Явная реализация Hashable
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    public static func == (lhs: Askeza, rhs: Askeza) -> Bool {
        return lhs.id == rhs.id
    }
    
    // Создает строковое представление продолжительности
    public var durationString: String {
        switch duration {
        case .days(let days):
            return "\(days) \(days.daysString)"
        case .lifetime:
            return "Пожизненно"
        }
    }
    
    // Вычисляет количество дней практики
    public var daysPracticed: Int {
        let calendar = Calendar.current
        let startDateOnly = calendar.startOfDay(for: startDate)
        let currentDateOnly = calendar.startOfDay(for: Date())
        
        let components = calendar.dateComponents([.day], from: startDateOnly, to: currentDateOnly)
        return components.day ?? 0
    }
    
    // Вычисляет, является ли аскеза пожизненной
    public var isLifetime: Bool {
        if case .lifetime = duration {
            return true
        }
        return false
    }
    
    // Возвращает общее количество дней для аскезы с фиксированной продолжительностью
    public var totalDays: Int {
        switch duration {
        case .days(let days):
            return days
        case .lifetime:
            return 0 // 0 обозначает бессрочную практику
        }
    }
    
    public var daysLeft: Int? {
        switch duration {
        case .days(let total):
            return max(0, total - progress)
        case .lifetime:
            return nil
        }
    }
    
    public var progressPercentage: Double {
        switch duration {
        case .days(let total):
            return min(1.0, Double(progress) / Double(total))
        case .lifetime:
            return 0
        }
    }
}

public enum AskezaCategory: String, Codable, CaseIterable, Identifiable {
    case telo = "Тело"
    case um = "Ум"
    case dukh = "Дух"
    case otnosheniya = "Отношения"
    case osvobozhdenie = "Зависимости"
    case velikie = "Великие"
    case custom = "Своя"
    
    public var id: String { rawValue }
    
    public var systemImage: String {
        switch self {
        case .osvobozhdenie:
            return "wineglass"
        case .telo:
            return "figure.strengthtraining.traditional"
        case .um:
            return "brain"
        case .dukh:
            return "sparkles"
        case .otnosheniya:
            return "heart"
        case .velikie:
            return "crown"
        case .custom:
            return "star"
        }
    }
    
    var mainColor: Color {
        switch self {
        case .telo:            return Color("TeloColor")
        case .um:              return Color("UmColor")
        case .dukh:            return Color("DukhColor")
        case .otnosheniya:     return Color("OtnosheniyaColor")
        case .osvobozhdenie:   return Color("OsvobozhdenieColor")
        case .velikie:         return Color("VelikieColor")
        case .custom:          return Color("CustomColor")
        }
    }
    
    var accentColor: Color {
        // Временно упрощаем для отладки
        return mainColor.opacity(0.7)
    }
    
    var gradient: LinearGradient {
        // Временно заменяем градиент сплошным цветом для отладки
        LinearGradient(
            colors: [mainColor, mainColor],
            startPoint: .top,
            endPoint: .bottom
        )
    }
    
    public var color: Color {
        return mainColor
    }
} 