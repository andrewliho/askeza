import SwiftUI

public struct MainView: View {
    @EnvironmentObject private var viewModel: AskezaViewModel
    // Временно отключено до оформления Apple Developer Program
    // @EnvironmentObject private var authModel: AuthenticationViewModel
    
    // Разделяем флаги для каждого view
    @State private var showingGlobalCreateAskeza = false
    @State private var showingAddWish = false
    @State private var showingSettings = false
    
    // Флаги для передачи в другие view
    @State private var listShowCreateAskeza = false
    
    public init() {}
    
    public var body: some View {
        ZStack {
            TabView(selection: $viewModel.selectedTab) {
                NavigationView {
                    AskezaListView(viewModel: viewModel, showCreateAskeza: $listShowCreateAskeza)
                        /* Временно отключено
                        .toolbar {
                            ToolbarItem(placement: .navigationBarTrailing) {
                                Button(action: {
                                    showingSettings = true
                                }) {
                                    Image(systemName: "gearshape")
                                        .foregroundColor(AskezaTheme.accentColor)
                                }
                            }
                        }
                        */
                }
                .tabItem {
                    Label("Аскезы", systemImage: "house.fill")
                }
                .tag(AskezaViewModel.Tab.askezas)
                
                NavigationView {
                    WorkshopView(viewModel: viewModel)
                }
                .tabItem {
                    Label("Мастерская", systemImage: "figure.mind.and.body")
                }
                .tag(AskezaViewModel.Tab.workshop)
                
                NavigationView {
                    WishesView(viewModel: viewModel)
                }
                .tabItem {
                    Label("Желания", systemImage: "gift.fill")
                }
                .tag(AskezaViewModel.Tab.wishes)
                
                /* Временно отключено до оформления Apple Developer Program
                NavigationView {
                    if authModel.user != nil {
                        ProfileView()
                    } else {
                        AuthenticationView()
                    }
                }
                .tabItem {
                    Label("Профиль", systemImage: "person.fill")
                }
                .tag(AskezaViewModel.Tab.profile)
                */
            }
            .tint(AskezaTheme.accentColor)
            
            // Плавающие кнопки
            VStack {
                Spacer()
                
                HStack {
                    Spacer()
                    
                    HStack(spacing: 16) {
                        // Кнопка "Загадать желание" - показываем только на экране желаний
                        if viewModel.selectedTab == .wishes {
                            Button {
                                showingAddWish = true
                            } label: {
                                Circle()
                                    .fill(Color("PurpleAccent"))
                                    .frame(width: 50, height: 50)
                                    .overlay(
                                        Image(systemName: "gift.fill")
                                            .font(.system(size: 20))
                                            .foregroundColor(.white)
                                    )
                                    .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 2)
                            }
                        }
                        
                        // Кнопка "Добавить аскезу" - не показываем на экране желаний
                        if viewModel.selectedTab != .wishes {
                            Button {
                                // Используем отдельный флаг для FloatingButton
                                showingGlobalCreateAskeza = true
                            } label: {
                                Circle()
                                    .fill(AskezaTheme.accentColor)
                                    .frame(width: 50, height: 50)
                                    .overlay(
                                        Image(systemName: "plus")
                                            .font(.system(size: 20))
                                            .foregroundColor(.white)
                                    )
                                    .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 2)
                            }
                        }
                    }
                    .padding(.trailing, 20)
                    .padding(.bottom, 80) // Отступ для расположения над TabBar
                }
            }
        }
        .sheet(isPresented: $showingSettings) {
            NavigationView {
                SettingsView(viewModel: viewModel)
            }
        }
        // Полностью отдельная форма создания аскезы для кнопки в MainView
        .sheet(isPresented: $showingGlobalCreateAskeza) {
            NavigationView {
                AskezaCreationFlowView(
                    viewModel: viewModel,
                    isPresented: $showingGlobalCreateAskeza,
                    onCreated: nil
                )
            }
        }
        .sheet(isPresented: $showingAddWish) {
            NavigationView {
                AddWishView(viewModel: viewModel, isPresented: $showingAddWish)
            }
        }
    }
}

#Preview {
    MainView()
        .environmentObject(AskezaViewModel())
        // Временно отключено до оформления Apple Developer Program
        // .environmentObject(AuthenticationViewModel())
} 