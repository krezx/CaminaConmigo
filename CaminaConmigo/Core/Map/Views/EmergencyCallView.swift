import SwiftUI
import AVFoundation
import MediaPlayer

struct EmergencyCallView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    @StateObject private var emergencyContactViewModel = EmergencyContactViewModel()
    @State private var audioPlayer: AVAudioPlayer?
    @State private var previousVolume: Float = 0.0
    
    func playEmergencySound() {
        do {
            // Guardar el volumen actual
            previousVolume = AVAudioSession.sharedInstance().outputVolume
            
            // Configurar la sesión de audio
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
            
            // Configurar el volumen al máximo
            let volumeView = MPVolumeView()
            if let slider = volumeView.subviews.first(where: { $0 is UISlider }) as? UISlider {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    slider.value = 1.0
                }
            }
            
            if let soundURL = Bundle.main.url(forResource: "emergency_alarm", withExtension: "mp3") {
                audioPlayer = try AVAudioPlayer(contentsOf: soundURL)
                audioPlayer?.prepareToPlay()
                audioPlayer?.numberOfLoops = -1
                audioPlayer?.volume = 1.0
                audioPlayer?.play()
            }
        } catch {
            print("Error reproduciendo el sonido: \(error.localizedDescription)")
        }
    }
    
    func stopEmergencySound() {
        audioPlayer?.stop()
        audioPlayer = nil
        
        // Restaurar el volumen anterior
        let volumeView = MPVolumeView()
        if let slider = volumeView.subviews.first(where: { $0 is UISlider }) as? UISlider {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                slider.value = previousVolume
            }
        }
    }
    
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
                                .foregroundColor(Color.customText)
                            Text("Carabineros")
                                .font(.system(size: 13, weight: .bold))
                                .foregroundColor(Color.customText)
                        }
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
                                        .foregroundColor(Color.customText)
                                    Text(contact.name)
                                        .font(.system(size: 13, weight: .bold))
                                        .lineLimit(1)
                                }
                                .foregroundColor(Color.customText)
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
                    stopEmergencySound()
                    dismiss()
                }) {
                    Text("Cerrar")
                        .font(.system(size: 13))
                        .foregroundColor(Color.customText)
                }
            }
            .padding(.vertical, 21)
            .padding(.trailing, 10)
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 8)
        .background(Color.customBackground)
        .cornerRadius(30)
        .shadow(color: Color.black.opacity(0.2), radius: 5)
        .frame(width: 320)
        .presentationBackground(.clear)
        .onAppear {
            playEmergencySound()
        }
        .onDisappear {
            stopEmergencySound()
        }
    }
}
