import SwiftUI

struct LyricDetailView: View {
    let song: Song
    @StateObject private var viewModel = SongViewModel.shared
    @Environment(\.dismiss) private var dismiss
    @State private var showShareSheet = false
    @State private var showCopiedAlert = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Title and Artist
                VStack(alignment: .leading, spacing: 8) {
                    Text(song.title)
                        .font(.title)
                        .bold()
                    
                    Text(song.artist)
                        .font(.title2)
                        .foregroundColor(.secondary)
                }
                
                // Streaming Services - Compact Design
                HStack(spacing: 12) {
                    Button {
                        viewModel.openInSpotify(song: song)
                    } label: {
                        HStack(spacing: 4) {
                            Image("spotify")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 16, height: 16) // Smaller icon size
                            Text("Listen on Spotify")
                                .font(.footnote)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color(.systemGray6))
                        .clipShape(Capsule())
                    }
                    
                    Button {
                        viewModel.openInYouTube(song: song)
                    } label: {
                        HStack(spacing: 4) {
                            Image("youtube")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 16, height: 16) // Smaller icon size
                            Text("Watch on YouTube")
                                .font(.footnote)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color(.systemGray6))
                        .clipShape(Capsule())
                    }
                }
                .foregroundColor(.primary)
                
                Divider()
                    .padding(.vertical, 8)
                
                // Lyrics
                Text(song.lyrics)
                    .font(.body)
                    .lineSpacing(8)
            }
            .padding()
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                HStack(spacing: 16) {
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
                    
                    Button {
                        showShareSheet = true
                    } label: {
                        Image(systemName: "square.and.arrow.up")
                            .font(.system(size: 16, weight: .medium))
                    }
                    .accessibilityLabel("Share song")
                }
            }
        }
        .sheet(isPresented: $showShareSheet) {
            ShareSheet(items: ["\(song.title) by \(song.artist)\n\n\(song.lyrics)"])
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
        LyricDetailView(song: Song(
            id: "1",
            title: "Sample Song",
            artist: "Sample Artist",
            lyrics: "Sample lyrics\nSecond line\nThird line",
            category: "Pop",
            views: "1000",
            createdAt: "",
            updatedAt: ""
        ))
    }
} 