import SwiftUI

/// View for managing app settings and displaying app information.
/// Provides user configuration options and app details.
struct SettingsView: View {
    // MARK: - View Body
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    NavigationLink(destination: ThemeSettingsView()) {
                        Label("Theme", systemImage: "paintbrush")
                            .font(.system(size: 17))
                    }
                    NavigationLink(destination: CardStyleSettingsView()) {
                        Label("Card Style", systemImage: "rectangle.on.rectangle")
                            .font(.system(size: 17))
                    }
                } header: {
                    Text("Appearance")
                        .textCase(.uppercase)
                        .font(.system(size: 13, weight: .semibold))
                }
                
                Section {
                    Button(role: .destructive) {
                        // Clear data action
                    } label: {
                        Label("Clear All Data", systemImage: "trash")
                            .font(.system(size: 17))
                    }
                    
                    Button {
                        // Export action
                    } label: {
                        Label("Export Data", systemImage: "square.and.arrow.up")
                            .font(.system(size: 17))
                    }
                } header: {
                    Text("Data Management")
                        .textCase(.uppercase)
                        .font(.system(size: 13, weight: .semibold))
                }
                
                Section {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                    
                    Link(destination: URL(string: "https://example.com/privacy")!) {
                        Label("Privacy Policy", systemImage: "hand.raised")
                    }
                    
                    Link(destination: URL(string: "https://example.com/terms")!) {
                        Label("Terms of Service", systemImage: "doc.text")
                    }
                } header: {
                    Text("About")
                        .textCase(.uppercase)
                        .font(.system(size: 13, weight: .semibold))
                }
            }
            .navigationTitle("Settings")
        }
    }
}

#Preview {
    SettingsView()
} 