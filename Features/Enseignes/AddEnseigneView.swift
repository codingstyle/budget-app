import SwiftData
import SwiftUI
import UniformTypeIdentifiers

struct AddEnseigneView: View {
    let household: Household?
    var onCreated: ((Enseigne) -> Void)?

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel: EnseigneEditorViewModel
    @FocusState private var isNameFocused: Bool

    init(household: Household?, onCreated: ((Enseigne) -> Void)? = nil) {
        self.household = household
        self.onCreated = onCreated
        _viewModel = State(initialValue: EnseigneEditorViewModel(enseigne: nil, household: household))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: SpacingTokens.sm) {
            HStack(spacing: SpacingTokens.md) {
                Button(action: presentImporter) {
                    DSEnseigneLogo(imageData: viewModel.logoPreview, size: 44)
                }
                .buttonStyle(.plain)
                .help("Choisir un logo")
                .accessibilityLabel("Choisir un logo")

                TextField("Nom de l’enseigne", text: $viewModel.name)
                    .textFieldStyle(.roundedBorder)
                    .focused($isNameFocused)
                    .onSubmit(save)
            }

            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .font(.caption)
                    .foregroundStyle(ColorTokens.debit)
            }
        }
        .padding(SpacingTokens.lg)
        .frame(minWidth: 340)
        .onAppear { isNameFocused = true }
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
        guard let enseigne = viewModel.save(in: modelContext) else { return }
        onCreated?(enseigne)
        dismiss()
    }
}
