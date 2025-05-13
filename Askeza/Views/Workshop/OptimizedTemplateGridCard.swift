import SwiftUI

/// Оптимизированная версия карточки шаблона для сетки шаблонов
struct OptimizedTemplateGridCard: View {
    let template: PracticeTemplate
    let progress: TemplateProgress?
    let onTap: () -> Void
    
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
        Button(action: onTap) {
            VStack(spacing: 0) {
                // Верхняя часть с фоном категории
                ZStack {
                    // Градиент фон
                    Rectangle()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(
                                    colors: [
                                        template.category.mainColor.opacity(0.7),
                                        template.category.mainColor.opacity(0.3)
                                    ]
                                ),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                    
                    // Большая иконка категории с круговым прогресс-баром
                    ZStack {
                        // Серый фоновый круг для прогресс-бара и прогресс-бар
                        if status == .inProgress {
                            Circle()
                                .stroke(Color.white.opacity(0.3), lineWidth: 6)
                                .frame(width: 120, height: 120)
                                .padding(10)
                            
                            // Сам прогресс-бар
                            Circle()
                                .trim(from: 0, to: progressPercentage)
                                .stroke(status.color, lineWidth: 6)
                                .frame(width: 120, height: 120)
                                .rotationEffect(.degrees(-90))
                                .padding(10)
                        } else if status == .completed || status == .mastered {
                            // Для завершенных шаблонов
                            Circle()
                                .stroke(status.color.opacity(0.6), lineWidth: 6)
                                .frame(width: 120, height: 120)
                                .padding(10)
                        } else if status == .notStarted {
                            // Для неначатых шаблонов - серый круг
                            Circle()
                                .stroke(Color.gray.opacity(0.3), lineWidth: 4)
                                .frame(width: 120, height: 120)
                                .padding(10)
                        }
                        
                        // Иконка категории
                        ZStack {
                            // Фон иконки
                            Circle()
                                .fill(Color.white.opacity(0.3))
                                .frame(width: 100, height: 100)
                            
                            // Иконка категории полупрозрачная
                            Image(systemName: template.category.systemImage)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 70, height: 70)
                                .foregroundColor(template.category.mainColor)
                                .opacity(0.7)
                        }
                    }
                    .padding(.top, 25)
                    .padding(.bottom, 30)
                    
                    // Если шаблон завершен или мастер, добавляем иконку завершения сверху между севером и востоком (1:30)
                    if status == .completed || status == .mastered {
                        Image(systemName: status.icon)
                            .font(.system(size: 20))
                            .foregroundColor(.white)
                            .padding(4)
                            .background(status.color)
                            .clipShape(Circle())
                            .offset(x: 45, y: -45)  // Позиция на 1:30 с значением 45
                            .zIndex(10) // Поверх всех элементов
                    }
                    
                    // Информация поверх
                    VStack(spacing: 0) {
                        // Верхняя строка: процент и звезды/статус
                        HStack {
                            // Процент выполнения в левом углу или количество дней
                            if status == .inProgress {
                                Text("\(Int(progressPercentage * 100))%")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(Color.black.opacity(0.4))
                                    .cornerRadius(4)
                            } else {
                                Text(template.duration == 0 ? "∞" : "\(template.duration) дн.")
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(Color.black.opacity(0.4))
                                    .cornerRadius(4)
                            }
                            
                            Spacer()
                            
                            // Статус вместо звездочек
                            if status != .notStarted {
                                HStack(spacing: 2) {
                                    Image(systemName: status.icon)
                                        .font(.system(size: 8))
                                        .foregroundColor(.white)
                                    
                                    Text(status == .inProgress ? "Активная" : status.rawValue)
                                        .font(.system(size: 8))
                                        .foregroundColor(.white)
                                }
                                .padding(.horizontal, 4)
                                .padding(.vertical, 2)
                                .background(status.color.opacity(0.7))
                                .cornerRadius(4)
                            } else {
                                // Звезды сложности на темном фоне
                                HStack(spacing: 1) {
                                    ForEach(1...5, id: \.self) { i in
                                        Image(systemName: i <= template.difficulty ? "star.fill" : "star")
                                            .font(.system(size: 8))
                                            .foregroundColor(i <= template.difficulty ? .yellow : Color.gray.opacity(0.2))
                                    }
                                }
                                .padding(.horizontal, 4)
                                .padding(.vertical, 2)
                                .background(Color.black.opacity(0.4))
                                .cornerRadius(4)
                            }
                        }
                        .padding(6)
                        
                        Spacer()
                        
                        // Прогресс бар для активных шаблонов
                        if status == .inProgress {
                            VStack(spacing: 0) {
                                if let progress = progress {
                                    HStack {
                                        Text("День: \(progress.daysCompleted)")
                                            .font(.system(size: 12, weight: .medium))
                                            .foregroundColor(.white)
                                        
                                        Spacer()
                                        
                                        if progress.currentStreak > 0 {
                                            HStack(spacing: 2) {
                                                Text("\(progress.currentStreak)")
                                                    .font(.system(size: 12, weight: .medium))
                                                    .foregroundColor(.orange)
                                                
                                                Image(systemName: "flame.fill")
                                                    .font(.system(size: 12))
                                                    .foregroundColor(.orange)
                                            }
                                        }
                                    }
                                    .padding(.vertical, 8)
                                    .padding(.horizontal, 10)
                                }
                            }
                            .background(Color.black.opacity(0.4))
                        }
                        // Статус внизу для завершенных и мастеров
                        else if status != .notStarted {
                            HStack {
                                Text(statusText(for: status))
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(.white)
                                
                                Spacer()
                            }
                            .padding(.vertical, 8)
                            .padding(.horizontal, 10)
                            .background(Color.black.opacity(0.4))
                        }
                    }
                }
                .frame(height: 200)
                
                // Нижняя часть с заголовком
                Text(template.title)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(AskezaTheme.textColor)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(8)
                    .frame(height: 45)
                    .background(AskezaTheme.buttonBackground)
                
                // Добавляем отображение количества завершений
                if let progress = progress, progress.timesCompleted > 0 {
                    HStack {
                        Text("Пройдено: \(progress.timesCompleted) раз")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.white)
                            .padding(.vertical, 4)
                            .padding(.horizontal, 8)
                            .background(Color.purple.opacity(0.7))
                            .cornerRadius(10)
                    }
                    .padding(.vertical, 4)
                    .padding(.horizontal, 8)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .background(AskezaTheme.buttonBackground)
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(statusBorderColor, lineWidth: statusBorderWidth)
            )
            .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    // Вспомогательные методы
    
