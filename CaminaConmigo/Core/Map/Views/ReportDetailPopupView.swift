import SwiftUI
import MapKit

// Vista para el encabezado del reporte
struct ReportHeaderView: View {
    let report: ReportAnnotation
    
    var body: some View {
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
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

// Vista para el carrusel de imágenes y mapa
struct CarouselView: View {
    let report: ReportAnnotation
    let region: MKCoordinateRegion
    @Binding var currentImageIndex: Int
    let demoImages: [String]
    
    var body: some View {
        VStack {
            TabView(selection: $currentImageIndex) {
                Map(coordinateRegion: .constant(region), annotationItems: [report]) { location in
                    MapMarker(coordinate: location.coordinate)
                }
                .frame(height: 200)
                .tag(0)
                
                ForEach(0..<demoImages.count, id: \.self) { index in
                    Image(demoImages[index])
                        .resizable()
                        .scaledToFill()
                        .frame(height: 200)
                        .clipped()
                        .tag(index + 1)
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never)) // Oculta el indicador de página del TabView
            .frame(height: 200)

            // Indicadores de página manualmente interactivos
            HStack {
                ForEach(0..<demoImages.count + 1, id: \.self) { index in
                    Circle()
                        .fill(index == currentImageIndex ? Color.blue : Color.gray)
                        .frame(width: 8, height: 8)
                        .onTapGesture {
                            // Cambia el índice actual al que se ha tocado
                            currentImageIndex = index
                        }
                }
            }
            .padding(.top, 8) // Espaciado entre el TabView y el indicador
        }
    }
}

// Vista para los botones de interacción
struct InteractionButtonsView: View {
    @Binding var liked: Bool
    let onShare: () -> Void
    let onLike: () -> Void
    let likesCount: Int
    
    var body: some View {
        HStack(spacing: 20) {
            Button(action: onLike) {
                HStack {
                    Image(systemName: liked ? "heart.fill" : "heart")
                        .foregroundColor(liked ? .red : .gray)
                    Text("\(likesCount) Me gusta")
                }
            }
            
            Button(action: onShare) {
                HStack {
                    Image(systemName: "square.and.arrow.up")
                    Text("Compartir")
                }
            }
        }
        .foregroundColor(.gray)
    }
}

// Vista para la sección de comentarios
struct CommentsSection: View {
    let viewModel: ReportViewModel
    let currentUserId: String?
    let reportId: String?
    @Binding var comment: String
    let onAddComment: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Comentarios")
                .font(.headline)
            
            if viewModel.isLoadingComments {
                ProgressView()
            } else {
                ForEach(viewModel.comments) { comment in
                    CommentView(
                        comment: comment,
                        currentUserId: currentUserId,
                        onDelete: {
                            if let reportId = reportId {
                                viewModel.deleteComment(commentId: comment.id ?? "", reportId: reportId)
                            }
                        }
                    )
                }
            }
            
            if currentUserId != nil {
                HStack {
                    TextField("Añadir un comentario...", text: $comment)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    Button(action: onAddComment) {
                        Text("Enviar")
                            .foregroundColor(.blue)
                    }
                }
            }
        }
    }
}

struct ReportDetailPopupView: View {
    let report: ReportAnnotation
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: ReportViewModel
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    @StateObject private var profileViewModel = ProfileViewModel()
    @State private var currentImageIndex = 1
    @State private var comment: String = ""
    @State private var liked = false
    @State private var region: MKCoordinateRegion
    @State private var showLoginAlert = false
    @State private var navigateToLogin = false
    @State private var likesCount: Int = 0
    
    let demoImages = ["demo_image1", "demo_image2"]
    
