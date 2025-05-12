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
    @State private var isExtendingAskeza = false
    
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
                        VStack(spacing: 16) {
                            Image(systemName: "sparkles")
                                .font(.system(size: 50))
                                .foregroundColor(AskezaTheme.secondaryTextColor)
                            
                            Text(emptyStateMessage)
                                .font(AskezaTheme.bodyFont)
                                .foregroundColor(AskezaTheme.secondaryTextColor)
                                .multilineTextAlignment(.center)
                        }
                        .padding()
                        Spacer()
                    } else {
                        ScrollView {
                            LazyVStack(spacing: 16) {
                                ForEach(filteredAskezas) { askeza in
                                    Button {
                                        selectedAskeza = askeza
                                        showAskezaDetail = true
                                    } label: {
                                        AskezaCardView(
                                            askeza: askeza,
                                            onDelete: {
                                                viewModel.deleteAskeza(askeza)
                                            },
                                            onComplete: {
                                                viewModel.completeAskeza(askeza)
                                            },
                                            onExtend: {
                                                selectedAskeza = askeza
                                                isExtendingAskeza = true
                                                showCreateAskeza = true
                                            },
                                            onProgressUpdate: { newProgress in
                                                viewModel.updateProgress(askeza, newProgress: newProgress)
                                            }
                                        )
                                    }
                                    .contextMenu {
                                        Button(action: {
                                            UIPasteboard.general.string = formatAskezaHashtag(askeza)
                                            withAnimation {
                                                showCopiedToast = true
                                            }
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                                withAnimation {
                                                    showCopiedToast = false
                                                }
                                            }
                                        }) {
                                            Label("Скопировать хэштег", systemImage: "doc.on.doc")
                                        }
                                        
                                        Button(role: .destructive) {
                                            askezaToDelete = askeza
                                            showingDeleteConfirmation = true
                                        } label: {
                                            Label("Удалить", systemImage: "trash")
                                        }
                                    }
                                }
                            }
                            .padding()
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
        .sheet(isPresented: $showCreateAskeza, onDismiss: {
            isExtendingAskeza = false
        }) {
            NavigationView {
                if isExtendingAskeza, let askeza = selectedAskeza, 
                   selectedFilter == .active {
                    CreateAskezaView(
                        viewModel: viewModel,
                        isPresented: $showCreateAskeza,
                        existingAskeza: askeza,
                        category: askeza.category
                    )
                    .onDisappear {
                        isExtendingAskeza = false
                    }
                } else {
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
    
    private var emptyStateMessage: String {
        switch selectedFilter {
        case .active:
            return "Нет активных аскез\nСоздайте новую аскезу"
        case .completed:
            return "Нет завершённых аскез\nЗавершите аскезу, чтобы увидеть её здесь"
        case .lifetime:
            return "Нет пожизненных аскез\nСоздайте пожизненную аскезу"
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