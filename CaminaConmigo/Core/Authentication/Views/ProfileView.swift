//
//  ProfileView.swift
//  CaminaConmigo
//
//  Created by a on 21-01-25.
//


import SwiftUI

struct ProfileView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = ProfileViewModel()
    @State private var showEditName = false
    @State private var showEditUsername = false
    @State private var showImagePicker = false
    @State private var selectedImage: UIImage?
    @State private var tempName: String = ""
    @State private var tempUsername: String = ""
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading) {
                // Header con flecha de retorno
                HStack {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "arrow.left")
                            .foregroundColor(.black)
                            .font(.title2)
                    }
                    .padding([.top, .leading], 20)
                    
                    Spacer()
                }

                if viewModel.isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    // Foto de perfil
                    VStack {
                        Button(action: {
                            showImagePicker = true
                        }) {
                            if let selectedImage = selectedImage {
                                Image(uiImage: selectedImage)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 150, height: 150)
                                    .clipShape(Circle())
                            } else {
                                Image(systemName: "person.circle")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 150, height: 150)
                                    .foregroundColor(.gray)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .center)
                        
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
                        
                        ProfileOption(
                            title: "Tipo de perfil",
                            value: viewModel.userProfile?.profileType ?? "Público"
                        )
                    }
                    .padding(.top, 20)
                    
                    // Información adicional
                    if let joinDate = viewModel.userProfile?.joinDate {
                        HStack {
                            Image(systemName: "calendar")
                                .foregroundColor(.black)
                            Text("Miembro desde \(joinDate.formatted(.dateTime.month().year()))")
                                .font(.footnote)
                                .foregroundColor(.black)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.top, 10)
                    }
                    
                    Spacer()
                }
            }
            .padding(.horizontal)
            .sheet(isPresented: $showImagePicker) {
                ImagePicker(image: $selectedImage)
                    .onChange(of: selectedImage) { newImage in
                        if let image = newImage {
                            viewModel.uploadProfileImage(image)
                        }
                    }
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
                    .foregroundColor(.black)
                Text(value)
                    .font(.title3)
                    .foregroundColor(.gray)
            }
            Spacer()
            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
        }
        .padding()
        .background(Color(UIColor.systemBackground))
        .cornerRadius(10)
        .shadow(color: Color.gray.opacity(0.4), radius: 4, x: 0, y: 2)
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}
