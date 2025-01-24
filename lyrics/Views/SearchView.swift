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

struct SearchBar: View {
    @Binding var text: String
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
            
            TextField("Search songs or artists", text: $text)
                .textFieldStyle(.plain)
                .autocorrectionDisabled()
            
            if !text.isEmpty {
                Button(action: { text = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(12)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(10)
    }
}

struct SearchResultRow: View {
    let song: Song
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(song.title)
                .font(.headline)
            
            Text(song.artist)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 8)
    }
}

#Preview {
    NavigationStack {
        SearchView()
    }
} 
