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

private enum ActionButtonConfiguration{
    case showMenu
    case dismissActionView
    
    init(){
        self = .showMenu
    }
}

class HomeController: UIViewController{
    
    // MARK: -  properties
    private let mapView = MKMapView()
    private let locationManager = LocationHandler.shared.locationManager
    private let inputActivationView = LocationInputActivation()
    private let locationInputView = LocationInputView()
    private let rideActionView = RideActionView()
    private var searchResults = [MKPlacemark]()
    private var actionButtonConfig = ActionButtonConfiguration()
    private let tableView = UITableView()
    private final let locationInputViewHeight = 200
    private final let rideActionViewHeight = 300
    private var user: User? {
        didSet{
            locationInputView.user = user
            if user?.accountType == .passenger {
                fetchDrivers()
                configureLocationInputActivationView()
                observeCurrentTrip()
            }else {
                observeTrips()
            }
        }
    }
    private var trip: Trip? {
        didSet{
            guard let user = user else { return }
            
            if user.accountType == .driver {
                guard let trip = trip else {return }
                let controller = PickupController(trip: trip)
                controller.modalPresentationStyle = .fullScreen
                self.present(controller, animated: true, completion: nil)
                controller.delegate = self
            }else{
                print("DEBUG: show ride action view for accepted trip ...")
            }
        
        }
    }
    private let actionButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "menu_icon").withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(acctionButtonPressed), for: .touchUpInside)
        return button
    }()

    private var route: MKRoute?
    // MARK: -  lifycicle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        enableLocationServices()
        fechUserData()
       // fetchDrivers()
        //signOut()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        guard let trip = trip else { return }
        
    }
    
    // MARK: -  API
    
    func observeCurrentTrip(){
        Service.shared.observeCurrentTrip { (trip) in
            self.trip = trip
            
            if trip.state == .accepted {
                self.shouldPresentLoadingView(false)
                
                guard let driverUid = trip.driverUid else { return }
                
                Service.shared.fetchUserData(uid: driverUid) { (driver) in
                    self.animateRideActionVIew(shouldShow: true, config: .tripAccepted, user: driver)
                }
                
                
            }
        }
    }
    
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
    
    func observeTrips(){
        Service.shared.observeTrips { (trip) in
            self.trip = trip
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
    
    private func configureActionButton(config: ActionButtonConfiguration){
        switch config {
            case .showMenu:
                actionButton.setImage(#imageLiteral(resourceName: "menu_icon").withRenderingMode(.alwaysOriginal), for: .normal)
                actionButtonConfig = .showMenu
                
            case .dismissActionView:
                actionButton.setImage(#imageLiteral(resourceName: "baseline_arrow_back_black_36dp").withRenderingMode(.alwaysOriginal), for: .normal)
                actionButtonConfig = .dismissActionView
            
        }
    }
    
    func configureUI(){
        configureMapView()
        configureRideActionView()
        view.addSubview(actionButton)
        actionButton.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, paddingTop: 16, paddingLeft: 20, width: 30, height: 30)
        
        
        
        
        
       
        
        configureTableView()
        
    }
    
    
    func configureLocationInputActivationView(){
        view.addSubview(inputActivationView)
        inputActivationView.centerX(inView: view)
        inputActivationView.setDimentions(height: 50, width: view.frame.width - 64)
        inputActivationView.anchor(top: actionButton.bottomAnchor, paddingTop: 32)
        inputActivationView.alpha = 0
        inputActivationView.delegate = self
        
        
        UIView.animate(withDuration: 0.3) {
            self.inputActivationView.alpha = 1
        }
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
    
    func configureRideActionView(){
        rideActionView.delegate = self
        view.addSubview(rideActionView)
        rideActionView.frame = CGRect(x: 0, y: view.frame.height , width: view.frame.width, height: CGFloat(self.rideActionViewHeight))
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
            
        }, completion: completion)

    }
    
    func animateRideActionVIew(shouldShow: Bool, destination: MKPlacemark? = nil, config: RideActionViewConfiguration? = nil, user: User? = nil){
        
        let yOrigin = shouldShow ? self.view.frame.height - CGFloat(self.rideActionViewHeight) : self.view.frame.height
        
        UIView.animate(withDuration: 0.3) {
            self.rideActionView.frame.origin.y = yOrigin
        }
        
        if shouldShow {
            guard let config = config else { return }
            
            if let destination = destination {
                rideActionView.destination = destination
            }
            
            if let user = user {
                rideActionView.user = user
            }
            
            rideActionView.configureUI(withCOnfig: config)
           
        }
        
      
        
    }
}

// MARK: -  #selectors
extension HomeController{
    @objc func acctionButtonPressed(){
        switch actionButtonConfig {
        
        case .showMenu:
            print("menu")
        case .dismissActionView:
           removeAnnotationsAndOverlay()
            mapView.showAnnotations(mapView.annotations, animated: true)
            UIView.animate(withDuration: 0.3) {
                self.inputActivationView.alpha = 1
                self.configureActionButton(config: .showMenu)
                self.animateRideActionVIew(shouldShow: false)
                
            }
           
        }
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
    
    func generatePolyline(toDestination destination: MKMapItem){
        let request = MKDirections.Request()
        request.source = MKMapItem.forCurrentLocation()
        request.destination = destination
        request.transportType = .automobile
        
        
        
        let directionRequest = MKDirections(request: request)
        directionRequest.calculate { (response, error) in
            guard let response = response else { return }
            self.route = response.routes[0]
            guard let polyline = self.route?.polyline else { return }
            self.mapView.addOverlay(polyline)
        }
    }
    
    func removeAnnotationsAndOverlay(){
        mapView.annotations.forEach { (annotation) in
            if let anno = annotation as? MKPointAnnotation{
                    self.mapView.removeAnnotation(anno)
            }
        }
        
        if mapView.overlays.count > 0 {
            mapView.removeOverlay(mapView.overlays[0])
        }
    }
    
    func centerMapOnUserLocation(){
        guard let coordinate = locationManager?.location?.coordinate else {return}
        let region = MKCoordinateRegion(center: coordinate, latitudinalMeters: 2000, longitudinalMeters: 2000)
        mapView.setRegion(region, animated: true)
    }
    
    func setCustomRegion(withCoordinates coordinates: CLLocationCoordinate2D){
        
        let region = CLCircularRegion(center: coordinates, radius: 25, identifier: "pickup")
        locationManager?.startMonitoring(for: region)
    }
}

// MARK: - MKMapViewDelegate
extension HomeController: MKMapViewDelegate{
    
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        guard let user = self.user else {return}
        guard user.accountType == .driver else {return}
        guard  let location = userLocation.location else {return}
        
        Service.shared.updateDriverLocation(location: location)
    }
    
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if let annotation = annotation as? DriverAnnotation{
            let view = MKAnnotationView(annotation: annotation, reuseIdentifier: annotationIdentifier)
            view.image = UIImage(systemName: "car.fill")
            return view
        }
        
        return nil
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let route = self.route {
            let polyline = route.polyline
            let lineRenderer = MKPolylineRenderer(overlay: polyline)
            lineRenderer.strokeColor = .mainBlueTint
            lineRenderer.lineWidth = 4
            return lineRenderer
        }
        
        return MKOverlayRenderer()
    }
}


