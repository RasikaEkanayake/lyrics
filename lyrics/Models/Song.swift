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
    
    var previewText: String {
        String(lyrics.prefix(100)) + "..."
    }
    
    var formattedViews: String {
        if let viewCount = Int(views) {
            if viewCount >= 1000 {
                let kViews = Double(viewCount) / 1000.0
                return String(format: "%.2fk views", kViews)
            } else {
                return "\(viewCount) views"
            }
        }
        return "0 views"
    }
} 
