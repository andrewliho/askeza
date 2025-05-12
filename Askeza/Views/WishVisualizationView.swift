import SwiftUI

struct WishVisualizationView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var timeRemaining = 60
    @State private var showingCompletionAlert = false
    @State private var currentStep = 0
    let onComplete: () -> Void
    
    let visualizationSteps = [
        "Закройте глаза и сделайте глубокий вдох...",
        "Представьте, что ваше желание уже исполнилось",
        "Почувствуйте радость и благодарность",
        "Ощутите, как изменилась ваша жизнь",
        "Запомните эти чувства..."
    ]
    
    var body: some View {
        ZStack {
            AskezaTheme.backgroundColor
                .ignoresSafeArea()
            
            VStack(spacing: 32) {
                Spacer()
                
                Text(visualizationSteps[currentStep])
                    .font(AskezaTheme.titleFont)
                    .foregroundColor(AskezaTheme.textColor)
                    .multilineTextAlignment(.center)
                    .animation(.easeInOut, value: currentStep)
                    .transition(.opacity)
                
                Spacer()
                
                // Таймер
                ZStack {
                    Circle()
                        .stroke(lineWidth: 8.0)
                        .opacity(0.3)
                        .foregroundColor(AskezaTheme.accentColor)
                    
                    Circle()
                        .trim(from: 0.0, to: CGFloat(timeRemaining) / 60.0)
                        .stroke(style: StrokeStyle(lineWidth: 8.0, lineCap: .round, lineJoin: .round))
                        .foregroundColor(AskezaTheme.accentColor)
                        .rotationEffect(Angle(degrees: 270.0))
                    
                    Text("\(timeRemaining)")
                        .font(.system(size: 50, weight: .bold, design: .rounded))
                        .foregroundColor(AskezaTheme.textColor)
                }
                .frame(width: 150, height: 150)
                
                Spacer()
                
                Button(action: {
                    showingCompletionAlert = true
                }) {
                    Text("Пропустить")
                        .font(AskezaTheme.bodyFont)
                        .foregroundColor(AskezaTheme.secondaryTextColor)
                        .padding()
                }
            }
            .padding()
        }
        .onAppear {
            startTimer()
        }
        .alert("Визуализация завершена", isPresented: $showingCompletionAlert) {
            Button("Сохранить желание") {
                onComplete()
                dismiss()
            }
        } message: {
            Text("Пусть ваше желание исполнится наилучшим образом")
        }
    }
    
    private func startTimer() {
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            if timeRemaining > 0 {
                timeRemaining -= 1
                if timeRemaining % 12 == 0 {
                    withAnimation {
                        currentStep = (currentStep + 1) % visualizationSteps.count
                    }
                }
            } else {
                timer.invalidate()
                showingCompletionAlert = true
            }
        }
    }
}

#Preview {
    WishVisualizationView(onComplete: {})
} 