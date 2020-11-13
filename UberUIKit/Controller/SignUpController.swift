//
//  SignUpController.swift
//  UberUIKit
//
//  Created by Javier Cueto on 10/11/20.
//

import UIKit
import Firebase
import GeoFire

class SignUpController: UIViewController {
    // MARK: -  properties
    
    private var location = LocationHandler.shared.locationManager.location
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "UBER"
        label.font = UIFont(name: "Avenir-Light", size: 36)
        label.textColor = UIColor(white: 1, alpha: 0.8)
        return label
    }()
    
    private lazy var emailContainerView: UIView = {
        let view = UIView().inputContainerView(image: UIImage(systemName: "envelope")!, textField: emailTextField)
        view.heightAnchor.constraint(equalToConstant: 50).isActive = true
        return view
    }()
    
    private let emailTextField: UITextField = {
        return UITextField().textField(withPlaceHolder: "Email")
    }()
    
    private lazy var fullNameContainerView: UIView = {
        let view = UIView().inputContainerView(image: UIImage(systemName: "person")!, textField: fullNameTextField)
        view.heightAnchor.constraint(equalToConstant: 50).isActive = true
        return view
    }()
    
    private let fullNameTextField: UITextField = {
        return UITextField().textField(withPlaceHolder: "Full Name")
    }()
    
    private lazy var passContainerView: UIView = {
        let view = UIView().inputContainerView(image: UIImage(systemName: "lock")!, textField: passTextField)
        view.heightAnchor.constraint(equalToConstant: 50).isActive = true
        return view
    }()
    
    private let passTextField: UITextField = {
        return UITextField().textField(withPlaceHolder: "Password", isSecureTextEntry: true)
    }()
    
    let haveAccountButton: UIButton = {
        let button = UIButton(type: .system)
        
        let attributedTitle = NSMutableAttributedString(string: "Already have an account? ", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16),
            NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        
        attributedTitle.append(NSAttributedString(string: "Sign Up", attributes:
                                [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 16),
                                 NSAttributedString.Key.foregroundColor: UIColor.mainBlueTint]))
        button.addTarget(self, action: #selector(handleShowSignUp), for: .touchUpInside)
        button.setAttributedTitle(attributedTitle, for: .normal)
        return button
    }()
    
    private let signUpButton: AuthButton = {
        let button = AuthButton(type: .system)
        button.setTitle("Sign Up", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        button.addTarget(self, action: #selector(handleSignUp), for: .touchUpInside)
        return button
    }()
    
    
    private lazy var accountTypeContainerView: UIView = {
        let view = UIView().inputContainerView(image: UIImage(systemName: "person.fill")!, segmentedControl: accountTypeSegmentedControl)
        view.heightAnchor.constraint(equalToConstant: 50).isActive = true
     
        return view
    }()
    
    private let accountTypeSegmentedControl: UISegmentedControl = {
        let sc = UISegmentedControl(items: ["Rider","Driver"])
        let normalTitleAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        let selectedTitleAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black]
        
        sc.setTitleTextAttributes(normalTitleAttributes, for: .normal)
        sc.setTitleTextAttributes(selectedTitleAttributes, for: .selected)
        sc.layer.borderColor = UIColor.white.cgColor
        sc.layer.borderWidth = 1
        sc.backgroundColor = .backgroundColor
        sc.tintColor = UIColor(white: 1, alpha: 0.87)
        sc.selectedSegmentIndex = 0
        
        return sc
    }()
    
    // MARK: -  lifecycles
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        
        //print("DEBUG: localizacion actual \(location)")
    }
    
    
    // MARK: -  helpers
    func configureUI(){
        
        view.backgroundColor = .backgroundColor
        
        //title label
        view.addSubview(titleLabel)
        titleLabel.anchor(top: view.safeAreaLayoutGuide.topAnchor)
        titleLabel.centerX(inView: view)
        
        // stack for inputs
        let stack = UIStackView(arrangedSubviews: [emailContainerView,fullNameContainerView,passContainerView,accountTypeContainerView,signUpButton])
        view.addSubview(stack)
        
        stack.axis = .vertical
        stack.distribution = .fillProportionally
        stack.spacing = 24
        stack.anchor(top: titleLabel.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor,
                     paddingTop: 40,paddingLeft: 16, paddingRight: 16)
        
        //button to create a new account
        view.addSubview(haveAccountButton)
        haveAccountButton.anchor(bottom: view.safeAreaLayoutGuide.bottomAnchor)
        haveAccountButton.centerX(inView: view)
    }
    

    
    // MARK: -  selectors
    @objc func handleShowSignUp(){
        navigationController?.popViewController(animated: true)
    }
    
    @objc func handleSignUp(){
        guard let email = emailTextField.text else { return }
        guard let password = passTextField.text else { return }
        guard let fullName = fullNameTextField.text else { return }
        let accountTypeIndex = accountTypeSegmentedControl.selectedSegmentIndex 
        
        Auth.auth().createUser(withEmail: email, password: password) { (result, error) in
            if let error = error {
                print("Error \(error)")
                return
            }
            
            guard let uid = result?.user.uid else {return}
            
            let values = ["email" : email,
                          "fullname" : fullName,
            "accountType" : accountTypeIndex] as [String : Any]
            
            
            if accountTypeIndex == 1{
                let geofire = GeoFire(firebaseRef: REF_DRIVER_LOCATIONS)
                guard let location = self.location else { return }
                geofire.setLocation(location, forKey: uid) { (error) in
                    self.uploadUserDataAndShowHomeController(uid: uid, values: values)
                }
                
            }
            
            self.uploadUserDataAndShowHomeController(uid: uid, values: values)
 
           
        }
    }
    
    // MARK: -  helper functions
    func uploadUserDataAndShowHomeController(uid: String, values: [String: Any]){
        REF_USERS.child(uid).updateChildValues(values) { (error, ref) in
            // go to another view
            let nav = HomeController()
            nav.modalPresentationStyle = .fullScreen
            self.present(nav, animated: true, completion: nil)
        }
    }

}
