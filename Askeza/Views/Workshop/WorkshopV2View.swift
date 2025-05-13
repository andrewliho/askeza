import SwiftUI
import SwiftData

// Создаем класс для управления состоянием
class WorkshopStateManager: ObservableObject {
    @Published var searchText: String = ""
    @Published var selectedCategory: AskezaCategory? = nil
    @Published var selectedDifficulty: Int? = nil
    @Published var selectedDuration: Int? = nil
    @Published var showingFilters = false
    @Published var showingOnboarding = false
    
    let templateStore = PracticeTemplateStore.shared
    
    func resetFilters() {
        selectedCategory = nil
        selectedDifficulty = nil
        selectedDuration = nil
        searchText = ""
    }
    
    func ensureDigitalDetoxExists() {
        // Проверяем, был ли уже создан шаблон цифрового детокса
        if UserDefaults.standard.bool(forKey: "digitalDetoxTemplateCreated") {
            print("✅ WorkshopV2View - Шаблон цифрового детокса уже был создан ранее")
            return
        }
        
        print("🔍 WorkshopV2View - Проверка наличия шаблона цифрового детокса")
        
        // Проверяем существует ли шаблон
        if templateStore.getTemplate(byTemplateId: "digital-detox-7") == nil {
            print("⚠️ WorkshopV2View - Шаблон цифрового детокса не найден, создаем его")
            
            // Создаем шаблон с уникальным идентификатором
            let digitalDetoxUUID = UUID()
            print("🔑 WorkshopV2View - Назначен UUID для цифрового детокса: \(digitalDetoxUUID)")
            
            let digitalDetox = PracticeTemplate(
                id: digitalDetoxUUID,
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
            print("✅ WorkshopV2View - Шаблон цифрового детокса успешно создан")
            
            // Отмечаем, что шаблон был создан
            UserDefaults.standard.set(true, forKey: "digitalDetoxTemplateCreated")
        } else {
            print("✅ WorkshopV2View - Шаблон цифрового детокса уже существует в базе")
            // Отмечаем, что шаблон был найден
            UserDefaults.standard.set(true, forKey: "digitalDetoxTemplateCreated")
        }
    }
}

struct WorkshopV2View: View {
    @StateObject private var stateManager = WorkshopStateManager()
    
