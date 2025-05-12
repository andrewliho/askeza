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
                                    print("🔍 WorkshopGridView - Выбран шаблон: \(template.title), ID: \(template.templateId), UUID: \(template.id)")
                                    
                                    // Проверяем, является ли это шаблоном "7 дней цифрового детокса"
                                    let isDigitalDetox = template.title.contains("цифрового детокса") || template.title.contains("digital detox")
                                    
                                    // Для цифрового детокса используем увеличенную задержку
                                    let loadDelay = isDigitalDetox ? 0.5 : 0.1
                                    
                                    // Если это шаблон цифрового детокса, обеспечиваем правильное templateId
                                    let templateIdToLoad = isDigitalDetox ? "digital-detox-7" : template.templateId
                                    
                                    print("WorkshopGridView - Загрузка шаблона \(isDigitalDetox ? "цифрового детокса" : template.title) с ID: \(templateIdToLoad)")
                                    
                                    // Сначала загружаем данные шаблона
                                    templateStore.preloadTemplateData(for: templateIdToLoad)
                                    print("WorkshopGridView - Предварительно загружены данные для шаблона: \(templateIdToLoad)")
                                    
                                    // Создаем копию шаблона для гарантии
                                    let templateCopy = isDigitalDetox ? 
                                        PracticeTemplate(
                                            templateId: "digital-detox-7",
                                            title: template.title,
                                            category: template.category,
                                            duration: template.duration,
                                            quote: template.quote,
                                            difficulty: template.difficulty,
                                            description: template.practiceDescription,
                                            intention: template.intention
                                        ) : template
                                    
                                    // Устанавливаем выбранный шаблон
                                    selectedTemplate = templateCopy
                                    
                                    // Небольшая задержка перед отображением sheet для гарантии готовности данных
                                    DispatchQueue.main.asyncAfter(deadline: .now() + loadDelay) {
                                        if selectedTemplate != nil {
                                            print("WorkshopGridView - Отображаем detail view для шаблона: \(templateCopy.title)")
                                            showingTemplateDetail = true
                                        } else {
                                            // Если шаблон не установлен, повторяем попытку с еще большей задержкой
                                            selectedTemplate = templateCopy
                                            print("WorkshopGridView - Повторная попытка отобразить detail view")
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                                showingTemplateDetail = true
                                            }
                                        }
                                    }
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
                        // Сбрасываем выбранный шаблон и перезагружаем данные после закрытия
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            selectedTemplate = nil
                            
                            // Выводим дополнительную информацию для диагностики
                            print("🔄 WorkshopGridView - Sheet закрыт, сбрасываем выбранный шаблон: \(template.title)")
                            
                            // Обновляем данные для шаблона, если это был шаблон цифрового детокса
                            if template.title.contains("цифрового детокса") || template.title.contains("digital detox") {
                                print("🔄 WorkshopGridView - Принудительное обновление данных шаблона цифрового детокса")
                                templateStore.preloadTemplateData(for: "digital-detox-7")
                            }
                        }
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
        VStack {
            // Предварительно загружаем данные еще раз для надежности при показе sheet
            TemplateDetailView(
                template: template,
                templateStore: templateStore
            )
            .onAppear {
                // При появлении sheet, еще раз загружаем данные для надежности
                print("🔍 WorkshopGridView - onAppear вызван для sheet с шаблоном: \(template.title)")
                
                // Еще раз загружаем данные, чтобы гарантировать доступность
                templateStore.preloadTemplateData(for: template.templateId)
                
                // При отображении digital-detox-7 добавляем дополнительную обработку
                if template.templateId == "digital-detox-7" || template.title.contains("цифрового детокса") {
                    print("⚠️ WorkshopGridView - Обнаружен особый шаблон: цифровой детокс")
                    
                    // Серия повторных загрузок с увеличивающимися интервалами для гарантированной загрузки
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        print("🔄 WorkshopGridView - Повторная загрузка 1 для цифрового детокса")
                        templateStore.preloadTemplateData(for: "digital-detox-7")
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            print("🔄 WorkshopGridView - Повторная загрузка 2 для цифрового детокса")
                            templateStore.preloadTemplateData(for: "digital-detox-7")
                            
                            // Третья попытка с еще большей задержкой
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                print("🔄 WorkshopGridView - Финальная загрузка для цифрового детокса")
                                templateStore.preloadTemplateData(for: "digital-detox-7")
                            }
                        }
                    }
                }
            }
            .background(AskezaTheme.backgroundColor)
            .edgesIgnoringSafeArea(.all)
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