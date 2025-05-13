import SwiftUI
import SwiftData

class WorkshopStateManager: ObservableObject {
    @Published var searchText: String = ""
    @Published var selectedCategory: AskezaCategory? = nil
    @Published var selectedDifficulty: Int? = nil
    @Published var selectedDuration: Int? = nil
    @Published var showingFilters = false
    @Published var showingOnboarding = false
    
    let templateStore = PracticeTemplateStore.shared
    var askezaViewModel: AskezaViewModel? = nil
    
    var observerToken: NSObjectProtocol? = nil
    
    func resetFilters() {
        selectedCategory = nil
        selectedDifficulty = nil
        selectedDuration = nil
        searchText = ""
    }
    
    func setupObservers() {
        // Создаем только один обработчик обновления данных
        observerToken = NotificationCenter.default.addObserver(
            forName: .refreshWorkshopData,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            guard let self = self else { return }
            
            // Если уведомление содержит аскезу, добавляем её в модель
            if let askeza = notification.object as? Askeza, 
               let askezaViewModel = self.askezaViewModel {
                // Используем DispatchQueue.main.async для вызова @MainActor-isolated метода
                DispatchQueue.main.async {
                    askezaViewModel.addAskezaToActive(askeza)
                }
            }
            
            // Обновляем UI немедленно
            self.objectWillChange.send()
        }
    }
    
    deinit {
        // Корректно убираем наблюдателя при удалении объекта
        if let token = observerToken {
            NotificationCenter.default.removeObserver(token)
        }
    }
}

// Расширяем Notification.Name для уведомлений мастерской
extension Notification.Name {
    static let refreshWorkshopData = Notification.Name("RefreshWorkshopDataNotification")
}

struct WorkshopView: View {
    @StateObject private var stateManager = WorkshopStateManager()
    @EnvironmentObject var askezaViewModel: AskezaViewModel
    
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
                    
                    // Основной контент - галерея шаблонов
                    ScrollView {
                        LazyVStack(spacing: 24) {
                            // Пути развития
                            pathsSection
                            
                            // Галерея шаблонов
                            TemplateGridView(
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
                // Устанавливаем ссылку на viewModel
                stateManager.askezaViewModel = askezaViewModel
                
                // Настраиваем обработчики
                stateManager.setupObservers()
                
                // Гарантируем, что шаблоны добавлены в хранилище только при первом запуске
                if !UserDefaults.standard.bool(forKey: "templatesAdded") {
                    AdditionalTemplates.addTemplates(to: stateManager.templateStore)
                    UserDefaults.standard.set(true, forKey: "templatesAdded")
                }
                
                // Показываем онбординг при первом запуске
                if !UserDefaults.standard.bool(forKey: "workshopOnboardingShown") {
                    stateManager.showingOnboarding = true
                    UserDefaults.standard.set(true, forKey: "workshopOnboardingShown")
                }
            }
            .onDisappear {
                // Корректно удаляем наблюдателя при исчезновении экрана
                if let token = stateManager.observerToken {
                    NotificationCenter.default.removeObserver(token)
                    stateManager.observerToken = nil
                }
            }
        }
    }
    
    // MARK: - UI Components
    
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
    
    private var pathsSection: some View {
        let courses = stateManager.templateStore.courses
        
        return Group {
            if !courses.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Пути развития")
                        .font(.headline)
                        .foregroundColor(AskezaTheme.textColor)
                        .padding(.horizontal)
                    
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
    
    // MARK: - Helper Functions
    
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

struct CoursePathCardView: View {
    let course: CoursePath
    let templateStore: PracticeTemplateStore
    
    @State private var showingCourseDetail = false
    
    var body: some View {
        Button(action: {
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
                        .lineLimit(1)
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
        .buttonStyle(PlainButtonStyle())
        .sheet(isPresented: $showingCourseDetail) {
            CourseDetailView(course: course, templateStore: templateStore)
        }
    }
}

#Preview {
    WorkshopView()
} 