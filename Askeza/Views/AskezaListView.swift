import SwiftUI

public struct AskezaListView: View {
    @ObservedObject public var viewModel: AskezaViewModel
    @Binding var showCreateAskeza: Bool
    @State private var selectedFilter: AskezaFilter = .active
    @State private var selectedAskeza: Askeza?
    @State private var showAskezaDetail = false
    @State private var showingDeleteConfirmation = false
    @State private var askezaToDelete: Askeza?
    @State private var showCopiedToast = false
    @State private var searchText: String = ""
    @State private var isRefreshing = false
    
    // Внутренний флаг для продления аскезы
    @State private var showExtendForm = false
    @State private var askezaToExtend: Askeza?
    
    // Добавляем новый флаг для очистки данных
    @State private var showingClearDataAlert = false
    
    private enum AskezaFilter: String, CaseIterable {
        case active = "Активные"
        case completed = "Завершённые"
        case lifetime = "Пожизненные"
    }
    
    private var filteredAskezas: [Askeza] {
        // Сначала определяем базовый набор аскез в зависимости от выбранного фильтра
        let baseAskezas: [Askeza]
        
        switch selectedFilter {
        case .active:
            // Фильтруем только активные аскезы (не пожизненные)
            baseAskezas = viewModel.activeAskezas.filter { askeza in
                if case .lifetime = askeza.duration { return false }
                return true
            }
        case .completed:
            // Для завершенных аскез
            baseAskezas = viewModel.completedAskezas
        case .lifetime:
            // Фильтруем только пожизненные аскезы
            baseAskezas = viewModel.activeAskezas.filter { askeza in
                if case .lifetime = askeza.duration { return true }
                return false
            }
        }
        
        // Проверяем наличие дубликатов в базовом наборе
        var deduplicated = baseAskezas
        if baseAskezas.count != Set(baseAskezas.map { $0.id }).count {
            // Если есть дубликаты, удаляем их
            var seenIDs = Set<UUID>()
            deduplicated = baseAskezas.filter { askeza in
                if seenIDs.contains(askeza.id) {
                    print("⚠️ filteredAskezas: Обнаружен дубликат в исходном списке, ID: \(askeza.id), название: \(askeza.title)")
                    return false
                } else {
                    seenIDs.insert(askeza.id)
                    return true
                }
            }
        }
        
        // Применяем поиск, если задан текст поиска
        if searchText.isEmpty {
            return deduplicated
        } else {
            let searchQuery = searchText.lowercased()
            
            // Фильтруем по поисковому запросу
            return deduplicated.filter { askeza in
                let title = askeza.title.lowercased()
                let intention = askeza.intention?.lowercased() ?? ""
                let category = askeza.category.rawValue.lowercased()
                return title.contains(searchQuery) || intention.contains(searchQuery) || category.contains(searchQuery)
            }
        }
    }
    
    private func formatAskezaHashtag(_ askeza: Askeza) -> String {
        let hashtag = askeza.title
            .components(separatedBy: CharacterSet.alphanumerics.inverted)
            .joined()
            .lowercased()
        
        let progress = askeza.progress
        let duration: String
        
        switch askeza.duration {
        case .days(let days):
            duration = "\(progress)/\(days)"
        case .lifetime:
            duration = "\(progress)/∞"
        }
        
        return "\(duration)\n#\(hashtag)"
    }
    
    public init(viewModel: AskezaViewModel, showCreateAskeza: Binding<Bool>) {
        self.viewModel = viewModel
        self._showCreateAskeza = showCreateAskeza
    }
    
