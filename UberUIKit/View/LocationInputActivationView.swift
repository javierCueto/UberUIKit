//
//  LocationInputActivationView.swift
//  UberUIKit
//
//  Created by Javier Cueto on 10/11/20.
//

import UIKit

class LocationInputActivation: UIView {
    // MARK: -  properties
    private let indicatorView: UIView = {
       let view = UIView()
        view.backgroundColor = .black
        return view
    }()
    
    private let placeHolderLabel: UILabel = {
        let label = UILabel()
        label.text = "Where to?"
        label.font = UIFont.systemFont(ofSize: 18)
        label.textColor = .darkGray
        return label
    }()
    
    // MARK: -  life cycle
    
    override init(frame : CGRect){
        super.init(frame: frame)
        
        backgroundColor = .white
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.55
        layer.shadowOffset = CGSize(width: 0.5, height: 0.5)
        layer.masksToBounds = false
        
        addSubview(indicatorView)
        indicatorView.centerY(inView: self, leftAnchor: leftAnchor, paddingLeft: 16)
        indicatorView.setDimentions(height: 6, width: 6)
        
        addSubview(placeHolderLabel)
        placeHolderLabel.centerY(inView: self,leftAnchor: indicatorView.rightAnchor, paddingLeft: 20)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
