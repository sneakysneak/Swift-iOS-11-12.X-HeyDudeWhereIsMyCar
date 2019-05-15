//
//  ViewController.swift
//  DudeWhereIsMyCar
//
//  Created by sneakysneak on 03/04/2019.
//  Copyright © 2019 sneakysneak. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {

    @IBOutlet var map: MKMapView!
    
    var manager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        // Define a long press recognizer
        let uilpgr = UILongPressGestureRecognizer(target: self, action: #selector(ViewController.longpress(gestureRecognizer:)))
        
        map.addGestureRecognizer(uilpgr)
        
        if activePlace == -1 {
            
            manager.delegate = self
            manager.desiredAccuracy = kCLLocationAccuracyBest
            manager.requestWhenInUseAuthorization()
            manager.startUpdatingLocation()
            
        } else {
            
            // Get place details and display them on the map
            if places.count > activePlace {
                
                if let name = places[activePlace]["name"] {
                    
                    if let lat = places[activePlace]["lat"] {
                        
                        if let lon = places[activePlace]["lon"] {
                            
                            if let latitude = Double(lat) {
                                
                                if let longitude = Double(lon) {
                                    
                                    let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                                    
                                    let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                                    
                                    let region = MKCoordinateRegion(center: coordinate, span: span)
                                    
                                    self.map.setRegion(region, animated: true)
                                    
                                    let annotation = MKPointAnnotation()
                                    
                                    annotation.coordinate = coordinate
                                    
                                    annotation.title = name
                                    
                                    self.map.addAnnotation(annotation)
                                    
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    @objc func longpress(gestureRecognizer: UILongPressGestureRecognizer) {
        
//        print("its working?!")
        
        // Longpress print it ONCE!
        if gestureRecognizer.state == UIGestureRecognizer.State.began {
        
        let touchPoint = gestureRecognizer.location(in: self.map)
            
        let newCoordinate = self.map.convert(touchPoint, toCoordinateFrom: self.map)
            
        let  location = CLLocation(latitude: newCoordinate.latitude, longitude: newCoordinate.longitude)
            
        var title = ""

        // CLlocation or CLlocation 2D !! gotta convert
        CLGeocoder().reverseGeocodeLocation(location, completionHandler: { (placemarks, error) in
                
                if error != nil {
                    
                    print(error)
                    
                } else {
                    
                    if let placemark = placemarks?[0] {
                        
                        // Convert 1D to 2D CLLocation
                        if placemark.subThoroughfare != nil {
                            
                            title += placemark.subThoroughfare! + " "
                        }
                        
                        if placemark.thoroughfare != nil {
                            
                            title += placemark.thoroughfare!
                        }
                        
                    }
                    
                }
            
            if title == "" {
                
                title = "\(NSDate())"
                
            }
            
//            print(newCoordinate)
            
            let annotaion = MKPointAnnotation()
            
            annotaion.coordinate = newCoordinate
            
            annotaion.title = "My vehicle"
            
            self.map.addAnnotation(annotaion)
            
            places.append(["name":title,"lat":String(newCoordinate.latitude),"lon":String(newCoordinate.longitude)])
            
            // Update user default array too
            UserDefaults.standard.set(places, forKey: "places")
            
            print(places)
            
            })
            
        }
        
    }
    
    // didUpdateLocation method
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let location = CLLocationCoordinate2D(latitude: locations[0].coordinate.latitude, longitude: locations[0].coordinate.longitude)
        
        let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        
        let region = MKCoordinateRegion(center: location, span: span)
        
        self.map.setRegion(region, animated: true)
        
    }

}

