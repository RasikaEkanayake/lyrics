import SwiftUI

struct PopularSongsView: View {
    @StateObject private var viewModel = SongViewModel.shared
    @State private var isRefreshing = false
    
    // Two-column grid layout
    private let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    
    // Sort songs by views in descending order
    private var sortedSongs: [Song] {
        viewModel.popularSongs.sorted { song1, song2 in
            Int(song1.views) ?? 0 > Int(song2.views) ?? 0
        }
    }
    
    var body: some View {
        ScrollView {
            if viewModel.popularSongs.isEmpty {
                ContentUnavailableView(
                    "No Songs Available",
                    systemImage: "music.note",
                    description: Text("Pull to refresh to load songs")
                )
            } else {
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(sortedSongs) { song in
                        SongCard(song: song)
                    }
                }
                .padding()
            }
        }
        .navigationTitle("Popular Songs")
        .task {
            await viewModel.fetchPopularSongs()
        }
    }
}

struct SongCard: View {
    let song: Song
    @StateObject private var viewModel = SongViewModel.shared
    
    var body: some View {
        NavigationLink(destination: LyricDetailView(song: song)) {
            VStack(spacing: 0) {
                Rectangle()
                    .fill(Color(.systemGray6))
                    .overlay {
                        Image(systemName: "music.note")
                            .font(.system(size: 40))
                            .foregroundColor(.gray)
                    }
                    .aspectRatio(1, contentMode: .fit)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    .overlay(alignment: .topTrailing) {
                        Text(song.formattedViews)
                            .font(.caption2)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(.ultraThinMaterial)
                            .clipShape(Capsule())
                            .padding(8)
                    }
                
                VStack(alignment: .leading, spacing: 8) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(song.title)
                            .font(.headline)
                            .lineLimit(1)
                        
                        Text(song.artist)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    }
                    
                    HStack {
                        Button {
                            viewModel.openInSpotify(song: song)
                        } label: {
                            Image("spotify")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 24, height: 24)
                        }
                        
                        Button {
                            viewModel.openInYouTube(song: song)
                        } label: {
                            Image("youtube")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 24, height: 24)
                        }
                        
                        Spacer()
                        
                        Button {
                            withAnimation {
                                viewModel.toggleFavorite(song: song)
                            }
                        } label: {
                            Image(systemName: viewModel.isFavorite(song: song) ? "heart.fill" : "heart")
                                .foregroundColor(.red)
                        }
                    }
                }
                .padding(12)
            }
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    NavigationStack {
        PopularSongsView()
    }
} 
