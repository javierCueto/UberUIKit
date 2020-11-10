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
    // MARK: -  lifycicle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkIfUserIsLoggedIn()
        //signOut()
        print("DEBUG: se inicio el home")
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
