import SwiftUI
import MapKit

struct MapPickerView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var coordinate: CLLocationCoordinate2D?

    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )

    var body: some View {
        VStack {
            Map(coordinateRegion: $region, interactionModes: .all, showsUserLocation: true, userTrackingMode: .follow)
                .edgesIgnoringSafeArea(.all)
                .onTapGesture {
                    let location = CLLocationCoordinate2D(latitude: region.center.latitude, longitude: region.center.longitude)
                    coordinate = location
                    dismiss()
                }
            
            Button("Seleccionar esta ubicación") {
                coordinate = region.center
                dismiss()
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(8)
        }
    }
}