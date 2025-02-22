//
//  ContentView.swift
//  AI Idea Swipe
//
//  Created by Ihor Pokrovetskyi on 2/21/25.
//

import SwiftUI
import SwiftData

/// The main view controller for the AI Idea Swipe app.
/// Manages the tab navigation and core functionality for generating and managing date ideas.
struct ContentView: View {
    // MARK: - Properties
    
    /// The SwiftData model context for persistent storage
    @Environment(\.modelContext) private var modelContext
    
    /// Collection of saved date ideas
    @Query private var items: [Item]
    
    /// Current offset for the card swipe animation
    @State private var offset: CGSize = .zero
    
    /// Background color that changes during swipe gestures
    @State private var color: Color = .white
    
    /// Currently selected tab index
    @State private var selectedTab = 0
    
    /// Currently displayed date idea
    @State private var currentIdea: (title: String, description: String) = ("", "")
    
    /// Loading state indicator
    @State private var isLoading = false
    
    /// Service for generating AI date ideas
    private let openAIService = OpenAIService()
    
    var body: some View {
        TabView(selection: $selectedTab) {
            DateIdeaView(
                currentIdea: $currentIdea,
                isLoading: $isLoading,
                offset: $offset,
                color: $color,
                modelContext: modelContext,
                generateNewIdea: generateNewIdea,
                handleSwipe: handleSwipe
            )
            .tabItem {
                Image(systemName: "heart.fill")
                Text("Date Ideas")
            }
            .tag(0)
            
            SavedView()
                .tabItem {
                    Image(systemName: "bookmark.fill")
                    Text("Saved")
                }
                .tag(1)
            
            SettingsView()
                .tabItem {
                    Image(systemName: "gear")
                    Text("Settings")
                }
                .tag(2)
        }
        .onAppear {
            generateNewIdea()
        }
    }
    
    private func generateNewIdea() {
        guard !isLoading else { return }
        isLoading = true
        
        Task {
            do {
                let ideaText = try await openAIService.generateIdea()
                let components = ideaText.components(separatedBy: "\n")
                
                let title = components.first?.replacingOccurrences(of: "Title: ", with: "") ?? ""
                let description = components.last?.replacingOccurrences(of: "Description: ", with: "") ?? ""
                
                await MainActor.run {
                    currentIdea = (title, description)
                    isLoading = false
                }
            } catch {
                print("Error generating idea: \(error)")
                await MainActor.run {
                    currentIdea = ("Error", "Failed to generate idea. Please try again.")
                    isLoading = false
                }
            }
        }
    }
    
    private func handleSwipe(width: CGFloat) {
        let card = offset.width
        
        if abs(card) > 100 {
            // Swipe right (save)
            if card > 0 {
                offset.width = 500
                let newItem = Item(title: currentIdea.title, ideaDescription: currentIdea.description)
                modelContext.insert(newItem)
                
                // Generate new idea after saving
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    generateNewIdea()
                }
            }
            // Swipe left (dismiss)
            else {
                offset.width = -500
                // Generate new idea after dismissing
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    generateNewIdea()
                }
            }
            
            // Reset position
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                offset = .zero
            }
        } else {
            // Reset position if not swiped far enough
            offset = .zero
        }
    }
}

// Create a separate view for the date idea card
struct DateIdeaView: View {
    @Binding var currentIdea: (title: String, description: String)
    @Binding var isLoading: Bool
    @Binding var offset: CGSize
    @Binding var color: Color
    let modelContext: ModelContext
    let generateNewIdea: () -> Void
    let handleSwipe: (CGFloat) -> Void
    
    var body: some View {
        ZStack {
            Color(.systemBackground)
            
            GeometryReader { geometry in
                VStack {
                    Spacer()
                    
                    HStack {
                        Spacer()
                        CardView(
                            currentIdea: currentIdea,
                            isLoading: isLoading,
                            offset: $offset,
                            color: $color,
                            handleSwipe: handleSwipe
                        )
                        Spacer()
                    }
                    
                    Spacer()
                }
            }
        }
    }
}

// Create a separate view for the card
struct CardView: View {
    @Environment(\.colorScheme) private var colorScheme
    let currentIdea: (title: String, description: String)
    let isLoading: Bool
    @Binding var offset: CGSize
    @Binding var color: Color
    let handleSwipe: (CGFloat) -> Void
    
    var body: some View {
        ZStack {
            VStack(spacing: 20) {
                if isLoading {
                    Spacer()
                    ProgressView()
                        .scaleEffect(1.5)
                    Spacer()
                } else {
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 20) {
                            Text(currentIdea.title)
                                .font(.system(size: 24, weight: .bold))
                                .multilineTextAlignment(.center)
                                .foregroundColor(colorScheme == .dark ? .black : .primary)
                                .padding(.top, 40)
                                .padding(.horizontal)
                            
                            Text(currentIdea.description)
                                .font(.system(size: 18))
                                .multilineTextAlignment(.leading)
                                .fixedSize(horizontal: false, vertical: true)
                                .padding(.horizontal, 25)
                                .foregroundColor(colorScheme == .dark ? .black.opacity(0.7) : .secondary)
                                .padding(.bottom, 20)
                                .lineSpacing(4)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                    
                    Spacer(minLength: 0)
                    
                    HStack {
                        Text("← Skip")
                            .foregroundColor(.red)
                        Spacer()
                        Text("Save →")
                            .foregroundColor(.green)
                    }
                    .padding(.horizontal, 40)
                    .padding(.bottom, 30)
                }
            }
            .frame(width: 320)
            .frame(minHeight: 400, maxHeight: 600)
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .fill(colorScheme == .dark ? .white : .white)
                    .shadow(radius: 10)
            )
            .offset(offset)
            .rotationEffect(.degrees(Double(offset.width / 20)))
            .gesture(
                DragGesture()
                    .onChanged { gesture in
                        offset = gesture.translation
                        withAnimation {
                            color = offset.width > 0 ? .green.opacity(0.2) : .red.opacity(0.2)
                        }
                    }
                    .onEnded { _ in
                        withAnimation {
                            handleSwipe(offset.width)
                            color = .white
                        }
                    }
            )
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}

