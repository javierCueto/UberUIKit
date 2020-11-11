//
//  LoginController.swift
//  UberUIKit
//
//  Created by José Javier Cueto Mejía on 09/11/20.
//

import UIKit
import Firebase

class LoginController: UIViewController {
    
    // MARK: -  properties
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
    
    
    private lazy var passContainerView: UIView = {
        let view = UIView().inputContainerView(image: UIImage(systemName: "lock")!, textField: passTextField)
        view.heightAnchor.constraint(equalToConstant: 50).isActive = true
        return view
    }()
    
    private let passTextField: UITextField = {
        return UITextField().textField(withPlaceHolder: "Password", isSecureTextEntry: true)
    }()
    
    private let loginButton: AuthButton = {
        let button = AuthButton(type: .system)
        button.setTitle("Log In", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        button.addTarget(self, action: #selector(handleLogin), for: .touchUpInside)
        return button
    }()
    
    let dontHaveAccountButton: UIButton = {
        let button = UIButton(type: .system)
        
        let attributedTitle = NSMutableAttributedString(string: "Don't have an account? ", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16),
            NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        
        attributedTitle.append(NSAttributedString(string: "Sign Up", attributes:
                                [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 16),
                                 NSAttributedString.Key.foregroundColor: UIColor.mainBlueTint]))
        button.addTarget(self, action: #selector(handleShowSignUp), for: .touchUpInside)
        button.setAttributedTitle(attributedTitle, for: .normal)
        return button
    }()
    
    
    // MARK: -  Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
       
    }
    
    /*override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }*/
    
    // MARK: -  selectors
    
    @objc func handleShowSignUp(){
        let controller = SignUpController()
        navigationController?.pushViewController(controller, animated: true)
    }
    
    
    @objc func handleLogin(){
        guard let email = emailTextField.text else { return }
        guard let password = passTextField.text else { return }
        Auth.auth().signIn(withEmail: email, password: password) { (result, error) in
            if let error = error {
                print("Error \(error.localizedDescription)")
                return
            }
            
            // go to another view
            let nav = HomeController()
            nav.modalPresentationStyle = .fullScreen
            self.present(nav, animated: true, completion: nil)
        }
    }

    
    // MARK: -  helper functions
    
    func configureUI(){
        configureNavigationBar()
        
        view.backgroundColor = .backgroundColor
        
        //title label
        view.addSubview(titleLabel)
        titleLabel.anchor(top: view.safeAreaLayoutGuide.topAnchor)
        titleLabel.centerX(inView: view)
        
       // stack for inputs
        let stack = UIStackView(arrangedSubviews: [emailContainerView,passContainerView,loginButton])
        view.addSubview(stack)
        stack.axis = .vertical
        stack.distribution = .fillEqually
        stack.spacing = 24
        stack.anchor(top: titleLabel.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor,
                     paddingTop: 40,paddingLeft: 16, paddingRight: 16)
        
        //button to create a new account
        view.addSubview(dontHaveAccountButton)
        dontHaveAccountButton.anchor(bottom: view.safeAreaLayoutGuide.bottomAnchor)
        dontHaveAccountButton.centerX(inView: view)
    }
    
    func configureNavigationBar(){
        navigationController?.navigationBar.isHidden = true
        navigationController?.navigationBar.barStyle = .black
    }

}

