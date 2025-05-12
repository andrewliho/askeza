import SwiftUI

public struct MainView: View {
    @EnvironmentObject private var viewModel: AskezaViewModel
    // Временно отключено до оформления Apple Developer Program
    // @EnvironmentObject private var authModel: AuthenticationViewModel
    @State private var showingCreateAskeza = false
    @State private var showingAddWish = false
    @State private var showingSettings = false
    
    public init() {}
    
    public var body: some View {
        ZStack {
            TabView(selection: $viewModel.selectedTab) {
                NavigationView {
                    AskezaListView(viewModel: viewModel, showCreateAskeza: $showingCreateAskeza)
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
                        
                        // Кнопка "Добавить аскезу"
                        Button {
                            showingCreateAskeza = true
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
        .sheet(isPresented: $showingCreateAskeza) {
            NavigationView {
                AskezaCreationFlowView(
                    viewModel: viewModel,
                    isPresented: $showingCreateAskeza,
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