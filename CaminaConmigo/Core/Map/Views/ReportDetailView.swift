//
//  ReportDetailView.swift
//  CaminaConmigo
//
//  Created by a on 23-01-25.
//

import SwiftUI
import PhotosUI

/// Vista para completar los detalles de un reporte, permitiendo al usuario agregar una descripción,
/// tomar o seleccionar una foto, y elegir si quiere enviar el reporte de manera anónima o no.
struct ReportDetailView: View {
    @Environment(\.dismiss) var dismiss  // Permite cerrar la vista de detalles del reporte.
    @ObservedObject var viewModel: MapViewModel  // El ViewModel que maneja la lógica del reporte.
    @State private var description: String = ""  // Descripción del reporte proporcionada por el usuario.
    @State private var isAnonymous: Bool = true  // Controla si el reporte se enviará de forma anónima.
    @State private var showImagePicker = false  // Controla si se debe mostrar el selector de imagen.
    @State private var selectedImage: UIImage?  // Imagen seleccionada para el reporte.
    
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
                        .foregroundColor(.black)
                }
            }
            .padding(.bottom)
            
            // Campo de texto para que el usuario ingrese una descripción del reporte.
            ZStack(alignment: .topLeading) {
                if description.isEmpty {
                    Text("¿Qué sucede?...")  // Placeholder que aparece cuando el campo está vacío.
                        .foregroundColor(.gray)
                        .padding(.horizontal, 4)
                        .padding(.vertical, 8)
                        .zIndex(1)
                }
                
                TextEditor(text: $description)  // Editor de texto para la descripción.
                    .frame(height: 100)
                    .padding(4)
                    .background(Color.white)
            }
            .background(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.2)))  // Fondo con borde redondeado.
            
            // Información de la ubicación.
            HStack {
                Image(systemName: "location.fill")  // Icono de ubicación.
                Text("Avenida Francisco de Aguirre...")  // Texto de la ubicación (puede ser dinámico).
                    .foregroundColor(.gray)
            }
            .padding(.vertical, 8)
            .frame(maxWidth: .infinity)
            .background(Color.gray.opacity(0.2))
            .cornerRadius(8)
            
            // Botones para tomar o seleccionar una foto.
            HStack(spacing: 20) {
                Spacer()
                Button {
                    // Implementar funcionalidad para tomar una foto
                } label: {
                    HStack {
                        Image(systemName: "camera")  // Icono de cámara.
                        Text("Tomar foto")  // Texto del botón.
                    }
                }
                Button {
                    showImagePicker = true  // Muestra el selector de imagen al presionar.
                } label: {
                    HStack {
                        Image(systemName: "photo")  // Icono de foto.
                        Text("Seleccionar foto")  // Texto del botón.
                    }
                }
                Spacer()
            }
            
            // Toggle para elegir si el reporte es anónimo o no.
            Toggle("Reportar anónimamente", isOn: $isAnonymous)
                .tint(.purple)
            
            Spacer()
            
            // Botón para enviar el reporte.
            Button {
                viewModel.submitReport()  // Llama al método del ViewModel para enviar el reporte.
                dismiss()  // Cierra la vista después de enviar el reporte.
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
        .background(Color.white)  // Fondo blanco para toda la vista.
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(image: $selectedImage)  // Muestra el selector de imágenes cuando está activo.
        }
    }
}

/// Vista auxiliar para seleccionar una imagen usando PHPickerViewController.
struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?  // Imagen seleccionada, vinculada al estado de la vista principal.
    
    /// Crea el controlador de vista PHPickerViewController para seleccionar imágenes.
    ///
    /// - Parameter context: Contexto utilizado para el ciclo de vida de la vista.
    /// - Returns: Un controlador PHPickerViewController configurado.
    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration()  // Configura el selector de imágenes.
        config.selectionLimit = 1  // Permite seleccionar solo una imagen.
        config.filter = .images  // Filtra para que solo se puedan seleccionar imágenes.
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
            picker.dismiss(animated: true)  // Cierra el picker después de la selección.
            
            guard let provider = results.first?.itemProvider else { return }
            
            if provider.canLoadObject(ofClass: UIImage.self) {
                provider.loadObject(ofClass: UIImage.self) { image, _ in
                    DispatchQueue.main.async {
                        self.parent.image = image as? UIImage  // Asigna la imagen seleccionada.
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
