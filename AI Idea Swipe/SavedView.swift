import SwiftUI
import SwiftData

/// View for displaying and managing saved date ideas.
/// Provides list view with deletion capability.
struct SavedView: View {
    // MARK: - Properties
    
    /// SwiftData context for managing saved items
    @Environment(\.modelContext) private var modelContext
    
    /// Collection of saved date ideas
    @Query private var items: [Item]
    
    // MARK: - Private Methods
    
    /// Deletes selected items from persistent storage
    /// - Parameter offsets: IndexSet of items to delete
    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(items[index])
            }
        }
    }
    
    var body: some View {
        NavigationView {
            List {
                ForEach(items) { item in
                    VStack(alignment: .leading, spacing: 12) {
                        Text(item.title.isEmpty ? "Untitled Idea" : item.title)
                            .font(.system(size: 20, weight: .semibold))
                            .padding(.top, 4)
                        
                        Text(item.ideaDescription)
                            .font(.system(size: 16))
                            .foregroundColor(.secondary)
                            .lineSpacing(4)
                            .padding(.bottom, 4)
                    }
                    .padding(.vertical, 8)
                }
                .onDelete(perform: deleteItems)
            }
            .navigationTitle("Saved Ideas")
            .listStyle(InsetGroupedListStyle())
        }
    }
}

#Preview {
    SavedView()
        .modelContainer(for: Item.self, inMemory: true)
} 