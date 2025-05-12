import SwiftUI
import SwiftData

struct TemplateDetailView: View {
    let template: PracticeTemplate
    let templateStore: PracticeTemplateStore
    
    @Environment(\.dismiss) private var dismiss
    @State private var showingShareSheet = false
    @State private var shareText: String = ""
    
    var body: some View {
        NavigationView {
            ZStack {
                AskezaTheme.backgroundColor
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        // Заголовок и категория
                        headerSection
                        
                        // Цитата
                        quoteSection
                        
                        // Детали
                        detailsSection
                        
                        // Прогресс, если есть
                        if let progress = templateStore.getProgress(forTemplateID: template.id) {
                            progressSection(progress)
                        }
                        
                        // Отзывы (скрыто в текущем релизе)
                        // reviewsSection
                        
                        // Кнопки действий
                        actionButtons
                    }
                    .padding(.bottom, 50)
                }
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("Закрыть") {
                            dismiss()
                        }
                        .foregroundColor(AskezaTheme.accentColor)
                    }
                    
                    ToolbarItem(placement: .principal) {
                        VStack {
                            Text("Мастерская")
                                .font(.headline)
                                .foregroundColor(AskezaTheme.textColor)
                            
                            Text(template.category.rawValue)
                                .font(.caption)
                                .foregroundColor(AskezaTheme.secondaryTextColor)
                        }
                    }
                }
                .sheet(isPresented: $showingShareSheet) {
                    ShareSheet(activityItems: [shareText])
                }
            }
        }
    }
    
    // MARK: - Sections
    
    private var headerSection: some View {
        VStack(alignment: .center, spacing: 16) {
            // Статус и прогресс
            let status = templateStore.getStatus(forTemplateID: template.id)
            
            if status != .notStarted {
                ZStack {
                    Circle()
                        .stroke(status.color.opacity(0.2), lineWidth: 8)
                        .frame(width: 120, height: 120)
                    
                    if status == .inProgress, let progress = templateStore.getProgress(forTemplateID: template.id) {
                        Circle()
                            .trim(from: 0, to: CGFloat(min(1.0, Double(progress.daysCompleted) / Double(template.duration))))
                            .stroke(status.color, lineWidth: 8)
                            .frame(width: 120, height: 120)
                            .rotationEffect(.degrees(-90))
                    }
                    
                    Image(systemName: status.icon)
                        .font(.system(size: 40))
                        .foregroundColor(status.color)
                }
                .padding(.bottom, 8)
            }
            
            // Заголовок
            Text(template.title)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(AskezaTheme.textColor)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            // Иконка категории
            HStack {
                Image(systemName: template.category.systemImage)
                    .foregroundColor(template.category.mainColor)
                
                Text(template.category.rawValue)
                    .foregroundColor(AskezaTheme.secondaryTextColor)
            }
            
            // Сложность
            difficultyView(level: template.difficulty)
                .padding(.top, 8)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(AskezaTheme.buttonBackground)
        .cornerRadius(16)
        .padding(.horizontal)
    }
    
    private var quoteSection: some View {
        Text("\"\(template.quote)\"")
            .font(.system(size: 18, weight: .light, design: .serif))
            .italic()
            .foregroundColor(AskezaTheme.intentColor)
            .multilineTextAlignment(.center)
            .padding(.horizontal, 40)
            .padding(.vertical, 20)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(AskezaTheme.buttonBackground.opacity(0.5))
            )
            .padding(.horizontal)
    }
    
    private var detailsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            detailRow(title: "Длительность:", value: durationText(template.duration))
            detailRow(title: "Сложность:", value: difficultyText(template.difficulty))
            
            Text("Описание")
                .font(.headline)
                .foregroundColor(AskezaTheme.textColor)
            
            Text(template.description)
                .foregroundColor(AskezaTheme.secondaryTextColor)
                .fixedSize(horizontal: false, vertical: true)
            
            Text("Цель")
                .font(.headline)
                .foregroundColor(AskezaTheme.textColor)
            
            Text(template.intention)
                .foregroundColor(AskezaTheme.secondaryTextColor)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding()
        .background(AskezaTheme.buttonBackground)
        .cornerRadius(16)
        .padding(.horizontal)
    }
    
    private func progressSection(_ progress: TemplateProgress) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Ваш прогресс")
                .font(.headline)
                .foregroundColor(AskezaTheme.textColor)
            
            ProgressCardView(
                progress: progress,
                templateDuration: template.duration
            )
        }
        .padding()
        .background(AskezaTheme.buttonBackground)
        .cornerRadius(16)
        .padding(.horizontal)
    }
    
    private var actionButtons: some View {
        HStack {
            Button(action: {
                let askeza = templateStore.startTemplate(template)
                // TODO: Добавить аскезу в основную модель
                // viewModel.addAskeza(askeza)
                dismiss()
            }) {
                Text(startButtonText)
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(AskezaTheme.accentColor)
                    .cornerRadius(12)
            }
            
            Button(action: shareTemplate) {
                Image(systemName: "square.and.arrow.up")
                    .font(.headline)
                    .foregroundColor(AskezaTheme.accentColor)
                    .padding()
                    .background(AskezaTheme.buttonBackground)
                    .cornerRadius(12)
            }
        }
        .padding(.horizontal)
    }
    
    // MARK: - Helper Views
    
    private func detailRow(title: String, value: String) -> some View {
        HStack {
            Text(title)
                .font(.subheadline)
                .foregroundColor(AskezaTheme.textColor)
            
            Spacer()
            
            Text(value)
                .font(.subheadline)
                .foregroundColor(AskezaTheme.secondaryTextColor)
        }
    }
    
    private func difficultyView(level: Int) -> some View {
        HStack(spacing: 4) {
            ForEach(1...3, id: \.self) { i in
                Circle()
                    .fill(i <= level ? difficultyColor(level: level) : Color.gray.opacity(0.3))
                    .frame(width: 12, height: 12)
            }
        }
        .overlay(
            Text(difficultyText(level))
                .font(.caption)
                .foregroundColor(AskezaTheme.secondaryTextColor)
                .padding(.leading, 50)
        )
    }
    
    // MARK: - Helper Methods
    
    private var startButtonText: String {
        let status = templateStore.getStatus(forTemplateID: template.id)
        switch status {
        case .notStarted:
            return "Начать практику"
        case .inProgress:
            return "Продолжить"
        case .completed:
            return "Начать заново"
        case .mastered:
            return "Начать снова"
        }
    }
    
    private func shareTemplate() {
        shareText = """
        🧘‍♂️ Аскеза: \(template.title)
        📝 Категория: \(template.category.rawValue)
        ⏳ Длительность: \(durationText(template.duration))
        ✨ Цитата: "\(template.quote)"
        
        #Askeza #\(template.category.rawValue) #СамоРазвитие
        """
        
        showingShareSheet = true
    }
    
    private func difficultyText(_ level: Int) -> String {
        switch level {
        case 1:
            return "Легкий"
        case 2:
            return "Средний"
        case 3:
            return "Сложный"
        default:
            return "Неизвестно"
        }
    }
    
    private func durationText(_ days: Int) -> String {
        if days == 0 {
            return "Пожизненно"
        } else {
            return "\(days) дней"
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

struct ProgressCardView: View {
    let progress: TemplateProgress
    let templateDuration: Int
    
    var status: TemplateStatus {
        progress.status(templateDuration: templateDuration)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: status.icon)
                    .foregroundColor(status.color)
                
                Text("Статус: \(status.rawValue)")
                    .foregroundColor(AskezaTheme.secondaryTextColor)
                
                Spacer()
                
                if status == .inProgress {
                    Text("\(Int(progressPercentage * 100))%")
                        .fontWeight(.medium)
                        .foregroundColor(status.color)
                }
            }
            
            if status == .inProgress {
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(height: 8)
                            .cornerRadius(4)
                        
                        Rectangle()
                            .fill(status.color)
                            .frame(width: geometry.size.width * progressPercentage, height: 8)
                            .cornerRadius(4)
                    }
                }
                .frame(height: 8)
                .padding(.vertical, 4)
            }
            
            Text("Дней завершено: \(progress.daysCompleted)\(templateDuration > 0 ? " из \(templateDuration)" : "")")
                .foregroundColor(AskezaTheme.secondaryTextColor)
            
            if progress.currentStreak > 0 {
                HStack {
                    Text("Текущая серия:")
                        .foregroundColor(AskezaTheme.secondaryTextColor)
                    
                    Text("\(progress.currentStreak) дней")
                        .foregroundColor(.orange)
                    
                    Image(systemName: "flame.fill")
                        .foregroundColor(.orange)
                }
            }
            
            if progress.bestStreak > 0 {
                Text("Лучшая серия: \(progress.bestStreak) дней")
                    .foregroundColor(AskezaTheme.secondaryTextColor)
            }
            
            if progress.timesCompleted > 0 {
                Text("Завершено раз: \(progress.timesCompleted)")
                    .foregroundColor(AskezaTheme.secondaryTextColor)
            }
        }
    }
    
    private var progressPercentage: Double {
        if templateDuration <= 0 {
            return progress.daysCompleted > 0 ? 1.0 : 0.0
        }
        return min(1.0, Double(progress.daysCompleted) / Double(templateDuration))
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(
            activityItems: activityItems,
            applicationActivities: nil
        )
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {
        // Nothing to do here
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
    
    return TemplateDetailView(
        template: template,
        templateStore: PracticeTemplateStore.shared
    )
} 