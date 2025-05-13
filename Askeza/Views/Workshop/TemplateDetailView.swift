import SwiftUI
import SwiftData
import MarkdownUI
// Импортируем общий файл с определением ShareSheet
// Этот импорт не нужен, если он определен в том же модуле
// import Common

// MARK: - View State
class TemplateDetailViewState: ObservableObject {
    @Published var showError = false
    @Published var errorMessage = ""
    @Published var showConfirmationDialog = false
}

struct TemplateDetailView: View {
    let template: PracticeTemplate
    @ObservedObject var templateStore: PracticeTemplateStore
    @StateObject private var state = TemplateDetailViewState()
    @Environment(\.dismiss) private var dismiss
    @State private var showingShareSheet = false
    @State private var shareText = ""
    @State private var isLoadingData = true
    @State private var progress: TemplateProgress?
    @State private var showingConfirmation = false
    @State private var errorMessage = ""
    @State private var showingError = false
    
    init(template: PracticeTemplate, templateStore: PracticeTemplateStore) {
        self.template = template
        self.templateStore = templateStore
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                AskezaTheme.backgroundColor
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Верхняя часть с заголовком и статусом
                        headerSection
                            .padding(.horizontal)
                        
                        // Блоки информации
                        infoBlocks
                            .padding(.horizontal)
                        
                        // Описание практики
                        if !template.description.isEmpty {
                            descriptionSection
                                .padding(.horizontal)
                        }
                        
                        // Намерение практики
                        if !template.intention.isEmpty {
                            intentionSection
                                .padding(.horizontal)
                        }
                        
                        // Инструкции доступны только после начала практики
                        if let progress = progress, progress.daysCompleted > 0 || progress.status(templateDuration: template.duration) == .completed {
                            instructionsSection
                                .padding(.horizontal)
                        }
                        
                        // Кнопка старта
                        startButton
                            .padding()
                    }
                    .padding(.vertical)
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
                        Text("Шаблон практики")
                            .font(.headline)
                            .foregroundColor(AskezaTheme.textColor)
                    }
                }
                .alert("Ошибка", isPresented: $showingError) {
                    Button("OK", role: .cancel) {}
                } message: {
                    Text(errorMessage)
                }
                .alert("Начать аскезу?", isPresented: $showingConfirmation) {
                    Button("Отмена", role: .cancel) {}
                    Button("Начать") {
                        startPractice()
                    }
                } message: {
                    Text("Вы действительно хотите начать практику '\(template.title)'?")
                }
                .sheet(isPresented: $showingShareSheet) {
                    ShareSheet(activityItems: [shareText])
                }
                .onAppear {
                    loadData()
                }
            }
        }
    }
    
    // MARK: - Секции интерфейса
    
    private var headerSection: some View {
        VStack(alignment: .center, spacing: 12) {
            // Категория
            HStack {
                Image(systemName: template.category.systemImage)
                    .foregroundColor(template.category.mainColor)
                
                Text(template.category.rawValue)
                    .font(.subheadline)
                    .foregroundColor(template.category.mainColor)
            }
            
            // Заголовок
            Text(template.title)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(AskezaTheme.textColor)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
            
            // Статус, если практика уже начата
            if let progress = progress {
                let status = progress.status(templateDuration: template.duration)
                
                HStack {
                    Image(systemName: status.icon)
                        .foregroundColor(status.color)
                    
                    Text(status.rawValue)
                        .font(.subheadline)
                        .foregroundColor(status.color)
                }
                
                // Прогресс бар для активных шаблонов
                if status == .inProgress {
                    let progressValue = template.duration > 0 
                        ? Double(progress.daysCompleted) / Double(template.duration)
                        : 0.05
                        
                    VStack(spacing: 4) {
                        GeometryReader { geometry in
                            ZStack(alignment: .leading) {
                                Rectangle()
                                    .fill(Color.gray.opacity(0.3))
                                    .frame(height: 8)
                                    .cornerRadius(4)
                                
                                Rectangle()
                                    .fill(status.color)
                                    .frame(width: geometry.size.width * min(1.0, progressValue), height: 8)
                                    .cornerRadius(4)
                            }
                        }
                        .frame(height: 8)
                        
                        HStack {
                            Text("День \(progress.daysCompleted)")
                                .font(.caption)
                                .foregroundColor(AskezaTheme.secondaryTextColor)
                            
                            Spacer()
                            
                            Text("\(template.duration > 0 ? "\(Int(progressValue * 100))%" : "∞")")
                                .font(.caption)
                                .foregroundColor(AskezaTheme.secondaryTextColor)
                        }
                    }
                    .padding(.top, 4)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(AskezaTheme.buttonBackground)
        .cornerRadius(16)
    }
    
    private var infoBlocks: some View {
        HStack(spacing: 12) {
            // Длительность
            VStack {
                Image(systemName: "calendar")
                    .font(.system(size: 20))
                    .foregroundColor(AskezaTheme.accentColor)
                
                Text("Длительность")
                    .font(.caption)
                    .foregroundColor(AskezaTheme.secondaryTextColor)
                
                Text(durationText(template.duration))
                    .font(.headline)
                    .foregroundColor(AskezaTheme.textColor)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(AskezaTheme.buttonBackground)
            .cornerRadius(12)
            
            // Сложность
            VStack {
                Image(systemName: "chart.bar")
                    .font(.system(size: 20))
                    .foregroundColor(AskezaTheme.accentColor)
                
                Text("Сложность")
                    .font(.caption)
                    .foregroundColor(AskezaTheme.secondaryTextColor)
                
                HStack(spacing: 2) {
                    ForEach(1...5, id: \.self) { i in
                        Image(systemName: i <= template.difficulty ? "star.fill" : "star")
                            .font(.system(size: 10))
                            .foregroundColor(i <= template.difficulty ? .yellow : Color.gray.opacity(0.3))
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(AskezaTheme.buttonBackground)
            .cornerRadius(12)
        }
    }
    
    private var descriptionSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Описание")
                .font(.headline)
                .foregroundColor(AskezaTheme.textColor)
            
            Text(template.description)
                .font(.body)
                .foregroundColor(AskezaTheme.secondaryTextColor)
                .fixedSize(horizontal: false, vertical: true)
            
            if !template.quote.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("\"\(template.quote)\"")
                        .font(.system(.body, design: .serif))
                        .italic()
                        .foregroundColor(AskezaTheme.intentColor)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.vertical, 8)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(template.category.mainColor.opacity(0.1))
                .cornerRadius(8)
            }
        }
        .padding()
        .background(AskezaTheme.buttonBackground)
        .cornerRadius(16)
    }
    
    private var intentionSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Намерение")
                .font(.headline)
                .foregroundColor(AskezaTheme.textColor)
            
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: "sparkles")
                    .font(.system(size: 20))
                    .foregroundColor(AskezaTheme.intentColor)
                    .frame(width: 24, height: 24)
                
                Text(template.intention)
                    .font(.body)
                    .foregroundColor(AskezaTheme.intentColor)
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(AskezaTheme.intentBackgroundColor)
            .cornerRadius(12)
        }
        .padding()
        .background(AskezaTheme.buttonBackground)
        .cornerRadius(16)
    }
    
    private var instructionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Инструкции")
                .font(.headline)
                .foregroundColor(AskezaTheme.textColor)
            
            if let instructions = templateStore.getInstructions(for: template.templateId) {
                ScrollView {
                    Markdown(instructions)
                        .markdownTheme(.custom)
                        .padding(.horizontal, 8)
                }
                .frame(maxWidth: .infinity)
            } else {
                Text("Инструкции временно недоступны")
                    .font(.body)
                    .foregroundColor(AskezaTheme.secondaryTextColor)
                    .padding()
            }
        }
        .padding()
        .background(AskezaTheme.buttonBackground)
        .cornerRadius(16)
    }
    
    private var startButton: some View {
        Button(action: {
            showingConfirmation = true
        }) {
            HStack {
                Image(systemName: "play.fill")
                Text(startButtonText)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(AskezaTheme.accentColor)
            .foregroundColor(.white)
            .cornerRadius(12)
            .font(.headline)
        }
    }
    
    // MARK: - Вспомогательные методы
    
    private func loadData() {
        isLoadingData = true
        
        // Загружаем прогресс шаблона
        progress = templateStore.getProgress(forTemplateID: template.id)
        
        // Если не найден по ID, пробуем по templateId
        if progress == nil {
            progress = templateStore.getProgress(forTemplateID: template.templateId)
        }
        
        isLoadingData = false
    }
    
    private func startPractice() {
        Task {
            if let askeza = templateStore.startTemplate(template) {
                // Отправляем уведомление в основном потоке для обновления UI
                DispatchQueue.main.async {
                    // Обновляем локальный прогресс
                    loadData()
                    
                    // Отправляем уведомление для обновления других компонентов
                    NotificationCenter.default.post(
                        name: .refreshWorkshopData,
                        object: askeza
                    )
                    
                    // Закрываем экран
                    dismiss()
                }
            } else {
                // Показываем ошибку
                DispatchQueue.main.async {
                    errorMessage = "Этот шаблон уже активен. Завершите текущую аскезу, прежде чем начать заново."
                    showingError = true
                }
            }
        }
    }
    
    private var startButtonText: String {
        if progress == nil {
            return "Начать практику"
        }
        
        let status = progress!.status(templateDuration: template.duration)
        switch status {
        case .notStarted: return "Начать"
        case .inProgress: return "Продолжить"
        case .completed: return "Повторить"
        case .mastered: return "Начать снова"
        }
    }
    
    private func durationText(_ days: Int) -> String {
        if days == 0 {
            return "Пожизненно"
        } else {
            return "\(days) дней"
        }
    }
}

