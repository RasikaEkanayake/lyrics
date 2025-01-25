import Foundation
import SwiftUI

@MainActor
class SongViewModel: ObservableObject {
    static let shared = SongViewModel()
    
    @Published var popularSongs: [Song] = []
    @Published var searchResults: [Song] = []
    @Published var favoriteSongs: Set<String> = []
    @Published var isLoading = false
    
    private let favoritesKey = "favoriteSongs"
    private let apiURL = "https://devlk.com/lyricsv1.php"
    
    init() {
        loadFavorites()
    }
    
    private func loadFavorites() {
        if let data = UserDefaults.standard.data(forKey: favoritesKey),
           let favorites = try? JSONDecoder().decode(Set<String>.self, from: data) {
            favoriteSongs = favorites
        }
    }
    
    private func saveFavorites() {
        if let data = try? JSONEncoder().encode(favoriteSongs) {
            UserDefaults.standard.set(data, forKey: favoritesKey)
        }
    }
    
    func toggleFavorite(song: Song) {
        withAnimation {
            if favoriteSongs.contains(song.id) {
                favoriteSongs.remove(song.id)
            } else {
                favoriteSongs.insert(song.id)
            }
            saveFavorites()
        }
    }
    
    func isFavorite(song: Song) -> Bool {
        favoriteSongs.contains(song.id)
    }
    
    var favorites: [Song] {
        popularSongs.filter { favoriteSongs.contains($0.id) }
    }
    
    func fetchPopularSongs() async {
        isLoading = true
        
        do {
            guard let url = URL(string: apiURL) else {
                throw URLError(.badURL)
            }
            
            let (data, response) = try await URLSession.shared.data(from: url)
            
            if let httpResponse = response as? HTTPURLResponse {
                print("API Status Code: \(httpResponse.statusCode)")
            }
            
            // Print the received JSON for debugging
            if let jsonString = String(data: data, encoding: .utf8) {
                print("Received JSON:", jsonString)
            }
            
            let decoder = JSONDecoder()
            let allSongs = try decoder.decode([Song].self, from: data)
            
            await MainActor.run {
                self.popularSongs = allSongs
                self.isLoading = false
            }
        } catch {
            print("Error fetching songs: \(error.localizedDescription)")
            await MainActor.run {
                self.isLoading = false
            }
        }
    }
    
    func searchSongs(query: String) {
        guard !query.isEmpty else {
            searchResults = []
            return
        }
        searchResults = popularSongs.filter {
            $0.title.localizedCaseInsensitiveContains(query) ||
            $0.artist.localizedCaseInsensitiveContains(query)
        }
    }
    
    func openInSpotify(song: Song) {
        let query = "\(song.title) \(song.artist)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        
        // Try to open Spotify app first
        if let spotifyURL = URL(string: "spotify://search/\(query)"),
           UIApplication.shared.canOpenURL(spotifyURL) {
            UIApplication.shared.open(spotifyURL)
        } else {
            // Fallback to web version
            if let webURL = URL(string: "https://open.spotify.com/search/\(query)") {
                UIApplication.shared.open(webURL)
            }
        }
    }
    
    func openInYouTube(song: Song) {
        let query = "\(song.title) \(song.artist)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        
        // Try to open YouTube app first
        if let youtubeURL = URL(string: "youtu.be://\(query)"),
           UIApplication.shared.canOpenURL(youtubeURL) {
            UIApplication.shared.open(youtubeURL)
        } else if let youtubeURL = URL(string: "youtube://\(query)"),
                  UIApplication.shared.canOpenURL(youtubeURL) {
            UIApplication.shared.open(youtubeURL)
        } else {
            // Fallback to web version
            if let webURL = URL(string: "https://www.youtube.com/results?search_query=\(query)") {
                UIApplication.shared.open(webURL)
            }
        }
    }
} 