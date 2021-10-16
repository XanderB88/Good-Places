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
    let mapManager = MapManager()
    
    var place = Place()
    var incomeSegueIdentifier = ""
    var mapViewControllerDelegate: MapViewControllerDelegate?
    var previousLocation: CLLocation? {
        didSet {
            mapManager.startTrackingUserLocation(mapView: mapView,
                                                 location: previousLocation) { (currentLocation) in
                self.previousLocation = currentLocation
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    self.mapManager.showUserLocation(mapView: self.mapView)
                }
            }
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
    }
    
    // MARK: - Private methods
    
    private func setupMapView() {
        directionButton.isHidden = true
        
        mapManager.checkLocationServices(mapView: mapView) {
            mapManager.locationManager.delegate = self
        }
        
        if incomeSegueIdentifier == "showPlace" {
            mapManager.setupPlaceMark(place: place, mapView: mapView)
            userMark.isHidden = true
            addressLabel.isHidden = true
            doneButton.isHidden = true
            directionButton.isHidden = false
        }
    }
    
    // MARK: - IBActions
    @IBAction func cancelPressed(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func centerUserLocation(_ sender: UIButton) {
        mapManager.showUserLocation(mapView: mapView)
    }
    
    @IBAction func doneButtonPressed(_ sender: Any) {
        mapViewControllerDelegate?.getAddress(addressLabel.text)
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func directionButtonPressed(_ sender: UIButton) {
        mapManager.getDirections(for: mapView) { location in
            self.previousLocation = location
        }
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
        let currentLocation = mapManager.getCenterMapLocation(for: mapView)
        let geoCoder = CLGeocoder()
        
        if incomeSegueIdentifier == "showPlace" && previousLocation != nil {
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                self.mapManager.showUserLocation(mapView: mapView)
            }
        }
        
        geoCoder.cancelGeocode()
        
        geoCoder.reverseGeocodeLocation(currentLocation) { placeMarks, error in
            if let error = error {
                print(error)
                return
            }
            
            guard let placeMarks = placeMarks else { return }
            
            let placeMark = placeMarks.first
            let streetName = placeMark?.thoroughfare
            let buildNumber = placeMark?.subThoroughfare
            
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
                    mapManager.showUserLocation(mapView: mapView)
                    userMark.isHidden = false
                }
                break
            case .denied, .restricted:
                showAlertLocationService()
                break
            case .authorizedAlways:
                break
            @unknown default:
                print("New case is available")
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
