//
//  MapManager.swift
//  Good Places
//
//  Created by Alexander on 16.10.2021.
//

import UIKit
import MapKit

class MapManager {
    // MARK: - Properties
    let locationManager = CLLocationManager()
    private let regionInMeters = 1_000.0
    
    private var placeCoordinate: CLLocationCoordinate2D?
    private var directionsArray: [MKDirections] = []
    
    // MARK: - Methods
    //    Mark of a place
    func setupPlaceMark(place: Place, mapView: MKMapView) {
        guard let location = place.location else { return }
        
        let geoCoder = CLGeocoder()
        geoCoder.geocodeAddressString(location) { placeMarks, error in
            if let error = error {
                print(error)
                return
            }
            
            guard let placeMarks = placeMarks else { return }
            let placeMark = placeMarks.first
            
            let annotation = MKPointAnnotation()
            annotation.title = place.name
            annotation.subtitle = place.type
            
            guard let placeMarkLocation = placeMark?.location else { return }
            
            annotation.coordinate = placeMarkLocation.coordinate
            self.placeCoordinate = placeMarkLocation.coordinate
            
            mapView.showAnnotations([annotation], animated: true)
            mapView.selectAnnotation(annotation, animated: true)
        }
    }
    
    //    Check location services is available
    func checkLocationServices(mapView: MKMapView, closure: () -> ()) {
        if CLLocationManager.locationServicesEnabled() {
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            closure()
        }
    }
    
    //    Focus on the user location
    func showUserLocation(mapView: MKMapView) {
        if let location = locationManager.location?.coordinate {
            let region = MKCoordinateRegion(center: location,
                                            latitudinalMeters: regionInMeters,
                                            longitudinalMeters: regionInMeters)
            
            mapView.setRegion(region, animated: true)
        }
    }
    
    //    Route to the place location
    func getDirections(for mapView: MKMapView, previousLocation: (CLLocation) -> ()) {
        guard let location = locationManager.location?.coordinate else {
            showAlert(title: "Error", message: "Current location is not found")
            return
        }
        
        locationManager.startUpdatingLocation()
        previousLocation(CLLocation(latitude: location.latitude, longitude: location.longitude))
        
        
        guard let request = createDirectionsRequest(from: location) else {
            showAlert(title: "Error", message: "Destination is not found")
            return
        }
        
        let directions = MKDirections(request: request)
        resetMapView(with: directions, mapView: mapView)
        
        directions.calculate { response, error in
            if let error = error {
                print(error)
                return
            }
            
            guard let response = response else {
                self.showAlert(title: "Error", message: "Direction is not available")
                return
            }
            
            for route in response.routes {
                mapView.addOverlay(route.polyline)
                mapView.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
                
                let distance = String(format: "%.1f", route.distance / 1000)
                let travelTime = route.expectedTravelTime
                
                print("Distance \(distance) km.")
                print("Time\(travelTime) s.")
            }
        }
    }
    
    //    Config a direction request
    func createDirectionsRequest(from coordinate: CLLocationCoordinate2D) -> MKDirections.Request? {
        guard let destinationCoordinate = placeCoordinate else { return nil }
        
        let startLocation = MKPlacemark(coordinate: coordinate)
        let destination = MKPlacemark(coordinate: destinationCoordinate)
        
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: startLocation)
        request.destination = MKMapItem(placemark: destination)
        request.transportType = .automobile
        request.requestsAlternateRoutes = true
        
        return request
    }
    
    //    Change a map region according the user location
    func startTrackingUserLocation(mapView: MKMapView, location: CLLocation?, closure: (_ previousLocation: CLLocation) -> ()) {
        guard let location = location else { return }
        let centerMapLocation = getCenterMapLocation(for: mapView)
        guard centerMapLocation.distance(from: location) > 50 else { return }
        
        closure(centerMapLocation)
    }
    
    func getCenterMapLocation(for mapView: MKMapView) -> CLLocation {
        let latitude = mapView.centerCoordinate.latitude
        let longitude = mapView.centerCoordinate.longitude
        
        return CLLocation(latitude: latitude, longitude: longitude)
    }
    
    //    Reset the mapView before the routing
    func resetMapView(with directions: MKDirections, mapView: MKMapView) {
        mapView.removeOverlays(mapView.overlays)
        directionsArray.append(directions)
        let _ = directionsArray.map{ $0.cancel() }
        directionsArray.removeAll()
    }
    
    //    Alert
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        
        let alertWindow = UIWindow(frame: UIScreen.main.bounds)
        alertWindow.rootViewController = UIViewController()
        alertWindow.windowLevel = UIWindow.Level.alert + 1
        alertWindow.makeKeyAndVisible()
        alertWindow.rootViewController?.present(alert, animated: true, completion: nil)
    }
}
