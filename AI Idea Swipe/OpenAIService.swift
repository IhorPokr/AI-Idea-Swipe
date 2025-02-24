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
        // Remove or comment out these lines since they're not being used
        // let categories = [
        //     "Cozy Indoor Fun",
        //     "Local Exploring",
        //     "Food Adventures",
        //     "Creative Moments",
        //     "Nature & Parks",
        //     "Sweet Treats",
        //     "Silly Activities",
        //     "Learning Together",
        //     "Photo Fun",
        //     "Random Acts"
        // ]
        
        // let randomCategory = categories.randomElement() ?? "Simple Activities"
        
        let prompt = """
        Give me a quick, real-life date idea that two people can do right now in Illinois.  
        Rules:  
        1. Use a casual, buddy-like tone—like texting a friend.  
        2. Keep it under $30 total.  
        3. Mention specific spots like Dunkin', Starbucks, Chipotle, Taco Bell, Panda Express, Wendy's, Target, Woodfield Mall, Gurnee Mills, Fox Valley Mall, HIP, AMC Theatres, Dave & Buster's, bowling alleys, or parking spots.  
        4. Recommend specific trending movies, music, or TikTok activities so users don't have to choose.  
        5. Make each idea logically structured, with one main activity that makes sense (no combining things that would conflict, like bowling and a movie at the same time).  
        6. Keep it short, clear, and easy to do within 30 minutes of seeing the idea.  

        Format as:  
        Title: [2-4 catchy words]  
        Description: [1-2 quick sentences with specifics]  

        Examples:  
        - "AMC & Frosties" – Catch a late-night movie at AMC, then swing by Wendy's for Frosties on the way home.  
        - "Taco Bell & TikToks" – Grab Taco Bell takeout, park somewhere chill, and watch trending TikTok videos together.  
        - "Starbucks & Mall Walk" – Get iced coffees from Starbucks and stroll through Woodfield Mall, people-watching and rating the best outfits.  
        - "Dave & Buster's Showdown" – Head to Dave & Buster's, spend $10 each on games, and see who can win the weirdest prize.  
        - "Target Snack Run" – Hit Target, each grab a $5 snack, and sit in the car listening to trending TikTok songs while rating each snack.  
        - "Bowling & Pizza" – Bowl a quick game at the nearest alley, then share a small pizza from Panda Express next door.  
        - "Dunkin' & Netflix" – Get hot chocolates from Dunkin', park somewhere quiet, and stream an episode of *Money Heist* on your phone.  

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
