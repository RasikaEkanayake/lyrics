import SwiftUI

struct SearchView: View {
    @StateObject private var viewModel = SongViewModel.shared
    @State private var searchText = ""
    
    var body: some View {
        Group {
            if searchText.isEmpty {
                ContentUnavailableView(
                    "Search Songs",
                    systemImage: "magnifyingglass",
                    description: Text("Enter a song title or artist name")
                )
            } else if viewModel.searchResults.isEmpty {
                ContentUnavailableView(
                    "No Results",
                    systemImage: "music.note",
                    description: Text("Try searching with different keywords")
                )
            } else {
                List(viewModel.searchResults) { song in
                    NavigationLink(destination: LyricDetailView(song: song)) {
                        VStack(alignment: .leading) {
                            Text(song.title)
                                .font(.headline)
                            Text(song.artist)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
        }
        .searchable(text: $searchText)
        .onChange(of: searchText) { _, newValue in
            viewModel.searchSongs(query: newValue)
        }
        .navigationTitle("Search")
    }
}

#Preview {
    NavigationStack {
        SearchView()
    }
} 