// MARK: -  location services
extension HomeController: CLLocationManagerDelegate{
    
    func locationManager(_ manager: CLLocationManager, didStartMonitoringFor region: CLRegion) {
        print("DEBUG: Did start monitoring for region \(region)")
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        print("DEBUG: Driver di enter passenger region ...")
    }
    
    func enableLocationServices(){
        locationManager?.delegate = self
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
        dissmisLocationView { (_) in
            UIView.animate(withDuration: 0.3) {
                self.inputActivationView.alpha = 1
            }
        }

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

        configureActionButton(config: .dismissActionView)

        
        let destination = MKMapItem(placemark: selectedPlacemark)
        generatePolyline(toDestination: destination)
        

        dissmisLocationView { (_) in
            let annotation = MKPointAnnotation()
            annotation.coordinate = selectedPlacemark.coordinate
            self.mapView.addAnnotation(annotation)
            self.mapView.selectAnnotation(annotation, animated: true)
            
            
            let annotations = self.mapView.annotations.filter({!$0.isKind(of: DriverAnnotation.self)})
            
            self.mapView.zoomFit(annotations: annotations)
            
            self.animateRideActionVIew(shouldShow: true,destination: selectedPlacemark,config: .requestRide)
            

        }
        
        
        
        
    }
    
}


extension HomeController: RideActionViewDelegate{
    func cancelTrip() {
        Service.shared.cancelTrip { (error, ref) in
            if let error = error {
                print("DEBUG: Error deleting trip ...\(error.localizedDescription)")
                return
            }
            
            self.centerMapOnUserLocation()
            
            self.animateRideActionVIew(shouldShow: false)
            self.removeAnnotationsAndOverlay()
            
            self.actionButton.setImage(#imageLiteral(resourceName: "menu_icon").withRenderingMode(.alwaysOriginal), for: .normal)
            self.actionButtonConfig = .showMenu
            
            self.inputActivationView.alpha = 1
   
        }
    }
    
    
    
    func uploadTrip(_ view: RideActionView) {
        
        print("here_ mostrando")
        guard  let pickupCoordinates = locationManager?.location?.coordinate else {
            return
        }
        print("here_ mostrando 2")
        guard  let destinationCoordinates = view.destination?.location?.coordinate else {
            return
        }
        
        print("here_ mostrando 3")
        shouldPresentLoadingView(true, message: "Finding you a ride ...")
        print("here_ mostrando 4")
        Service.shared.uploadTrip(pickupCoordinates, destinationCoordinates) { (error, ref) in
            if let error = error {
                print("DEBUG: error in confirm UBERX \(error.localizedDescription)")
            }
            
            UIView.animate(withDuration: 0.3) {
                self.rideActionView.frame.origin.y = self.view.frame.height
            }
            
        }
    }
}

// MARK: -  pickupControllerDelegate
extension HomeController: PickupControllerDelegate {
    func didAcceptTrip(_ trip: Trip) {
        //self.trip?.state = .accepted
        let anno = MKPointAnnotation()
        anno.coordinate = trip.pickupCoordinates
        mapView.addAnnotation(anno)
        mapView.selectAnnotation(anno, animated: true)
        
        setCustomRegion(withCoordinates: trip.pickupCoordinates)
        
        let placeMark = MKPlacemark(coordinate: trip.pickupCoordinates)
        let mapItem = MKMapItem(placemark: placeMark)
        generatePolyline(toDestination: mapItem)
        
        mapView.zoomFit(annotations: mapView.annotations)
        
        
        Service.shared.observeTripCancelled(trip: trip) {
            self.removeAnnotationsAndOverlay()
            self.animateRideActionVIew(shouldShow: false)
            self.centerMapOnUserLocation()
            
            self.presentAlertController(withTitle: "Oops!",withMessage: "The passenger has decided to cancel this ride. press OK to continue.")
        }
        
        
        
        self.dismiss(animated: true){
            Service.shared.fetchUserData(uid: trip.passengerUid) { (passenger) in
                self.animateRideActionVIew(shouldShow: true, config: .tripAccepted, user: passenger)
            }
            
        }
    }
    
    
}
