import SwiftUI

struct TemplateCardView: View {
    let template: PracticeTemplate
    let progress: TemplateProgress?
    var onStart: () -> Void
    var onShare: () -> Void
    
    @ObservedObject private var templateStore = PracticeTemplateStore.shared
    
    private var status: TemplateStatus {
        if let progress = progress {
            return progress.status(templateDuration: template.duration)
        }
        return .notStarted
    }
    
    private var progressPercentage: Double {
        guard let progress = progress, template.duration > 0 else {
            return 0
        }
        return min(1.0, Double(progress.daysCompleted) / Double(template.duration))
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Заголовок с иконкой статуса
            HStack {
                Image(systemName: status.icon)
                    .foregroundColor(status.color)
                
                Text(template.title)
                    .font(.headline)
                    .foregroundColor(AskezaTheme.textColor)
            }
            
            // Категория и сложность
            HStack {
                Image(systemName: template.category.systemImage)
                    .foregroundColor(template.category.mainColor)
                
                Text(template.category.rawValue)
                    .font(.subheadline)
                    .foregroundColor(AskezaTheme.secondaryTextColor)
                
                Spacer()
                
                Text("Сложность: ")
                    .font(.caption)
                    .foregroundColor(AskezaTheme.secondaryTextColor)
                
                difficultyView(level: template.difficulty)
            }
            
            // Цитата
            Text("\"\(template.quote)\"")
                .font(.system(size: 14, weight: .light, design: .serif))
                .italic()
                .foregroundColor(AskezaTheme.intentColor)
                .padding(.vertical, 4)
            
            // Прогресс (если есть)
            if let progress = progress, status == .inProgress {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Прогресс: \(Int(progressPercentage * 100))%")
                        .font(.caption)
                        .foregroundColor(AskezaTheme.secondaryTextColor)
                    
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.gray.opacity(0.3))
                                .frame(height: 8)
                            
                            RoundedRectangle(cornerRadius: 4)
                                .fill(status.color)
                                .frame(width: geometry.size.width * progressPercentage, height: 8)
                        }
                    }
                    .frame(height: 8)
                    
                    if progress.currentStreak > 0 {
                        HStack {
                            Text("Серия: \(progress.currentStreak) дн.")
                                .font(.caption)
                                .foregroundColor(AskezaTheme.secondaryTextColor)
                            
                            Image(systemName: "flame.fill")
                                .foregroundColor(.orange)
                                .font(.caption)
                        }
                    }
                }
                .padding(.vertical, 4)
            }
            
            // Кнопки действий
            HStack {
                Button(action: onStart) {
                    Text(buttonTitle)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(AskezaTheme.accentColor)
                        .cornerRadius(8)
                }
                
                Spacer()
                
                Button(action: onShare) {
                    HStack {
                        Image(systemName: "square.and.arrow.up")
                        Text("Поделиться")
                    }
                    .font(.subheadline)
                    .foregroundColor(AskezaTheme.accentColor)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(AskezaTheme.buttonBackground)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(borderColor, lineWidth: borderWidth)
        )
    }
    
    // MARK: - Helper Views
    
    private func difficultyView(level: Int) -> some View {
        HStack(spacing: 2) {
            ForEach(1...3, id: \.self) { i in
                Circle()
                    .fill(i <= level ? difficultyColor(level: level) : Color.gray.opacity(0.3))
                    .frame(width: 8, height: 8)
            }
        }
    }
    
    // MARK: - Helper Properties
    
    private var buttonTitle: String {
        switch status {
        case .notStarted:
            return "Начать"
        case .inProgress:
            return "Продолжить"
        case .completed:
            return "Повторить"
        case .mastered:
            return "Начать снова"
        }
    }
    
    private var borderColor: Color {
        switch status {
        case .notStarted:
            return Color.clear
        case .inProgress:
            return status.color.opacity(0.3)
        case .completed:
            return status.color
        case .mastered:
            return Color.purple
        }
    }
    
    private var borderWidth: CGFloat {
        switch status {
        case .notStarted:
            return 0
        case .inProgress:
            return 1
        case .completed, .mastered:
            return 2
        }
    }
    
    private func difficultyColor(level: Int) -> Color {
        switch level {
        case 1:
            return .green
        case 2:
            return .yellow
        case 3:
            return .red
        default:
            return .gray
        }
    }
}

#Preview {
    let template = PracticeTemplate(
        templateId: "cold-shower-14",
        title: "14-дневный челлендж холодного душа",
        category: .telo,
        duration: 14,
        quote: "Дисциплина — мать свободы.",
        difficulty: 2,
        description: "Победа над комфортом каждое утро. Начните с 30 секунд и постепенно увеличивайте время.",
        intention: "Укрепить силу воли и иммунитет"
    )
    
    let progress = TemplateProgress(
        templateID: template.id,
        dateStarted: Date(),
        daysCompleted: 6,
        timesCompleted: 0,
        currentStreak: 6,
        bestStreak: 6
    )
    
    return VStack {
        TemplateCardView(
            template: template,
            progress: progress,
            onStart: {},
            onShare: {}
        )
        .padding()
        
        TemplateCardView(
            template: template,
            progress: nil,
            onStart: {},
            onShare: {}
        )
        .padding()
    }
    .background(AskezaTheme.backgroundColor)
} 