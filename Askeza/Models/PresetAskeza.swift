import SwiftUI

public struct PresetAskeza {
    public let title: String
    public let description: String
    public let intention: String
    public let category: AskezaCategory
    public let difficulty: Int? // Сложность от 1 до 5 звезд, опциональная
    public let duration: Int? // Продолжительность в днях, 0 для пожизненных, опциональная
    
    public init(title: String, description: String, intention: String, category: AskezaCategory, difficulty: Int? = nil, duration: Int? = nil) {
        self.title = title
        self.description = description
        self.intention = intention
        self.category = category
        self.difficulty = difficulty
        self.duration = duration
    }
} 