import SwiftUI
import SwiftData

struct WorkshopV2View: View {
    @ObservedObject private var templateStore = PracticeTemplateStore.shared
    
    @State private var searchText: String = ""
    @State private var selectedCategory: AskezaCategory? = nil
    @State private var selectedDifficulty: Int? = nil
    @State private var selectedDuration: Int? = nil
    @State private var showingFilters = false
    @State private var showingOnboarding = false
    
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
                            recommendationsSection
                            
                            // Курсы-пути
                            pathsSection
                            
                            // Галерея шаблонов
                            WorkshopGridView(
                                templateStore: templateStore,
                                searchText: $searchText,
                                selectedCategory: $selectedCategory,
                                selectedDifficulty: $selectedDifficulty,
                                selectedDuration: $selectedDuration
                            )
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
                        showingFilters = true
                    }) {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                            .foregroundColor(AskezaTheme.accentColor)
                    }
                }
            }
            .sheet(isPresented: $showingFilters) {
                FilterSheetView(
                    selectedDifficulty: $selectedDifficulty,
                    selectedDuration: $selectedDuration,
                    onReset: resetFilters
                )
            }
            .sheet(isPresented: $showingOnboarding) {
                WorkshopOnboardingView()
            }
            .onAppear {
                // Показываем онбординг при первом запуске
                if !UserDefaults.standard.bool(forKey: "workshopOnboardingShown") {
                    showingOnboarding = true
                    UserDefaults.standard.set(true, forKey: "workshopOnboardingShown")
                }
            }
        }
    }
    
    // MARK: - Sections
    
    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(AskezaTheme.secondaryTextColor)
            
            TextField("Поиск практик...", text: $searchText)
                .foregroundColor(AskezaTheme.textColor)
            
            if !searchText.isEmpty {
                Button(action: {
                    searchText = ""
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
        let recommendations = templateStore.getRecommendedTemplates(limit: 3)
        
        return Group {
            if !recommendations.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    sectionHeader("Рекомендуемые для вас")
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 16) {
                            ForEach(recommendations) { template in
                                TemplateCardView(
                                    template: template,
                                    progress: templateStore.getProgress(forTemplateID: template.id),
                                    onStart: {
                                        // TODO: Navigate to detail view
                                    },
                                    onShare: {
                                        // TODO: Share sheet
                                    }
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
    
    private var pathsSection: some View {
        let courses = templateStore.courses
        
        return Group {
            if !courses.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    sectionHeader("Пути развития")
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 16) {
                            ForEach(courses) { course in
                                CoursePathCardView(
                                    course: course,
                                    templateStore: templateStore
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
            if selectedCategory == category {
                selectedCategory = nil
            } else {
                selectedCategory = category
            }
        }) {
            HStack(spacing: 6) {
                if let category = category {
                    Image(systemName: category.systemImage)
                        .font(.system(size: 14))
                        .foregroundColor(selectedCategory == category ? .white : category.mainColor)
                }
                
                Text(text)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(selectedCategory == category ? .white : AskezaTheme.textColor)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(selectedCategory == category ? AskezaTheme.accentColor : AskezaTheme.buttonBackground)
            )
        }
    }
    
    private func resetFilters() {
        selectedCategory = nil
        selectedDifficulty = nil
        selectedDuration = nil
        searchText = ""
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
                        
                        HStack(spacing: 16) {
                            difficultyButton(1, label: "Легкий")
                            difficultyButton(2, label: "Средний")
                            difficultyButton(3, label: "Сложный")
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
                        
                        HStack(spacing: 16) {
                            durationButton(7, label: "7 дней")
                            durationButton(14, label: "14 дней")
                            durationButton(30, label: "30 дней")
                            durationButton(0, label: "∞")
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
                }
                
                // Описание
                Text(course.description)
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
                    
                    ForEach(1...course.difficulty, id: \.self) { _ in
                        Circle()
                            .fill(difficultyColor(level: course.difficulty))
                            .frame(width: 8, height: 8)
                    }
                }
            }
            .padding()
            .background(AskezaTheme.buttonBackground)
            .cornerRadius(16)
        }
        .sheet(isPresented: $showingCourseDetail) {
            CourseDetailView(course: course, templateStore: templateStore)
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
                                ForEach(1...3, id: \.self) { i in
                                    Circle()
                                        .fill(i <= course.difficulty ? difficultyColor(level: course.difficulty) : Color.gray.opacity(0.3))
                                        .frame(width: 12, height: 12)
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
                            
                            Text(course.description)
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
                    }
                }
            }
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
        Button(action: onTap) {
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
                    
                    Text("\(template.duration) дней • \(difficultyText(template.difficulty))")
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

#Preview {
    WorkshopV2View()
}