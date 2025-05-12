import SwiftUI
import SwiftData

struct WorkshopGridView: View {
    @ObservedObject private var templateStore: PracticeTemplateStore
    @Binding private var searchText: String
    @Binding private var selectedCategory: AskezaCategory?
    @Binding private var selectedDifficulty: Int?
    @Binding private var selectedDuration: Int?
    
    @State private var showingTemplateDetail = false
    @State private var selectedTemplate: PracticeTemplate?
    
    let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]
    
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
        VStack(spacing: 0) {
            // Заголовок секции
            HStack {
                Text(sectionTitle)
                    .font(.headline)
                    .foregroundColor(AskezaTheme.textColor)
                
                Spacer()
                
                if hasActiveFilters {
                    Button(action: clearFilters) {
                        Label("Сбросить", systemImage: "xmark.circle.fill")
                            .font(.footnote)
                            .foregroundColor(AskezaTheme.accentColor)
                    }
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            
            if templates.isEmpty {
                emptyResultsView
            } else {
                // Grid галерея шаблонов
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 12) {
                        ForEach(templates) { template in
                            TemplateGridCardView(
                                template: template,
                                progress: templateStore.getProgress(forTemplateID: template.id),
                                onTap: {
                                    selectedTemplate = template
                                    showingTemplateDetail = true
                                }
                            )
                        }
                    }
                    .padding()
                }
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
    
    // MARK: - Helper Views and Properties
    
    private var templates: [PracticeTemplate] {
        return templateStore.filteredTemplates(
            category: selectedCategory,
            difficulty: selectedDifficulty,
            duration: selectedDuration,
            searchText: searchText
        )
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
    
    private var hasActiveFilters: Bool {
        return selectedCategory != nil || selectedDifficulty != nil || selectedDuration != nil || !searchText.isEmpty
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
    
    private func clearFilters() {
        selectedCategory = nil
        selectedDifficulty = nil
        selectedDuration = nil
        searchText = ""
    }
}

struct TemplateGridCardView: View {
    let template: PracticeTemplate
    let progress: TemplateProgress?
    let onTap: () -> Void
    
    private var status: TemplateStatus {
        if let progress = progress {
            return progress.status(templateDuration: template.duration)
        }
        return .notStarted
    }
    
    private var progressPercentage: Double {
        guard let progress = progress, template.duration > 0 else {
            return 0
        }
        return min(1.0, Double(progress.daysCompleted) / Double(template.duration))
    }
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 0) {
                // Верхняя часть карточки с фоном цвета категории
                ZStack(alignment: .topTrailing) {
                    // Градиент фон
                    RoundedRectangle(cornerRadius: 16)
                        .fill(
                            LinearGradient(
                                gradient: Gradient(
                                    colors: [
                                        template.category.mainColor.opacity(0.7),
                                        template.category.mainColor.opacity(0.3)
                                    ]
                                ),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .aspectRatio(1, contentMode: .fill)
                    
                    // Иконка категории
                    Image(systemName: template.category.systemImage)
                        .font(.system(size: 36))
                        .foregroundColor(template.category.mainColor)
                        .padding()
                        .opacity(0.8)
                    
                    // Бейдж сложности
                    difficultyBadge
                        .padding(8)
                    
                    // Статус
                    if status != .notStarted {
                        VStack {
                            Spacer()
                            
                            // Прогресс бар
                            if status == .inProgress {
                                GeometryReader { geometry in
                                    ZStack(alignment: .leading) {
                                        Rectangle()
                                            .fill(Color.gray.opacity(0.3))
                                            .frame(height: 4)
                                        
                                        Rectangle()
                                            .fill(status.color)
                                            .frame(width: geometry.size.width * progressPercentage, height: 4)
                                    }
                                }
                                .frame(height: 4)
                                .padding(.horizontal)
                            }
                            
                            // Индикатор статуса
                            HStack {
                                Image(systemName: status.icon)
                                    .foregroundColor(status.color)
                                
                                Text(status.rawValue)
                                    .font(.caption)
                                    .foregroundColor(AskezaTheme.textColor)
                                
                                if let progress = progress, status == .inProgress, progress.currentStreak > 0 {
                                    Spacer()
                                    
                                    HStack(spacing: 2) {
                                        Text("\(progress.currentStreak)")
                                            .font(.caption)
                                            .foregroundColor(.orange)
                                        
                                        Image(systemName: "flame.fill")
                                            .font(.caption)
                                            .foregroundColor(.orange)
                                    }
                                }
                            }
                            .padding(.horizontal, 8)
                            .padding(.bottom, 8)
                        }
                    }
                }
                .frame(height: 140)
                
                // Нижняя часть карточки с информацией
                VStack(alignment: .leading, spacing: 4) {
                    Text(template.title)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(AskezaTheme.textColor)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Text("\(durationText(template.duration))")
                        .font(.caption)
                        .foregroundColor(AskezaTheme.secondaryTextColor)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(8)
                .background(AskezaTheme.buttonBackground)
            }
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(statusBorderColor, lineWidth: statusBorderWidth)
            )
            .shadow(color: Color.black.opacity(0.1), radius: 3, x: 0, y: 2)
        }
    }
    
    // MARK: - Helper Views and Properties
    
    private var difficultyBadge: some View {
        HStack(spacing: 2) {
            ForEach(1...template.difficulty, id: \.self) { _ in
                Circle()
                    .fill(difficultyColor(level: template.difficulty))
                    .frame(width: 8, height: 8)
            }
        }
        .padding(6)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.black.opacity(0.2))
        )
    }
    
    private var statusBorderColor: Color {
        switch status {
        case .notStarted:
            return Color.clear
        case .inProgress:
            return status.color.opacity(0.3)
        case .completed:
            return status.color
        case .mastered:
            return Color.purple
        }
    }
    
    private var statusBorderWidth: CGFloat {
        switch status {
        case .notStarted:
            return 0
        case .inProgress:
            return 1
        case .completed, .mastered:
            return 2
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
    
    private func durationText(_ days: Int) -> String {
        if days == 0 {
            return "Пожизненная практика"
        } else {
            return "\(days) дней"
        }
    }
}

#Preview {
    let templateStore = PracticeTemplateStore.shared
    
    return WorkshopGridView(
        templateStore: templateStore,
        searchText: .constant(""),
        selectedCategory: .constant(nil),
        selectedDifficulty: .constant(nil),
        selectedDuration: .constant(nil)
    )
    .background(AskezaTheme.backgroundColor)
} 