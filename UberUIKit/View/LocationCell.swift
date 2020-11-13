//
//  LocationInputCell.swift
//  UberUIKit
//
//  Created by Javier Cueto on 12/11/20.
//

import UIKit

class LocationCell: UITableViewCell {
    
    var titleLabelText: String? {
        didSet{
            titleLabel.text = titleLabelText
        }
    }
    
    var addressLabelText: String? {
        didSet{
            addressLabel.text = addressLabelText
        }
    }
        

    // MARK: -  properties
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        return label
    }()
    
    private let addressLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .lightGray
        return label
    }()
    // MARK: -  lifecycle
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        let stack = UIStackView(arrangedSubviews: [titleLabel,addressLabel])
        
        selectionStyle = .none
        
        stack.axis = .vertical
        stack.distribution = .fillEqually
        stack.spacing = 4
        
        addSubview(stack)
        stack.centerY(inView: self, leftAnchor: leftAnchor, paddingLeft: 12)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

}
