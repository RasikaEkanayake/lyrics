import SwiftUI
import UniformTypeIdentifiers

struct IconExporter: View {
    let sizes: [(String, CGFloat)] = [
        ("iPhone Notification 20pt 2x", 40),
        ("iPhone Notification 20pt 3x", 60),
        ("iPhone Settings 29pt 2x", 58),
        ("iPhone Settings 29pt 3x", 87),
        ("iPhone Spotlight 40pt 2x", 80),
        ("iPhone Spotlight 40pt 3x", 120),
        ("iPhone App 60pt 2x", 120),
        ("iPhone App 60pt 3x", 180),
        ("iPad Notifications 20pt 1x", 20),
        ("iPad Notifications 20pt 2x", 40),
        ("iPad Settings 29pt 1x", 29),
        ("iPad Settings 29pt 2x", 58),
        ("iPad Spotlight 40pt 1x", 40),
        ("iPad Spotlight 40pt 2x", 80),
        ("iPad App 76pt 1x", 76),
        ("iPad App 76pt 2x", 152),
        ("iPad Pro App 83.5pt 2x", 167),
        ("App Store 1024pt 1x", 1024),
    ]
    
    var body: some View {
        List(sizes, id: \.0) { name, size in
            HStack {
                AppIcon()
                    .frame(width: 60, height: 60)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                
                VStack(alignment: .leading) {
                    Text(name)
                    Text("\(Int(size))×\(Int(size))")
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                Button("Export") {
                    exportIcon(size: size)
                }
            }
            .padding(.vertical, 4)
        }
    }
    
    func exportIcon(size: CGFloat) {
        let renderer = ImageRenderer(content: AppIcon())
        renderer.scale = size / 1024
        
        if let image = renderer.uiImage {
            UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        }
    }
}

#Preview {
    IconExporter()
} 