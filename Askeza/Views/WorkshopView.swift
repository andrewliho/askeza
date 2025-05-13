import SwiftUI

struct WorkshopView: View {
    @ObservedObject var viewModel: AskezaViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var selectedCategory: AskezaCategory = .telo
    @State private var showingCreateAskeza = false
    @State private var selectedPresetAskeza: PresetAskeza?
    @State private var showAskezaDetail = false
    @State private var createdAskeza: Askeza?
    @State private var showingCreateSheet = false
    @State private var showingCompletionAlert = false
    
    // Заменяем прямую инициализацию на функцию для улучшения компиляции
    private func getPresetsForCategory(_ category: AskezaCategory) -> [PresetAskeza] {
        return PresetAskezaStore.shared.askezasByCategory[category] ?? []
    }
    
    // Выносим фильтрацию категорий в отдельную функцию
    private func getFilteredCategories() -> [AskezaCategory] {
        return AskezaCategory.allCases.filter { $0 != .custom }
    }
    
    // Создаем вспомогательную функцию для создания кнопки категории
    private func categoryButton(for category: AskezaCategory) -> some View {
        let isSelected = selectedCategory == category
        
        return Button(action: {
            // При смене категории сбрасываем выбранную аскезу
            if selectedCategory != category {
                selectedPresetAskeza = nil
            }
            
            if isSelected {
                selectedCategory = .telo
            } else {
                selectedCategory = category
            }
        }) {
            HStack(spacing: 6) {
                Image(systemName: category.systemImage)
                    .font(.system(size: 14))
                    .foregroundColor(isSelected ? .white : category.mainColor)
                
                Text(category.rawValue)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(isSelected ? .white : AskezaTheme.textColor)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(isSelected ? AskezaTheme.accentColor : AskezaTheme.buttonBackground)
            )
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                AskezaTheme.backgroundColor
                    .ignoresSafeArea()
                
                VStack(spacing: 20) {
                    // Category Picker
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            // Используем функцию для получения отфильтрованных категорий
                            let filteredCategories = getFilteredCategories()
                            ForEach(filteredCategories, id: \.self) { category in
                                categoryButton(for: category)
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    // Askezas List
                    askezasList
                }
            }
            .navigationTitle("Мастерская")
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(isPresented: $showAskezaDetail) {
                if let askeza = createdAskeza {
                    AskezaDetailView(askeza: askeza, viewModel: viewModel)
                }
            }
            .sheet(isPresented: $showingCreateAskeza) {
                showAskezaCreationSheet
            }
        }
    }
    
    // Выносим список аскез в отдельное свойство
    private var askezasList: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                let filteredAskezas = getPresetsForCategory(selectedCategory)
                
                if filteredAskezas.isEmpty {
                    Text("Нет доступных аскез в этой категории")
                        .font(.system(size: 16))
                        .foregroundColor(AskezaTheme.secondaryTextColor)
                        .padding(.top, 40)
                } else {
                    ForEach(filteredAskezas, id: \.title) { askeza in
                        AskezaPresetCard(askeza: askeza) {
                            // Явно присваиваем значение перед открытием sheet
                            selectedPresetAskeza = askeza
                            
                            // Дополнительная отладочная информация
                            print("Выбрана аскеза: \(askeza.title), категория: \(askeza.category.rawValue)")
                            print("Описание: \(askeza.description)")
                            print("Намерение: \(askeza.intention)")
                            
                            // Предварительно загружаем данные, если шаблон связан с PracticeTemplate
                            if let templateId = getTemplateIdForPreset(askeza.title) {
                                print("Найден templateId для выбранной аскезы: \(templateId)")
                                // Используем PracticeTemplateStore для загрузки данных
                                if let practiceStore = ServiceResolver.shared.resolve(PracticeTemplateStore.self) {
                                    practiceStore.preloadTemplateData(for: templateId)
                                }
                            } else {
                                print("Не удалось найти templateId для аскезы: \(askeza.title)")
                            }
                            
                            // Открываем форму создания аскезы с предзаполненными полями
                            showingCreateAskeza = true
                        }
                    }
                }
            }
            .padding()
        }
    }
    
    // Выносим содержимое sheet в отдельное свойство
    @ViewBuilder
    private var showAskezaCreationSheet: some View {
        if let preset = selectedPresetAskeza {
            NavigationView {
                // Добавляем отладочный вывод для проверки данных
                let _ = print("Создание аскезы из мастерской: \(preset.title), \(preset.intention)")
                
                CreateAskezaView(
                    viewModel: viewModel,
                    isPresented: $showingCreateAskeza,
                    presetTitle: preset.title,
                    presetWish: preset.intention
                ) { newAskeza in
                    createdAskeza = newAskeza
                    showingCreateAskeza = false
                    showAskezaDetail = true
                }
            }
        } else {
            // Если selectedPresetAskeza равен nil, показываем пустую форму
            NavigationView {
                CreateAskezaView(
                    viewModel: viewModel,
                    isPresented: $showingCreateAskeza
                ) { newAskeza in
                    createdAskeza = newAskeza
                    showingCreateAskeza = false
                    showAskezaDetail = true
                }
            }
        }
    }
    
    // Функция для определения templateId по заголовку аскезы
    func getTemplateIdForPreset(_ title: String) -> String? {
        // Специальные случаи для известных шаблонов, у которых могут быть проблемы
        if title.contains("Железной дисциплины") || title.contains("железной дисциплины") {
            print("🔍 WorkshopView - Определен специальный ID для шаблона 'Год железной дисциплины'")
            return "365-days-discipline"
        } else if title.contains("Вегетарианство") {
            print("🔍 WorkshopView - Определен специальный ID для шаблона 'Вегетарианство'")
            return "lifetime-vegetarian"
        } else if title.contains("100 дней отжиманий") {
            return "100-days-pushups"
        } else if title.contains("100 дней медитации") {
            return "100-days-meditation"
        } else if title.contains("180 дней") {
            return "180-days-healthy-lifestyle"
        } else if title.contains("цифрового детокса") || title.contains("digital detox") {
            print("🔍 WorkshopView - Определен специальный ID для шаблона '7 дней цифрового детокса'")
            return "digital-detox-7"
        }
        
        // Для других шаблонов генерируем ID на основе заголовка
        let id = title.lowercased()
            .replacingOccurrences(of: " ", with: "-")
            .replacingOccurrences(of: ".", with: "")
            .replacingOccurrences(of: ",", with: "")
        
        return id
    }
}

