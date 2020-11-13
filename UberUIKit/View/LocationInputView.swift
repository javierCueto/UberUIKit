//
//  LocationInputView.swift
//  UberUIKit
//
//  Created by Javier Cueto on 11/11/20.
//

import UIKit

protocol LocationInputViewDelegate: class{
    func dissmisLocationInpurView()
    func executeSearch(query: String)
}

class LocationInputView: UIView {
    // MARK: -  properties
    var user: User? {
        didSet{
            titleLabel.text = user?.fullname
        }
    }
    
    weak var delegate: LocationInputViewDelegate?
    
    private let backButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "arrow.backward")?.withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(handleBackTapped), for: .touchUpInside)
        return button
    }()
    
    private var titleLabel: UILabel = {
       let label = UILabel()
        label.text = "loading ..."
        label.textColor = .darkGray
        label.font = UIFont.systemFont(ofSize: 16)
        return label
    }()
    
    private let startLocationIndicatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .lightGray
        return view
    }()
    
    private let linkingView: UIView = {
        let view = UIView()
        view.backgroundColor = .darkGray
        return view
    }()
    
    private let destinationIndicatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        return view
    }()
    
    
    private lazy var startigLocationTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Current location"
        tf.backgroundColor = .systemGroupedBackground
        tf.isEnabled = false
        tf.font = UIFont.systemFont(ofSize: 14)
        let paddinView = UIView()
        paddinView.setDimentions(height: 30, width: 8)
        tf.leftView = paddinView
        tf.leftViewMode = .always
        return tf
    }()
    
    private lazy var destinationLocationTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Enter destination"
        tf.backgroundColor = .lightGray
        tf.returnKeyType = .search
        tf.font = UIFont.systemFont(ofSize: 14)
        tf.delegate = self
        
        let paddinView = UIView()
        paddinView.setDimentions(height: 30, width: 8)
        tf.leftView = paddinView
        tf.leftViewMode = .always
        return tf
    }()
    
    // MARK: -  lifecyle

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(backButton)
        addShadow()
        backgroundColor = .white
        backButton.anchor(top: topAnchor, left: leftAnchor, paddingTop: 44, paddingLeft: 12, width: 24, height: 24)
        
        addSubview(titleLabel)
        titleLabel.centerY(inView: backButton)
        titleLabel.centerX(inView: self)
        
        addSubview(startigLocationTextField)
        startigLocationTextField.anchor(top: backButton.bottomAnchor, left: leftAnchor, right: rightAnchor,
                                        paddingTop: 4, paddingLeft: 40, paddingRight: 40,height: 30)
        addSubview(destinationLocationTextField)
        destinationLocationTextField.anchor(top: startigLocationTextField.bottomAnchor, left: leftAnchor, right: rightAnchor,
                                        paddingTop: 12, paddingLeft: 40, paddingRight: 40,height: 30)
        
        
        addSubview(startLocationIndicatorView)
        startLocationIndicatorView.centerY(inView: startigLocationTextField,leftAnchor: leftAnchor,paddingLeft: 20)
        startLocationIndicatorView.setDimentions(height: 6, width: 6)
        startLocationIndicatorView.layer.cornerRadius = 6 / 2
        
        addSubview(destinationIndicatorView)
        destinationIndicatorView.centerY(inView: destinationLocationTextField,leftAnchor: leftAnchor,paddingLeft: 20)
        destinationIndicatorView.setDimentions(height: 6, width: 6)
        
        addSubview(linkingView)
        linkingView.centerX(inView: startLocationIndicatorView)
        linkingView.anchor(top: startLocationIndicatorView.bottomAnchor,
                           bottom: destinationIndicatorView.topAnchor,
                           paddingTop: 4, paddingBottom: 4, width: 0.5)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: -  selectors
    
    @objc func handleBackTapped(){
        delegate?.dissmisLocationInpurView()
    }
}


// MARK: -  UItextField delegate
extension LocationInputView: UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard let query = textField.text else { return false}
        delegate?.executeSearch(query: query)
        return true
    }
}
