//
//  Services.swift
//  FocusHabitTracker
//
//  Created by Abdullah Alghabban on 10/29/25.
//

import Foundation
import CoreLocation
import MapKit
import Combine

//QuoteService (JSON via URLSession)
import Foundation

struct QuoteService {
    // JSON from https://zenquotes.io/api/today
    struct ZenQuote: Decodable {
        let q: String   // quote text
        let a: String   // author
    }
    
    static func fetchDailyQuote() async throws -> String {
        let url = URL(string: "https://zenquotes.io/api/today")!
        // Web API call
        let (data, _) = try await URLSession.shared.data(from: url)
        // Decode JSON array of ZenQuote
        let decoded = try JSONDecoder().decode([ZenQuote].self, from: data)
        guard let first = decoded.first else {
            return "Stay consistent today."
        }
        return "“\(first.q)” - \(first.a)"
    }
}

//LocationService
@MainActor
final class LocationService: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var authorization: CLAuthorizationStatus
    @Published var userCoordinate: CLLocationCoordinate2D?
    
    private let manager = CLLocationManager()
    
    override init() {
        self.authorization = .notDetermined
        super.init()
        manager.delegate = self
    }
    
    func request() {
        if manager.authorizationStatus == .notDetermined {
            manager.requestWhenInUseAuthorization()
        } else {
            manager.startUpdatingLocation()
        }
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorization = manager.authorizationStatus
        if authorization == .authorizedWhenInUse || authorization == .authorizedAlways {
            manager.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        userCoordinate = locations.last?.coordinate
    }
}
