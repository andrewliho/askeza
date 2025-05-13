import SwiftUI

public struct WishesView: View {
    @ObservedObject var viewModel: AskezaViewModel
    @State private var selectedFilter: WishStatus = .waiting
    @State private var showingAddWish = false
    
    private var filteredAskezas: [Askeza] {
        // Получаем все аскезы (активные и завершенные) с желаниями
        let allAskezasWithWishes = (viewModel.activeAskezas + viewModel.completedAskezas)
            .filter { $0.wish != nil }
        
        // Фильтруем по статусу, если он задан
        return allAskezasWithWishes.filter { askeza in
            // Если статус не задан, показываем только в режиме "ожидания"
            guard let status = askeza.wishStatus else {
                return selectedFilter == .waiting
            }
            return status == selectedFilter
        }
    }
    
    public var body: some View {
        ZStack {
            AskezaTheme.backgroundColor
                .ignoresSafeArea()
            
            VStack(spacing: 16) {
                // Фильтры
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach([WishStatus.waiting, .fulfilled], id: \.rawValue) { status in
                            FilterButton(title: status.rawValue,
                                       isSelected: selectedFilter == status) {
                                selectedFilter = status
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                
                if filteredAskezas.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "gift")
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
                                WishListItem(askeza: askeza, viewModel: viewModel)
                            }
                        }
                        .padding()
                    }
                }
            }
        }
        .navigationTitle("Ваши Желания")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingAddWish) {
            NavigationView {
                AddWishView(viewModel: viewModel, isPresented: $showingAddWish)
            }
        }
    }
    
    private var emptyStateMessage: String {
        switch selectedFilter {
        case .waiting:
            return "Нет желаний, ожидающих исполнения"
        case .fulfilled:
            return "Нет исполненных желаний"
        case .unfulfilled:
            return "Нет неисполненных желаний"
        }
    }
}

struct AddWishView: View {
    @ObservedObject var viewModel: AskezaViewModel
    @Binding var isPresented: Bool
    @State private var selectedAskeza: Askeza?
    @State private var wishText = ""
    @State private var showingWishInput = false
    @State private var showingCreateAskeza = false
    @State private var showingVisualization = false
    @State private var tempWishText = ""
    @State private var selectedAskezaForWish: Askeza?
    
    private var askezasWithoutWish: [Askeza] {
        viewModel.activeAskezas.filter { $0.wish == nil }
    }
    
