import SwiftUI

struct ContentView: View {
    @State private var showingLoginSheet = false
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationStack {
                PopularSongsView()
            }
            .tabItem {
                Label("Popular", systemImage: "music.note")
            }
            .tag(0)
            
            NavigationStack {
                SearchView()
            }
            .tabItem {
                Label("Search", systemImage: "magnifyingglass")
            }
            .tag(1)
            
            NavigationStack {
                FavoritesView()
            }
            .tabItem {
                Label("Favorites", systemImage: "heart")
            }
            .tag(2)
        }
    }
}

#Preview {
    ContentView()
}
