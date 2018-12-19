//
//  ViewController.swift
//  MapTaskWaleedSaad
//
//  Created by Waleed Saad on 11/24/18.
//  Copyright © 2018 Waleed Saad. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class MainScreenVC: UIViewController {
    //OUTLETS
    @IBOutlet weak var mapView: MKMapView!
    
    //VARIABLES
    private let locationManager = CLLocationManager()
    private let radius: Double = 5000
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //Define delegates
        mapView.delegate = self
        locationManager.delegate = self
        
        //Check for LocationServices
        checkLocationServices()
        
        

    }
    
    
    private func checkLocationServices(){
        if CLLocationManager.locationServicesEnabled() {
            //Check for Authorization
            checkAuth()
        } else {
            //Alert to show an error when locaion services are off
            let gpsAllert = UIAlertController(title: "Location Services", message: "Turn on Location Services", preferredStyle: .alert)
            present(gpsAllert, animated: true, completion: nil)
        }
    }
    
    private func checkAuth(){
        switch CLLocationManager.authorizationStatus() {
        case .authorizedWhenInUse:
            //Get location
            getCurrentLocation()
        default:
            locationManager.requestWhenInUseAuthorization()
        }
    }
    
    private func getCurrentLocation(){
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
        mapView.showsUserLocation = true
        //Center the map on blue point of location around 5 KM radius
        centerMap()
    }
    
    private func centerMap(){
        if let coordinates = locationManager.location?.coordinate {
            let region = MKCoordinateRegion(center: coordinates, latitudinalMeters: radius, longitudinalMeters: radius)
            mapView.setRegion(region, animated: true)
        }
    }
    
    
    //BUTTONS CLICKED
    
    //Search for nearby banks
    @IBAction func seachBankAction(_ sender: Any) {
        search(textToSearchWith: "bank")
    }
    //Search for nearby mosques
    @IBAction func searchMosqueAction(_ sender: Any) {
        search(textToSearchWith: "mosque")
    }
    
    
    //Local search request
    private func search(textToSearchWith text: String){
        let searchRequest = MKLocalSearch.Request()
        searchRequest.naturalLanguageQuery = text
        searchRequest.region.center = mapView.region.center
        let search = MKLocalSearch(request: searchRequest)
        search.start { (response, error) in
            guard let places = response?.mapItems else {
                return
            }
            self.mapView.removeAnnotations(self.mapView.annotations)
            for place in places {
                let annotation = MKPointAnnotation()
                annotation.coordinate = place.placemark.coordinate
                annotation.title = place.name
                self.mapView.addAnnotation(annotation)
            }
            self.centerMap()
        }
    }
    

}

//EXTENSIONS FOR DELEGATES
//MapView Delegate
extension MainScreenVC: MKMapViewDelegate{
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        guard view.annotation?.coordinate != nil else {
            return
        }
        if view.annotation?.title == "My Location" {
            return
        }
        let destinationAnnotation = view.annotation
        
        let annotationToSend = AnnotationModel.init(annotation: destinationAnnotation)
        performSegue(withIdentifier: "detailedMapSegue", sender: annotationToSend)
    
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let detailedMapVC = segue.destination as? DetailedMapVC {
            detailedMapVC.initInnotation(annotation: sender as! AnnotationModel)
        }
    }
    
}

//CoreLocaion Delegate
extension MainScreenVC: CLLocationManagerDelegate{
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let lastLocation = locations.last else {
            return
        }
        let center = CLLocationCoordinate2D(latitude: lastLocation.coordinate.latitude, longitude: lastLocation.coordinate.longitude)
        let region = MKCoordinateRegion(center: center, latitudinalMeters: radius, longitudinalMeters: radius)
        mapView.setRegion(region, animated: true)
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        switch status {
        case .notDetermined:
            locationManager.requestLocation()
        case .authorizedWhenInUse:
            self.getCurrentLocation()
        default:
            print("Denied")
        }
        
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
    }
    
}
