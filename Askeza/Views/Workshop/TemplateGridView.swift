import SwiftUI

// Добавим импорт Common, если ShareSheet определена там
import SwiftUI
// Для ShareSheet используем общий компонент из приложения

struct TemplateGridView: View {
    @ObservedObject private var templateStore: PracticeTemplateStore
    @Binding var searchText: String
    @Binding var selectedCategory: AskezaCategory?
    @Binding var selectedDifficulty: Int?
    @Binding var selectedDuration: Int?
    
    init(
        templateStore: PracticeTemplateStore,
        searchText: Binding<String>,
        selectedCategory: Binding<AskezaCategory?>,
        selectedDifficulty: Binding<Int?>,
        selectedDuration: Binding<Int?>
    ) {
        self.templateStore = templateStore
        self._searchText = searchText
        self._selectedCategory = selectedCategory
        self._selectedDifficulty = selectedDifficulty
        self._selectedDuration = selectedDuration
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Заголовок секции с отображением количества шаблонов
            HStack {
                Text("Галерея шаблонов")
                    .font(.headline)
                    .foregroundColor(AskezaTheme.textColor)
                
                Spacer()
                
                Text("\(filteredTemplates.count) шаблонов")
                    .font(.caption)
                    .foregroundColor(AskezaTheme.secondaryTextColor)
            }
            .padding(.horizontal)
            
            if filteredTemplates.isEmpty {
                // Сообщение при отсутствии шаблонов
                emptyTemplatesView
            } else {
                // Сетка шаблонов
                LazyVGrid(columns: [
                    GridItem(.flexible(), spacing: 16),
                    GridItem(.flexible(), spacing: 16)
                ], spacing: 16) {
                    ForEach(filteredTemplates) { template in
                        TemplateCardView(template: template)
                            .environmentObject(templateStore)
                    }
                }
                .padding(.horizontal)
            }
        }
    }
    
    private var emptyTemplatesView: some View {
        VStack(spacing: 16) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 40))
                .foregroundColor(AskezaTheme.secondaryTextColor)
            
            Text("Шаблоны не найдены")
                .font(.headline)
                .foregroundColor(AskezaTheme.textColor)
            
            Text("Попробуйте изменить параметры поиска или фильтры")
                .font(.subheadline)
                .foregroundColor(AskezaTheme.secondaryTextColor)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(32)
    }
    
    // Применяем все фильтры к списку шаблонов
    private var filteredTemplates: [PracticeTemplate] {
        templateStore.templates.filter { template in
            var matches = true
            
            // Фильтр по поисковому запросу
            if !searchText.isEmpty {
                matches = matches && (
                    template.title.localizedCaseInsensitiveContains(searchText) ||
                    template.practiceDescription.localizedCaseInsensitiveContains(searchText) ||
                    template.intention.localizedCaseInsensitiveContains(searchText)
                )
            }
            
            // Фильтр по категории
            if let category = selectedCategory {
                matches = matches && template.category == category
            }
            
            // Фильтр по сложности
            if let difficulty = selectedDifficulty {
                matches = matches && template.difficulty == difficulty
            }
            
            // Фильтр по продолжительности
            if let duration = selectedDuration {
                if duration == 0 { // Пожизненные шаблоны
                    matches = matches && template.duration == 0
                } else {
                    matches = matches && template.duration == duration
                }
            }
            
            return matches
        }
        .sorted { $0.title < $1.title } // Сортировка по алфавиту
    }
}

struct TemplateCardView: View {
    let template: PracticeTemplate
    @EnvironmentObject var templateStore: PracticeTemplateStore
    @State private var showingTemplateDetail = false
    @State private var showingShareSheet = false
    @State private var shareText: String = ""
    @State private var errorMessage: String = ""
    @State private var showError = false
    
