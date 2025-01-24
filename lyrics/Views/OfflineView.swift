import SwiftUI

struct OfflineView: View {
    var body: some View {
        ContentUnavailableView(
            "No Downloaded Songs",
            systemImage: "arrow.down.circle",
            description: Text("Downloaded songs will be available offline")
        )
        .navigationTitle("Downloads")
    }
}

#Preview {
    NavigationStack {
        OfflineView()
    }
} 