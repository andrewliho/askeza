import SwiftUI

public struct DetailSection: View {
    let title: String
    let content: String
    
    public init(title: String, content: String) {
        self.title = title
        self.content = content
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(AskezaTheme.bodyFont)
                .foregroundColor(AskezaTheme.secondaryTextColor)
            
            Text(content)
                .font(AskezaTheme.bodyFont)
                .foregroundColor(AskezaTheme.textColor)
        }
    }
} 