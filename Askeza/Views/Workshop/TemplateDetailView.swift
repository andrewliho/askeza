import SwiftUI
import SwiftData
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
    @State private var isDataLoaded = false
    @State private var mutableTemplate: PracticeTemplate
    
    init(template: PracticeTemplate, templateStore: PracticeTemplateStore) {
        self.template = template
        self.templateStore = templateStore
        // Инициализируем mutableTemplate копией переданного шаблона
        _mutableTemplate = State(initialValue: template)
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                AskezaTheme.backgroundColor
                    .ignoresSafeArea()
                
                if isDataLoaded {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 24) {
                            // Заголовок и категория
                            headerSection
                            
                            // Цитата
                            quoteSection
                            
                            // Детали
                            detailsSection
                            
                            // Прогресс, если есть
                            if let progress = templateStore.getProgress(forTemplateID: mutableTemplate.id) {
                                progressSection(progress)
                            }
                            
                            // Отзывы (скрыто в текущем релизе)
                            // reviewsSection
                            
                            // Кнопки действий
                            actionButtons
                        }
                        .padding(.bottom, 50)
                        .background(AskezaTheme.backgroundColor)
                    }
                    .background(AskezaTheme.backgroundColor)
                } else {
                    // Показываем индикатор загрузки
                    ProgressView("Загрузка...")
                        .foregroundColor(AskezaTheme.textColor)
                        .padding(50)
                        .background(AskezaTheme.backgroundColor)
                }
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
                        
                        Text(mutableTemplate.category.rawValue)
                            .font(.caption)
                            .foregroundColor(AskezaTheme.secondaryTextColor)
                    }
                }
            }
            .sheet(isPresented: $showingShareSheet) {
                ShareSheet(activityItems: [shareText])
            }
            .onAppear {
                // Загружаем данные при появлении представления
                loadData()
            }
        }
    }
    
    // Загрузка всех необходимых данных
    private func loadData() {
        print("🔍 TemplateDetailView - Загрузка данных для шаблона: \(mutableTemplate.title)")
        
        // Сначала проверяем special cases
        handleSpecialTemplates()
        
        // Сразу запускаем таймер показа UI, чтобы избежать "зависания"
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            if !self.isDataLoaded {
                self.isDataLoaded = true
                print("⚠️ TemplateDetailView - Данные не загрузились вовремя, принудительно показываем UI")
            }
        }
        
        // Загружаем прогресс шаблона
        if let progress = templateStore.getProgress(forTemplateID: mutableTemplate.id) {
            print("✅ TemplateDetailView - Загружен прогресс: \(progress.daysCompleted) дней")
            isDataLoaded = true
        } else {
            print("🔍 TemplateDetailView - Прогресс не найден, пробуем загрузить по templateId")
            
            // Проверяем существование шаблона и создаем его при необходимости
            if let template = templateStore.getTemplate(byTemplateId: mutableTemplate.templateId) {
                print("✅ TemplateDetailView - Найден шаблон по templateId")
                if mutableTemplate.id != template.id {
                    mutableTemplate = template
                    print("🔄 TemplateDetailView - Обновлен ID шаблона")
                }
                isDataLoaded = true
            } else {
                print("⚠️ TemplateDetailView - Шаблон не найден ни по ID, ни по templateId")
                isDataLoaded = true // Всё равно показываем UI
            }
        }
    }
    
    // Обработка специальных случаев для шаблонов
    private func handleSpecialTemplates() {
        // Цифровой детокс
        if mutableTemplate.title.contains("цифрового детокса") || mutableTemplate.title.contains("digital detox") {
            mutableTemplate.templateId = "digital-detox-7"
            ensureDigitalDetoxExists()
        }
        
        // Другие специальные случаи
        if mutableTemplate.title.contains("Год железной дисциплины") {
            mutableTemplate.templateId = "365-days-discipline"
        }
    }
    
    // Гарантируем существование шаблона цифрового детокса
    private func ensureDigitalDetoxExists() {
        if templateStore.getTemplate(byTemplateId: "digital-detox-7") == nil {
            print("⚠️ TemplateDetailView - Создаем шаблон цифрового детокса")
            
            let digitalDetox = PracticeTemplate(
                templateId: "digital-detox-7",
                title: "7 дней цифрового детокса",
                category: .osvobozhdenie,
                duration: 7,
                quote: "Иногда нужно отключиться, чтобы восстановить связь.",
                difficulty: 2,
                description: "Ограничение использования смартфона и социальных сетей до 30 минут в день.",
                intention: "Вернуть контроль над своим вниманием и временем"
            )
            
            templateStore.addTemplate(digitalDetox)
        }
    }
    
    // MARK: - Sections
    
    private var headerSection: some View {
        VStack(alignment: .center, spacing: 16) {
            // Статус и прогресс
            let status = templateStore.getStatus(forTemplateID: mutableTemplate.id)
            
            if status != .notStarted {
                ZStack {
                    Circle()
                        .stroke(status.color.opacity(0.2), lineWidth: 8)
                        .frame(width: 120, height: 120)
                    
                    if status == .inProgress, let progress = templateStore.getProgress(forTemplateID: mutableTemplate.id) {
                        Circle()
                            .trim(from: 0, to: CGFloat(min(1.0, Double(progress.daysCompleted) / Double(mutableTemplate.duration))))
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
            Text(mutableTemplate.title)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(AskezaTheme.textColor)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            // Иконка категории
            HStack {
                Image(systemName: mutableTemplate.category.systemImage)
                    .foregroundColor(mutableTemplate.category.mainColor)
                
                Text(mutableTemplate.category.rawValue)
                    .foregroundColor(AskezaTheme.secondaryTextColor)
            }
            
            // Сложность
            difficultyView(level: mutableTemplate.difficulty)
                .padding(.top, 8)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(AskezaTheme.buttonBackground)
        .cornerRadius(16)
        .padding(.horizontal)
    }
    
    private var quoteSection: some View {
        Text("\"\(mutableTemplate.quote)\"")
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
            detailRow(title: "Длительность:", value: durationText(mutableTemplate.duration))
            detailRow(title: "Сложность:", value: difficultyText(mutableTemplate.difficulty))
            
            Text("Описание")
                .font(.headline)
                .foregroundColor(AskezaTheme.textColor)
            
            Text(mutableTemplate.practiceDescription)
                .foregroundColor(AskezaTheme.secondaryTextColor)
                .fixedSize(horizontal: false, vertical: true)
            
            Text("Цель")
                .font(.headline)
                .foregroundColor(AskezaTheme.textColor)
            
            Text(mutableTemplate.intention)
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
                templateDuration: mutableTemplate.duration
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
                print("Нажата кнопка 'Начать практику'")
                // Показываем диалог подтверждения перед добавлением аскезы
                state.errorMessage = "Вы хотите добавить аскезу '\(mutableTemplate.title)' в свой список?"
                state.showConfirmationDialog = true
            }) {
                Text(startButtonText)
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(AskezaTheme.accentColor)
                    .cornerRadius(12)
            }
            .buttonStyle(PlainButtonStyle())
            .alert("Начать практику", isPresented: $state.showConfirmationDialog) {
                Button("Отмена", role: .cancel) {}
                Button("Добавить") {
                    // Создаем аскезу без лишних операций
                    if let askeza = templateStore.startTemplate(mutableTemplate) {
                        print("✅ TemplateDetailView: Создана аскеза \(askeza.title)")
                        
                        // Отправляем уведомление без async/await и Task
                        NotificationCenter.default.post(
                            name: Notification.Name.refreshWorkshopData,
                            object: askeza
                        )
                        
                        // Закрываем экран после отправки уведомления
                        dismiss()
                    } else {
                        // Показываем сообщение об ошибке - шаблон уже активен
                        state.errorMessage = "Этот шаблон уже активен. Завершите текущую аскезу, прежде чем начать заново."
                        state.showError = true
                    }
                }
            } message: {
                Text(state.errorMessage)
            }
            .alert("Внимание", isPresented: $state.showError) {
                Button("ОК", role: .cancel) {}
            } message: {
                Text(state.errorMessage)
            }
            
            Button(action: {
                print("Нажата кнопка 'Поделиться'")
                shareTemplate()
            }) {
                Image(systemName: "square.and.arrow.up")
                    .font(.headline)
                    .foregroundColor(AskezaTheme.accentColor)
                    .padding()
                    .background(AskezaTheme.buttonBackground)
                    .cornerRadius(12)
            }
            .buttonStyle(PlainButtonStyle())
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
            Text("Сложность:")
                .font(.subheadline)
                .foregroundColor(AskezaTheme.secondaryTextColor)
            
            HStack(spacing: 2) {
                ForEach(1...5, id: \.self) { i in
                    Image(systemName: i <= level ? "star.fill" : "star")
                        .font(.system(size: 12))
                        .foregroundColor(i <= level ? .yellow : Color.gray.opacity(0.2))
                }
            }
        }
    }
    
    // MARK: - Helper Methods
    
    private var startButtonText: String {
        let status = templateStore.getStatus(forTemplateID: mutableTemplate.id)
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
        print("Подготавливаем текст для шаринга")
        shareText = """
        🧘‍♂️ Аскеза: \(mutableTemplate.title)
        📝 Категория: \(mutableTemplate.category.rawValue)
        ⏳ Длительность: \(durationText(mutableTemplate.duration))
        ✨ Цитата: "\(mutableTemplate.quote)"
        
        #Askeza #\(mutableTemplate.category.rawValue) #СамоРазвитие
        """
        
        print("Текст для шаринга: \(shareText)")
        showingShareSheet = true
    }
    
    private func difficultyText(_ level: Int) -> String {
        switch level {
        case 1:
            return "★"
        case 2:
            return "★★"
        case 3:
            return "★★★"
        case 4:
            return "★★★★"
        case 5:
            return "★★★★★"
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
    
    // MARK: - Actions
    
    // Запуск практики
    private func startAction() {
        // ... existing code ...
    }
    
    // Метод для отправки уведомления об обновлении счетчика завершенных шаблонов
    private func notifyTemplateCompletionUpdate() {
        print("📢 TemplateDetailView - Отправка уведомления об обновлении счетчика завершенных шаблонов")
        
        // Отправляем уведомление для обновления данных в мастерской
        NotificationCenter.default.post(
            name: .refreshWorkshopData,
            object: nil
        )
        
        // Чтобы гарантировать обновление, вызываем с задержкой
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            NotificationCenter.default.post(
                name: .refreshWorkshopData,
                object: nil
            )
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
                
                Text("Статус: \(status == .inProgress ? "Активная" : status.rawValue)")
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