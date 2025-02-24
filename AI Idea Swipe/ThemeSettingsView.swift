import SwiftUI

struct ThemeSettingsView: View {
    @AppStorage("appTheme") private var appTheme = "System"
    let themes = ["System", "Light", "Dark"]
    
    var body: some View {
        List {
            ForEach(themes, id: \.self) { theme in
                HStack {
                    Text(theme)
                    Spacer()
                    if theme == appTheme {
                        Image(systemName: "checkmark")
                            .foregroundColor(.blue)
                    }
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    appTheme = theme
                }
            }
        }
        .navigationTitle("Theme")
        .navigationBarTitleDisplayMode(.inline)
    }
} 