    var body: some View {
        ZStack {
            AskezaTheme.backgroundColor
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
                if askezasWithoutWish.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "sparkles")
                            .font(.system(size: 50))
                            .foregroundColor(AskezaTheme.secondaryTextColor)
                        
                        Text("Для того чтобы загадать желание,\nнужно сначала дать обет")
                            .font(AskezaTheme.bodyFont)
                            .foregroundColor(AskezaTheme.secondaryTextColor)
                            .multilineTextAlignment(.center)
                        
                        AskezaButton(title: "Создать новую аскезу") {
                            showingCreateAskeza = true
                        }
                    }
                    .padding()
                } else {
                    if showingWishInput {
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Загадайте желание")
                                .font(AskezaTheme.subtitleFont)
                                .foregroundColor(AskezaTheme.textColor)
                            
                            Text("Для аскезы: \(selectedAskeza?.title ?? "")")
                                .font(AskezaTheme.bodyFont)
                                .foregroundColor(AskezaTheme.secondaryTextColor)
                            
                            AskezaTextField(placeholder: "Введите ваше желание", text: $wishText)
                            
                            AskezaButton(title: "Визуализировать") {
                                tempWishText = wishText
                                selectedAskezaForWish = selectedAskeza
                                showingVisualization = true
                            }
                            .disabled(wishText.isEmpty)
                            .opacity(wishText.isEmpty ? 0.5 : 1)
                        }
                        .padding()
                        .sheet(isPresented: $showingVisualization) {
                            WishVisualizationView {
                                if let askeza = selectedAskezaForWish {
                                    // Сохраняем желание и устанавливаем статус "ожидание"
                                    viewModel.updateWish(askeza, newWish: tempWishText)
                                    viewModel.updateWishStatus(askeza, status: .waiting)
                                    isPresented = false
                                }
                            }
                        }
                    } else {
                        Text("Выберите аскезу для желания")
                            .font(AskezaTheme.subtitleFont)
                            .foregroundColor(AskezaTheme.textColor)
                            .padding()
                        
                        ScrollView {
                            LazyVStack(spacing: 16) {
                                ForEach(askezasWithoutWish) { askeza in
                                    AskezaCardView(askeza: askeza) {
                                        // Пустой обработчик удаления, так как карточка только для выбора
                                    }
                                    .contentShape(Rectangle())
                                    .onTapGesture {
                                        selectedAskeza = askeza
                                        showingWishInput = true
                                    }
                                }
                            }
                            .padding()
                        }
                    }
                }
            }
        }
        .navigationTitle("Загадать желание")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                if showingWishInput {
                    Button("Назад") {
                        showingWishInput = false
                    }
                    .foregroundColor(AskezaTheme.accentColor)
                } else {
                    Button("Отмена") {
                        isPresented = false
                    }
                    .foregroundColor(AskezaTheme.accentColor)
                }
            }
        }
        .sheet(isPresented: $showingCreateAskeza) {
            NavigationView {
                // Используем CreateAskezaView для прямого создания аскезы
                CreateAskezaView(
                    viewModel: viewModel,
                    isPresented: $showingCreateAskeza
                ) { newAskeza in
                    selectedAskeza = newAskeza
                    showingWishInput = true
                }
            }
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

private struct WishListItem: View {
    let askeza: Askeza
    @ObservedObject var viewModel: AskezaViewModel
    @State private var showingWishStatusSheet = false
    @State private var showingDeleteConfirmation = false
    @State private var showingEditWishDialog = false
    @State private var editedWishText = ""
    @State private var giftIconColor = Color.purple // Начальный цвет
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Spacer()
                Image(systemName: askeza.category.systemImage)
                    .font(.system(size: 24))
                    .foregroundColor(AskezaTheme.accentColor)
                
                Text(askeza.title)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(AskezaTheme.textColor)
                    .multilineTextAlignment(.center)
                Spacer()
            }
            
            Button(action: {
                showingWishStatusSheet = true
            }) {
                Image(systemName: "gift.fill")
                    .font(.system(size: 96))
                    .foregroundColor(giftIconColor)
                    .padding(.vertical, 8)
            }
            
            if let wish = askeza.wish {
                Text(wish)
                    .font(.system(size: 16))
                    .foregroundColor(AskezaTheme.secondaryTextColor)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
            }
            
            // Статус аскезы (активная или завершенная)
            if askeza.isCompleted {
                Text("Аскеза завершена")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Color.green)
                    .padding(.vertical, 4)
            } else {
                if case .days(let duration) = askeza.duration {
                    Text("Аскеза в процессе: \(askeza.progress)/\(duration) дней")
                        .font(.system(size: 14))
                        .foregroundColor(AskezaTheme.secondaryTextColor)
                } else {
                    Text("Пожизненная аскеза: \(askeza.progress) дней")
                        .font(.system(size: 14))
                        .foregroundColor(AskezaTheme.secondaryTextColor)
                }
            }
            
            // Статус желания
            if let status = askeza.wishStatus {
                HStack {
                    Spacer()
                    Image(systemName: statusImage(for: status))
                        .foregroundColor(statusColor(for: status))
                    
                    Text(status.rawValue)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(statusColor(for: status))
                    Spacer()
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(AskezaTheme.buttonBackground)
        )
        .contextMenu {
            Button {
                editedWishText = askeza.wish ?? ""
                showingEditWishDialog = true
            } label: {
                Label("Перезагадать желание", systemImage: "pencil")
            }
            
            Button(role: .destructive) {
                showingDeleteConfirmation = true
            } label: {
                Label("Удалить", systemImage: "trash")
            }
        }
        .alert("Удалить желание?", isPresented: $showingDeleteConfirmation) {
            Button("Отмена", role: .cancel) { }
            Button("Удалить", role: .destructive) {
                withAnimation {
                    viewModel.updateWish(askeza, newWish: nil)
                }
            }
        } message: {
            Text("Это действие нельзя отменить")
        }
        .alert("Перезагадать желание", isPresented: $showingEditWishDialog) {
            TextField("Желание", text: $editedWishText)
            Button("Отмена", role: .cancel) { }
            Button("Сохранить") {
                if !editedWishText.isEmpty {
                    viewModel.updateWish(askeza, newWish: editedWishText)
                }
            }
        }
        .confirmationDialog("Исполнилось ли желание?",
                          isPresented: $showingWishStatusSheet,
                          titleVisibility: .visible) {
            Button("Исполнилось") {
                viewModel.updateWishStatus(askeza, status: .fulfilled)
            }
            Button("Ожидает исполнения") {
                viewModel.updateWishStatus(askeza, status: .waiting)
            }
            Button("Отмена", role: .cancel) {}
        }
        .onAppear {
            withAnimation(Animation.easeInOut(duration: 2.0).repeatForever()) {
                giftIconColor = Color.pink
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                withAnimation(Animation.easeInOut(duration: 2.0).repeatForever()) {
                    giftIconColor = Color.blue
                }
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
                withAnimation(Animation.easeInOut(duration: 2.0).repeatForever()) {
                    giftIconColor = Color.purple
                }
            }
        }
    }
    
    private func statusImage(for status: WishStatus) -> String {
        switch status {
        case .waiting:
            return "hourglass"
        case .fulfilled:
            return "checkmark.circle.fill"
        case .unfulfilled:
            return "xmark.circle.fill"
        }
    }
    
    private func statusColor(for status: WishStatus) -> Color {
        switch status {
        case .waiting:
            return .orange
        case .fulfilled:
            return .green
        case .unfulfilled:
            return .red
        }
    }
}

#Preview {
    NavigationView {
        WishesView(viewModel: AskezaViewModel())
    }
} 