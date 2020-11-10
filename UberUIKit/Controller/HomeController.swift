//
//  HomeController.swift
//  UberUIKit
//
//  Created by Javier Cueto on 10/11/20.
//

import UIKit
import Firebase

class HomeController: UIViewController{
    
    // MARK: -  properties
    
    // MARK: -  lifycicle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkIfUserIsLoggedIn()
        //signOut()
        view.backgroundColor = .red
        
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
            print("DEBUG: User id is \(String(describing: Auth.auth().currentUser?.uid))")
        }
    }
    
    func signOut(){
        do{
            try Auth.auth().signOut()
        }catch{
            print("DEBUG: un error a ocurrido")
        }
       
    }
}
