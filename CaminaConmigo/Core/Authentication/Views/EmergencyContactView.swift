//
//  EmergencyContact.swift
//  CaminaConmigo
//
//  Created by a on 21-01-25.
//


import SwiftUI

struct EmergencyContact: Identifiable {
    let id: Int
    let name: String
    let phone: String
}

struct EmergencyContactsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var contacts: [EmergencyContact] = [
        EmergencyContact(id: 1, name: "Mamá", phone: "+569 12345678"),
        EmergencyContact(id: 2, name: "Papá", phone: "+569 12345679")
    ]
    
    let pinkColor = Color(red: 239/255, green: 96/255, blue: 152/255)
    
    var body: some View {
        NavigationView {
            VStack {
                // Encabezado
                HStack {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "arrow.left")
                            .foregroundColor(.black)
                            .font(.title2)
                    }
                    
                    Spacer()
                    
                    Text("Contactos de Emergencia")
                        .font(.title)
                        .bold()
                    
                    Spacer() // Para balancear el espacio
                }
                .padding(5)
                .background(Color(UIColor.systemBackground))
                .shadow(color: Color.gray.opacity(0.4), radius: 4, x: 0, y: 2)
                
                // Lista de contactos
                VStack(spacing: 20) {
                    ForEach(contacts) { contact in
                        HStack {
                            Text("\(contact.id)")
                                .font(.title)
                                .foregroundColor(.black)
                                .frame(width: 30)
                            
                            HStack {
                                Text(contact.name)
                                    .font(.title2)
                                Text(contact.phone)
                                    .font(.title3)
                            }
                            
                            Spacer()
                            
                            Button(action: {
                                // Acción para editar
                            }) {
                                Image(systemName: "pencil")
                                    .foregroundColor(.black)
                            }
                            
                            Button(action: {
                                // Acción para más opciones
                            }) {
                                Image(systemName: "arrow.up.and.down.text.horizontal")
                                    .foregroundColor(.black)
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                
                // Botón añadir contacto
                Button(action: {
                    // Acción para añadir contacto
                }) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                        Text("Añadir contacto")
                    }
                    .foregroundColor(.black)
                }
                .padding()
                
                Spacer()
                
                // Botones inferiores
                VStack(spacing: 8) {
                    Button(action: {
                        // Acción para Hecho
                    }) {
                        Text("Hecho")
                            .font(.title)
                            .bold()
                            .foregroundColor(.white)
                            .frame(width: 268, height: 57)
                            .background(pinkColor)
                            .cornerRadius(8)
                    }
                    
                    Button(action: {
                        // Acción para Descartar
                    }) {
                        Text("Descartar")
                            .foregroundColor(.red)
                            .frame(maxWidth: .infinity)
                            .padding()
                    }
                }
                .padding()
            }
        }
        .navigationBarHidden(true)
        .toolbar(.hidden, for: .tabBar)
    }
}

struct EmergencyContactsView_Previews: PreviewProvider {
    static var previews: some View {
        EmergencyContactsView()
    }
}
