//
//  PickupController.swift
//  UberUIKit
//
//  Created by Javier Cueto on 16/11/20.
//

import UIKit
import MapKit

class PickupController: UIViewController {
    
    // MARK: -  properties
    private let mapview = MKMapView()
    let trip: Trip
    
    private let cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "xmark"), for: .normal)
        button.tintColor = .white
        button.addTarget(self, action: #selector(handleDismissal), for: .touchUpInside)
        return button
    }()
    
    private let pickupLabel: UILabel = {
        let label = UILabel()
        label.text = "Would you like to pickup passenger?"
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .white   
        return label
    }()
    
    private let accepTripButton: UIButton = {
        let button = UIButton(type: .system)
        button.addTarget(self, action: #selector(handleTrip), for: .touchUpInside)
        button.backgroundColor = .white
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        button.setTitleColor(.black, for: .normal)
        button.setTitle("ACCEPT TRIP", for: .normal)
        return button
    }()
    
    // MARK: -  lifecycle
    
    init(trip: Trip){
        self.trip = trip
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        configureMapView()
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    // MARK: -  selectors
    
    @objc func handleDismissal(){
        dismiss(animated: true, completion: nil)
    }
    
    
    @objc func handleTrip(){
        dismiss(animated: true, completion: nil)
    }
    // MARK: -  API
    
    // MARK: -  helper functions
    
    func configureMapView(){
        let region = MKCoordinateRegion(center: trip.pickupCoordinates, latitudinalMeters: 1000 , longitudinalMeters: 1000)
        mapview.setRegion(region, animated: true)
        
        let anno = MKPointAnnotation()
        anno.coordinate = trip.pickupCoordinates
        mapview.addAnnotation(anno)
        mapview.selectAnnotation(anno, animated: true)
        
    }
    
    func configureUI(){
        view.backgroundColor = .backgroundColor
        
        view.addSubview(cancelButton)
        
        cancelButton.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, paddingTop: 16, paddingLeft: 16)
        
        
        view.addSubview(mapview)
        mapview.setDimentions(height: 270, width: 270)
        mapview.layer.cornerRadius = 270 / 2
        mapview.centerX(inView: view)
        mapview.anchor(top: view.safeAreaLayoutGuide.topAnchor, paddingTop: 16)
        
        view.addSubview(pickupLabel)
        pickupLabel.centerX(inView: view)
        pickupLabel.anchor(top: mapview.bottomAnchor, paddingTop: 16)
        
        view.addSubview(accepTripButton)
        accepTripButton.anchor(top: pickupLabel.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 16, paddingLeft: 32, paddingRight:  32,height: 50)
    }
}