    private func statusText(for status: TemplateStatus) -> String {
        switch status {
        case .notStarted: return "Не начато"
        case .inProgress: return "Активная"
        case .completed: return "Завершено"
        case .mastered: return "Мастер"
        }
    }
    
    private var statusBorderColor: Color {
        switch status {
        case .notStarted: return Color.clear
        case .inProgress: return status.color.opacity(0.5)
        case .completed: return status.color
        case .mastered: return Color.purple
        }
    }
    
    private var statusBorderWidth: CGFloat {
        switch status {
        case .notStarted: return 0
        case .inProgress: return 1
        case .completed, .mastered: return 2
        }
    }
}

#Preview {
    let template = PracticeTemplate(
        templateId: "cold-shower-14",
        title: "14-дневный челлендж холодного душа",
        category: .telo, 
        duration: 14,
        quote: "Цитата",
        difficulty: 3,
        description: "Описание",
        intention: "Цель"
    )
    
    let progress = TemplateProgress(
        templateID: template.id,
        dateStarted: Date(),
        daysCompleted: 6,
        timesCompleted: 0,
        currentStreak: 6,
        bestStreak: 6
    )
    
    return VStack(spacing: 20) {
        OptimizedTemplateGridCard(
            template: template,
            progress: progress,
            onTap: {}
        )
        .frame(width: 160)
        
        OptimizedTemplateGridCard(
            template: template, 
            progress: nil,
            onTap: {}
        )
        .frame(width: 160)
    }
    .padding()
    .background(Color.gray.opacity(0.1))
} 