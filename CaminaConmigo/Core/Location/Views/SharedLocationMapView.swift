import SwiftUI
import MapKit

struct SharedLocationMapView: View {
    let locationMessage: LocationMessage
    @State private var region: MKCoordinateRegion
    @State private var showFullScreen = false
    
    init(locationMessage: LocationMessage) {
        self.locationMessage = locationMessage
        let coordinate = CLLocationCoordinate2D(
            latitude: locationMessage.latitude,
            longitude: locationMessage.longitude
        )
        _region = State(initialValue: MKCoordinateRegion(
            center: coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        ))
    }
    
    var body: some View {
        Button {
            showFullScreen = true
        } label: {
            Map(coordinateRegion: $region, annotationItems: [locationMessage]) { message in
                MapMarker(
                    coordinate: CLLocationCoordinate2D(
                        latitude: message.latitude,
                        longitude: message.longitude
                    ),
                    tint: .blue
                )
            }
            .frame(width: 200, height: 150)
            .cornerRadius(12)
        }
        .buttonStyle(.plain)
        .fullScreenCover(isPresented: $showFullScreen) {
            NavigationStack {
                Map(coordinateRegion: $region, annotationItems: [locationMessage]) { message in
                    MapMarker(
                        coordinate: CLLocationCoordinate2D(
                            latitude: message.latitude,
                            longitude: message.longitude
                        ),
                        tint: .blue
                    )
                }
                .ignoresSafeArea()
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Cerrar") {
                            showFullScreen = false
                        }
                    }
                }
            }
        }
    }
} 
