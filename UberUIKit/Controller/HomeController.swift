//
//  HomeController.swift
//  UberUIKit
//
//  Created by Javier Cueto on 10/11/20.
//

import UIKit
import Firebase
import MapKit

private let reuseIndentifier = "LocationCell"
private let annotationIdentifier = "DriverAnnotation"

class HomeController: UIViewController{
    
    // MARK: -  properties
    private let mapView = MKMapView()
    private let locationManager = LocationHandler.shared.locationManager
    private let inputActivationView = LocationInputActivation()
    private let locationInputView = LocationInputView()
    private var searchResults = [MKPlacemark]()
    
    private let tableView = UITableView()
    
    private final let locationInputViewHeight = 200
    
    private var user: User? {
        didSet{
            locationInputView.user = user
        }
    }

    // MARK: -  lifycicle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        enableLocationServices()
        fechUserData()
        fetchDrivers()
        //signOut()
    }
    
    // MARK: -  API
    func fechUserData(){
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        Service.shared.fetchUserData(uid: currentUid) { (user) in
            self.user = user
        }
    }
    
    func fetchDrivers(){
        guard let location = locationManager?.location else {return}
        Service.shared.fetchDrivers(location: location) { (driver) in
            guard let coordinate = driver.location?.coordinate else { return}
            let annotation = DriverAnnotation(uid: driver.uid, coordinate: coordinate)
            
            var driverIsVisible: Bool{
                return self.mapView.annotations.contains { (annotation) -> Bool in
                    guard let driverAnno = annotation as? DriverAnnotation else { return false}
                    if driverAnno.uid == driver.uid {
                        driverAnno.updateAnnotationPosition(with: coordinate)
                        return true
                    }
                    return false
                }
                
            }
            
            if !driverIsVisible{
                self.mapView.addAnnotation(annotation)
            }
            
            
        }
    }

    
    func signOut(){
        do{
            try Auth.auth().signOut()
        }catch{
            print("DEBUG: un error a ocurrido")
        }
       
    }
    
    // MARK: -  helper functions
    
    func configureUI(){
        configureMapView()
        view.addSubview(inputActivationView)
        inputActivationView.centerX(inView: view)
        inputActivationView.setDimentions(height: 50, width: view.frame.width - 64)
        inputActivationView.anchor(top: view.safeAreaLayoutGuide.topAnchor, paddingTop: 32)
        inputActivationView.alpha = 0
        inputActivationView.delegate = self
        
        UIView.animate(withDuration: 0.3) {
            self.inputActivationView.alpha = 1
        }
        
        configureTableView()
        
    }
    
    func configureMapView(){
        view.addSubview(mapView)
        mapView.frame = view.frame
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .follow
        mapView.delegate = self
    }
    
    func configureLocationInputView(){
        locationInputView.delegate = self
        view.addSubview(locationInputView)
        locationInputView.anchor(top: view.topAnchor,left:  view.leftAnchor, right: view.rightAnchor, height: CGFloat(locationInputViewHeight))
        locationInputView.alpha = 0
        UIView.animate(withDuration: 0.5) {
            self.locationInputView.alpha = 1
        } completion: { (_) in
            UIView.animate(withDuration: 0.3) {
                self.tableView.frame.origin.y = CGFloat(self.locationInputViewHeight)
            }
            
        }

    }
    
    func configureTableView(){
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(LocationCell.self, forCellReuseIdentifier: reuseIndentifier)
        tableView.rowHeight = 60
        tableView.tableFooterView = UIView()
        let height = view.frame.height - CGFloat(locationInputViewHeight)
        tableView.frame = CGRect(x: 0, y: view.frame.height, width: view.frame.width, height: height)
        
        view.addSubview(tableView)
    }
    
    
    func dissmisLocationView(completion: ((Bool) -> Void)? = nil){

        
        UIView.animate(withDuration: 0.3, animations:  {
            self.locationInputView.alpha = 0
            self.tableView.frame.origin.y = self.view.frame.height
            self.locationInputView.removeFromSuperview()
            UIView.animate(withDuration: 0.3) {
                self.inputActivationView.alpha = 1
            }
        }, completion: completion)

    }
}


// MARK: -  map helper functions

private extension HomeController{
    func searchBy(naturalLanguajeQuery: String , completion: @escaping([MKPlacemark]) -> Void){
        var results = [MKPlacemark]()
        let request = MKLocalSearch.Request()
        
        request.region = mapView.region
        
        request.naturalLanguageQuery = naturalLanguajeQuery
        
        let search = MKLocalSearch(request: request)
        
        search.start { (response, error) in
            guard let response = response else {return}
            response.mapItems.forEach { (item) in
                results.append(item.placemark)
            }
            
            completion(results)
        }
    }
}

// MARK: - MKMapViewDelegate
extension HomeController: MKMapViewDelegate{
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if let annotation = annotation as? DriverAnnotation{
            let view = MKAnnotationView(annotation: annotation, reuseIdentifier: annotationIdentifier)
            view.image = UIImage(systemName: "car.fill")
            return view
        }
        
        return nil
    }
}


// MARK: -  location services
extension HomeController: CLLocationManagerDelegate{
    
    func enableLocationServices(){
        switch CLLocationManager.authorizationStatus(){
        
        case .notDetermined:
            print("DEBUG: Not determined")
            locationManager?.requestWhenInUseAuthorization()
        case .restricted, .denied:
           break
        case .authorizedAlways:
            print("DEBUG: auth always ...")
            locationManager?.startUpdatingLocation()
            locationManager?.desiredAccuracy = kCLLocationAccuracyBest
        case .authorizedWhenInUse:
            print("DEBUG: auth when in use")
            locationManager?.requestAlwaysAuthorization()
        @unknown default:
            break
        }
    }
    
   
}

// MARK: -  location input activation delegate
extension HomeController: LocationInputActivationViewDelegate {
    func presentLocationInputView() {
        inputActivationView.alpha = 0
        configureLocationInputView()
    }
    
    
}

// MARK: -  location input view delegate

extension HomeController: LocationInputViewDelegate {
    func executeSearch(query: String) {
        searchBy(naturalLanguajeQuery: query) { (placemarks) in
            self.searchResults = placemarks
            self.tableView.reloadData()
        }
    }
    
    func dissmisLocationInputView() {
        dissmisLocationView()

    }
    
    
}

// MARK: -  tables datasource and delegate

extension HomeController: UITableViewDataSource, UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "test"
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? 2 : searchResults.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIndentifier, for: indexPath) as! LocationCell
        if indexPath.section == 1 {
            cell.titleLabelText = searchResults[indexPath.row].name
            cell.addressLabelText = searchResults[indexPath.row].address
        }
   
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedPlacemark = searchResults[indexPath.row]
        dissmisLocationView { (_) in
            let annotation = MKPointAnnotation()
            annotation.coordinate = selectedPlacemark.coordinate
            self.mapView.addAnnotation(annotation)
            self.mapView.selectAnnotation(annotation, animated: true)
        }
    }
    
}
