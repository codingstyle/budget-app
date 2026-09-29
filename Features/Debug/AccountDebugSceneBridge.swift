import SwiftData
import SwiftUI

struct AccountDebugSceneBridge: ViewModifier {
    @Environment(\.modelContext) private var modelContext
    @Environment(AppSession.self) private var session
    @State private var handler = AccountDebugHandler()

    func body(content: Content) -> some View {
        content
            .focusedSceneValue(\.accountDebugHandler, handler)
            .onAppear(perform: syncHandler)
            .onChange(of: session.selectedAccountID) {
                syncHandler()
            }
    }

    private func syncHandler() {
        handler.modelContext = modelContext
        handler.session = session
        handler.selectedAccountID = session.selectedAccountID
    }
}
