//
//  DriverAnnotation.swift
//  UberUIKit
//
//  Created by Javier Cueto on 13/11/20.
//

import MapKit
class DriverAnnotation: NSObject, MKAnnotation{
    //this move the annotation in the map
    dynamic var coordinate: CLLocationCoordinate2D
    var uid: String
    init(uid: String, coordinate: CLLocationCoordinate2D) {
        self.uid = uid
        self.coordinate = coordinate
        
    }
    
    
    func updateAnnotationPosition(with coodinate: CLLocationCoordinate2D){
        UIView.animate(withDuration: 0.2) {
            self.coordinate = coodinate
        }
        
    }

    
    
}
