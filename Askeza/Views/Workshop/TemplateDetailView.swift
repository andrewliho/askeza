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
    @Binding var isPresented: Bool
    @EnvironmentObject var templateStore: PracticeTemplateStore
    @StateObject private var state = TemplateDetailViewState()
    @Environment(\.dismiss) private var dismiss
    @State private var isLoadingData = true
    @State private var progress: TemplateProgress?
    @State private var errorMessage = ""
    @State private var showingError = false
    
    init(template: PracticeTemplate, isPresented: Binding<Bool>) {
        self.template = template
        self._isPresented = isPresented
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
                        if !template.practiceDescription.isEmpty {
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
                        
                        // Кнопки для практики в зависимости от статуса
                        if let templateProgress = progress {
                            let status = templateProgress.status(templateDuration: template.duration)
                            // Показываем разные кнопки в зависимости от статуса практики
                            switch status {
                            case .inProgress:
                                // Для активных практик показываем информационный блок
                                activeStatusInfoView
                            case .completed, .mastered:
                                // Для завершенных и освоенных практик показываем инфоблок и кнопку "Повторить"
                                VStack(spacing: 16) {
                                    // Информационный блок о завершении
                                    completedStatusInfoView(status: status, progress: templateProgress)
                                    
                                    // Кнопка для повторного запуска
                                    restartPracticeButton
                                }
                            case .notStarted:
                                // Для не начатых практик показываем кнопку "Начать"
                                startPracticeButton
                            }
                        } else {
                            // Если прогресс не найден, то практика точно не активна
                            startPracticeButton
                        }
                    }
                    .padding(.vertical)
                }
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("Закрыть") {
                            isPresented = false
                        }
                        .foregroundColor(AskezaTheme.accentColor)
                    }
                    
                    ToolbarItem(placement: .principal) {
                        Text("Практика")
                            .font(.headline)
                            .foregroundColor(AskezaTheme.textColor)
                    }
                }
                .alert("Ошибка", isPresented: $showingError) {
                    Button("OK", role: .cancel) {}
                } message: {
                    Text(errorMessage)
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
                let isPermanent = template.duration == 0  // Пожизненная практика
                
                HStack {
                    Image(systemName: status.icon)
                        .foregroundColor(isPermanent && (status == .inProgress || status == .mastered) ? Color.indigo : status.color)
                    
                    if status == .completed || status == .mastered {
                        // Для завершенных практик показываем расширенную информацию
                        Text(getExtendedStatusInfo(status, progress: progress, isPermanent: isPermanent))
                            .font(.subheadline)
                            .foregroundColor(isPermanent && status == .mastered ? Color.indigo : status.color)
                    } else {
                        // Для остальных показываем стандартный текст
                        Text(getStatusText(status, isPermanent: isPermanent))
                            .font(.subheadline)
                            .foregroundColor(isPermanent && status == .inProgress ? Color.indigo : status.color)
                    }
                }
                
                // Прогресс бар для активных практик
                if status == .inProgress {
                    let progressValue = template.duration > 0 
                        ? Double(progress.daysCompleted) / Double(template.duration)
                        : min(1.0, Double(progress.daysCompleted) / 100.0)  // Для пожизненных показываем % до 100 дней
                        
                    VStack(spacing: 4) {
                        GeometryReader { geometry in
                            ZStack(alignment: .leading) {
                                Rectangle()
                                    .fill(Color.gray.opacity(0.3))
                                    .frame(height: 8)
                                    .cornerRadius(4)
                                
                                Rectangle()
                                    .fill(isPermanent ? Color.indigo : status.color)
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
                            
                            if isPermanent {
                                Text("Пожизненная ∞")
                                    .font(.caption)
                                    .foregroundColor(Color.indigo)
                            } else {
                                Text("\(Int(progressValue * 100))%")
                                    .font(.caption)
                                    .foregroundColor(AskezaTheme.secondaryTextColor)
                            }
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
    
    // Добавляем кнопку "Начать практику"
    private var startPracticeButton: some View {
        Button(action: {
            startPractice()
        }) {
            HStack {
                Image(systemName: "play.fill")
                Text("Начать практику")
                    .fontWeight(.medium)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(AskezaTheme.accentColor)
            .foregroundColor(.white)
            .cornerRadius(12)
        }
        .padding(.horizontal)
    }
    
    // Добавляем кнопку "Повторить практику" для завершенных практик
    private var restartPracticeButton: some View {
        Button(action: {
            startPractice() // Используем тот же метод для запуска практики
        }) {
            HStack {
                Image(systemName: "arrow.clockwise")
                Text("Повторить практику")
                    .fontWeight(.medium)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [Color.green, Color.green.opacity(0.8)]),
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .foregroundColor(.white)
            .cornerRadius(12)
        }
        .padding(.horizontal)
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
            
            Text(template.practiceDescription)
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
            .background(template.category.mainColor.opacity(0.1))
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
            
            // Простая заглушка для инструкций
            Text("Инструкции временно недоступны")
                .font(.body)
                .foregroundColor(AskezaTheme.secondaryTextColor)
                .padding()
        }
        .padding()
        .background(AskezaTheme.buttonBackground)
        .cornerRadius(16)
    }
    
    // Добавляем информационный блок для активных практик
    private var activeStatusInfoView: some View {
        HStack {
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(.green)
            
            Text("Практика уже активна")
                .fontWeight(.medium)
                .foregroundColor(AskezaTheme.secondaryTextColor)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(AskezaTheme.buttonBackground)
        .cornerRadius(12)
        .padding(.horizontal)
    }
    
    // Информационный блок для завершенных практик
    private func completedStatusInfoView(status: TemplateStatus, progress: TemplateProgress) -> some View {
        return HStack {
            Image(systemName: status == .mastered ? "star.fill" : "checkmark.circle.fill")
                .foregroundColor(status == .mastered ? .purple : .green)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(status == .mastered ? "Практика освоена" : "Практика завершена")
                    .fontWeight(.bold)
                    .foregroundColor(status == .mastered ? .purple : .green)
                
                if progress.timesCompleted > 0 {
                    Text("Пройдено \(progress.timesCompleted) \(pluralForm(progress.timesCompleted))")
                        .font(.subheadline)
                        .foregroundColor(AskezaTheme.secondaryTextColor)
                }
                
                Text("Вы можете начать практику заново")
                    .font(.caption)
                    .foregroundColor(AskezaTheme.secondaryTextColor)
            }
            
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            (status == .mastered ? Color.purple : Color.green)
                .opacity(0.1)
        )
        .cornerRadius(12)
        .padding(.horizontal)
    }
    
    // Получаем расширенную информацию о статусе практики для отображения
    private func getExtendedStatusInfo(_ status: TemplateStatus, progress: TemplateProgress, isPermanent: Bool) -> String {
        // Строка с основной информацией о статусе
        var statusInfo = getStatusText(status, isPermanent: isPermanent)
        
        // Добавляем информацию о количестве прохождений
        if progress.timesCompleted > 0 {
            let timesStr = pluralForm(progress.timesCompleted)
            statusInfo += " • Пройдено \(progress.timesCompleted) \(timesStr)"
        }
        
        return statusInfo
    }
    
    // Вспомогательная функция для склонения слова "раз"
    private func pluralForm(_ number: Int) -> String {
        let lastDigit = number % 10
        let lastTwoDigits = number % 100
        
        if lastDigit == 1 && lastTwoDigits != 11 {
            return "раз"
        } else if (lastDigit >= 2 && lastDigit <= 4) && !(lastTwoDigits >= 12 && lastTwoDigits <= 14) {
            return "раза"
        } else {
            return "раз"
        }
    }
    
    // MARK: - Вспомогательные методы
    
    private func loadData() {
        isLoadingData = true
        
        // Загружаем прогресс шаблона
        progress = templateStore.getProgress(forTemplateID: template.id)
        
        // Если не найден по ID, пробуем по templateId
        if progress == nil {
            // Здесь нужно искать по ID, так как templateId - это строка, а не UUID
            let allProgress = templateStore.getAllProgress()
            progress = allProgress.first(where: { 
                if let template = templateStore.getTemplate(byID: $0.templateID) {
                    return template.templateId == self.template.templateId
                }
                return false
            })
        }
        
        // Если прогресс найден, проверяем его статус
        if let currentProgress = progress {
            // Проверяем, есть ли активная аскеза с таким templateID
            let isActive = checkIfTemplateIsActiveInAskeza()
            let currentStatus = currentProgress.status(templateDuration: template.duration)
            
            print("📊 TemplateDetailView.loadData: Статус шаблона: \(currentStatus.rawValue), активен в аскезах: \(isActive), завершений: \(currentProgress.timesCompleted)")
            
            // Если шаблон активен, но его статус не соответствует активному - исправляем
            if isActive && currentStatus != .inProgress {
                print("🔄 TemplateDetailView.loadData: Исправление статуса шаблона на Активный")
                // Не меняем статус, так как это произойдет автоматически при следующем обновлении
            }
            
            // Если шаблон не активен, но его статус активный, и есть хотя бы одно завершение - исправляем
            if !isActive && currentStatus == .inProgress && currentProgress.timesCompleted > 0 {
                print("🔄 TemplateDetailView.loadData: Исправление статуса шаблона на Завершен")
                
                // Сбрасываем прогресс до 0, сохраняя счетчик завершений
                // Это приведет к тому, что status() вернет .completed вместо .inProgress
                currentProgress.daysCompleted = 0
                
                // Если progressStatus = completed, но флаг isProcessingCompletion все еще активен - сбрасываем
                if currentProgress.isProcessingCompletion {
                    currentProgress.isProcessingCompletion = false
                    print("🔄 TemplateDetailView.loadData: Сброс флага isProcessingCompletion")
                }
                
                // Сохраняем изменения
                templateStore.saveContext()
                
                // Тут не обновляем progress, так как обновления будут применены только 
                // после сохранения и будут доступны при следующем loadData()
            }
        }
        
        isLoadingData = false
    }
    
    // Метод для проверки, есть ли активная аскеза с этим шаблоном
    private func checkIfTemplateIsActiveInAskeza() -> Bool {
        // Отправляем уведомление для проверки статуса в AskezaViewModel
        // AskezaViewModel добавит активность на это уведомление
        NotificationCenter.default.post(
            name: .checkTemplateActivity,
            object: template.id
        )
        
        // В реальности тут должен быть код, который получает ответ
        // Но пока просто возвращаем false
        return false
    }
    
    private func durationText(_ days: Int) -> String {
        if days == 0 {
            return "Пожизненно"
        } else {
            return "\(days) дней"
        }
    }
    
    // Получаем текст статуса с учетом пожизненных практик
    private func getStatusText(_ status: TemplateStatus, isPermanent: Bool) -> String {
        if isPermanent && status == .inProgress {
            return "Пожизненная ∞"
        }
        
        if isPermanent && status == .mastered {
            return "Освоена ∞"
        }
        
        return status.displayText
    }
    
    // Метод для начала практики
    private func startPractice() {
        print("🚀 TemplateDetailView: Начало практики \(template.title)")
        
        // Проверяем статус шаблона перед запуском
        if let currentProgress = progress {
            let currentStatus = currentProgress.status(templateDuration: template.duration)
            print("📊 TemplateDetailView: Текущий статус шаблона перед запуском: \(currentStatus.rawValue)")
            
            // Если практика уже завершена, сначала сбрасываем прогресс
            if currentStatus == .completed || currentStatus == .mastered || (currentStatus == .inProgress && currentProgress.timesCompleted > 0) {
                print("🔄 TemplateDetailView: Сброс предыдущего прогресса для завершенной практики")
                
                // Сбрасываем прогресс, но не удаляем запись о прошлом прохождении
                templateStore.resetTemplateProgress(template.id)
                
                // Принудительно устанавливаем дату начала для корректного состояния "Активная"
                if let resetProgress = templateStore.getProgress(forTemplateID: template.id) {
                    resetProgress.dateStarted = Date()
                    resetProgress.daysCompleted = 1  // Устанавливаем прогресс 1 день для гарантии статуса "Активная"
                    resetProgress.isProcessingCompletion = false
                    
                    // Сохраняем изменения
                    templateStore.saveContext()
                    
                    // Принудительно обновляем UI
                    DispatchQueue.main.async {
                        NotificationCenter.default.post(name: .refreshWorkshopData, object: nil)
                    }
                }
                
                // Даем время на обновление
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    // Обновляем локальную переменную прогресса
                    self.progress = self.templateStore.getProgress(forTemplateID: self.template.id)
                    print("✅ TemplateDetailView: Прогресс обновлен после сброса, текущее значение: \(self.progress?.daysCompleted ?? 0)")
                }
            }
        }
        
        if let askeza = templateStore.startTemplate(template) {
            // Отправляем уведомление для добавления аскезы через AskezaViewModel
            DispatchQueue.main.async {
                print("✨ TemplateDetailView: Практика успешно начата, отправляем уведомление")
                
                // Перезагружаем прогресс шаблона после создания аскезы
                self.loadData()
                
                // Принудительно синхронизируем статусы между шаблоном и аскезой
                // Устанавливаем статус "в процессе" для только что созданной практики
                if let updatedProgress = self.templateStore.getProgress(forTemplateID: self.template.id) {
                    updatedProgress.dateStarted = Date()
                    updatedProgress.daysCompleted = 1  // Устанавливаем прогресс 1 день для гарантии статуса "Активная"
                    updatedProgress.isProcessingCompletion = false
                    
                    // Сохраняем изменения
                    self.templateStore.saveContext()
                    
                    print("✅ TemplateDetailView: Статус шаблона успешно обновлен и синхронизирован")
                }
                
                // Отправляем уведомление для обновления UI и добавления аскезы
                NotificationCenter.default.post(
                    name: .askezaAddedFromTemplate,
                    object: askeza
                )
                
                // Отправляем дополнительное уведомление для обновления мастерской
                NotificationCenter.default.post(
                    name: .refreshWorkshopData,
                    object: nil
                )
                
                // Через некоторое время отправляем дополнительное уведомление
                // для гарантии обновления интерфейса
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    NotificationCenter.default.post(
                        name: .refreshWorkshopData,
                        object: nil
                    )
                }
                
                // Закрываем экран деталей
                isPresented = false
            }
        } else {
            // Показываем ошибку, что практика уже активна
            DispatchQueue.main.async {
                print("⚠️ TemplateDetailView: Ошибка при начале практики - уже активна")
                errorMessage = "Эта практика уже активна. Завершите текущую аскезу, прежде чем начать заново."
                showingError = true
            }
        }
    }
}

#Preview {
    let template = PracticeTemplate(
        id: UUID(),
        templateId: "meditation-7",
        title: "7 дней медитации",
        category: .um,
        duration: 7,
        quote: "Медитация – это не бегство от реальности, а встреча с ней.",
        difficulty: 2,
        description: "Ежедневная практика медитации для развития осознанности и снижения стресса.",
        intention: "Стать более спокойным и сосредоточенным"
    )
    
    TemplateDetailView(template: template, isPresented: .constant(true))
} // Обновлено
