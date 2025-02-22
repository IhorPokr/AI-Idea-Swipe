import SwiftUI

/// View for managing app settings and displaying app information.
/// Provides user configuration options and app details.
struct SettingsView: View {
    // MARK: - View Body
    
    var body: some View {
        NavigationView {
            List {
                Section("Appearance") {
                    Text("Theme")
                    Text("Card Style")
                }
                
                Section("Data") {
                    Text("Clear All Data")
                    Text("Export Data")
                }
                
                Section("About") {
                    Text("Version 1.0")
                    Text("Privacy Policy")
                    Text("Terms of Service")
                }
            }
            .navigationTitle("Settings")
        }
    }
}

#Preview {
    SettingsView()
} 