    var body: some View {
        NavigationStack {
            ZStack {
                AskezaTheme.backgroundColor
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Поисковая строка
                    searchBar
                        .padding(.horizontal)
                        .padding(.vertical, 8)
                    
                    // Фильтры категорий
                    categoryFilters
                    
                    // Основной контент (рекомендации, курсы, галерея)
                    ScrollView {
                        LazyVStack(spacing: 24) {
                            // Рекомендации
                            // recommendationsSection
                            
                            // Курсы-пути
                            pathsSection
                            
                            // Галерея шаблонов
                            WorkshopGridView(
                                templateStore: stateManager.templateStore,
                                searchText: $stateManager.searchText,
                                selectedCategory: $stateManager.selectedCategory,
                                selectedDifficulty: $stateManager.selectedDifficulty,
                                selectedDuration: $stateManager.selectedDuration
                            )
                            .padding(.top, 8)
                        }
                        .padding(.bottom, 50)
                    }
                }
            }
            .navigationTitle("Мастерская")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        stateManager.showingFilters = true
                    }) {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                            .foregroundColor(AskezaTheme.accentColor)
                    }
                }
            }
            .sheet(isPresented: $stateManager.showingFilters) {
                FilterSheetView(
                    selectedDifficulty: $stateManager.selectedDifficulty,
                    selectedDuration: $stateManager.selectedDuration,
                    onReset: stateManager.resetFilters
                )
            }
            .sheet(isPresented: $stateManager.showingOnboarding) {
                WorkshopOnboardingView()
            }
            .onAppear {
                // Гарантируем, что шаблоны добавлены в хранилище только при первом запуске
                if !UserDefaults.standard.bool(forKey: "templatesAdded") {
                    AdditionalTemplates.addTemplates(to: stateManager.templateStore)
                    UserDefaults.standard.set(true, forKey: "templatesAdded")
                    print("✅ WorkshopV2View - Первичное добавление шаблонов выполнено")
                }
                
                // Предзагружаем и гарантируем существование шаблона цифрового детокса
                stateManager.ensureDigitalDetoxExists()
                
                // Показываем онбординг при первом запуске
                if !UserDefaults.standard.bool(forKey: "workshopOnboardingShown") {
                    stateManager.showingOnboarding = true
                    UserDefaults.standard.set(true, forKey: "workshopOnboardingShown")
                }
                
                // Настраиваем наблюдатель для обновления списка после добавления аскезы
                NotificationCenter.default.addObserver(
                    forName: Notification.Name("AddAskezaNotification"),
                    object: nil,
                    queue: .main
                ) { [weak stateManager] _ in
                    // Обновляем список шаблонов
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        stateManager?.objectWillChange.send()
                    }
                }
            }
            .onDisappear {
                // Удаляем наблюдатель при исчезновении представления
                NotificationCenter.default.removeObserver(self)
            }
        }
    }
    
    // Обновляем все свойства для использования stateManager
    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(AskezaTheme.secondaryTextColor)
            
            TextField("Поиск практик...", text: $stateManager.searchText)
                .foregroundColor(AskezaTheme.textColor)
            
            if !stateManager.searchText.isEmpty {
                Button(action: {
                    stateManager.searchText = ""
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(AskezaTheme.secondaryTextColor)
                }
            }
        }
        .padding(10)
        .background(AskezaTheme.buttonBackground)
        .cornerRadius(12)
    }
    
    private var categoryFilters: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                categoryButton(nil, text: "Все")
                
                ForEach(AskezaCategory.allCases.filter { $0 != .custom }, id: \.self) { category in
                    categoryButton(category, text: category.rawValue)
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
        }
    }
    
    private var recommendationsSection: some View {
        let recommendations = stateManager.templateStore.getRecommendedTemplates(limit: 3)
        
        return Group {
            if !recommendations.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    // Заголовок с дополнительной информацией
                    HStack {
                        Text("Рекомендуемые для вас")
                            .font(.headline)
                            .foregroundColor(AskezaTheme.textColor)
                            .padding(.horizontal)
                        
                        Spacer()
                        
                        Text("\(recommendations.count) шаблонов")
                            .font(.caption)
                            .foregroundColor(AskezaTheme.secondaryTextColor)
                    }
                    .padding(.horizontal)
                    
                    // Горизонтальная прокрутка карточек
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 16) {
                            ForEach(recommendations) { template in
                                RecommendationCardWrapper(
                                    template: template,
                                    templateStore: stateManager.templateStore
                                )
                                .frame(width: 300, height: 240) // Увеличиваем размер для лучшего отображения
                            }
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 8) // Добавляем отступ снизу для тени
                    }
                }
                .background(AskezaTheme.backgroundColor) // Обеспечиваем правильный фон
            }
        }
    }
    
    private var pathsSection: some View {
        let courses = stateManager.templateStore.courses
        
        return Group {
            if !courses.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    sectionHeader("Пути развития")
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 16) {
                            ForEach(courses) { course in
                                CoursePathCardView(
                                    course: course,
                                    templateStore: stateManager.templateStore
                                )
                                .frame(width: 300)
                            }
                        }
                        .padding(.horizontal)
                    }
                }
            }
        }
    }
    
    // MARK: - Helper Views
    
    private func sectionHeader(_ title: String) -> some View {
        Text(title)
            .font(.headline)
            .foregroundColor(AskezaTheme.textColor)
            .padding(.horizontal)
    }
    
    private func categoryButton(_ category: AskezaCategory?, text: String) -> some View {
        Button(action: {
            if stateManager.selectedCategory == category {
                stateManager.selectedCategory = nil
            } else {
                stateManager.selectedCategory = category
            }
        }) {
            HStack(spacing: 6) {
                if let category = category {
                    Image(systemName: category.systemImage)
                        .font(.system(size: 14))
                        .foregroundColor(stateManager.selectedCategory == category ? .white : category.mainColor)
                }
                
                Text(text)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(stateManager.selectedCategory == category ? .white : AskezaTheme.textColor)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(stateManager.selectedCategory == category ? AskezaTheme.accentColor : AskezaTheme.buttonBackground)
            )
        }
    }
}

