import SwiftUI

public struct PresetAskeza {
    public let title: String
    public let description: String
    public let intention: String
    public let category: AskezaCategory
    
    public init(title: String, description: String, intention: String, category: AskezaCategory) {
        self.title = title
        self.description = description
        self.intention = intention
        self.category = category
    }
} 