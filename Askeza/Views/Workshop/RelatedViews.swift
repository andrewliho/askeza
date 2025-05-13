import SwiftUI

// Компонент для отображения информации об отсутствии шаблонов
struct NoTemplatesView: View {
    let message: String
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "tray")
                .font(.system(size: 40))
                .foregroundColor(AskezaTheme.secondaryTextColor)
            
            Text(message)
                .font(.headline)
                .foregroundColor(AskezaTheme.textColor)
                .multilineTextAlignment(.center)
        }
        .padding(32)
        .frame(maxWidth: .infinity)
    }
}

// Компонент для анимированного индикатора загрузки
struct LoadingView: View {
    var message: String = "Загрузка..."
    
    var body: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.5)
            
            Text(message)
                .font(.headline)
                .foregroundColor(AskezaTheme.secondaryTextColor)
        }
        .padding(32)
    }
}

// Кнопка для фильтрации
struct FilterButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .foregroundColor(isSelected ? .white : AskezaTheme.textColor)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(isSelected ? AskezaTheme.accentColor : Color.gray.opacity(0.2))
                )
        }
    }
}

// Компонент для информации о статусе шаблона
struct StatusBadge: View {
    let status: TemplateStatus
    
    var body: some View {
        HStack {
            Image(systemName: status.icon)
                .font(.system(size: 12))
                .foregroundColor(status.color)
            
            Text(status.rawValue)
                .font(.caption)
                .foregroundColor(status.color)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(status.color.opacity(0.1))
        .cornerRadius(8)
    }
}

#Preview {
    VStack(spacing: 20) {
        NoTemplatesView(message: "Шаблоны не найдены")
        
        LoadingView()
        
        HStack {
            FilterButton(title: "7 дней", isSelected: true) {}
            FilterButton(title: "30 дней", isSelected: false) {}
        }
        
        HStack {
            StatusBadge(status: .notStarted)
            StatusBadge(status: .inProgress)
            StatusBadge(status: .completed)
        }
    }
    .padding()
    .background(AskezaTheme.backgroundColor)
    .previewLayout(.sizeThatFits)
} 