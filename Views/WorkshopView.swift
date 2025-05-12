import SwiftUI

struct WorkshopView: View {
    @State private var showingCreateAskeza = false
    @State private var selectedPresetAskeza: PresetAskeza?
    @State private var createdAskeza: Askeza?
    @State private var showAskezaDetail = false

    var body: some View {
        // ... existing code ...
        .sheet(isPresented: $showingCreateAskeza) {
            if let preset = selectedPresetAskeza {
                NavigationView {
                    CreateAskezaView(
                        viewModel: viewModel,
                        isPresented: $showingCreateAskeza,
                        presetTitle: preset.title,
                        category: preset.category
                    ) { newAskeza in
                        createdAskeza = newAskeza
                        showingCreateAskeza = false
                        showAskezaDetail = true
                    }
                }
            }
        }
        // ... existing code ...
    }

    private var viewModel: CreateAskezaViewModel {
        // Implementation of viewModel
        CreateAskezaViewModel()
    }
}

struct WorkshopView_Previews: PreviewProvider {
    static var previews: some View {
        WorkshopView()
    }
} 