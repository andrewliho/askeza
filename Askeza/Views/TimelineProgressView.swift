import SwiftUI

public struct TimelineProgressView: View {
    public let progress: Int
    public let duration: Int?
    public let startDate: Date
    @State private var currentDate = Date()
    
    private struct TimeUnit {
        let value: Int
        let label: String
        let color: Color
        let progress: Double
    }
    
    public init(progress: Int, duration: Int?, startDate: Date) {
        self.progress = progress
        self.duration = duration
        self.startDate = startDate
    }
    
    private func getLabel(value: Int, unit: String) -> String {
        switch unit {
        case "год":
            switch value {
            case 1: return "год"
            case 2...4: return "года"
            default: return "лет"
            }
        case "месяц":
            switch value {
            case 1: return "месяц"
            case 2...4: return "месяца"
            default: return "месяцев"
            }
        case "день":
            switch value {
            case 1: return "день"
            case 2...4: return "дня"
            default: return "дней"
            }
        case "час":
            switch value {
            case 1: return "час"
            case 2...4: return "часа"
            default: return "часов"
            }
        case "минута":
            switch value {
            case 1: return "минута"
            case 2...4: return "минуты"
            default: return "минут"
            }
        case "секунда":
            switch value {
            case 1: return "секунда"
            case 2...4: return "секунды"
            default: return "секунд"
            }
        default:
            return unit
        }
    }
    
    public var body: some View {
        VStack(spacing: 16) {
            // Progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(AskezaTheme.accentColor.opacity(0.2))
                        .cornerRadius(6)
                    
                    if let duration = duration {
                        Rectangle()
                            .fill(AskezaTheme.accentColor)
                            .frame(width: geometry.size.width * CGFloat(progress) / CGFloat(duration))
                            .cornerRadius(6)
                    }
                }
            }
            .frame(height: 12)
            
            // Progress text
            HStack {
                Text("\(progress)")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(AskezaTheme.textColor)
                
                if let duration = duration {
                    Text("/")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(AskezaTheme.secondaryTextColor)
                    
                    Text("\(duration)")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(AskezaTheme.secondaryTextColor)
                } else {
                    Text("∞")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(AskezaTheme.secondaryTextColor)
                }
            }
        }
        .padding()
    }
}

#Preview {
    TimelineProgressView(progress: 5, duration: 30, startDate: Date())
} 