    init(report: ReportAnnotation, viewModel: ReportViewModel) {
        self.report = report
        self.viewModel = viewModel
        _region = State(initialValue: MKCoordinateRegion(
            center: report.coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        ))
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    ReportHeaderView(report: report)
                    
                    CarouselView(
                        report: report,
                        region: region,
                        currentImageIndex: $currentImageIndex,
                        demoImages: demoImages
                    )
                    
                    Text(report.report.description)
                        .font(.body)
                    
                    InteractionButtonsView(
                        liked: $liked,
                        onShare: shareReport,
                        onLike: handleLike,
                        likesCount: likesCount
                    )
                    
                    Divider()
                    
                    CommentsSection(
                        viewModel: viewModel,
                        currentUserId: authViewModel.userSession?.uid,
                        reportId: report.report.id,
                        comment: $comment,
                        onAddComment: addComment
                    )
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
            .onAppear {
                if let reportId = report.report.id {
                    viewModel.fetchComments(for: reportId)
                    likesCount = report.report.likes
                    
                    if let userId = authViewModel.userSession?.uid {
                        viewModel.checkLikeStatus(for: reportId, userId: userId) { isLiked in
                            liked = isLiked
                        }
                    }
                }
            }
            .alert("Iniciar Sesión", isPresented: $showLoginAlert) {
                Button("Cancelar", role: .cancel) {}
                Button("Iniciar Sesión") {
                    navigateToLogin = true
                }
            } message: {
                Text("Necesitas iniciar sesión para comentar")
            }
            .fullScreenCover(isPresented: $navigateToLogin) {
                LoginView()
            }
        }
    }
    
    private func shareReport() {
        guard let reportId = report.report.id else { return }
        
        // Crear el texto del mensaje con el deep link
        let deepLinkUrl = "caminaconmigo://report/\(reportId)"
        let shareText = """
        🚨 Reporte de \(report.report.type.title) en CaminaConmigo
        
        📍 Ver detalles del reporte:
        \(deepLinkUrl)
        
        💡 Si no tienes la app, búscala en la App Store como "CaminaConmigo"
        """
        
        // Crear los items para compartir
        let activityItems: [Any] = [shareText]
        let activityVC = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
        
        // Obtener la ventana y el controlador raíz
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            // En iPad, necesitamos especificar el origen del popover
            if let popoverController = activityVC.popoverPresentationController {
                popoverController.sourceView = window
                popoverController.sourceRect = CGRect(x: window.bounds.midX, y: window.bounds.midY, width: 0, height: 0)
                popoverController.permittedArrowDirections = []
            }
            
            // Encontrar el controlador más alto en la jerarquía que no esté presentando
            var topController = window.rootViewController
            while let presentedController = topController?.presentedViewController {
                topController = presentedController
            }
            
            // Presentar el activity controller
            DispatchQueue.main.async {
                topController?.present(activityVC, animated: true)
            }
        }
    }
    
    private func addComment() {
        guard !comment.isEmpty else { return }
        guard let user = authViewModel.userSession else {
            showLoginAlert = true
            return
        }
        guard let reportId = report.report.id else {
            print("Error: No se pudo obtener el ID del reporte")
            return
        }
        
        viewModel.addComment(
            text: comment,
            reportId: reportId,
            authorId: user.uid,
            authorName: profileViewModel.userProfile?.username ?? "Usuario"
        )
        comment = ""
    }
    
    private func handleLike() {
        guard let user = authViewModel.userSession else {
            showLoginAlert = true
            return
        }
        
        guard let reportId = report.report.id else {
            print("Error: No se pudo obtener el ID del reporte")
            return
        }
        
        viewModel.toggleLike(for: reportId, userId: user.uid)
        liked.toggle()
        likesCount += liked ? 1 : -1
    }
}

struct CommentView: View {
    let comment: Comment
    let currentUserId: String?
    let onDelete: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(comment.authorName)
                    .font(.subheadline)
                    .fontWeight(.bold)
                Spacer()
                Text(formatCommentDate(comment.timestamp))
                    .font(.caption)
                    .foregroundColor(.gray)
                
                if comment.authorId == currentUserId {
                    Button(action: onDelete) {
                        Image(systemName: "trash")
                            .foregroundColor(.red)
                    }
                }
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