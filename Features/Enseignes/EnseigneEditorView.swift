import SwiftData
import SwiftUI
import UniformTypeIdentifiers

struct EnseigneEditorView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel: EnseigneEditorViewModel

    init(enseigne: Enseigne? = nil, household: Household? = nil) {
        _viewModel = State(initialValue: EnseigneEditorViewModel(enseigne: enseigne, household: household))
    }

    var body: some View {
        Form {
            TextField("Nom", text: $viewModel.name)
            HStack(spacing: SpacingTokens.md) {
                DSEnseigneLogo(imageData: viewModel.logoPreview, size: 64)
                Button("Choisir un logo", action: presentImporter)
                if viewModel.logoPreview != nil {
                    Button("Supprimer le logo", role: .destructive, action: viewModel.removeLogo)
                }
            }
            Text("Le logo est redimensionné à l’import et affiché en 16×16 dans le tableau.")
                .font(.caption)
                .foregroundStyle(ColorTokens.secondaryText)
            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .foregroundStyle(ColorTokens.debit)
            }
        }
        .formStyle(.grouped)
        .padding(SpacingTokens.lg)
        .frame(minWidth: 420, minHeight: 280)
        .navigationTitle(viewModel.isCreating ? "Nouvelle enseigne" : "Enseigne")
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Annuler", action: dismiss.callAsFunction)
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Enregistrer", action: save)
            }
        }
        .fileImporter(
            isPresented: $viewModel.isImporterPresented,
            allowedContentTypes: [.image, .png, .jpeg, .webP, .heic],
            allowsMultipleSelection: false,
            onCompletion: handleLogoResult
        )
    }

    private func presentImporter() {
        viewModel.isImporterPresented = true
    }

    private func handleLogoResult(_ result: Result<[URL], Error>) {
        switch result {
        case .success(let urls):
            guard let url = urls.first else { return }
            viewModel.importLogo(from: url)
        case .failure(let error):
            viewModel.errorMessage = error.localizedDescription
        }
    }

    private func save() {
        guard viewModel.save(in: modelContext) != nil else { return }
        dismiss()
    }
}
