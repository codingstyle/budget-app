import SwiftData
import SwiftUI

struct TagsSidebarView: View {
    let filterText: String
    let addToken: Int

    @Query(sort: \Tag.label) private var tags: [Tag]
    @Query private var households: [Household]
    @Environment(AppSession.self) private var session
    @State private var isEditorPresented = false
    @State private var tagBeingEdited: Tag?
    @State private var parentForNewTag: Tag?

    var body: some View {
        VStack(alignment: .leading, spacing: SpacingTokens.xs) {
            Button(action: clearTagFilter) {
                Label {
                    Text("Toutes les étiquettes")
                        .foregroundStyle(.black)
                        .lineLimit(1)
                        .frame(maxWidth: .infinity, alignment: .leading)
                } icon: {
                    DSTagGlyph(symbolName: "tag", colorHex: "#6B7280")
                }
                .padding(.horizontal, SpacingTokens.sm)
                .padding(.vertical, SpacingTokens.xs)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    session.selectedTagID == nil ? ColorTokens.accent.opacity(0.16) : Color.clear,
                    in: RoundedRectangle(cornerRadius: 6)
                )
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .padding(.horizontal, SpacingTokens.sm)
            .accessibilityLabel("Toutes les étiquettes")
            .accessibilityAddTraits(session.selectedTagID == nil ? .isSelected : [])

            ScrollView {
                LazyVStack(alignment: .leading, spacing: 2) {
                    ForEach(treeNodes) { node in
                        TagTreeOutline(
                            node: node,
                            selectedID: session.selectedTagID,
                            onSelect: toggle,
                            onEdit: { tagBeingEdited = $0 },
                            onAddChild: addChild(to:)
                        )
                    }
                }
                .padding(.horizontal, SpacingTokens.sm)
                .padding(.bottom, SpacingTokens.sm)
            }
        }
        .padding(.top, SpacingTokens.sm)
        .onChange(of: addToken) { _, _ in
            addRootTag()
        }
        .sheet(item: $tagBeingEdited, content: editorSheet)
        .sheet(isPresented: $isEditorPresented, content: newTagSheet)
    }

    private var treeNodes: [TagTreeNode] {
        TagTreeNode.roots(from: Array(tags), filter: filterText)
    }

    private func addRootTag() {
        parentForNewTag = nil
        isEditorPresented = true
    }

    private func addChild(to tag: Tag) {
        parentForNewTag = tag
        isEditorPresented = true
    }

    private func clearTagFilter() {
        session.selectedTagID = nil
    }

    private func toggle(_ tag: Tag) {
        if session.selectedTagID == tag.persistentModelID {
            session.selectedTagID = nil
        } else {
            session.selectedTagID = tag.persistentModelID
        }
    }

    @ViewBuilder
    private func editorSheet(_ tag: Tag) -> some View {
        if let household = tag.household ?? households.first {
            TagEditorView(tag: tag, household: household, availableTags: tags)
        }
    }

    @ViewBuilder
    private func newTagSheet() -> some View {
        if let household = households.first {
            TagEditorView(
                tag: nil,
                household: household,
                parent: parentForNewTag,
                availableTags: tags
            )
        }
    }
}
