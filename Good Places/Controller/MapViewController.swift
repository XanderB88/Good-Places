//
//  MapViewController.swift
//  Good Places
//
//  Created by Alexander on 09.10.2021.
//

import UIKit
import MapKit
import CoreLocation

protocol MapViewControllerDelegate {
    func getAddress(_ address: String?)
}

class MapViewController: UIViewController {
    // MARK: - Properties
    let annotationIdentifier = "annotationIdentifier"
    let locationManager = CLLocationManager()
    let regionInMeters = 1_000.0
    
    var place = Place()
    var incomeSegueIdentifier = ""
    var mapViewControllerDelegate: MapViewControllerDelegate?
    var placeCoordinate: CLLocationCoordinate2D?
    var directionsArray: [MKDirections] = []
    var previousLocation: CLLocation? {
        didSet {
            startTrackingUserLocation()
        }
    }
    
    
    // MARK: - Outlets
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var userMark: UIImageView!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var directionButton: UIButton!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        addressLabel.text = ""
        setupMapView()
        checkLocationServices()
    }
    
    // MARK: - Private methods
    
    //    Work with a user location and a place location
    private func setupMapView() {
        directionButton.isHidden = true
        
        if incomeSegueIdentifier == "showPlace" {
            setupPlacemark()
            userMark.isHidden = true
            addressLabel.isHidden = true
            doneButton.isHidden = true
            directionButton.isHidden = false
        }
    }
    
    private func setupPlacemark() {
        guard let location = place.location else { return }
        
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(location) { placemarks, error in
            if let error = error {
                print(error)
                return
            }
            
            guard let placemarks = placemarks else { return }
            let placemark = placemarks.first
            
            let annotation = MKPointAnnotation()
            annotation.title = self.place.name
            annotation.subtitle = self.place.type
            
            guard let placemarkLocation = placemark?.location else { return }
            
            annotation.coordinate = placemarkLocation.coordinate
            self.placeCoordinate = placemarkLocation.coordinate
            
            self.mapView.showAnnotations([annotation], animated: true)
            self.mapView.selectAnnotation(annotation, animated: true)
        }
    }
    
    private func checkLocationServices() {
        if CLLocationManager.locationServicesEnabled() {
            setupLocationManager()
        } else { }
    }
    
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    private func showUserLocation() {
        if let location = locationManager.location?.coordinate {
            let region = MKCoordinateRegion(center: location,
                                            latitudinalMeters: regionInMeters,
                                            longitudinalMeters: regionInMeters)
            
            mapView.setRegion(region, animated: true)
        }
    }
    
    private func getCurrentLocation(for mapView: MKMapView) -> CLLocation {
        let latitude = mapView.centerCoordinate.latitude
        let longitude = mapView.centerCoordinate.longitude
        
        return CLLocation(latitude: latitude, longitude: longitude)
    }
    
    //    Work with a direction
    private func resetMapView(with directions: MKDirections) {
        mapView.removeOverlays(mapView.overlays)
        directionsArray.append(directions)
        let _ = directionsArray.map{ $0.cancel() }
        directionsArray.removeAll()
    }
    
    
    private func getDirections() {
        guard let location = locationManager.location?.coordinate else {
            showAlert(title: "Error", message: "Current location is not found")
            return
        }
        
        locationManager.startUpdatingLocation()
        previousLocation = CLLocation(latitude: location.latitude, longitude: location.longitude)
        
        guard let request = createDirectionsRequest(from: location) else {
            showAlert(title: "Error", message: "Destination is not found")
            return
        }
        
        let directions = MKDirections(request: request)
        resetMapView(with: directions)
        
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
                self.mapView.addOverlay(route.polyline)
                self.mapView.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
                
                let distance = String(format: "%.1f", route.distance / 1000)
                let travelTime = route.expectedTravelTime
                
                print("Distance \(distance) km.")
                print("Time\(travelTime) s.")
            }
        }
    }
    
    private func createDirectionsRequest(from coordinate: CLLocationCoordinate2D) -> MKDirections.Request? {
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
    
    private func startTrackingUserLocation() {
        guard let previousLocation = previousLocation else { return }
        
        let currentLocation = getCurrentLocation(for: mapView)
        guard currentLocation.distance(from: previousLocation) > 50 else { return }
        self.previousLocation = currentLocation
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.showUserLocation()
        }
    }
    
    //    Alert
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        
        present(alert, animated: true, completion: nil)
    }
    
    // MARK: - IBActions
    @IBAction func cancelPressed(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func centerUserLocation(_ sender: UIButton) {
        showUserLocation()
    }
    
    @IBAction func doneButtonPressed(_ sender: Any) {
        mapViewControllerDelegate?.getAddress(addressLabel.text)
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func directionButtonPressed(_ sender: UIButton) {
        getDirections()
        
    }
}

// MARK: - Map view delegate
extension MapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard !(annotation is MKUserLocation) else { return nil }
        
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: annotationIdentifier)
        
        if annotationView == nil {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: annotationIdentifier)
            annotationView?.canShowCallout = true
        }
        
        if let imageData = place.imageData {
            let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
            imageView.layer.cornerRadius = 10
            imageView.clipsToBounds = true
            imageView.image = UIImage(data: imageData)
            annotationView?.rightCalloutAccessoryView = imageView
        }
        
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        let currentLocation = getCurrentLocation(for: mapView)
        let geocoder = CLGeocoder()
        
        if incomeSegueIdentifier == "showPlace" && previousLocation != nil {
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                self.showUserLocation()
            }
        }
        
        geocoder.cancelGeocode()
        
        geocoder.reverseGeocodeLocation(currentLocation) { placemarks, error in
            if let error = error {
                print(error)
                return
            }
            
            guard let placemarks = placemarks else { return }
            
            let placemark = placemarks.first
            let streetName = placemark?.thoroughfare
            let buildNumber = placemark?.subThoroughfare
            
            DispatchQueue.main.async {
                if streetName != nil && buildNumber != nil {
                    self.addressLabel.text = "\(streetName!), \(buildNumber!)"
                } else if streetName != nil {
                    self.addressLabel.text = "\(streetName!)"
                } else {
                    self.addressLabel.text = ""
                }
                
            }
        }
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay as! MKPolyline)
        renderer.strokeColor = .blue
        renderer.lineWidth = 5.0
        
        return renderer
    }
}

// MARK: - Location manager delegate
extension MapViewController: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
            case .notDetermined:
                manager.requestWhenInUseAuthorization()
                break
            case .authorizedWhenInUse:
                mapView.showsUserLocation = true
                
                if incomeSegueIdentifier == "userLocation" {
                    showUserLocation()
                    userMark.isHidden = false
                }
                break
            case .denied, .restricted:
                showAlertLocationService()
                break
            case .authorizedAlways:
                break
            @unknown default:
                print("New case is avalible")
        }
    }
    
    fileprivate func showAlertLocationService() {
        let alert = UIAlertController(title: "Your location is not available", message:"For using your location to give permission go to settings" , preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Settings", style: .default, handler: { _ in
            let url = URL(string: "App-prefs:root=LOCATION_SERVICES")!
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
}
