import SwiftUI

struct WorkshopGalleryView: View {
    @ObservedObject private var viewModel: AskezaViewModel
    @ObservedObject private var templateStore = PracticeTemplateStore.shared
    
    @State private var selectedCategory: AskezaCategory?
    @State private var selectedDifficulty: Int?
    @State private var selectedDuration: Int?
    @State private var searchText: String = ""
    @State private var showingTemplateDetail = false
    @State private var selectedTemplate: PracticeTemplate?
    @State private var showingShareSheet = false
    
    @State private var shareText: String = ""
    @State private var showError = false
    @State private var errorMessage: String = ""
    
    init(viewModel: AskezaViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                AskezaTheme.backgroundColor
                    .ignoresSafeArea()
                
                VStack(spacing: 20) {
                    // Фильтры категорий
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            categoryFilterButton(nil, text: "Все")
                            
                            ForEach(AskezaCategory.allCases.filter { $0 != .custom }, id: \.self) { category in
                                categoryFilterButton(category, text: category.rawValue)
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    // Фильтры сложности и длительности
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 16) {
                            // Сложность
                            HStack {
                                Text("Сложность:")
                                    .font(.caption)
                                    .foregroundColor(AskezaTheme.secondaryTextColor)
                                
                                ForEach([1, 2, 3], id: \.self) { level in
                                    difficultyFilterButton(level)
                                }
                            }
                            
                            Divider().frame(height: 20)
                            
                            // Длительность
                            HStack {
                                Text("Дни:")
                                    .font(.caption)
                                    .foregroundColor(AskezaTheme.secondaryTextColor)
                                
                                ForEach([7, 14, 30], id: \.self) { days in
                                    durationFilterButton(days)
                                }
                                
                                durationFilterButton(0, label: "∞")
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    // Список шаблонов
                    templatesList
                }
            }
            .navigationTitle("Мастерская")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showingTemplateDetail) {
                if let template = selectedTemplate {
                    templateDetailView(template)
                }
            }
            .sheet(isPresented: $showingShareSheet) {
                ShareSheet(activityItems: [shareText])
            }
        }
    }
    
    // MARK: - Template List
    
    private var templatesList: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                // Раздел "Рекомендуемые" (Featured)
                featuredSection
                
                // Раздел всех шаблонов, с учетом фильтрации
                filteredTemplatesSection
            }
            .padding()
        }
    }
    
    private var featuredSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Рекомендуемые")
                .font(.headline)
                .foregroundColor(AskezaTheme.textColor)
                .padding(.horizontal)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(templateStore.templates.prefix(3)) { template in
                        TemplateCardView(
                            template: template,
                            progress: templateStore.getProgress(forTemplateID: template.id),
                            onStart: {
                                selectedTemplate = template
                                showingTemplateDetail = true
                            },
                            onShare: {
                                shareTemplate(template)
                            }
                        )
                        .frame(width: 300)
                    }
                }
                .padding(.horizontal)
            }
        }
    }
    
    private var filteredTemplatesSection: some View {
        let filtered = filteredTemplates()
        
        return VStack(alignment: .leading, spacing: 8) {
            Text(sectionTitle)
                .font(.headline)
                .foregroundColor(AskezaTheme.textColor)
                .padding(.horizontal)
            
            if filtered.isEmpty {
                emptyResultsView
            } else {
                ForEach(filtered) { template in
                    TemplateCardView(
                        template: template,
                        progress: templateStore.getProgress(forTemplateID: template.id),
                        onStart: {
                            selectedTemplate = template
                            showingTemplateDetail = true
                        },
                        onShare: {
                            shareTemplate(template)
                        }
                    )
                    .padding(.horizontal)
                }
            }
        }
    }
    
    private var emptyResultsView: some View {
        VStack(spacing: 16) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 50))
                .foregroundColor(AskezaTheme.secondaryTextColor)
            
            Text("Нет шаблонов, соответствующих фильтрам")
                .font(AskezaTheme.bodyFont)
                .foregroundColor(AskezaTheme.secondaryTextColor)
                .multilineTextAlignment(.center)
            
            Button(action: clearFilters) {
                Text("Сбросить фильтры")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(AskezaTheme.accentColor)
                    .cornerRadius(8)
            }
        }
        .padding()
        .background(AskezaTheme.buttonBackground)
        .cornerRadius(16)
        .padding(.horizontal)
    }
    
    // MARK: - Detail View
    
    private func templateDetailView(_ template: PracticeTemplate) -> some View {
        NavigationView {
            ZStack {
                AskezaTheme.backgroundColor
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        // Заголовок и статус
                        VStack(alignment: .center, spacing: 8) {
                            Text(template.title)
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(AskezaTheme.textColor)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                            
                            HStack {
                                Image(systemName: template.category.systemImage)
                                    .foregroundColor(template.category.mainColor)
                                
                                Text(template.category.rawValue)
                                    .foregroundColor(AskezaTheme.secondaryTextColor)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        
                        // Цитата
                        Text("\"\(template.quote)\"")
                            .font(.system(size: 18, weight: .light, design: .serif))
                            .italic()
                            .foregroundColor(AskezaTheme.intentColor)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                            .frame(maxWidth: .infinity)
                        
                        // Детали
                        VStack(alignment: .leading, spacing: 16) {
                            detailRow(title: "Длительность:", value: durationText(template.duration))
                            detailRow(title: "Сложность:", value: difficultyText(template.difficulty))
                            
                            Text("Описание")
                                .font(.headline)
                                .foregroundColor(AskezaTheme.textColor)
                            
                            Text(template.practiceDescription)
                                .foregroundColor(AskezaTheme.secondaryTextColor)
                                .fixedSize(horizontal: false, vertical: true)
                            
                            Text("Цель")
                                .font(.headline)
                                .foregroundColor(AskezaTheme.textColor)
                            
                            Text(template.intention)
                                .foregroundColor(AskezaTheme.secondaryTextColor)
                                .fixedSize(horizontal: false, vertical: true)
                            
                            // Прогресс, если есть
                            if let progress = templateStore.getProgress(forTemplateID: template.id) {
                                Text("Ваш прогресс")
                                    .font(.headline)
                                    .foregroundColor(AskezaTheme.textColor)
                                
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Статус: \(templateStore.getStatus(forTemplateID: template.id).rawValue)")
                                        .foregroundColor(AskezaTheme.secondaryTextColor)
                                    
                                    Text("Дней завершено: \(progress.daysCompleted)")
                                        .foregroundColor(AskezaTheme.secondaryTextColor)
                                    
                                    Text("Текущая серия: \(progress.currentStreak) дней")
                                        .foregroundColor(AskezaTheme.secondaryTextColor)
                                    
                                    Text("Лучшая серия: \(progress.bestStreak) дней")
                                        .foregroundColor(AskezaTheme.secondaryTextColor)
                                    
                                    Text("Завершено раз: \(progress.timesCompleted)")
                                        .foregroundColor(AskezaTheme.secondaryTextColor)
                                }
                            }
                        }
                        .padding()
                        .background(AskezaTheme.buttonBackground)
                        .cornerRadius(16)
                        .padding(.horizontal)
                        
                        // Кнопки действий
                        HStack {
                            Button(action: {
                                print("WorkshopGalleryView: Нажата кнопка 'Начать практику'")
                                if let askeza = templateStore.startTemplate(template) {
                                    print("WorkshopGalleryView: Создана аскеза: \(askeza.title)")
                                    
                                    // Асинхронно добавляем аскезу в viewModel через Task
                                    Task { @MainActor in
                                        viewModel.addAskeza(askeza)
                                        print("WorkshopGalleryView: Аскеза добавлена в viewModel")
                                    }
                                    
                                    showingTemplateDetail = false
                                } else {
                                    // Показываем ошибку, что шаблон уже активен
                                    errorMessage = "Этот шаблон уже активен. Завершите текущую аскезу, прежде чем начать заново."
                                    showError = true
                                }
                            }) {
                                Text("Начать практику")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(AskezaTheme.accentColor)
                                    .cornerRadius(12)
                            }
                            .buttonStyle(PlainButtonStyle())
                            .alert("Внимание", isPresented: $showError) {
                                Button("ОК", role: .cancel) {}
                            } message: {
                                Text(errorMessage)
                            }
                            
                            Button(action: {
                                print("WorkshopGalleryView: Нажата кнопка 'Поделиться'")
                                shareTemplate(template)
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
                    .padding(.vertical)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Закрыть") {
                        showingTemplateDetail = false
                    }
                    .foregroundColor(AskezaTheme.accentColor)
                }
            }
        }
    }
    
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
    
    // MARK: - Filter Buttons
    
    private func categoryFilterButton(_ category: AskezaCategory?, text: String) -> some View {
        Button(action: {
            if selectedCategory == category {
                selectedCategory = nil
            } else {
                selectedCategory = category
            }
        }) {
            Text(text)
                .font(.subheadline)
                .foregroundColor(selectedCategory == category ? .white : AskezaTheme.textColor)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(selectedCategory == category ? AskezaTheme.accentColor : AskezaTheme.buttonBackground)
                )
        }
    }
    
    private func difficultyFilterButton(_ level: Int) -> some View {
        Button(action: {
            if selectedDifficulty == level {
                selectedDifficulty = nil
            } else {
                selectedDifficulty = level
            }
        }) {
            let isSelected = selectedDifficulty == level
            
            HStack(spacing: 4) {
                ForEach(1...level, id: \.self) { _ in
                    Circle()
                        .fill(difficultyColor(level: level))
                        .frame(width: 8, height: 8)
                }
            }
            .padding(6)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? difficultyColor(level: level) : Color.clear, lineWidth: 2)
            )
        }
    }
    
    private func durationFilterButton(_ days: Int, label: String? = nil) -> some View {
        Button(action: {
            if selectedDuration == days {
                selectedDuration = nil
            } else {
                selectedDuration = days
            }
        }) {
            Text(label ?? "\(days)")
                .font(.caption)
                .foregroundColor(selectedDuration == days ? .white : AskezaTheme.textColor)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(selectedDuration == days ? AskezaTheme.accentColor : AskezaTheme.buttonBackground)
                )
        }
    }
    
    // MARK: - Helper Methods
    
    private func filteredTemplates() -> [PracticeTemplate] {
        return templateStore.templates.filter { template in
            let categoryMatch = selectedCategory == nil || template.category == selectedCategory
            let difficultyMatch = selectedDifficulty == nil || template.difficulty == selectedDifficulty
            let durationMatch = selectedDuration == nil || template.duration == selectedDuration
            
            return categoryMatch && difficultyMatch && durationMatch
        }
    }
    
    private func shareTemplate(_ template: PracticeTemplate) {
        print("WorkshopGalleryView: Подготовка текста для шаринга")
        shareText = """
        🧘‍♂️ Аскеза: \(template.title)
        📝 Категория: \(template.category.rawValue)
        ⏳ Длительность: \(durationText(template.duration))
        ✨ Цитата: "\(template.quote)"
        
        #Askeza #\(template.category.rawValue) #СамоРазвитие
        """
        
        print("WorkshopGalleryView: Текст для шаринга подготовлен: \(shareText)")
        print("WorkshopGalleryView: Открываем sheet для шаринга (текущее значение showingShareSheet: \(showingShareSheet))")
        // Принудительное обновление для гарантированного открытия
        DispatchQueue.main.async {
            showingShareSheet = true
            print("WorkshopGalleryView: Значение showingShareSheet установлено: \(showingShareSheet)")
        }
    }
    
    private func clearFilters() {
        selectedCategory = nil
        selectedDifficulty = nil
        selectedDuration = nil
    }
    
    private var sectionTitle: String {
        var components: [String] = []
        
        if let category = selectedCategory {
            components.append(category.rawValue)
        }
        
        if let difficulty = selectedDifficulty {
            components.append("сложность \(difficulty)")
        }
        
        if let duration = selectedDuration {
            if duration == 0 {
                components.append("пожизненные")
            } else {
                components.append("\(duration) дней")
            }
        }
        
        return components.isEmpty ? "Все шаблоны" : components.joined(separator: " · ")
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

#Preview {
    WorkshopGalleryView(viewModel: AskezaViewModel())
} 