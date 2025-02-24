import SwiftUI

struct CardStyleSettingsView: View {
    @AppStorage("cardStyle") private var cardStyle = "Classic"
    let styles = ["Classic", "Modern", "Minimal"]
    
    var body: some View {
        List {
            ForEach(styles, id: \.self) { style in
                HStack {
                    Text(style)
                    Spacer()
                    if style == cardStyle {
                        Image(systemName: "checkmark")
                            .foregroundColor(.blue)
                    }
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    cardStyle = style
                }
            }
        }
        .navigationTitle("Card Style")
        .navigationBarTitleDisplayMode(.inline)
    }
} 