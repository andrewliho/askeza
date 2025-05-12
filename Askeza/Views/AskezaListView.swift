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
    
    private enum AskezaFilter: String, CaseIterable {
        case active = "Активные"
        case completed = "Завершённые"
        case lifetime = "Пожизненные"
    }
    
    private var filteredAskezas: [Askeza] {
        if searchText.isEmpty {
            switch selectedFilter {
            case .active:
                return viewModel.activeAskezas.filter { askeza in
                    if case .lifetime = askeza.duration { return false }
                    return true
                }
            case .completed:
                return viewModel.completedAskezas
            case .lifetime:
                return viewModel.activeAskezas.filter { askeza in
                    if case .lifetime = askeza.duration { return true }
                    return false
                }
            }
        } else {
            let searchQuery = searchText.lowercased()
            
            // Выбираем коллекцию на основе фильтра
            let askezas: [Askeza]
            switch selectedFilter {
            case .active:
                askezas = viewModel.activeAskezas.filter { askeza in
                    if case .lifetime = askeza.duration { return false }
                    return true
                }
            case .completed:
                askezas = viewModel.completedAskezas
            case .lifetime:
                askezas = viewModel.activeAskezas.filter { askeza in
                    if case .lifetime = askeza.duration { return true }
                    return false
                }
            }
            
            // Применяем поиск к выбранной коллекции
            return askezas.filter { askeza in
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
        }
        // Отдельная sheet для продления аскезы
        .sheet(isPresented: $showExtendForm) {
            NavigationView {
                if let askeza = askezaToExtend, selectedFilter == .active {
                    CreateAskezaView(
                        viewModel: viewModel,
                        isPresented: $showExtendForm,
                        existingAskeza: askeza,
                        category: askeza.category
                    )
                }
            }
        }
        // Оставляем sheet для создания новой аскезы из внешних источников (MainView)
        .sheet(isPresented: $showCreateAskeza) {
            NavigationView {
                AskezaCreationFlowView(
                    viewModel: viewModel,
                    isPresented: $showCreateAskeza,
                    onCreated: { newAskeza in
                        selectedAskeza = newAskeza
                        showAskezaDetail = true
                    }
                )
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
    
    // Выносим отображение сетки аскез в отдельное свойство
    private var askezaGridView: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 160), spacing: 12)], spacing: 12) {
                ForEach(filteredAskezas) { askeza in
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
                                viewModel.completeAskeza(askeza)
                            },
                            onExtend: {
                                askezaToExtend = askeza
                                showExtendForm = true
                            },
                            onProgressUpdate: { newProgress in
                                viewModel.updateProgress(askeza, newProgress: newProgress)
                            }
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding()
        }
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