import SwiftUI

struct FavoritesView: View {
    @StateObject private var viewModel = SongViewModel.shared
    @State private var isRefreshing = false
    
    var body: some View {
        Group {
            if viewModel.favorites.isEmpty {
                ContentUnavailableView(
                    "No Favorites Yet",
                    systemImage: "heart",
                    description: Text("Your favorite songs will appear here")
                )
            } else {
                List {
                    ForEach(viewModel.favorites) { song in
                        NavigationLink(destination: LyricDetailView(song: song)) {
                            FavoriteRow(song: song, viewModel: viewModel)
                        }
                    }
                }
                .listStyle(.insetGrouped)
            }
        }
        .navigationTitle("Favorites")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    isRefreshing = true
                    Task {
                        await viewModel.fetchPopularSongs()
                        isRefreshing = false
                    }
                } label: {
                    Image(systemName: "arrow.clockwise")
                        .rotationEffect(.degrees(isRefreshing ? 360 : 0))
                        .animation(isRefreshing ? .linear(duration: 0.5) : .none, value: isRefreshing)
                }
                .disabled(isRefreshing)
            }
        }
    }
}

struct FavoriteRow: View {
    let song: Song
    @ObservedObject var viewModel: SongViewModel
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: "music.note")
                .font(.system(size: 32))
                .frame(width: 44, height: 44)
                .foregroundColor(.accentColor)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(song.title)
                    .font(.headline)
                
                Text(song.artist)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Button(action: {
                withAnimation {
                    viewModel.toggleFavorite(song: song)
                }
            }) {
                Image(systemName: viewModel.isFavorite(song: song) ? "heart.fill" : "heart")
                    .foregroundColor(.red)
                    .font(.system(size: 20))
            }
            .buttonStyle(.plain)
        }
        .padding(.vertical, 8)
    }
}

#Preview {
    NavigationStack {
        FavoritesView()
    }
} 
