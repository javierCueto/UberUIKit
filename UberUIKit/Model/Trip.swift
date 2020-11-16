//
//  Trip.swift
//  UberUIKit
//
//  Created by Javier Cueto on 16/11/20.
//

import CoreLocation

struct Trip {
    var pickupCoordinates: CLLocationCoordinate2D!
    var destinationCoordinates: CLLocationCoordinate2D!
    let passengerUid: String!
    var driverUid: String?
    var state: TripState?
    
    init(passengerUid: String, dictionay: [String: Any]) {
        self.passengerUid = passengerUid
        
        if let pickupCoordinates = dictionay["pickupCoordinates"] as? NSArray {
            guard let lat = pickupCoordinates[0] as? CLLocationDegrees else { return }
            guard let long = pickupCoordinates[1] as? CLLocationDegrees else { return }
            self.pickupCoordinates = CLLocationCoordinate2D(latitude: lat, longitude: long)
        }
        
        
        if let destinationCoordinates = dictionay["destinationCoordinates"] as? NSArray {
            guard let lat = destinationCoordinates[0] as? CLLocationDegrees else { return }
            guard let long = destinationCoordinates[1] as? CLLocationDegrees else { return }
            self.destinationCoordinates = CLLocationCoordinate2D(latitude: lat, longitude: long)
        }
        
        self.driverUid = dictionay["driverUid"] as? String ?? ""
        
        if let state = dictionay["state"] as? Int{
            self.state = TripState(rawValue: state)
        }
        
    }
}


enum TripState: Int {
    case requested
    case accepted
    case inProgress
    case completed
}
