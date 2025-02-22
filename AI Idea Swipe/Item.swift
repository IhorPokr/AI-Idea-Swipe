//
//  Item.swift
//  AI Idea Swipe
//
//  Created by Ihor Pokrovetskyi on 2/21/25.
//

import Foundation
import SwiftData

/// Represents a saved date idea in the app's persistent storage.
/// Conforms to SwiftData's @Model protocol for database management.
@Model
final class Item {
    // MARK: - Properties
    
    /// Unique identifier for the date idea
    var id: UUID
    
    /// Title of the date idea
    var title: String
    
    /// Detailed description of the date idea
    var ideaDescription: String
    
    /// Timestamp when the idea was saved
    var timestamp: Date
    
    // MARK: - Initialization
    
    /// Creates a new date idea item
    /// - Parameters:
    ///   - id: Unique identifier (defaults to new UUID)
    ///   - title: Title of the date idea
    ///   - ideaDescription: Detailed description
    ///   - timestamp: Creation time (defaults to current time)
    init(id: UUID = UUID(), title: String = "", ideaDescription: String = "", timestamp: Date = Date()) {
        self.id = id
        self.title = title
        self.ideaDescription = ideaDescription
        self.timestamp = timestamp
    }
}
