import SwiftUI
import Foundation

struct AskezasView: View {
    @ObservedObject var viewModel: AskezaViewModel
    
    var body: some View {
        Text("Активные аскезы")
    }
    
    private var askezasWithUniqueIDs: [Askeza] {
        var uniqueAskezas: [Askeza] = []
        var seenIDs: Set<UUID> = []
        
        for askeza in viewModel.activeAskezas {
            if !seenIDs.contains(askeza.id) {
                uniqueAskezas.append(askeza)
                seenIDs.insert(askeza.id)
            } else {
                print("⚠️ AskezasView: Обнаружен дубликат аскезы с ID \(askeza.id) - \(askeza.title), пропускаем")
            }
        }
        
        return uniqueAskezas
    }
} 