struct FilterSheetView: View {
    @Binding var selectedDifficulty: Int?
    @Binding var selectedDuration: Int?
    @Environment(\.dismiss) private var dismiss
    
    var onReset: () -> Void
    
    var body: some View {
        NavigationView {
            ZStack {
                AskezaTheme.backgroundColor
                    .ignoresSafeArea()
                
                VStack(spacing: 24) {
                    // Фильтр по сложности
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Сложность")
                            .font(.headline)
                            .foregroundColor(AskezaTheme.textColor)
                        
                        VStack(spacing: 12) {
                            Text("Выберите уровень сложности:")
                                .font(.caption)
                                .foregroundColor(AskezaTheme.secondaryTextColor)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            HStack(spacing: 16) {
                                difficultyButton(1, label: "★")
                                difficultyButton(2, label: "★★")
                                difficultyButton(3, label: "★★★")
                            }
                            HStack(spacing: 16) {
                                difficultyButton(4, label: "★★★★")
                                difficultyButton(5, label: "★★★★★")
                            }
                        }
                    }
                    .padding()
                    .background(AskezaTheme.buttonBackground)
                    .cornerRadius(16)
                    
                    // Фильтр по длительности
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Длительность")
                            .font(.headline)
                            .foregroundColor(AskezaTheme.textColor)
                        
                        VStack(spacing: 12) {
                            Text("Выберите продолжительность практики:")
                                .font(.caption)
                                .foregroundColor(AskezaTheme.secondaryTextColor)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            HStack(spacing: 16) {
                                durationButton(7, label: "7 дней")
                                durationButton(14, label: "14 дней")
                                durationButton(30, label: "30 дней")
                                durationButton(0, label: "∞")
                            }
                        }
                    }
                    .padding()
                    .background(AskezaTheme.buttonBackground)
                    .cornerRadius(16)
                    
                    Spacer()
                }
                .padding()
            }
            .navigationTitle("Фильтры")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Сбросить") {
                        onReset()
                    }
                    .foregroundColor(AskezaTheme.accentColor)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Готово") {
                        dismiss()
                    }
                    .foregroundColor(AskezaTheme.accentColor)
                }
            }
        }
    }
    
    private func difficultyButton(_ level: Int, label: String) -> some View {
        Button(action: {
            if selectedDifficulty == level {
                selectedDifficulty = nil
            } else {
                selectedDifficulty = level
            }
        }) {
            Text(label)
                .font(.subheadline)
                .foregroundColor(selectedDifficulty == level ? .white : AskezaTheme.textColor)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(selectedDifficulty == level ? AskezaTheme.accentColor : Color.gray.opacity(0.2))
                )
        }
    }
    
    private func durationButton(_ days: Int, label: String) -> some View {
        Button(action: {
            if selectedDuration == days {
                selectedDuration = nil
            } else {
                selectedDuration = days
            }
        }) {
            Text(label)
                .font(.subheadline)
                .foregroundColor(selectedDuration == days ? .white : AskezaTheme.textColor)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(selectedDuration == days ? AskezaTheme.accentColor : Color.gray.opacity(0.2))
                )
        }
    }
}

struct CoursePathCardView: View {
    let course: CoursePath
    let templateStore: PracticeTemplateStore
    
    @State private var showingCourseDetail = false
    
