import SwiftUI

struct WishCardView: View {
    let wish: String?
    let wishStatus: WishStatus?
    @Binding var showingWishInput: Bool
    @State private var isFlipped = false
    @State private var degree = 0.0
    
    var body: some View {
        VStack {
            if wish != nil {
                // Карта с желанием
                Button(action: {
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                        isFlipped.toggle()
                        degree += 180
                    }
                }) {
                    ZStack {
                        // Рубашка карты
                        cardBack
                            .opacity(isFlipped ? 0 : 1)
                        
                        // Лицевая сторона с желанием
                        cardFront
                            .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
                            .opacity(isFlipped ? 1 : 0)
                    }
                    .rotation3DEffect(
                        .degrees(degree),
                        axis: (x: 0.0, y: 1.0, z: 0.0)
                    )
                    .scaleEffect(isFlipped ? 1.05 : 1.0)
                    .animation(.spring(response: 0.5, dampingFraction: 0.8), value: isFlipped)
                }
            } else {
                // Кнопка добавления желания
                Button(action: {
                    showingWishInput = true
                }) {
                    VStack(spacing: 12) {
                        Image(systemName: "gift.fill")
                            .font(.system(size: 40))
                        Text("Загадать желание")
                            .font(.system(size: 16, weight: .medium))
                    }
                    .foregroundColor(AskezaTheme.accentColor)
                    .frame(maxWidth: .infinity)
                    .frame(height: 200)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(AskezaTheme.buttonBackground)
                            .shadow(color: Color.black.opacity(0.1), radius: 10)
                    )
                }
            }
        }
        .padding(.horizontal)
    }
    
    private var cardBack: some View {
        VStack {
            Spacer()
            Image(systemName: "gift.fill")
                .font(.system(size: 50))
                .foregroundColor(AskezaTheme.accentColor)
            Text("Тайное желание")
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(AskezaTheme.textColor)
            
            if let status = wishStatus {
                HStack {
                    Image(systemName: wishStatusImage(for: status))
                    Text(status.rawValue)
                        .font(.system(size: 16, weight: .medium))
                }
                .foregroundColor(wishStatusColor(for: status))
                .padding(.top, 8)
            }
            
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .frame(height: 200)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(AskezaTheme.buttonBackground)
                .shadow(color: Color.black.opacity(0.1), radius: 10)
        )
    }
    
    private var cardFront: some View {
        VStack {
            Text(wish ?? "")
                .font(.system(size: 20, weight: .medium))
                .foregroundColor(AskezaTheme.textColor)
                .multilineTextAlignment(.center)
                .padding()
        }
        .frame(maxWidth: .infinity)
        .frame(height: 200)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(AskezaTheme.buttonBackground)
                .shadow(color: Color.black.opacity(0.1), radius: 10)
        )
    }
    
    private func wishStatusImage(for status: WishStatus) -> String {
        switch status {
        case .waiting:
            return "hourglass"
        case .fulfilled:
            return "checkmark.circle.fill"
        case .unfulfilled:
            return "xmark.circle.fill"
        }
    }
    
    private func wishStatusColor(for status: WishStatus) -> Color {
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
    VStack {
        WishCardView(wish: "Хочу научиться медитировать каждый день", wishStatus: .waiting, showingWishInput: .constant(false))
        WishCardView(wish: nil, wishStatus: nil, showingWishInput: .constant(false))
    }
    .padding()
    .background(AskezaTheme.backgroundColor)
} 