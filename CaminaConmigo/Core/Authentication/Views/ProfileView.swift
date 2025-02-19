//
//  ProfileView.swift
//  CaminaConmigo
//
//  Created by a on 21-01-25.
//


import SwiftUI
import PhotosUI

struct ProfileView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = ProfileViewModel()
    @State private var showEditName = false
    @State private var showEditUsername = false
    @State private var showProfileTypeSelector = false
    @State private var showImagePicker = false
    @State private var selectedImage: UIImage?
    @State private var tempName: String = ""
    @State private var tempUsername: String = ""
    @State private var selectedItem: PhotosPickerItem?
    @State private var showImageOptions = false
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading) {
                // Header con flecha de retorno
                HStack {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "arrow.left")
                            .foregroundColor(Color.customText)
                            .font(.title2)
                    }
                    .padding([.top, .leading])
                    
                    Spacer()
                }

                if viewModel.isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    // Foto de perfil
                    VStack {
                        PhotosPicker(selection: $selectedItem,
                                    matching: .images) {
                            VStack {
                                if let selectedImage = selectedImage {
                                    Image(uiImage: selectedImage)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 150, height: 150)
                                        .clipShape(Circle())
                                } else if let photoURL = viewModel.userProfile?.photoURL,
                                        let url = URL(string: photoURL) {
                                    AsyncImage(url: url) { image in
                                        image
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 150, height: 150)
                                            .clipShape(Circle())
                                    } placeholder: {
                                        ProgressView()
                                            .frame(width: 150, height: 150)
                                    }
                                } else {
                                    Image(systemName: "person.circle")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 150, height: 150)
                                        .foregroundColor(Color.customText)
                                }
                            }
                        }
                        .contextMenu {
                            Button(role: .destructive) {
                                viewModel.removeProfilePhoto()
                                selectedImage = nil
                            } label: {
                                Label("Eliminar foto", systemImage: "trash")
                            }
                        }
                        .onChange(of: selectedItem) { newItem in
                            Task {
                                if let data = try? await newItem?.loadTransferable(type: Data.self),
                                   let image = UIImage(data: data) {
                                    selectedImage = image
                                    viewModel.uploadProfileImage(image)
                                }
                            }
                        }
                        
                        Button(action: {
                            showImagePicker = true
                        }) {
                            Text("Cambiar foto de perfil")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(Color(red: 239/255, green: 96/255, blue: 152/255))
                        }
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.top, 5)
                    }
                    
                    // Opciones del perfil
                    VStack(spacing: 2) {
                        Button(action: {
                            tempName = viewModel.userProfile?.name ?? ""
                            showEditName = true
                        }) {
                            ProfileOption(
                                title: "Nombre",
                                value: viewModel.userProfile?.name ?? "Sin nombre"
                            )
                        }
                        
                        Button(action: {
                            tempUsername = viewModel.userProfile?.username ?? ""
                            showEditUsername = true
                        }) {
                            ProfileOption(
                                title: "Nombre de usuario",
                                value: viewModel.userProfile?.username ?? "Sin usuario"
                            )
                        }
                        
                        Button(action: {
                            showProfileTypeSelector = true
                        }) {
                            ProfileOption(
                                title: "Tipo de perfil",
                                value: viewModel.userProfile?.profileType ?? "Público"
                            )
                        }
                    }
                    .padding(.top, 20)
                    
                    // Información adicional
                    if let joinDate = viewModel.userProfile?.joinDate {
                        HStack {
                            Image(systemName: "calendar")
                                .foregroundColor(Color.customText)
                            Text("Miembro desde \(joinDate.formatted(.dateTime.month().year()))")
                                .font(.footnote)
                                .foregroundColor(Color.customText)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.top, 10)
                    }
                    
                    Spacer()
                }
            }
            .padding(.horizontal)
            .confirmationDialog("Seleccionar tipo de perfil",
                              isPresented: $showProfileTypeSelector,
                              titleVisibility: .visible) {
                Button("Público") {
                    viewModel.updateProfileType("Público")
                }
                Button("Privado") {
                    viewModel.updateProfileType("Privado")
                }
                Button("Cancelar", role: .cancel) {}
            }
            .alert("Editar nombre", isPresented: $showEditName) {
                TextField("Nombre", text: $tempName)
                Button("Cancelar", role: .cancel) {}
                Button("Guardar") {
                    viewModel.updateName(tempName)
                }
            }
            .alert("Editar nombre de usuario", isPresented: $showEditUsername) {
                TextField("Nombre de usuario", text: $tempUsername)
                Button("Cancelar", role: .cancel) {
                    tempUsername = ""
                }
                Button("Guardar") {
                    Task {
                        await viewModel.updateUsername(tempUsername)
                        tempUsername = ""
                    }
                }
            }
            .alert("Error", isPresented: .constant(viewModel.error != nil)) {
                Button("OK", role: .cancel) {
                    viewModel.error = nil
                }
            } message: {
                if let error = viewModel.error {
                    Text(error)
                }
            }
        }
        .navigationBarHidden(true)
        .toolbar(.hidden, for: .tabBar)
    }
}

struct ProfileOption: View {
    var title: String
    var value: String
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(title)
                    .font(.title3)
                    .foregroundColor(Color.customText)
                Text(value)
                    .font(.title3)
                    .foregroundColor(Color.customText.opacity(0.8))
            }
            Spacer()
            Image(systemName: "chevron.right")
                .foregroundColor(Color.customText)
        }
        .padding()
        .background(Color.customBackground)
        .cornerRadius(10)
        .shadow(color: Color.gray.opacity(0.4), radius: 4, x: 0, y: 2)
    }
}
