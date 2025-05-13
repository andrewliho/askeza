import SwiftUI

// Расширяем функциональность проверки шаблонов
import Foundation

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
            }
            .tabItem {
                Label("Аскезы", systemImage: "house.fill")
            }
            .tag(AskezaViewModel.Tab.askezas)
            
            NavigationView {
                    WorkshopV2View()
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
        .onChange(of: viewModel.selectedTab) { oldTab, newTab in
            // При переключении вкладок принудительно проверяем и перемещаем завершенные аскезы
            viewModel.forceCheckCompletedAskezas()
            
            // Логируем для отладки
            print("Переключение вкладки: \(oldTab) -> \(newTab)")
        }
            
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
                CreateAskezaView(
                    viewModel: viewModel,
                    isPresented: $showingGlobalCreateAskeza
                )
            }
        }
        .sheet(isPresented: $showingAddWish) {
            NavigationView {
                AddWishView(viewModel: viewModel, isPresented: $showingAddWish)
            }
        }
        .onAppear {
            // Настройка обработчиков уведомлений
            setupNotifications()
            
            // Запускаем валидатор шаблонов для поиска несоответствий
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                print("⚙️ MainView: Обратите внимание - необходимо запустить валидацию шаблонов")
                print("⚙️ MainView: Проверьте совпадение количества дней в названии шаблона и его поле duration")
                
                // Очищаем дубликаты шаблонов
                PracticeTemplateStore.shared.cleanupDuplicateTemplates()
            }
        }
    }
    
    // Настройка обработчиков уведомлений
    private func setupNotifications() {
        // Удаляем обработчик уведомлений о создании аскезы в MainView,
        // так как AskezaViewModel уже обрабатывает это уведомление
        // и двойная обработка приводит к дублированию аскез
        
        // В будущем здесь могут быть другие обработчики уведомлений, специфичные для MainView
        print("🔔 MainView: Настройка обработчиков уведомлений завершена")
    }
}

#Preview {
    MainView()
        .environmentObject(AskezaViewModel())
        // Временно отключено до оформления Apple Developer Program
        // .environmentObject(AuthenticationViewModel())
} 