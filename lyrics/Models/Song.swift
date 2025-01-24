import Foundation

struct Song: Identifiable, Codable {
    let id: String
    let title: String
    let artist: String
    let lyrics: String
    let category: String
    let views: String
    let createdAt: String
    let updatedAt: String
    
    enum CodingKeys: String, CodingKey {
        case id, title, artist, lyrics, category, views
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
    
    // Add computed property for preview
    var previewText: String {
        String(lyrics.prefix(100)) + "..."
    }
} 
