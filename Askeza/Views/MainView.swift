import SwiftUI

public struct MainView: View {
    @EnvironmentObject private var viewModel: AskezaViewModel
    // Временно отключено до оформления Apple Developer Program
    // @EnvironmentObject private var authModel: AuthenticationViewModel
    @State private var showingCreateAskeza = false
    @State private var showingSettings = false
    
    public init() {}
    
    public var body: some View {
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
        .sheet(isPresented: $showingSettings) {
            NavigationView {
                SettingsView(viewModel: viewModel)
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