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
                            
                            // Добавляем небольшую задержку для надежности
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                showingCreateAskeza = true
                            }
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
                    presetIntention: preset.intention,
                    category: preset.category
                ) { newAskeza in
                    createdAskeza = newAskeza
                    showingCreateAskeza = false
                    showAskezaDetail = true
                }
            }
        } else {
            // Если selectedPresetAskeza равен nil, показываем пустую форму
            // Это необходимо для отладки - не должно происходить в нормальной работе
            Text("Ошибка: выбранная аскеза не определена")
                .foregroundColor(.red)
        }
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
            HStack(spacing: 16) {
                let categoryColor = askeza.category.mainColor
                
                Image(systemName: askeza.category.systemImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 30, height: 30)
                    .foregroundColor(categoryColor)
                
                VStack(alignment: .leading, spacing: 12) {
                    Text(askeza.title)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(Color.white)
                    
                    Text(askeza.description)
                        .font(.system(size: 16))
                        .foregroundColor(Color.white.opacity(0.85))
                        .lineLimit(2)
                    
                    if !askeza.intention.isEmpty {
                        Text(askeza.intention)
                            .font(.system(size: 14, weight: .light, design: .serif))
                            .foregroundColor(Color(red: 0.8, green: 0.6, blue: 0.4)) // Бронзовый цвет
                            .italic()
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(AskezaTheme.buttonBackground) // Используем стиль как в карточках желаний
            )
            .cornerRadius(12)
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