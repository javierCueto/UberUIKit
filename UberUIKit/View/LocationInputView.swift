//
//  LocationInputView.swift
//  UberUIKit
//
//  Created by Javier Cueto on 11/11/20.
//

import UIKit

protocol LocationInputViewDelegate: class{
    func dissmisLocationInpurView()
}

class LocationInputView: UIView {
    // MARK: -  properties
    weak var delegate: LocationInputViewDelegate?
    
    private let backButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "arrow.backward")?.withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(handleBackTapped), for: .touchUpInside)
        return button
    }()
    
    // MARK: -  lifecyle

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(backButton)
        addShadow()
        backgroundColor = .white
        backButton.anchor(top: topAnchor, left: leftAnchor, paddingTop: 44, paddingLeft: 12, width: 24, height: 24)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: -  selectors
    
    @objc func handleBackTapped(){
        delegate?.dissmisLocationInpurView()
    }
}