    var body: some View {
        Button(action: {
            print("CoursePathCardView: Нажата карточка пути: \(course.title)")
            showingCourseDetail = true
        }) {
            VStack(alignment: .leading, spacing: 12) {
                // Заголовок и категория
                HStack {
                    Image(systemName: course.category.systemImage)
                        .foregroundColor(course.category.mainColor)
                    
                    Text(course.title)
                        .font(.headline)
                        .foregroundColor(AskezaTheme.textColor)
                        .multilineTextAlignment(.leading)
                        .lineLimit(1) // Ограничиваем в одну строку
                }
                
                // Описание
                Text(course.courseDescription)
                    .font(.subheadline)
                    .foregroundColor(AskezaTheme.secondaryTextColor)
                    .lineLimit(2)
                
                // Шаги (визуализация)
                HStack(spacing: 4) {
                    ForEach(0..<course.templateIDs.count, id: \.self) { index in
                        let templateID = course.templateIDs[index]
                        let status = templateStore.getStatus(forTemplateID: templateID)
                        
                        ZStack {
                            Circle()
                                .fill(status.color)
                                .frame(width: 24, height: 24)
                            
                            Image(systemName: status.icon)
                                .font(.system(size: 12))
                                .foregroundColor(.white)
                        }
                        
                        if index < course.templateIDs.count - 1 {
                            Rectangle()
                                .fill(Color.gray.opacity(0.3))
                                .frame(height: 2)
                        }
                    }
                }
                .padding(.vertical, 8)
                
                // Сложность
                HStack {
                    Text("Сложность:")
                        .font(.caption)
                        .foregroundColor(AskezaTheme.secondaryTextColor)
                    
                    HStack(spacing: 2) {
                        ForEach(1...5, id: \.self) { i in
                            Image(systemName: i <= course.difficulty ? "star.fill" : "star")
                                .font(.system(size: 8))
                                .foregroundColor(i <= course.difficulty ? .yellow : Color.gray.opacity(0.3))
                        }
                    }
                }
            }
            .padding()
            .background(AskezaTheme.buttonBackground)
            .cornerRadius(16)
        }
        .buttonStyle(PlainButtonStyle()) // Добавляем для надежного срабатывания
        .sheet(isPresented: $showingCourseDetail) {
            CourseDetailView(course: course, templateStore: templateStore)
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

struct CourseDetailView: View {
    let course: CoursePath
    let templateStore: PracticeTemplateStore
    
    @Environment(\.dismiss) private var dismiss
    @State private var selectedTemplate: PracticeTemplate?
    @State private var showingTemplateDetail = false
    
    var body: some View {
        NavigationView {
            ZStack {
                AskezaTheme.backgroundColor
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        // Заголовок
                        VStack(alignment: .center, spacing: 8) {
                            Text(course.title)
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(AskezaTheme.textColor)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                            
                            HStack {
                                Image(systemName: course.category.systemImage)
                                    .foregroundColor(course.category.mainColor)
                                
                                Text(course.category.rawValue)
                                    .foregroundColor(AskezaTheme.secondaryTextColor)
                            }
                            
                            // Сложность
                            HStack(spacing: 4) {
                                Text("Сложность:")
                                    .font(.caption)
                                    .foregroundColor(AskezaTheme.secondaryTextColor)
                                
                                ForEach(1...5, id: \.self) { i in
                                    Image(systemName: i <= course.difficulty ? "star.fill" : "star")
                                        .font(.system(size: 10))
                                        .foregroundColor(i <= course.difficulty ? .yellow : Color.gray.opacity(0.3))
                                }
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(AskezaTheme.buttonBackground)
                        .cornerRadius(16)
                        .padding(.horizontal)
                        
                        // Описание
                        VStack(alignment: .leading, spacing: 8) {
                            Text("О пути")
                                .font(.headline)
                                .foregroundColor(AskezaTheme.textColor)
                            
                            Text(course.courseDescription)
                                .foregroundColor(AskezaTheme.secondaryTextColor)
                        }
                        .padding()
                        .background(AskezaTheme.buttonBackground)
                        .cornerRadius(16)
                        .padding(.horizontal)
                        
                        // Шаги
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Шаги")
                                .font(.headline)
                                .foregroundColor(AskezaTheme.textColor)
                                .padding(.horizontal)
                            
                            VStack(spacing: 16) {
                                ForEach(course.templateIDs, id: \.self) { templateID in
                                    if let template = templateStore.getTemplate(byID: templateID) {
                                        CourseStepView(
                                            template: template,
                                            progress: templateStore.getProgress(forTemplateID: templateID),
                                            onTap: {
                                                selectedTemplate = template
                                                showingTemplateDetail = true
                                            }
                                        )
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
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
                        Text("Путь")
                            .font(.headline)
                            .foregroundColor(AskezaTheme.textColor)
                    }
                }
                .sheet(isPresented: $showingTemplateDetail) {
                    if let template = selectedTemplate {
                        TemplateDetailView(
                            template: template,
                            templateStore: templateStore
                        )
                        .onAppear {
                            // При появлении sheet, загружаем данные
                            print("🔍 CourseDetailView - onAppear вызван для sheet с шаблоном: \(template.title)")
                            
                            // Предварительно загружаем данные шаблона
                            templateStore.preloadTemplateData(for: template.templateId)
                            
                            // При отображении digital-detox-7 добавляем дополнительную обработку
                            if template.templateId == "digital-detox-7" || template.title.contains("цифрового детокса") {
                                print("⚠️ CourseDetailView - Обнаружен особый шаблон: цифровой детокс")
                                
                                // Дополнительно загружаем данные с задержкой
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                    print("🔄 CourseDetailView - Повторная загрузка данных для цифрового детокса")
                                    templateStore.preloadTemplateData(for: "digital-detox-7")
                                }
                            }
                        }
                    }
                }
            }
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

struct CourseStepView: View {
    let template: PracticeTemplate
    let progress: TemplateProgress?
    let onTap: () -> Void
    
    var status: TemplateStatus {
        if let progress = progress {
            return progress.status(templateDuration: template.duration)
        }
        return .notStarted
    }
    
    var body: some View {
        Button(action: {
            // Предварительно загружаем данные шаблона
            print("🔍 CourseStepView - Выбран шаблон: \(template.title), ID: \(template.templateId)")
            
            // Проверяем, нужна ли специальная обработка для digital-detox-7
            if template.templateId == "digital-detox-7" || template.title.contains("цифрового детокса") {
                print("⚠️ CourseStepView - Обнаружен особый шаблон: цифровой детокс")
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    onTap()
                }
            } else {
                onTap()
            }
        }) {
            HStack(spacing: 16) {
                // Статус индикатор
                ZStack {
                    Circle()
                        .fill(status.color.opacity(0.2))
                        .frame(width: 40, height: 40)
                    
                    Image(systemName: status.icon)
                        .font(.system(size: 20))
                        .foregroundColor(status.color)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(template.title)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(AskezaTheme.textColor)
                        .lineLimit(1)
                    
                    Text("\(template.duration) дней • Сложность: \(difficultyText(template.difficulty))")
                        .font(.caption)
                        .foregroundColor(AskezaTheme.secondaryTextColor)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(AskezaTheme.secondaryTextColor)
            }
            .padding()
            .background(AskezaTheme.buttonBackground)
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
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
}

struct WorkshopOnboardingView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var currentPage = 0
    
    let pages = [
        OnboardingPage(
            title: "Добро пожаловать в Мастерскую!",
            description: "Здесь вы найдете кураторские шаблоны практик для самосовершенствования.",
            imageName: "sparkles"
        ),
        OnboardingPage(
            title: "Отслеживайте прогресс",
            description: "Видите статус каждой практики, получайте награды за достижения и следите за серией.",
            imageName: "flame.fill"
        ),
        OnboardingPage(
            title: "Проходите Пути",
            description: "Последовательные практики для комплексного развития в выбранной области.",
            imageName: "map"
        )
    ]
    
    var body: some View {
        ZStack {
            AskezaTheme.backgroundColor
                .ignoresSafeArea()
            
            VStack {
                // Индикатор прогресса
                HStack(spacing: 8) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        Circle()
                            .fill(currentPage == index ? AskezaTheme.accentColor : Color.gray.opacity(0.3))
                            .frame(width: 8, height: 8)
                    }
                }
                .padding(.top, 20)
                
                // Основной контент
                TabView(selection: $currentPage) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        onboardingView(for: pages[index])
                            .tag(index)
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                
                // Кнопки
                HStack {
                    if currentPage > 0 {
                        Button("Назад") {
                            withAnimation {
                                currentPage -= 1
                            }
                        }
                        .foregroundColor(AskezaTheme.accentColor)
                    } else {
                        Spacer()
                    }
                    
                    Spacer()
                    
                    if currentPage < pages.count - 1 {
                        Button("Далее") {
                            withAnimation {
                                currentPage += 1
                            }
                        }
                        .foregroundColor(AskezaTheme.accentColor)
                    } else {
                        Button("Начать") {
                            dismiss()
                        }
                        .foregroundColor(AskezaTheme.accentColor)
                        .fontWeight(.bold)
                    }
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 40)
            }
        }
    }
    
    private func onboardingView(for page: OnboardingPage) -> some View {
        VStack(spacing: 30) {
            Image(systemName: page.imageName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 120, height: 120)
                .foregroundColor(AskezaTheme.accentColor)
                .padding(.top, 60)
            
            Text(page.title)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(AskezaTheme.textColor)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Text(page.description)
                .font(.body)
                .foregroundColor(AskezaTheme.secondaryTextColor)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            Spacer()
        }
    }
}

struct OnboardingPage {
    let title: String
    let description: String
    let imageName: String
}

// Отдельный компонент для обертки карточки рекомендации
struct RecommendationCardWrapper: View {
    let template: PracticeTemplate
    let templateStore: PracticeTemplateStore
    
    @State private var showingTemplateDetail = false
    @State private var showingShareSheet = false
    @State private var shareText: String = ""
    @State private var errorMessage: String = ""
    @State private var showError = false
    
    var body: some View {
        Button(action: {
            print("RecommendationCardWrapper: Нажата карточка рекомендации: \(template.title)")
            showingTemplateDetail = true
        }) {
            ZStack {
                // Фон карточки с градиентом категории
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(
                                colors: [
                                    template.category.mainColor.opacity(0.1),
                                    AskezaTheme.buttonBackground
                                ]
                            ),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                
                VStack(alignment: .leading, spacing: 12) {
                    // Заголовок и категория
                    HStack {
                        // Иконка категории
                        Image(systemName: template.category.systemImage)
                            .font(.system(size: 24))
                            .foregroundColor(template.category.mainColor)
                            .frame(width: 36, height: 36)
                            .background(template.category.mainColor.opacity(0.2))
                            .cornerRadius(8)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            // Заголовок
                            Text(template.title)
                                .font(.headline)
                                .foregroundColor(AskezaTheme.textColor)
                                .lineLimit(1)
                            
                            // Категория и дни
                            HStack {
                                Text(template.category.rawValue)
                                    .font(.caption)
                                    .foregroundColor(AskezaTheme.secondaryTextColor)
                                
                                Text("•")
                                    .foregroundColor(AskezaTheme.secondaryTextColor)
                                
                                Text(durationText(template.duration))
                                    .font(.caption)
                                    .foregroundColor(AskezaTheme.secondaryTextColor)
                            }
                        }
                        
                        Spacer()
                        
                        // Сложность - звезды
                        HStack(spacing: 2) {
                            ForEach(1...5, id: \.self) { i in
                                Image(systemName: i <= template.difficulty ? "star.fill" : "star")
                                    .font(.system(size: 10))
                                    .foregroundColor(i <= template.difficulty ? .yellow : Color.gray.opacity(0.3))
                            }
                        }
                    }
                    
                    // Цитата
                    Text("\"\(template.quote)\"")
                        .font(.system(size: 14, weight: .light, design: .serif))
                        .italic()
                        .lineLimit(2)
                        .foregroundColor(AskezaTheme.intentColor)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 6)
                        .frame(maxWidth: .infinity)
                        .background(AskezaTheme.buttonBackground.opacity(0.5))
                        .cornerRadius(8)
                    
                    // Прогресс (если есть)
                    if let progress = templateStore.getProgress(forTemplateID: template.id) {
                        progressView(progress)
                    }
                    
                    // Кнопки действий
                    HStack {
                        Button(action: {
                            print("RecommendationCardWrapper: Нажата кнопка 'Начать' для шаблона: \(template.title)")
                            if let askeza = templateStore.startTemplate(template) {
                                // Отправляем уведомление для добавления аскезы через асинхронный вызов
                                Task {
                                    // Используем NotificationCenter для передачи аскезы
                                    // Это можно вызывать из любого контекста, так как NotificationCenter потокобезопасен
                                    NotificationCenter.default.post(
                                        name: Notification.Name("AddAskezaNotification"),
                                        object: askeza
                                    )
                                    print("RecommendationCardWrapper: Отправлено уведомление о создании аскезы: \(askeza.title)")
                                }
                            } else {
                                // Показываем ошибку, что шаблон уже активен
                                errorMessage = "Этот шаблон уже активен. Завершите текущую аскезу, прежде чем начать заново."
                                showError = true
                            }
                        }) {
                            Text(startButtonText)
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.white)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(AskezaTheme.accentColor)
                                .cornerRadius(8)
                        }
                        .buttonStyle(PlainButtonStyle())
                        .alert("Внимание", isPresented: $showError) {
                            Button("ОК", role: .cancel) {}
                        } message: {
                            Text(errorMessage)
                        }
                        
                        Spacer()
                        
                        Button(action: {
                            print("RecommendationCardWrapper: Нажата кнопка 'Поделиться' для шаблона: \(template.title)")
                            shareTemplate(template)
                        }) {
                            Image(systemName: "square.and.arrow.up")
                                .font(.system(size: 14))
                                .foregroundColor(AskezaTheme.accentColor)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(8)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding()
            }
            .shadow(color: Color.black.opacity(0.1), radius: 3, x: 0, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
        .sheet(isPresented: $showingTemplateDetail) {
            TemplateDetailView(
                template: template,
                templateStore: templateStore
            )
        }
        .sheet(isPresented: $showingShareSheet) {
            ShareSheet(activityItems: [shareText])
        }
    }
    
    private var startButtonText: String {
        let status = templateStore.getStatus(forTemplateID: template.id)
        switch status {
        case .notStarted: return "Начать"
        case .inProgress: return "Продолжить"
        case .completed: return "Повторить"
        case .mastered: return "Начать снова"
        }
    }
    
    private func progressView(_ progress: TemplateProgress) -> some View {
        let status = progress.status(templateDuration: template.duration)
        let progressPercent = calculateProgressPercentage(progress)
        
        return VStack(alignment: .leading, spacing: 4) {
            HStack {
                // Статус с иконкой
                Label(
                    title: { Text(status == .inProgress ? "Активная" : status.rawValue).font(.caption) },
                    icon: { Image(systemName: status.icon).font(.system(size: 10)) }
                )
                .foregroundColor(status.color)
                
                Spacer()
                
                // Процент
                if status == .inProgress {
                    Text("\(Int(progressPercent * 100))%")
                        .font(.caption.bold())
                        .foregroundColor(status.color)
                }
            }
            
            // Прогресс бар для активных шаблонов
            if status == .inProgress {
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(height: 6)
                            .cornerRadius(3)
                        
                        Rectangle()
                            .fill(status.color)
                            .frame(width: geometry.size.width * progressPercent, height: 6)
                            .cornerRadius(3)
                    }
                }
                .frame(height: 6)
                
                // Показываем дни и серию
                HStack {
                    Text("День \(progress.daysCompleted)\(template.duration > 0 ? " из \(template.duration)" : "")")
                        .font(.caption)
                        .foregroundColor(AskezaTheme.secondaryTextColor)
                    
                    Spacer()
                    
                    if progress.currentStreak > 0 {
                        HStack(spacing: 2) {
                            Text("Серия: \(progress.currentStreak)")
                                .font(.caption)
                                .foregroundColor(.orange)
                            
                            Image(systemName: "flame.fill")
                                .font(.system(size: 10))
                                .foregroundColor(.orange)
                        }
                    }
                }
            }
        }
    }
    
    private func calculateProgressPercentage(_ progress: TemplateProgress) -> Double {
        guard template.duration > 0 else { return 0 }
        return min(1.0, Double(progress.daysCompleted) / Double(template.duration))
    }
    
    private func shareTemplate(_ template: PracticeTemplate) {
        // Ограничиваем длину цитаты для шаринга
        let quote = template.quote.count > 50 ? template.quote.prefix(50) + "..." : template.quote
        
        shareText = """
        🧘‍♂️ Аскеза: \(template.title)
        📝 Категория: \(template.category.rawValue)
        ⏳ Длительность: \(durationText(template.duration))
        ✨ Цитата: "\(quote)"
        
        #Askeza #\(template.category.rawValue) #СамоРазвитие
        """
        
        print("RecommendationCardWrapper: Текст для шаринга подготовлен")
        showingShareSheet = true
        print("RecommendationCardWrapper: Открываем sheet для шаринга")
    }
    
    private func durationText(_ days: Int) -> String {
        if days == 0 {
            return "Пожизненно"
        } else {
            return "\(days) дней"
        }
    }
}

#Preview {
    WorkshopV2View()
}