struct CategoryButton: View {
    let title: String
    let isSelected: Bool
    let systemImage: String
    let action: () -> Void
    let category: AskezaCategory
    
    init(title: String, isSelected: Bool, systemImage: String, category: AskezaCategory, action: @escaping () -> Void) {
        self.title = title
        self.isSelected = isSelected
        self.systemImage = systemImage
        self.category = category
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: systemImage)
                    .font(.system(size: 14))
                    .foregroundColor(isSelected ? .white : category.mainColor)
                
                Text(title)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(isSelected ? .white : AskezaTheme.textColor)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(isSelected ? AskezaTheme.accentColor : AskezaTheme.buttonBackground)
            )
        }
    }
}

struct AskezaPresetCard: View {
    let askeza: PresetAskeza
    let action: () -> Void
    
    var body: some View {
        Button(action: {
            // Выводим информацию до вызова action для отладки
            print("Нажата карточка аскезы: \(askeza.title), \(askeza.intention)")
            action()
        }) {
            VStack(alignment: .leading, spacing: 14) {
                // Верхняя часть с иконкой, заголовком и сложностью
                HStack(spacing: 12) {
                    // Иконка категории с фоном
                    ZStack {
                        Circle()
                            .fill(askeza.category.mainColor.opacity(0.15))
                            .frame(width: 44, height: 44)
                        
                        Image(systemName: askeza.category.systemImage)
                            .font(.system(size: 20))
                            .foregroundColor(askeza.category.mainColor)
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        // Заголовок
                        Text(askeza.title)
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(Color.white)
                            .lineLimit(1)
                        
                        // Индикатор сложности
                        if let difficulty = askeza.difficulty {
                            HStack(spacing: 2) {
                                ForEach(1...5, id: \.self) { i in
                                    Image(systemName: i <= difficulty ? "star.fill" : "star")
                                        .font(.system(size: 12))
                                        .foregroundColor(i <= difficulty ? Color.yellow : Color.gray.opacity(0.2))
                                }
                                
                                Text(difficultyText(for: difficulty))
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(Color.gray.opacity(0.8))
                                    .padding(.leading, 4)
                            }
                        }
                    }
                    
                    Spacer()
                    
                    // Индикатор продолжительности
                    if let duration = askeza.duration {
                        if duration == 0 {
                            // Пожизненная
                            HStack(spacing: 2) {
                                Image(systemName: "infinity")
                                    .font(.system(size: 12))
                                Text("Пожизненно")
                                    .font(.system(size: 12, weight: .medium))
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.blue.opacity(0.3))
                            .cornerRadius(6)
                        } else {
                            // С указанным количеством дней
                            HStack(spacing: 2) {
                                Image(systemName: "calendar")
                                    .font(.system(size: 12))
                                Text("\(duration) дн.")
                                    .font(.system(size: 12, weight: .medium))
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(askeza.category.mainColor.opacity(0.3))
                            .cornerRadius(6)
                        }
                    }
                }
                
                // Описание
                Text(askeza.description)
                    .font(.system(size: 15))
                    .foregroundColor(Color.white.opacity(0.85))
                    .lineLimit(2)
                    .padding(.vertical, 2)
                
                // Намерение с декоративными элементами
                if !askeza.intention.isEmpty {
                    VStack(spacing: 4) {
                        // Тонкая декоративная линия
                        Rectangle()
                            .fill(Color(red: 0.8, green: 0.6, blue: 0.4).opacity(0.3))
                            .frame(height: 1)
                            .padding(.vertical, 2)
                        
                        Text("\"\(askeza.intention)\"")
                            .font(.system(size: 14, weight: .light, design: .serif))
                            .foregroundColor(Color(red: 0.8, green: 0.6, blue: 0.4)) // Бронзовый цвет
                            .italic()
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                }
            }
            .padding(.vertical, 16)
            .padding(.horizontal, 16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(AskezaTheme.buttonBackground) // Используем стиль как в карточках желаний
                    .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(askeza.category.mainColor.opacity(0.2), lineWidth: 1)
            )
        }
    }
    
    // Функция для преобразования числовой сложности в текстовое описание
    private func difficultyText(for difficulty: Int) -> String {
        switch difficulty {
        case 1:
            return "Легко"
        case 2:
            return "Средне"
        case 3:
            return "Умеренно"
        case 4:
            return "Сложно"
        case 5:
            return "Очень сложно"
        default:
            return ""
        }
    }
}

// Extension to blend colors - creates brighter text colors
extension Color {
    func blend(with color: Color, ratio: Double = 0.8) -> Color {
        // Смешиваем цвета без использования overlay (который возвращает View)
        // Возвращаем просто белый цвет, так как у нас нет прямого доступа к RGB компонентам
        return Color.white
    }
}

#Preview {
    WorkshopView(viewModel: AskezaViewModel())
} 