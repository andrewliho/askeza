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
                            OptimizedTemplateGridCard(
                                template: template,
                                progress: templateStore.getProgress(forTemplateID: template.id),
                                onTap: {
                                    print("🔍 WorkshopGridView - Выбран шаблон: \(template.title)")
                                    // Сразу устанавливаем шаблон и показываем detail view
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
        .navigationTitle("Мастерская")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingTemplateDetail) {
            if let template = selectedTemplate {
                templateDetailView(template)
                    .onDisappear {
                        // Просто сбрасываем выбранный шаблон
                        selectedTemplate = nil
                    }
            } else {
                // Вид с ошибкой, если шаблон не найден
                VStack {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.system(size: 50))
                        .foregroundColor(.yellow)
                        .padding()
                    
                    Text("Ошибка загрузки шаблона")
                        .font(.headline)
                        .foregroundColor(AskezaTheme.textColor)
                    
                    Text("Пожалуйста, попробуйте снова")
                        .font(.subheadline)
                        .foregroundColor(AskezaTheme.secondaryTextColor)
                        .padding(.top, 8)
                    
                    Button("Закрыть") {
                        showingTemplateDetail = false
                    }
                    .padding()
                    .background(AskezaTheme.buttonBackground)
                    .cornerRadius(8)
                    .padding(.top, 20)
                }
                .padding()
                .background(AskezaTheme.backgroundColor)
                .edgesIgnoringSafeArea(.all)
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
    
    private func templateDetailView(_ template: PracticeTemplate) -> some View {
        TemplateDetailView(
            template: template,
            templateStore: templateStore
        )
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