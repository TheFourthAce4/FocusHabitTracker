//
//  MapPickerView.swift
//  FocusHabitTracker
//
//  Created by Abdullah Alghabban on 10/29/25.
//

import SwiftUI
import MapKit
import CoreLocation
import Combine

struct MapPickerView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var loc = LocationService()


    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 33.4242, longitude: -111.9281), // Tempe fallback
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )

    var onSelect: (CLLocationCoordinate2D) -> Void

    var body: some View {
        NavigationStack {
            ZStack {

                Map(coordinateRegion: $region, interactionModes: .all)

                // center pin overlay
                Image(systemName: "mappin.circle.fill")
                    .font(.system(size: 28))
                    .foregroundStyle(.red)
                    .shadow(radius: 2)
            }
            .onAppear {

                loc.request()
                if let user = loc.userCoordinate {
                    region.center = user
                }
            }
            .onReceive(loc.$userCoordinate.compactMap { $0 }) { coord in

                region.center = coord
            }
            .navigationTitle("Pick Location")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Use This") {
                        onSelect(region.center)
                        dismiss()
                    }
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
            .safeAreaInset(edge: .bottom) {
                Text("Center: \(String(format: "%.5f", region.center.latitude)), \(String(format: "%.5f", region.center.longitude))")
                    .font(.caption)
                    .padding(8)
                    .frame(maxWidth: .infinity)
                    .background(.thinMaterial)
            }
        }
    }
}
