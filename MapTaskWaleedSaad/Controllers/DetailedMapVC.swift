//
//  DetailedMapVC.swift
//  MapTaskWaleedSaad
//
//  Created by Waleed Saad on 11/24/18.
//  Copyright © 2018 Waleed Saad. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class DetailedMapVC: UIViewController {
    
    //IBOUTLETS
    @IBOutlet weak var mapViewDetailed: MKMapView!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    
    //VARIABLES
    private var destinationAnnotation: AnnotationModel!
    private var locationManager = CLLocationManager()
    private var isWalking = false

    override func viewDidLoad() {
        super.viewDidLoad()

        
        updateLocationName()
        mapViewDetailed.delegate = self
        showLocation()
        

    }
    
    //Update name
    private func updateLocationName(){
        guard let title = destinationAnnotation.annotation?.title else {
            return
        }
        locationLabel.text = title
    }
    
    //Get user location
    private func showLocation(){
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
        mapViewDetailed.showsUserLocation = true
        
        //Request Route to destination by Car first (red line) then by Walking (green line)
        requestRoute(transportType: .automobile)
    }
    
    //Draw routes from user location to destination location
    func requestRoute(transportType: MKDirectionsTransportType){
        let currentLocationCoordinate = locationManager.location?.coordinate
        let destinationLocationCoordiante = self.destinationAnnotation.annotation?.coordinate
        let currentPlacemark = MKPlacemark(coordinate: currentLocationCoordinate!)
        let destinationPlacemark = MKPlacemark(coordinate: destinationLocationCoordiante!)
        let requestedRoute = MKDirections.Request()
        requestedRoute.source = MKMapItem(placemark: currentPlacemark)
        requestedRoute.destination = MKMapItem(placemark: destinationPlacemark)
        requestedRoute.transportType = transportType
        requestedRoute.requestsAlternateRoutes = true

        let directions = MKDirections(request: requestedRoute)
        directions.calculate { (response, error) in
            guard let routesArray = response?.routes else {
                return
            }
            for route in routesArray {
                self.mapViewDetailed.addOverlay(route.polyline)
                self.mapViewDetailed.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
                
                let distanceString = String(format: "%.1f", route.distance / 1000)
                self.distanceLabel.text = "\(distanceString) KM"
                
                let annotation = MKPointAnnotation()
                annotation.coordinate = (self.destinationAnnotation.annotation?.coordinate)!
                annotation.title = self.destinationAnnotation.annotation?.title!
                self.mapViewDetailed.addAnnotation(annotation)

            }
            
            //to add the walking route on top of the driving route
            while !self.isWalking{
                self.requestRoute(transportType: .walking)
                self.isWalking = true
            }
        }
    }

    
    //Inittialize annotation comes from segue from main screen
    func initInnotation(annotation: AnnotationModel){
        self.destinationAnnotation = annotation
    }
}


//EXTENSIONS
//MapView Delegate
extension DetailedMapVC: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let rendrer = MKPolylineRenderer(overlay: overlay as! MKPolyline)
        
        switch self.isWalking {
        case false:
            rendrer.strokeColor = .red
            rendrer.lineWidth = 10
            return rendrer
            
        case true:
            rendrer.strokeColor = .green
            rendrer.lineWidth = 5
            return rendrer
        }
        
    }
    
}

//CoreLocation Delegate
extension DetailedMapVC: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            self.showLocation()
        } else {
            locationManager.requestWhenInUseAuthorization()
        }
    }
    
}
