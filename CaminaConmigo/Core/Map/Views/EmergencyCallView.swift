import SwiftUI

struct EmergencyCallView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    @StateObject private var emergencyContactViewModel = EmergencyContactViewModel()
    
    var body: some View {
        VStack {
            VStack(spacing: 30 ) {
                Text(" Llamada de \nemergencia")
                    .font(.system(size: 24, weight: .bold))
                    .padding(.top, 21)
                HStack(spacing: 15) {
                    // Botón de Carabineros
                    Button(action: {
                        //if let url = URL(string: "tel://133") {
                        //    UIApplication.shared.open(url)
                        //}
                    }) {
                        VStack {
                            Image("policia")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 60)
                            Text("Carabineros")
                                .font(.system(size: 13, weight: .bold))
                        }
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                    }
                    
                    // Mostrar contactos de emergencia solo si el usuario está autenticado y tiene contactos
                    if !authViewModel.isGuestMode && !emergencyContactViewModel.contacts.isEmpty {
                        ForEach(emergencyContactViewModel.contacts.prefix(2)) { contact in
                            Button(action: {
                                if let url = URL(string: "tel://\(contact.phone)") {
                                    UIApplication.shared.open(url)
                                }
                            }) {
                                VStack {
                                    Image("llamada-de-emergencia")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 50)
                                        .padding(5)
                                    Text(contact.name)
                                        .font(.system(size: 13, weight: .bold))
                                        .lineLimit(1)
                                }
                                .foregroundColor(.black)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 8)
                            }
                        }
                    }
                }
            }
            
            HStack {
                Spacer()
                Button(action: {
                    dismiss()
                }) {
                    Text("Cerrar")
                        .font(.system(size: 13))
                        .foregroundColor(.black)
                }
            }
            .padding(.vertical, 21)
            .padding(.trailing, 10)
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 8)
        .background(Color.white)
        .cornerRadius(30)
        .shadow(color: Color.black.opacity(0.2), radius: 5)
        .frame(width: 320)
        .presentationBackground(.clear)
    }
}
