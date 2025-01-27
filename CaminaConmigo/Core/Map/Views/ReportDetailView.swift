//
//  ReportDetailView.swift
//  CaminaConmigo
//
//  Created by a on 23-01-25.
//


import SwiftUI
import PhotosUI

struct ReportDetailView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: MapViewModel
    @State private var description: String = ""
    @State private var isAnonymous: Bool = true
    @State private var showImagePicker = false
    @State private var selectedImage: UIImage?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Header
            HStack {
                Image(viewModel.currentReport?.type.imageName ?? "")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 30, height: 30)
                    .foregroundColor(.purple)
                
                Text(viewModel.currentReport?.type.title ?? "")
                    .font(.headline)
                
                Spacer()
                
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark")
                        .foregroundColor(.black)
                }
            }
            .padding(.bottom)
            
            // Description TextField
            ZStack(alignment: .topLeading) {
                if description.isEmpty {
                    Text("¿Qué sucede?...")
                        .foregroundColor(.gray)
                        .padding(.horizontal, 4)
                        .padding(.vertical, 8)
                        .zIndex(1)
                }
                
                TextEditor(text: $description)
                    .frame(height: 100)
                    .padding(4)
                    .background(Color.white)
            }
            .background(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.2)))
            
            // Location
            HStack {
                Image(systemName: "location.fill")
                Text("Avenida Francisco de Aguirre...")
                    .foregroundColor(.gray)
            }
            .padding(.vertical, 8)
            .frame(maxWidth: .infinity)
            .background(Color.gray.opacity(0.2))
            .cornerRadius(8)
            
            // Photo buttons
            HStack(spacing: 20) {
                Spacer()
                Button {
                    // Implementar tomar foto
                } label: {
                    HStack {
                        Image(systemName: "camera")
                        Text("Tomar foto")
                    }
                }
                Button {
                    showImagePicker = true
                } label: {
                    HStack {
                        Image(systemName: "photo")
                        Text("Seleccionar foto")
                    }
                }
                Spacer()
            }
            
            // Anonymous toggle
            Toggle("Reportar anónimamente", isOn: $isAnonymous)
                .tint(.purple)
            
            Spacer()
            
            // Submit button
            Button {
                viewModel.submitReport()
                dismiss()
            } label: {
                Text("REPORTAR")
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(red: 239/255, green: 96/255, blue: 152/255))
                    .cornerRadius(5)
            }
        }
        .padding()
        .background(Color.white)
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(image: $selectedImage)
        }
    }
}

// Helper view for image picking
struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    
    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration()
        config.selectionLimit = 1
        config.filter = .images
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            picker.dismiss(animated: true)
            
            guard let provider = results.first?.itemProvider else { return }
            
            if provider.canLoadObject(ofClass: UIImage.self) {
                provider.loadObject(ofClass: UIImage.self) { image, _ in
                    DispatchQueue.main.async {
                        self.parent.image = image as? UIImage
                    }
                }
            }
        }
    }
}

extension View {
    func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .leading,
        @ViewBuilder placeholder: () -> Content) -> some View {
        
        ZStack(alignment: alignment) {
            placeholder().opacity(shouldShow ? 1 : 0)
            self
        }
    }
}
