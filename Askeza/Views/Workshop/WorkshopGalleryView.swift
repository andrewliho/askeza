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
                    
                    // Основной список шаблонов
                    ScrollView {
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 300, maximum: 400), spacing: 16)], spacing: 16) {
                            ForEach(filteredTemplates()) { template in
                                Button(action: {
                                    selectedTemplate = template
                                    showingTemplateDetail = true
                                }) {
                                    TemplateCard(template: template, templateStore: templateStore)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding()
                    }
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
                        
                        // Информация о шаблоне
                        VStack(alignment: .leading, spacing: 16) {
                            // Категория и сложность
                            HStack {
                                Text(template.category.rawValue)
                                    .font(.subheadline)
                                    .foregroundColor(template.category.mainColor)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(template.category.mainColor.opacity(0.2))
                                    .cornerRadius(16)
                                
                                Spacer()
                                
                                // Сложность
                                HStack(spacing: 2) {
                                    ForEach(1...template.difficulty, id: \.self) { _ in
                                        Image(systemName: "star.fill")
                                            .foregroundColor(difficultyColor(level: template.difficulty))
                                    }
                                }
                            }
                            
                            // Статус шаблона
                            if let progress = templateStore.getProgress(forTemplateID: template.id) {
                                let status = progress.status(templateDuration: template.duration)
                                
                                HStack {
                                    Image(systemName: status.icon)
                                        .foregroundColor(status.color)
                                    
                                    Text(status.rawValue)
                                        .foregroundColor(status.color)
                                    
                                    Spacer()
                                    
                                    if progress.timesCompleted > 0 {
                                        Text("Завершено раз: \(progress.timesCompleted)")
                                            .foregroundColor(AskezaTheme.secondaryTextColor)
                                    }
                                }
                                .padding(.vertical, 8)
                                .padding(.horizontal, 12)
                                .background(AskezaTheme.buttonBackground)
                                .cornerRadius(12)
                            }
                            
                            // Цитата
                            if !template.quote.isEmpty {
                                Text("\"\(template.quote)\"")
                                    .font(.body)
                                    .italic()
                                    .foregroundColor(AskezaTheme.secondaryTextColor)
                            }
                            
                            // Описание
                            Text(template.practiceDescription)
                                .font(.body)
                                .foregroundColor(AskezaTheme.textColor)
                                .padding(.vertical, 8)
                            
                            // Намерение
                            if !template.intention.isEmpty {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Намерение:")
                                        .font(.headline)
                                        .foregroundColor(AskezaTheme.textColor)
                                    
                                    Text(template.intention)
                                        .font(.body)
                                        .foregroundColor(AskezaTheme.secondaryTextColor)
                                }
                                .padding(.vertical, 8)
                            }
                            
                            // Длительность
                            detailRow(title: "Длительность:", value: durationText(template.duration))
                                .padding(.vertical, 8)
                            
                            // Прогресс, если шаблон активен
                            if let progress = templateStore.getProgress(forTemplateID: template.id) {
                                let status = progress.status(templateDuration: template.duration)
                                
                                if status == .inProgress {
                                    VStack(alignment: .leading, spacing: 8) {
                                        Text("Текущий прогресс:")
                                            .font(.headline)
                                            .foregroundColor(AskezaTheme.textColor)
                                        
                                        // Прогресс-бар
                                        ProgressView(value: Double(progress.daysCompleted), total: Double(template.duration))
                                            .progressViewStyle(LinearProgressViewStyle(tint: template.category.mainColor))
                                        
                                        HStack {
                                            Text("\(progress.daysCompleted) из \(template.duration) дней")
                                                .font(.caption)
                                                .foregroundColor(AskezaTheme.secondaryTextColor)
                                            
                                            Spacer()
                                            
                                            Text("Текущая серия: \(progress.currentStreak) дней")
                                                .font(.caption)
                                                .foregroundColor(AskezaTheme.secondaryTextColor)
                                        }
                                    }
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
                                        viewModel.addAskezaToActive(askeza)
                                        print("WorkshopGalleryView: Аскеза добавлена в viewModel")
                                    }
                                    
                                    showingTemplateDetail = false
                                } else {
                                    // Показываем ошибку, что шаблон уже активен
                                    errorMessage = "Этот шаблон уже активен. Завершите текущую аскезу, прежде чем начать заново."
                                    showError = true
                                }
                            }) {
                                // Определяем текст кнопки в зависимости от статуса шаблона
                                Text(templateStore.getProgress(forTemplateID: template.id)?.timesCompleted ?? 0 > 0 
                                    ? "Повторить практику" 
                                    : "Начать практику")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(AskezaTheme.accentColor)
                                    .cornerRadius(12)
                            }
                            .buttonStyle(PlainButtonStyle())
                            
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
                        .alert("Внимание", isPresented: $showError) {
                            Button("ОК", role: .cancel) {}
                        } message: {
                            Text(errorMessage)
                        }
                    }
                    .padding(.vertical)
                }
            }
        }
        .navigationBarItems(leading: 
            Button("Закрыть") {
                showingTemplateDetail = false
            }
            .foregroundColor(AskezaTheme.accentColor)
        )
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

