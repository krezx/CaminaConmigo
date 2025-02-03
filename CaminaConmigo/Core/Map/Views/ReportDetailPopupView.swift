import SwiftUI
import MapKit

struct ReportDetailPopupView: View {
    let report: ReportAnnotation
    @Environment(\.dismiss) var dismiss
    @State private var currentImageIndex = 0
    @State private var comment: String = ""
    @State private var liked = false
    @State private var comments: [Comment] = []
    @State private var region: MKCoordinateRegion
    
    // Imágenes de prueba para el carrusel
    let demoImages = [
        "demo_image1", "demo_image2"
    ]
    
    init(report: ReportAnnotation) {
        self.report = report
        // Inicializar la región del mapa centrada en la ubicación del reporte
        _region = State(initialValue: MKCoordinateRegion(
            center: report.coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        ))
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    // Encabezado del reporte
                    HStack {
                        Image(report.report.type.imageName)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 40)
                        Text(report.report.type.title)
                            .font(.title2)
                        Spacer()
                        Text(formatDate(report.report.timestamp))
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    // Carrusel de imágenes y mapa
                    TabView(selection: $currentImageIndex) {
                        // Mapa
                        Map(coordinateRegion: .constant(region), annotationItems: [report]) { location in
                            MapMarker(coordinate: location.coordinate)
                        }
                        .frame(height: 200)
                        .tag(0)
                        
                        // Imágenes de prueba
                        ForEach(0..<demoImages.count, id: \.self) { index in
                            Image(demoImages[index])
                                .resizable()
                                .scaledToFill()
                                .frame(height: 200)
                                .clipped()
                                .tag(index)
                        }
                    }
                    .tabViewStyle(PageTabViewStyle())
                    .frame(height: 200)
                    
                    // Descripción
                    Text(report.report.description)
                        .font(.body)
                    
                    // Botones de interacción
                    HStack(spacing: 20) {
                        Button(action: { liked.toggle() }) {
                            HStack {
                                Image(systemName: liked ? "heart.fill" : "heart")
                                    .foregroundColor(liked ? .red : .gray)
                                Text("Me gusta")
                            }
                        }
                        
                        Button(action: shareReport) {
                            HStack {
                                Image(systemName: "square.and.arrow.up")
                                Text("Compartir")
                            }
                        }
                    }
                    .foregroundColor(.gray)
                    
                    Divider()
                    
                    // Sección de comentarios
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Comentarios")
                            .font(.headline)
                        
                        // Lista de comentarios
                        ForEach(comments) { comment in
                            CommentView(comment: comment)
                        }
                        
                        // Campo para nuevo comentario
                        HStack {
                            TextField("Añadir un comentario...", text: $comment)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                            
                            Button(action: addComment) {
                                Text("Enviar")
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Detalles del Reporte")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cerrar") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    private func shareReport() {
        // Implementar lógica para compartir
        let shareText = "Reporte de \(report.report.type.title) en CaminaConmigo"
        let activityVC = UIActivityViewController(activityItems: [shareText], applicationActivities: nil)
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first,
           let rootVC = window.rootViewController {
            rootVC.present(activityVC, animated: true)
        }
    }
    
    private func addComment() {
        guard !comment.isEmpty else { return }
        let newComment = Comment(
            id: UUID(),
            text: comment,
            author: "Usuario",
            timestamp: Date()
        )
        comments.append(newComment)
        comment = ""
    }
}

struct Comment: Identifiable {
    let id: UUID
    let text: String
    let author: String
    let timestamp: Date
}

struct CommentView: View {
    let comment: Comment
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(comment.author)
                    .font(.subheadline)
                    .fontWeight(.bold)
                Spacer()
                Text(formatCommentDate(comment.timestamp))
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            Text(comment.text)
                .font(.subheadline)
        }
        .padding(8)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(8)
    }
    
    private func formatCommentDate(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }
} 