// Расширение для создания пользовательской темы Markdown
extension MarkdownTheme {
    static let custom = MarkdownTheme(
        font: .system(size: 16),
        textColor: AskezaTheme.textColor,
        linkColor: AskezaTheme.accentColor,
        codeColor: AskezaTheme.accentColor,
        backgroundColor: AskezaTheme.backgroundColor,
        headingStyles: [
            .init(
                font: .system(.title, design: .default, weight: .bold),
                color: AskezaTheme.textColor
            ),
            .init(
                font: .system(.title2, design: .default, weight: .bold),
                color: AskezaTheme.textColor
            ),
            .init(
                font: .system(.title3, design: .default, weight: .bold),
                color: AskezaTheme.textColor
            )
        ],
        quoteStyle: .init(
            font: .system(.body, design: .serif, weight: .regular),
            color: AskezaTheme.intentColor,
            backgroundColor: AskezaTheme.intentBackgroundColor.opacity(0.5)
        ),
        codeBlockStyle: .init(
            font: .system(.body, design: .monospaced),
            color: AskezaTheme.textColor,
            backgroundColor: Color.gray.opacity(0.2)
        )
    )
}

#Preview {
    let template = PracticeTemplate(
        id: UUID(),
        templateId: "meditation-7",
        title: "7 дней медитации",
        category: .vnimaniye,
        duration: 7,
        quote: "Медитация – это не бегство от реальности, а встреча с ней.",
        difficulty: 2,
        description: "Ежедневная практика медитации для развития осознанности и снижения стресса.",
        intention: "Стать более спокойным и сосредоточенным"
    )
    
    return TemplateDetailView(template: template, templateStore: PracticeTemplateStore.shared)
} 