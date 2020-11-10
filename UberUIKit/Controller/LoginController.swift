//
//  LoginController.swift
//  UberUIKit
//
//  Created by José Javier Cueto Mejía on 09/11/20.
//

import UIKit

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
        return UITextField().textField(withPlaceHolder: "Email", isSecureTextEntry: false)
    }()
    
    
    private lazy var passContainerView: UIView = {
        let view = UIView().inputContainerView(image: UIImage(systemName: "lock")!, textField: passTextField)
        view.heightAnchor.constraint(equalToConstant: 50).isActive = true
        return view
    }()
    
    private let passTextField: UITextField = {
        return UITextField().textField(withPlaceHolder: "Password", isSecureTextEntry: false)
    }()
    // MARK: -  Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor(red: 25/255, green: 25/255, blue: 25/255, alpha: 1)
        
        //title label
        view.addSubview(titleLabel)
        titleLabel.anchor(top: view.safeAreaLayoutGuide.topAnchor)
        titleLabel.centerX(inView: view)
        
        let stack = UIStackView(arrangedSubviews: [emailContainerView,passContainerView])
        stack.axis = .vertical
        stack.distribution = .fillEqually
        stack.spacing = 16
        view.addSubview(stack)
        
        stack.anchor(top: titleLabel.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor,
                     paddingTop: 40,paddingLeft: 16, paddingRight: 16)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }


}