struct TemplateCard: View {
    let template: PracticeTemplate
    let templateStore: PracticeTemplateStore
    
    var body: some View {
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
                            
                        // Добавляем статус шаблона, если он не "Не начато"
                        if let progress = templateStore.getProgress(forTemplateID: template.id) {
                            let status = progress.status(templateDuration: template.duration)
                            if status != .notStarted {
                                Text("•")
                                    .foregroundColor(AskezaTheme.secondaryTextColor)
                                
                                HStack(spacing: 4) {
                                    Image(systemName: status.icon)
                                        .font(.caption)
                                        .foregroundColor(status.color)
                                    
                                    Text(status.rawValue)
                                        .font(.caption)
                                        .foregroundColor(status.color)
                                }
                                
                                // Если шаблон был завершен хотя бы раз, показываем количество завершений
                                if progress.timesCompleted > 0 {
                                    Text("•")
                                        .foregroundColor(AskezaTheme.secondaryTextColor)
                                    
                                    Text("✓ \(progress.timesCompleted)")
                                        .font(.caption)
                                        .foregroundColor(status.color)
                                        .fontWeight(.bold)
                                }
                            }
                        }
                    }
                }
                
                Spacer()
                
                // Сложность - звезды
                HStack(spacing: 2) {
                    ForEach(1...template.difficulty, id: \.self) { _ in
                        Image(systemName: "star.fill")
                            .font(.caption)
                            .foregroundColor(difficultyColor(level: template.difficulty))
                    }
                }
                .padding(.horizontal, 8)
            }
            
            // Цитата
            if !template.quote.isEmpty {
                Text("\"\(template.quote)\"")
                    .font(.caption)
                    .italic()
                    .foregroundColor(AskezaTheme.secondaryTextColor)
                    .lineLimit(2)
            }
            
            // Если шаблон завершен, добавляем индикатор завершения
            if let progress = templateStore.getProgress(forTemplateID: template.id),
               let status = progress.status(templateDuration: template.duration) as TemplateStatus?,
               status == .completed || status == .mastered {
                HStack {
                    Spacer()
                    Label(
                        progress.timesCompleted > 1 ? "Пройдено \(progress.timesCompleted) раза" : "Пройдено 1 раз", 
                        systemImage: "checkmark.circle.fill"
                    )
                    .font(.caption)
                    .foregroundColor(status.color)
                    .padding(.vertical, 4)
                    .padding(.horizontal, 8)
                    .background(status.color.opacity(0.2))
                    .cornerRadius(8)
                }
            }
        }
        .padding()
        .background(AskezaTheme.buttonBackground)
        .cornerRadius(12)
        .overlay(
            // Добавляем рамку для завершенных шаблонов
            Group {
                if let progress = templateStore.getProgress(forTemplateID: template.id),
                   let status = progress.status(templateDuration: template.duration) as TemplateStatus?,
                   status == .completed || status == .mastered {
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(status.color, lineWidth: 2)
                }
            }
        )
    }
    
    // Вспомогательные функции
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

#Preview {
    WorkshopGalleryView(viewModel: AskezaViewModel())
} 