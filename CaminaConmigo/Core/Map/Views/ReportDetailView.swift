//
//  ReportDetailView.swift
//  CaminaConmigo
//
//  Created by a on 23-01-25.
//

import SwiftUI
import PhotosUI
import MapKit

/// Vista para completar los detalles de un reporte, permitiendo al usuario agregar una descripción,
/// tomar o seleccionar una foto, y elegir si quiere enviar el reporte de manera anónima o no.
struct ReportDetailView: View {
    @Environment(\.dismiss) var dismiss  // Permite cerrar la vista de detalles del reporte.
    @ObservedObject var viewModel: ReportViewModel  // El ViewModel que maneja la lógica del reporte.
    @State private var description: String = ""  // Descripción del reporte proporcionada por el usuario.
    @State private var isAnonymous: Bool = true  // Controla si el reporte se enviará de forma anónima.
    @State private var showImagePicker = false  // Controla si se debe mostrar el selector de imagen.
    @State private var selectedImages: [UIImage] = []  // Imágenes seleccionadas para el reporte.
    @State private var showMapPicker = false  // Controla si se debe mostrar el selector de mapa.
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Header con el tipo de reporte y un botón para cerrar la vista.
            HStack {
                Image(viewModel.currentReport?.type.imageName ?? "")  // Icono del tipo de reporte.
                    .resizable()
                    .scaledToFit()
                    .frame(width: 30, height: 30)
                    .foregroundColor(.purple)
                
                Text(viewModel.currentReport?.type.title ?? "")  // Título del tipo de reporte.
                    .font(.headline)
                
                Spacer()  // Empuja el botón de cierre a la derecha.
                
                Button {
                    dismiss()  // Cierra la vista cuando se presiona.
                } label: {
                    Image(systemName: "xmark")  // Icono de "X" para cerrar.
                        .foregroundColor(Color.customText)
                }
            }
            .padding(.bottom)
            
            // Campo de texto para que el usuario ingrese una descripción del reporte.
            ZStack(alignment: .topLeading) {
                if description.isEmpty {
                    Text("¿Qué sucede?...")  // Placeholder que aparece cuando el campo está vacío.
                        .foregroundColor(Color.customText)
                        .padding(.horizontal, 4)
                        .padding(.vertical, 8)
                        .zIndex(1)
                }
                
                TextEditor(text: $description)  // Editor de texto para la descripción.
                    .frame(height: 100)
                    .padding(4)
                    .background(Color.customBackground)
            }
            .background(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.2)))  // Fondo con borde redondeado.
            
            // Botón para seleccionar una ubicación.
            Button {
                showMapPicker = true  // Muestra el selector de mapa al presionar.
            } label: {
                HStack {
                    Image(systemName: "location.fill")  // Icono de ubicación.
                    Text(viewModel.selectedLocation != nil ? "Ubicación seleccionada" : "Seleccionar ubicación")  // Texto del botón.
                        .foregroundColor(Color.gray)
                }
            }
            
            // Toggle para elegir si el reporte es anónimo o no.
            Toggle("Reportar anónimamente", isOn: $isAnonymous)
                .tint(Color(red: 239/255, green: 96/255, blue: 152/255))
            
            // Vista previa de imágenes seleccionadas
            if !selectedImages.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(selectedImages.indices, id: \.self) { index in
                            Image(uiImage: selectedImages[index])
                                .resizable()
                                .scaledToFill()
                                .frame(width: 100, height: 100)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                .overlay(
                                    Button(action: {
                                        selectedImages.remove(at: index)
                                    }) {
                                        Image(systemName: "xmark.circle.fill")
                                            .foregroundColor(.red)
                                            .padding(4)
                                    }
                                    .offset(x: 5, y: -5),
                                    alignment: .topTrailing
                                )
                        }
                    }
                    .padding(.horizontal)
                }
                .frame(height: 120)
            }
            
            // Botones para imágenes
            HStack(spacing: 20) {
                Spacer()
                Button {
                    showImagePicker = true
                } label: {
                    HStack {
                        Image(systemName: "photo")
                        Text("Agregar fotos")
                    }
                }
                Spacer()
            }
            
            Spacer()
            
            // Botón para enviar el reporte.
            Button {
                viewModel.currentReport?.description = description
                viewModel.currentReport?.isAnonymous = isAnonymous
                viewModel.submitReport(images: selectedImages)
                dismiss()
            } label: {
                Text("REPORTAR")
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(red: 239/255, green: 96/255, blue: 152/255))  // Color de fondo del botón.
                    .cornerRadius(5)  // Bordes redondeados del botón.
            }
        }
        .padding()
        .background(Color.customBackground)  // Fondo blanco para toda la vista.
        .sheet(isPresented: $showImagePicker) {
            MultiImagePicker(images: $selectedImages)
        }
        .sheet(isPresented: $showMapPicker) {
            MapPickerView(selectedLocation: $viewModel.selectedLocation, viewModel: viewModel)
        }
    }
}

/// Vista auxiliar para seleccionar una imagen usando PHPickerViewController.
struct ImagePicker: UIViewControllerRepresentable {
    @Binding var images: [UIImage]
    @Environment(\.presentationMode) var presentationMode
    
    /// Crea el controlador de vista PHPickerViewController para seleccionar imágenes.
    ///
    /// - Parameter context: Contexto utilizado para el ciclo de vida de la vista.
    /// - Returns: Un controlador PHPickerViewController configurado.
    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration()
        config.selectionLimit = 5  // Límite de 5 imágenes
        config.filter = .images
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator  // Asigna el delegado del picker.
        return picker
    }
    
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}  // No necesita actualización.
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)  // Crea el coordinador para manejar la selección de imágenes.
    }
    
    /// Coordinador para manejar la selección de imágenes del PHPickerViewController.
    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        /// Método delegado que se llama cuando se selecciona una imagen.
        ///
        /// - Parameter picker: El picker que gestionó la selección.
        /// - Parameter results: Los resultados de la selección.
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            parent.presentationMode.wrappedValue.dismiss()
            
            for result in results {
                if result.itemProvider.canLoadObject(ofClass: UIImage.self) {
                    result.itemProvider.loadObject(ofClass: UIImage.self) { image, error in
                        if let image = image as? UIImage {
                            DispatchQueue.main.async {
                                self.parent.images.append(image)
                            }
                        }
                    }
                }
            }
        }
    }
}

extension View {
    /// Modificador de vista para mostrar un placeholder cuando el texto está vacío.
    ///
    /// - Parameter shouldShow: Condición para mostrar el placeholder.
    /// - Parameter alignment: Alineación del placeholder.
    /// - Parameter placeholder: Vista que actúa como el placeholder.
    func placeholder<Content: View>(when shouldShow: Bool,
                                    alignment: Alignment = .leading,
                                    @ViewBuilder placeholder: () -> Content) -> some View {
        
        ZStack(alignment: alignment) {
            placeholder().opacity(shouldShow ? 1 : 0)  // Muestra el placeholder cuando la condición es verdadera.
            self
        }
    }
}
