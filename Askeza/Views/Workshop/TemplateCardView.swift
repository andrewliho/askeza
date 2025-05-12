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
        VStack(alignment: .leading, spacing: 4) {
            // Верхняя строка: количество дней и статус
            HStack(alignment: .top) {
                // Бейдж с количеством дней - делаем меньше
                Text(template.duration == 0 ? "∞" : "\(template.duration) дн.")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.white)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(template.category.mainColor)
                    )
                
                Spacer()
                
                // Статус - более компактный
                if status != .notStarted {
                    HStack(spacing: 2) {
                        Image(systemName: status.icon)
                            .font(.system(size: 11))
                            .foregroundColor(status.color)
                        
                        Text(statusText(for: status))
                            .font(.system(size: 11))
                            .foregroundColor(status.color)
                    }
                }
            }
            
            // Заголовок - на одну строку
            Text(template.title)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(AskezaTheme.textColor)
                .lineLimit(1)
                .padding(.vertical, 2)
            
            // Категория и сложность в одной строке
            HStack {
                // Категория
                HStack(spacing: 3) {
                    Image(systemName: template.category.systemImage)
                        .font(.system(size: 11))
                        .foregroundColor(template.category.mainColor)
                    
                    Text(template.category.rawValue)
                        .font(.system(size: 11))
                        .foregroundColor(AskezaTheme.secondaryTextColor)
                }
                
                Spacer()
                
                // Только звезды без подписи (чтобы сэкономить место)
                HStack(spacing: 0) {
                    ForEach(1...5, id: \.self) { i in
                        Image(systemName: i <= template.difficulty ? "star.fill" : "star")
                            .font(.system(size: 8))
                            .foregroundColor(i <= template.difficulty ? .yellow : Color.gray.opacity(0.3))
                    }
                }
            }
            .padding(.vertical, 1) // Минимальный вертикальный отступ
            
            // Цитата - уменьшаем высоту и отступы
            Text("\"\(template.quote)\"")
                .font(.system(size: 10, weight: .light, design: .serif))
                .italic()
                .foregroundColor(AskezaTheme.intentColor)
                .lineLimit(1)
                .padding(.vertical, 0) // Убираем вертикальный отступ
            
            // Прогресс (если есть)
            if let progress = progress, status == .inProgress {
                VStack(alignment: .leading, spacing: 1) {
                    Text("Прогресс: \(Int(progressPercentage * 100))%")
                        .font(.system(size: 10))
                        .foregroundColor(AskezaTheme.secondaryTextColor)
                    
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 2)
                                .fill(Color.gray.opacity(0.3))
                                .frame(height: 4)
                            
                            RoundedRectangle(cornerRadius: 2)
                                .fill(status.color)
                                .frame(width: geometry.size.width * progressPercentage, height: 4)
                        }
                    }
                    .frame(height: 4)
                    
                    if progress.currentStreak > 0 {
                        HStack {
                            Text("Серия: \(progress.currentStreak) дн.")
                                .font(.system(size: 10))
                                .foregroundColor(AskezaTheme.secondaryTextColor)
                            
                            Image(systemName: "flame.fill")
                                .foregroundColor(.orange)
                                .font(.system(size: 10))
                        }
                    }
                }
                .padding(.vertical, 1)
            }
            
            // Кнопки действий
            HStack {
                Button(action: onStart) {
                    Text(buttonTitle)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(AskezaTheme.accentColor)
                        .cornerRadius(6)
                }
                .buttonStyle(PlainButtonStyle())
                
                Spacer()
                
                Button(action: onShare) {
                    HStack(spacing: 2) {
                        Image(systemName: "square.and.arrow.up")
                            .font(.system(size: 11))
                        Text("Поделиться")
                            .font(.system(size: 11))
                    }
                    .foregroundColor(AskezaTheme.accentColor)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(AskezaTheme.buttonBackground)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(borderColor, lineWidth: borderWidth)
        )
    }
    
    // MARK: - Helper Views
    
    // Более краткий текст статуса
    private func statusText(for status: TemplateStatus) -> String {
        switch status {
        case .notStarted:
            return "Не начато"
        case .inProgress:
            return "Активная"
        case .completed:
            return "Завершено" 
        case .mastered:
            return "Мастер"
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
        case 1, 2:
            return .green
        case 3, 4:
            return .yellow
        case 5:
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