//
//  HomeController.swift
//  UberUIKit
//
//  Created by Javier Cueto on 10/11/20.
//

import UIKit
import Firebase
import MapKit

class HomeController: UIViewController{
    
    // MARK: -  properties
    private let mapView = MKMapView()
    private let locationManager = CLLocationManager()
    // MARK: -  lifycicle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkIfUserIsLoggedIn()
        enableLocationServices()
    }
    
    // MARK: -  API
    
    func checkIfUserIsLoggedIn(){
        if Auth.auth().currentUser?.uid == nil {
            DispatchQueue.main.async {
                let nav = UINavigationController(rootViewController: LoginController())
                nav.modalPresentationStyle = .fullScreen
                self.present(nav, animated: true, completion: nil)
            }
  
        }else {
            configureUI()
        }
    }
    
    func signOut(){
        do{
            try Auth.auth().signOut()
        }catch{
            print("DEBUG: un error a ocurrido")
        }
       
    }
    
    // MARK: -  helper functions
    
    func configureUI(){
        view.addSubview(mapView)
        mapView.frame = view.frame
    }
}


// MARK: -  location services
extension HomeController: CLLocationManagerDelegate{
    
    func enableLocationServices(){
        locationManager.delegate = self

        switch CLLocationManager.authorizationStatus(){
        
        case .notDetermined:
            print("DEBUG: Not determined")
            locationManager.requestWhenInUseAuthorization()
        case .restricted, .denied:
           break
        case .authorizedAlways:
            print("DEBUG: auth always ...")
            locationManager.startUpdatingLocation()
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
        case .authorizedWhenInUse:
            print("DEBUG: auth when in use")
            locationManager.requestAlwaysAuthorization()
        @unknown default:
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            locationManager.requestAlwaysAuthorization()
        }
    }
}
