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
                    VStack(alignment: .leading, spacing: 8) {
                        Text(item.title.isEmpty ? "Untitled Idea" : item.title)
                            .font(.headline)
                        Text(item.ideaDescription)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                .onDelete(perform: deleteItems)
            }
            .navigationTitle("Saved Ideas")
        }
    }
}

#Preview {
    SavedView()
        .modelContainer(for: Item.self, inMemory: true)
} 