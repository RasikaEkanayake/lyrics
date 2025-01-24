import SwiftUI

struct PopularSongsView: View {
    @StateObject private var viewModel = SongViewModel.shared
    @State private var selectedSong: Song?
    
    // Use grid layout for visual content
    private let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    
    var body: some View {
        Group {
            if viewModel.isLoading && viewModel.popularSongs.isEmpty {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if viewModel.popularSongs.isEmpty {
                ContentUnavailableView(
                    "No Songs Available",
                    systemImage: "music.note",
                    description: Text("Check back later for popular songs")
                )
            } else {
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 16) {
                        ForEach(viewModel.topSongs) { song in
                            SongCard(song: song, viewModel: viewModel)
                                .onTapGesture {
                                    selectedSong = song
                                }
                                // Make hit target at least 44x44
                                .frame(minHeight: 44)
                                // Add accessibility label
                                .accessibilityLabel("\(song.title) by \(song.artist)")
                        }
                    }
                    .padding(16)
                }
            }
        }
        .navigationTitle("Top 20 Songs")
        .task {
            if viewModel.popularSongs.isEmpty {
                await viewModel.fetchPopularSongs()
            }
        }
        // Present detail view as sheet for better UX
        .sheet(item: $selectedSong) { song in
            NavigationStack {
                LyricDetailView(song: song)
            }
        }
        // Support pull-to-refresh
        .refreshable {
            await viewModel.fetchPopularSongs()
        }
    }
}

struct SongCard: View {
    let song: Song
    @ObservedObject var viewModel: SongViewModel
    @Environment(\.colorScheme) var colorScheme
    @State private var isFavorite: Bool = false
    
    var formattedViews: String {
        if let views = Int(song.views) {
            if views >= 1000000 {
                return String(format: "%.1fM views", Double(views) / 1000000)
            } else if views >= 1000 {
                return String(format: "%.1fK views", Double(views) / 1000)
            } else {
                return "\(views) views"
            }
        }
        return "0 views"
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(song.title)
                    .font(.headline)
                    .lineLimit(2)
                    .minimumScaleFactor(0.9)
                
                Spacer()
                
                Button(action: {
                    isFavorite.toggle() // Immediate feedback
                    viewModel.toggleFavorite(song: song)
                }) {
                    Image(systemName: isFavorite ? "heart.fill" : "heart")
                        .foregroundColor(.red)
                        .scaleEffect(isFavorite ? 1.1 : 1.0)
                        .animation(.spring(response: 0.3), value: isFavorite)
                }
            }
            
            Text(song.artist)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .lineLimit(1)
            
            Text(formattedViews)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(colorScheme == .dark ? Color(.systemGray6) : Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(radius: 2, y: 1)
        .onAppear {
            isFavorite = viewModel.isFavorite(song: song)
        }
    }
}

struct LyricDetailView: View {
    @Environment(\.dismiss) private var dismiss
    let song: Song
    @State private var showShareSheet = false
    @State private var showCopiedAlert = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text(song.title)
                    .font(.title)
                    .bold()
                
                Text(song.artist)
                    .font(.title2)
                    .foregroundColor(.secondary)
                
                Text(song.lyrics)
                    .font(.body)
                    .padding(.top)
            }
            .padding()
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                HStack(spacing: 16) {
                    // Copy button
                    Button {
                        UIPasteboard.general.string = """
                            \(song.title)
                            by \(song.artist)
                            
                            \(song.lyrics)
                            """
                        showCopiedAlert = true
                    } label: {
                        Image(systemName: "doc.on.doc")
                            .font(.system(size: 16, weight: .medium))
                    }
                    .accessibilityLabel("Copy lyrics")
                    
                    // Share button
                    Button {
                        showShareSheet = true
                    } label: {
                        Image(systemName: "square.and.arrow.up")
                            .font(.system(size: 16, weight: .medium))
                    }
                    .accessibilityLabel("Share song")
                    
                    // Done button
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .sheet(isPresented: $showShareSheet) {
            let shareText = """
            \(song.title)
            by \(song.artist)
            
            \(song.lyrics)
            """
            ShareSheet(items: [shareText])
        }
        .alert("Copied to Clipboard", isPresented: $showCopiedAlert) {
            Button("OK", role: .cancel) {}
        }
    }
}

// Helper view for share sheet
struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

#Preview {
    NavigationStack {
        PopularSongsView()
    }
} 
