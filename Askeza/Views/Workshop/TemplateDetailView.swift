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
        print("🔍 TemplateDetailView - loadData() начата для шаблона: \(mutableTemplate.title), ID: \(mutableTemplate.templateId), UUID: \(mutableTemplate.id)")
        
        // Сначала устанавливаем isDataLoaded в false для показа индикатора загрузки
        isDataLoaded = false
        
        // Определяем является ли это шаблоном цифрового детокса
        let isDigitalDetox = mutableTemplate.title.contains("цифрового детокса") || mutableTemplate.title.contains("digital detox")
        
        // Если это цифровой детокс, сначала фиксируем templateId и выполняем предзагрузку
        if isDigitalDetox && mutableTemplate.templateId != "digital-detox-7" {
            mutableTemplate.templateId = "digital-detox-7"
            print("🔧 TemplateDetailView - Установлен корректный templateId для цифрового детокса")
        }
        
        // Для гарантии создания цифрового детокса, выполняем принудительную загрузку с задержками
        if isDigitalDetox {
            // Попытка немедленной загрузки
            templateStore.preloadTemplateData(for: "digital-detox-7")
            
            // Дополнительная загрузка с задержкой
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                self.templateStore.preloadTemplateData(for: "digital-detox-7")
                
                // После повторной загрузки данных шаблона можно продолжить
                self.attemptToLoadData()
            }
        } else {
            // Для обычных шаблонов просто начинаем загрузку
            attemptToLoadData()
        }
    }
    
    // Функция для попытки загрузки данных
    private func attemptToLoadData(attempt: Int = 1) {
        print("🔄 TemplateDetailView - Попытка \(attempt) загрузки данных для шаблона: \(mutableTemplate.title)")
        
        // Проверяем особые случаи для templateId
        var templateIdToLoad = mutableTemplate.templateId
        let isDigitalDetox = mutableTemplate.title.contains("цифрового детокса") || mutableTemplate.title.contains("digital detox")
        
        if mutableTemplate.title.contains("Год железной дисциплины") && mutableTemplate.templateId.isEmpty {
            print("🔍 TemplateDetailView - Обнаружен шаблон 'Год железной дисциплины' без templateId")
            templateIdToLoad = "365-days-discipline"
        } else if isDigitalDetox {
            print("🔍 TemplateDetailView - Обнаружен шаблон 'Цифровой детокс'")
            templateIdToLoad = "digital-detox-7"
            
            // Для цифрового детокса гарантируем существование шаблона
            ensureDigitalDetoxExists()
        }
        
        // Загружаем данные с небольшой задержкой для особых случаев
        if isDigitalDetox {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                self.templateStore.preloadTemplateData(for: templateIdToLoad)
                self.checkProgress(attempt: attempt)
            }
        } else {
            templateStore.preloadTemplateData(for: templateIdToLoad)
            checkProgress(attempt: attempt)
        }
    }
    
    // Гарантируем существование шаблона цифрового детокса
    private func ensureDigitalDetoxExists() {
        if templateStore.getTemplate(byTemplateId: "digital-detox-7") == nil {
            print("⚠️ TemplateDetailView - Шаблон цифрового детокса не найден, создаем его")
            
            // Создаем шаблон с фиксированным ID
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
            
            // Добавляем шаблон
            templateStore.addTemplate(digitalDetox)
            print("✅ TemplateDetailView - Создан шаблон цифрового детокса")
            
            // Обновляем текущий шаблон для отображения
            if mutableTemplate.id == digitalDetox.id || mutableTemplate.templateId == digitalDetox.templateId {
                mutableTemplate = digitalDetox
            }
        }
    }
    
    // Функция для проверки загруженного прогресса
    private func checkProgress(attempt: Int) {
        // Определяем является ли это шаблоном цифрового детокса
        let isDigitalDetox = mutableTemplate.title.contains("цифрового детокса") || mutableTemplate.title.contains("digital detox")
        
        // Дополнительно пробуем загрузить по UUID
        let progress = templateStore.getProgress(forTemplateID: mutableTemplate.id)
        if let progress = progress {
            print("✅ TemplateDetailView - Успешно загружен прогресс для шаблона: \(progress.daysCompleted) дней")
            
            // Если прогресс загрузился успешно, активируем UI
            DispatchQueue.main.async {
                isDataLoaded = true
                print("✅ TemplateDetailView - Данные шаблона загружены, isDataLoaded: \(isDataLoaded)")
            }
        } else {
            print("⚠️ TemplateDetailView - Не удалось загрузить прогресс для шаблона")
            
            // Для цифрового детокса пробуем еще раз с большей задержкой
            let retryDelay = isDigitalDetox ? 0.5 : 0.3
            let maxAttempts = isDigitalDetox ? 5 : 3
            
            // Если прогресс не загрузился и мы не достигли максимального числа попыток - пробуем еще раз
            if attempt < maxAttempts {
                print("🔄 TemplateDetailView - Планируем повторную попытку \(attempt + 1)")
                DispatchQueue.main.asyncAfter(deadline: .now() + retryDelay) {
                    self.attemptToLoadData(attempt: attempt + 1)
                }
            } else {
                // Если это цифровой детокс и после нескольких попыток не удалось
                if isDigitalDetox {
                    // Создаем шаблон заново для окончательной попытки
                    print("🔄 TemplateDetailView - Последняя попытка для цифрового детокса - принудительное создание шаблона")
                    
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
                    
                    // Добавляем шаблон
                    templateStore.addTemplate(digitalDetox)
                    
                    // Обновляем текущий шаблон
                    mutableTemplate = digitalDetox
                    
                    // Пробуем загрузить еще раз с искусственной задержкой
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        self.templateStore.preloadTemplateData(for: "digital-detox-7")
                        
                        // Искусственно создаем прогресс
                        if let createdTemplate = self.templateStore.getTemplate(byTemplateId: "digital-detox-7") {
                            print("✓ TemplateDetailView - Получен шаблон после финальной попытки")
                            _ = self.templateStore.startTemplate(createdTemplate)
                        }
                        
                        // В любом случае показываем UI
                        DispatchQueue.main.async {
                            self.isDataLoaded = true
                        }
                    }
                } else {
                    // Если и после нескольких попыток не удалось - все равно показываем UI
                    print("⚠️ TemplateDetailView - Достигнуто максимальное число попыток, показываем UI без данных")
                    DispatchQueue.main.async {
                        isDataLoaded = true
                    }
                }
            }
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
                    if let askeza = templateStore.startTemplate(mutableTemplate) {
                        // Используем NotificationCenter для передачи аскезы
                        Task {
                            NotificationCenter.default.post(
                                name: Notification.Name("AddAskezaNotification"),
                                object: askeza
                            )
                            print("Создана аскеза: \(askeza.title)")
                        }
                        dismiss()
                    } else {
                        // Показываем сообщение об ошибке - шаблон уже активен
                        print("Ошибка: Шаблон уже активен и не может быть начат повторно")
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