    public var body: some View {
        NavigationStack {
            ZStack {
                AskezaTheme.backgroundColor
                    .ignoresSafeArea()
                
                VStack(spacing: 16) {
                    // Фильтры
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(AskezaFilter.allCases, id: \.self) { filter in
                                FilterButton(
                                    title: filter.rawValue,
                                    isSelected: selectedFilter == filter
                                ) {
                                    selectedFilter = filter
                                }
                            }
                            
                            // Кнопка очистки данных
                            Button(action: {
                                showingClearDataAlert = true
                            }) {
                                HStack {
                                    Image(systemName: "trash.fill")
                                        .foregroundColor(.red)
                                    Text("Очистить")
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(.red)
                                }
                                .padding(.vertical, 8)
                                .padding(.horizontal, 12)
                                .background(Color.red.opacity(0.15))
                                .cornerRadius(20)
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    if filteredAskezas.isEmpty {
                        emptyStateView
                    } else {
                        askezaGridView
                            .refreshable {
                                // Имитация обновления данных
                                isRefreshing = true
                                // Здесь может быть ваш код обновления данных
                                viewModel.refreshData()
                                
                                // Задержка для визуального эффекта
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                                    isRefreshing = false
                                }
                            }
                    }
                }
            }
            .navigationDestination(isPresented: $showAskezaDetail) {
                if let askeza = selectedAskeza {
                    AskezaDetailView(askeza: askeza, viewModel: viewModel)
                }
            }
            .navigationTitle("Ваши Аскезы")
            .navigationBarTitleDisplayMode(.inline)
            .alert("Удалить аскезу?", isPresented: $showingDeleteConfirmation) {
                Button("Отмена", role: .cancel) { }
                Button("Удалить", role: .destructive) {
                    if let askeza = askezaToDelete {
                        withAnimation {
                            viewModel.deleteAskeza(askeza)
                        }
                        askezaToDelete = nil
                    }
                }
            } message: {
                Text("Это действие нельзя отменить")
            }
            // Добавляем диалог подтверждения очистки данных
            .alert("Очистить все данные?", isPresented: $showingClearDataAlert) {
                Button("Отмена", role: .cancel) { }
                Button("Очистить", role: .destructive) {
                    viewModel.resetAllData()
                }
            } message: {
                Text("Это действие нельзя отменить. Все аскезы и достижения будут удалены.")
            }
        }
        // Отдельная sheet для продления аскезы
        .sheet(isPresented: $showExtendForm) {
            NavigationView {
                if let askeza = askezaToExtend, selectedFilter == .active {
                    CreateAskezaView(
                        viewModel: viewModel,
                        isPresented: $showExtendForm,
                        existingAskeza: askeza
                    )
                }
            }
        }
        // Оставляем sheet для создания новой аскезы из внешних источников (MainView)
        .sheet(isPresented: $showCreateAskeza) {
            NavigationView {
                CreateAskezaView(
                    viewModel: viewModel,
                    isPresented: $showCreateAskeza
                ) { newAskeza in
                    selectedAskeza = newAskeza
                    showAskezaDetail = true
                }
            }
        }
        .overlay(
            Group {
                if showCopiedToast {
                    VStack {
                        Spacer()
                        Text("Скопировано!")
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.black.opacity(0.75))
                            .cornerRadius(10)
                            .padding(.bottom, 32)
                    }
                }
            }
        )
    }
    
    // Выносим отображение списка аскез в отдельное свойство (вместо сетки)
    private var askezaGridView: some View {
        ScrollView {
            VStack(spacing: 16) {
                ForEach(filteredAskezasWithUniqueIDs) { askeza in
                    Button {
                        selectedAskeza = askeza
                        showAskezaDetail = true
                    } label: {
                        OptimizedAskezaGridCard(
                            askeza: askeza,
                            onDelete: {
                                viewModel.deleteAskeza(askeza)
                            },
                            onComplete: {
                                withAnimation {
                                    viewModel.completeAskeza(askeza)
                                }
                            },
                            onExtend: {
                                askezaToExtend = askeza
                                showExtendForm = true
                            },
                            onProgressUpdate: { newProgress in
                                withAnimation(.easeInOut(duration: 0.5)) {
                                    viewModel.updateProgress(askeza, newProgress: newProgress)
                                }
                            }
                        )
                        .frame(width: UIScreen.main.bounds.width - 32, height: 140)
                        .id("\(askeza.id)-\(askeza.progress)") // Уникальный id для правильного обновления при изменении прогресса
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(16)
            .animation(.easeInOut(duration: 0.3), value: filteredAskezasWithUniqueIDs.count)
        }
    }
    
    // Добавляем проверку на дубликаты ID в отфильтрованных аскезах
    private var filteredAskezasWithUniqueIDs: [Askeza] {
        var uniqueAskezas: [Askeza] = []
        var seenIDs: Set<UUID> = []
        
        // Логируем список аскез для отладки
        print("📊 AskezaListView: Отладка списка аскез, фильтр: \(selectedFilter.rawValue), количество: \(filteredAskezas.count)")
        
        // Поиск дубликатов в исходном списке
        var idCount: [UUID: Int] = [:]
        for askeza in filteredAskezas {
            idCount[askeza.id, default: 0] += 1
        }
        
        // Логируем найденные дубликаты в исходном списке
        let duplicateIDs = idCount.filter { $0.value > 1 }.keys
        if !duplicateIDs.isEmpty {
            print("⚠️ AskezaListView: Исходные дубликаты в списке до фильтрации: \(duplicateIDs.count)")
            for id in duplicateIDs {
                print("⚠️ AskezaListView: ID \(id) встречается \(idCount[id] ?? 0) раз")
            }
        }
        
        // Фильтруем дубликаты
        for askeza in filteredAskezas {
            if !seenIDs.contains(askeza.id) {
                uniqueAskezas.append(askeza)
                seenIDs.insert(askeza.id)
            } else {
                print("⚠️ AskezaListView: Обнаружен дубликат аскезы с ID \(askeza.id) - \(askeza.title) в filteredAskezas, пропускаем")
            }
        }
        
        print("📊 AskezaListView: После удаления дубликатов: \(uniqueAskezas.count) аскез")
        
        return uniqueAskezas
    }
    
    // Улучшенный внешний вид для пустого состояния
    private var emptyStateView: some View {
        VStack(spacing: 24) {
            // Увеличиваем иконку и делаем её более привлекательной
            ZStack {
                Circle()
                    .fill(AskezaTheme.accentColor.opacity(0.1))
                    .frame(width: 120, height: 120)
                
                Circle()
                    .fill(AskezaTheme.accentColor.opacity(0.2))
                    .frame(width: 90, height: 90)
                
                Image(systemName: emptyStateIconName)
                    .font(.system(size: 40))
                    .foregroundColor(emptyStateIconColor)
            }
            
            VStack(spacing: 8) {
                Text(emptyStateTitle)
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(AskezaTheme.textColor)
                
                Text(emptyStateSubtitle)
                    .font(.system(size: 16))
                    .foregroundColor(AskezaTheme.secondaryTextColor)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }
            
            // Кнопка действия, привязанная к контексту
            if selectedFilter == .active || selectedFilter == .lifetime {
                Button(action: {
                    showCreateAskeza = true
                }) {
                    HStack {
                        Image(systemName: "plus.circle")
                        Text("Создать аскезу")
                    }
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(AskezaTheme.accentColor)
                    .cornerRadius(10)
                }
                .padding(.top, 12)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // Вспомогательные свойства для пустого состояния
    
    private var emptyStateTitle: String {
        switch selectedFilter {
        case .active:
            return "Нет активных аскез"
        case .completed:
            return "Нет завершённых аскез"
        case .lifetime:
            return "Нет пожизненных аскез"
        }
    }
    
    private var emptyStateSubtitle: String {
        switch selectedFilter {
        case .active:
            return "Создайте новую аскезу, чтобы начать практику самосовершенствования"
        case .completed:
            return "Завершайте аскезы, чтобы видеть здесь свои достижения"
        case .lifetime:
            return "Пожизненные аскезы – это обязательства, которые вы берёте на всю жизнь"
        }
    }
    
    private var emptyStateIconName: String {
        switch selectedFilter {
        case .active:
            return "flame"
        case .completed:
            return "checkmark.circle"
        case .lifetime:
            return "infinity"
        }
    }
    
    private var emptyStateIconColor: Color {
        switch selectedFilter {
        case .active:
            return Color.orange
        case .completed:
            return Color.green
        case .lifetime:
            return Color.blue
        }
    }
}

private struct FilterButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(isSelected ? .white : AskezaTheme.textColor)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(isSelected ? AskezaTheme.accentColor : AskezaTheme.buttonBackground)
                )
        }
    }
} 