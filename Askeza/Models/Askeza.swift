import Foundation
import SwiftUI

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
}

public enum WishStatus: String, Codable {
    case waiting = "Ожидает исполнения"
    case fulfilled = "Исполнилось"
    case unfulfilled = "Не исполнилось"
}

public struct Askeza: Identifiable, Codable {
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
    
    public init(id: UUID = UUID(),
         title: String,
         intention: String? = nil,
         startDate: Date = Date(),
         duration: AskezaDuration,
         progress: Int = 0,
         isCompleted: Bool = false,
         category: AskezaCategory = .custom,
         wish: String? = nil,
         wishStatus: WishStatus? = nil) {
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