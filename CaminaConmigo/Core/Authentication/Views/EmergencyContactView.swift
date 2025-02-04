//
//  EmergencyContact.swift
//  CaminaConmigo
//
//  Created by a on 21-01-25.
//


import SwiftUI

struct EmergencyContactsView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = EmergencyContactViewModel()
    @State private var showingAddContact = false
    @State private var showingEditContact = false
    @State private var newContactName = ""
    @State private var newContactPhone = ""
    @State private var selectedContact: EmergencyContact?
    
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
                        .font(.title3)
                        .bold()
                    
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.vertical, 10)
                .background(Color.white)
                .shadow(color: Color.gray.opacity(0.2), radius: 2)
                
                // Lista de contactos
                List {
                    ForEach(Array(viewModel.contacts.enumerated()), id: \.element.id) { index, contact in
                        HStack {
                            Text("\(index + 1)")
                                .foregroundColor(.black)
                                .frame(width: 25)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text(contact.name)
                                    .font(.system(size: 16, weight: .medium))
                                Text(contact.phone)
                                    .font(.system(size: 14))
                                    .foregroundColor(.gray)
                            }
                            
                            Spacer()
                            
                            Button(action: {
                                selectedContact = contact
                                newContactName = contact.name
                                newContactPhone = String(contact.phone.dropFirst(4))
                                showingEditContact = true
                            }) {
                                Image(systemName: "pencil")
                                    .foregroundColor(.gray)
                            }
                            
                            Image(systemName: "line.3.horizontal")
                                .foregroundColor(.gray)
                                .padding(.leading, 8)
                        }
                        .padding(.vertical, 4)
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                            Button(role: .destructive) {
                                viewModel.deleteContact(id: contact.id)
                            } label: {
                                Label("Eliminar", systemImage: "trash")
                            }
                        }
                    }
                    .onMove { from, to in
                        viewModel.contacts.move(fromOffsets: from, toOffset: to)
                        viewModel.updateContactsOrder()
                    }
                }
                .listStyle(PlainListStyle())
                
                // Botón añadir contacto
                Button(action: {
                    showingAddContact = true
                }) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                        Text("Añadir contacto")
                    }
                    .foregroundColor(.black)
                    .padding(.vertical, 30)
                }
            }
            .background(Color(UIColor.systemBackground))
        }
        .navigationBarHidden(true)
        .alert("Añadir Contacto", isPresented: $showingAddContact) {
            TextField("Nombre", text: $newContactName)
            TextField("Ingrese número sin +569 (8 dígitos)", text: $newContactPhone)
                .keyboardType(.phonePad)
            
            Button("Cancelar", role: .cancel) {
                newContactName = ""
                newContactPhone = ""
            }
            
            Button("Añadir") {
                viewModel.addContact(name: newContactName, phone: "+569" + newContactPhone)
                newContactName = ""
                newContactPhone = ""
            }
            .disabled(newContactName.isEmpty || newContactPhone.count != 8)
        }
        .alert("Editar Contacto", isPresented: $showingEditContact) {
            TextField("Nombre", text: $newContactName)
            TextField("Ingrese número sin +569 (8 dígitos)", text: $newContactPhone)
                .keyboardType(.phonePad)
            
            Button("Cancelar", role: .cancel) {
                newContactName = ""
                newContactPhone = ""
                selectedContact = nil
            }
            
            Button("Guardar") {
                if let contact = selectedContact {
                    viewModel.updateContact(id: contact.id, name: newContactName, phone: "+569" + newContactPhone)
                    newContactName = ""
                    newContactPhone = ""
                    selectedContact = nil
                }
            }
            .disabled(newContactName.isEmpty || newContactPhone.count != 8)
        }
    }
}
