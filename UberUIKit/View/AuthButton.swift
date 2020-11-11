//
//  AuthButton.swift
//  UberUIKit
//
//  Created by Javier Cueto on 10/11/20.
//

import UIKit

class AuthButton: UIButton {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setTitleColor(UIColor(white: 1, alpha: 0.8), for: .normal)
        self.backgroundColor = UIColor.mainBlueTint
        self.layer.cornerRadius = 5
        self.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
