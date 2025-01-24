import Foundation
import SwiftUI

@MainActor
class SongViewModel: ObservableObject {
    static let shared = SongViewModel() // Add singleton instance
    
    @Published var popularSongs: [Song] = []
    @Published var searchResults: [Song] = []
    @Published var favoriteSongs: Set<String> = []
    @Published var isLoading = false
    
    private let favoritesKey = "favoriteSongs"
    private let apiURL = "https://devlk.com/lyricsv1.php"
    
    init() {
        loadFavorites() // Only load favorites during init
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
            UserDefaults.standard.synchronize() // Force immediate save
        }
    }
    
    func toggleFavorite(song: Song) {
        withAnimation {
            if favoriteSongs.contains(song.id) {
                favoriteSongs.remove(song.id)
            } else {
                favoriteSongs.insert(song.id)
            }
            saveFavorites() // Save immediately
        }
    }
    
    func isFavorite(song: Song) -> Bool {
        favoriteSongs.contains(song.id)
    }
    
    var favorites: [Song] {
        popularSongs.filter { favoriteSongs.contains($0.id) }
    }
    
    // Load cached songs if available
    private func loadCachedSongs() {
        if let data = UserDefaults.standard.data(forKey: "cachedSongs"),
           let songs = try? JSONDecoder().decode([Song].self, from: data) {
            self.popularSongs = songs
        }
    }
    
    // Cache songs for faster subsequent launches
    private func cacheSongs(_ songs: [Song]) {
        if let data = try? JSONEncoder().encode(songs) {
            UserDefaults.standard.set(data, forKey: "cachedSongs")
        }
    }
    
    // Add computed property for top 20 songs
    var topSongs: [Song] {
        popularSongs
            .sorted { 
                // Convert views string to Int for comparison
                let views1 = Int($0.views) ?? 0
                let views2 = Int($1.views) ?? 0
                return views2 < views1 // Descending order
            }
            .prefix(20) // Take only top 20
            .map { $0 }
    }
    
    func fetchPopularSongs() async {
        if popularSongs.isEmpty {
            loadCachedSongs()
        }
        
        isLoading = true
        
        do {
            guard let url = URL(string: apiURL) else {
                throw URLError(.badURL)
            }
            
            let (data, _) = try await URLSession.shared.data(from: url)
            let allSongs = try JSONDecoder().decode([Song].self, from: data)
            
            await MainActor.run {
                self.popularSongs = allSongs
                self.isLoading = false
                self.cacheSongs(allSongs)
            }
        } catch {
            print("Error fetching songs: \(error)")
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
    
    @MainActor
    func refreshSongs() async {
        await fetchPopularSongs()
    }
} 