    var body: some View {
        Button(action: {
            showingTemplateDetail = true
        }) {
            VStack(alignment: .leading, spacing: 12) {
                // Заголовок и иконка категории
                HStack {
                    Image(systemName: template.category.systemImage)
                        .font(.system(size: 16))
                        .foregroundColor(template.category.mainColor)
                    
                    Text(template.title)
                        .font(.headline)
                        .foregroundColor(AskezaTheme.textColor)
                        .lineLimit(2)
                }
                
                // Дополнительная информация
                HStack {
                    Text(durationText(template.duration))
                        .font(.caption)
                        .foregroundColor(AskezaTheme.secondaryTextColor)
                    
                    Text("•")
                        .foregroundColor(AskezaTheme.secondaryTextColor)
                    
                    // Отображение сложности звездами
                    HStack(spacing: 2) {
                        ForEach(1...template.difficulty, id: \.self) { _ in
                            Image(systemName: "star.fill")
                                .font(.system(size: 8))
                                .foregroundColor(.yellow)
                        }
                    }
                }
                
                // Статус шаблона, если есть прогресс
                if let progress = templateStore.getProgress(forTemplateID: template.id) {
                    let status = progress.status(templateDuration: template.duration)
                    
                    HStack {
                        Image(systemName: status.icon)
                            .font(.system(size: 12))
                            .foregroundColor(status.color)
                        
                        Text(status.rawValue)
                            .font(.caption)
                            .foregroundColor(status.color)
                        
                        // Добавляем информацию о количестве завершений, если есть
                        if progress.timesCompleted > 0 {
                            Spacer()
                            HStack(spacing: 2) {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 10))
                                    .foregroundColor(AskezaTheme.accentColor)
                                
                                Text("Пройдено \(progress.timesCompleted) \(pluralForm(progress.timesCompleted))")
                                    .font(.caption)
                                    .foregroundColor(AskezaTheme.secondaryTextColor)
                            }
                        }
                    }
                    
                    // Показываем прогресс для активных шаблонов
                    if status == .inProgress {
                        let progressValue = template.duration > 0 
                            ? Double(progress.daysCompleted) / Double(template.duration)
                            : 0.0
                            
                        GeometryReader { geometry in
                            ZStack(alignment: .leading) {
                                Rectangle()
                                    .fill(Color.gray.opacity(0.3))
                                    .frame(height: 4)
                                    .cornerRadius(2)
                                
                                Rectangle()
                                    .fill(status.color)
                                    .frame(width: geometry.size.width * min(1.0, progressValue), height: 4)
                                    .cornerRadius(2)
                            }
                        }
                        .frame(height: 4)
                    }
                }
                
                // Кнопки действий
                HStack {
                    Button(action: {
                        startTemplate()
                    }) {
                        HStack {
                            Image(systemName: "play.fill")
                                .font(.system(size: 10))
                            
                            Text(startButtonText)
                                .font(.caption)
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(AskezaTheme.accentColor)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    Spacer()
                    
                    Button(action: {
                        shareTemplate()
                    }) {
                        Image(systemName: "square.and.arrow.up")
                            .font(.system(size: 12))
                            .foregroundColor(AskezaTheme.secondaryTextColor)
                            .padding(6)
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(8)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding()
            .background(AskezaTheme.buttonBackground)
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
        .sheet(isPresented: $showingTemplateDetail) {
            TemplateDetailView(template: template, templateStore: templateStore)
        }
        .sheet(isPresented: $showingShareSheet) {
            ShareSheet(activityItems: [shareText])
        }
        .alert("Внимание", isPresented: $showError) {
            Button("ОК", role: .cancel) {}
        } message: {
            Text(errorMessage)
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
    
    private func durationText(_ days: Int) -> String {
        if days == 0 {
            return "Пожизненно"
        } else {
            return "\(days) дней"
        }
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
    
    private func startTemplate() {
        Task {
            if let askeza = templateStore.startTemplate(template) {
                // Отправляем уведомление в основном потоке
                DispatchQueue.main.async {
                    NotificationCenter.default.post(
                        name: .refreshWorkshopData,
                        object: askeza
                    )
                }
            } else {
                // Показываем ошибку, что шаблон уже активен
                DispatchQueue.main.async {
                    errorMessage = "Этот шаблон уже активен. Завершите текущую аскезу, прежде чем начать заново."
                    showError = true
                }
            }
        }
    }
    
    private func shareTemplate() {
        // Ограничиваем длину цитаты для шаринга
        let quote = template.quote.count > 50 ? template.quote.prefix(50) + "..." : template.quote
        
        shareText = """
        🧘‍♂️ Аскеза: \(template.title)
        📝 Категория: \(template.category.rawValue)
        ⏳ Длительность: \(durationText(template.duration))
        ✨ Цитата: "\(quote)"
        
        #Askeza #\(template.category.rawValue) #СамоРазвитие
        """
        
        showingShareSheet = true
    }
}

#Preview {
    TemplateGridView(
        templateStore: PracticeTemplateStore.shared,
        searchText: .constant(""),
        selectedCategory: .constant(nil),
        selectedDifficulty: .constant(nil),
        selectedDuration: .constant(nil)
    )
} 