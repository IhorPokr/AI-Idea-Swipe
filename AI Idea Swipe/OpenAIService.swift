import Foundation

/// Service responsible for generating date ideas using OpenAI's GPT API.
/// Manages API communication and ensures idea uniqueness.
class OpenAIService {
    // MARK: - Properties
    
    /// API key for OpenAI authentication
    private var apiKey: String = Config.openAIKey
    
    /// Set of previously generated ideas to avoid repetition
    private var previousIdeas: Set<String> = []
    
    // MARK: - Public Methods
    
    /// Generates a new unique date idea using OpenAI's GPT model
    /// - Returns: A formatted string containing the idea title and description
    /// - Throws: URLError if the API request fails
    func generateIdea() async throws -> String {
        let categories = [
            "Cozy Indoor Fun",
            "Local Exploring",
            "Food Adventures",
            "Creative Moments",
            "Nature & Parks",
            "Sweet Treats",
            "Silly Activities",
            "Learning Together",
            "Photo Fun",
            "Random Acts"
        ]
        
        let randomCategory = categories.randomElement() ?? "Simple Activities"
        
        let prompt = """
        Generate a unique and creative date idea in the category: \(randomCategory).
        Make it specific and add a fun twist to make it memorable!

        Rules:
        1. Use warm, friendly language like talking to a friend
        2. Include one small, unexpected element to make it special
        3. Keep it budget-friendly and doable today
        4. Make it feel spontaneous and playful
        5. Add enough detail to paint a clear picture
        
        Examples of good ideas:
        - "Breakfast Food Hunt: Pick three local breakfast spots and share a different item at each place - one for coffee, one for pastries, and one wild card. Rate each spot together!"
        - "Sunset Polaroid Walk: Take a walk at golden hour with a polaroid/phone camera, but here's the twist - take turns choosing random objects that spell out a word, then make a mini photo album."
        - "DIY Taste Test Challenge: Visit a grocery store and each secretly pick 3 snacks under $5 that the other person has never tried. Find a nice spot outside and have a blind taste-testing session!"
        - "Library Date with a Twist: Each person finds a children's book they loved as a kid and dramatically reads it to the other in a quiet corner of the library, doing all the character voices."
        
        Format as:
        Title: [2-4 catchy words]
        Description: [2-3 engaging sentences with specific details]
        
        Previous ideas to avoid: \(Array(previousIdeas).joined(separator: ", "))
        """
        
        let payload: [String: Any] = [
            "model": "gpt-3.5-turbo",
            "messages": [
                ["role": "system", "content": """
                You are a creative and fun date idea generator who loves adding unexpected twists to simple activities.
                You focus on making everyday moments feel special and memorable.
                Your ideas should feel personal, warm, and exciting to try right away.
                Always include specific details that make the idea come alive.
                """],
                ["role": "user", "content": prompt]
            ],
            "temperature": 0.9,
            "max_tokens": 200,
            "presence_penalty": 0.7,
            "frequency_penalty": 0.7
        ]
        
        let jsonData = try JSONSerialization.data(withJSONObject: payload)
        var request = URLRequest(url: URL(string: "https://api.openai.com/v1/chat/completions")!)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        
        let result = try JSONDecoder().decode(OpenAIResponse.self, from: data)
        let generatedIdea = result.choices.first?.message.content ?? "Failed to generate idea"
        
        // Store the idea to avoid repetition
        if let title = generatedIdea.components(separatedBy: "\n").first {
            previousIdeas.insert(title)
            // Keep only the last 50 ideas to manage memory
            if previousIdeas.count > 50 {
                previousIdeas.remove(previousIdeas.first!)
            }
        }
        
        return generatedIdea
    }
}

// MARK: - Response Models

/// Model representing the OpenAI API response structure
struct OpenAIResponse: Codable {
    let choices: [Choice]
    
    struct Choice: Codable {
        let message: Message
    }
    
    struct Message: Codable {
        let content: String
    }
} 