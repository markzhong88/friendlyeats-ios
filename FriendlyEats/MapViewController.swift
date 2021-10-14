//
//  MapViewController.swift
//  FriendlyEats
//
//  Created by Mark Zhong on 10/14/21.
//  Copyright © 2021 Firebase. All rights reserved.
//

import UIKit
import FirebaseUI
import FirebaseFirestore
import SDWebImage
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate {
    
    var window: UIWindow?
    var mapView: MKMapView = MKMapView()
    private var flying_spots: [DBFlyingSpot] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Flying Spot"
        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.view.backgroundColor = UIColor.white
                
        let mapWidth:CGFloat = view.frame.size.width
        let mapHeight:CGFloat = view.frame.size.height
        
        mapView.frame = CGRect(x: 0, y: 0, width: mapWidth, height: mapHeight)
        
        mapView.mapType = MKMapType.standard
        mapView.isZoomEnabled = true
        mapView.isScrollEnabled = true
        
        // Or, if needed, we can position map in the center of the view
        mapView.center = view.center
        
        view.addSubview(mapView)
        
        fetchData()
    }
    
    func fetchData() {
        let db = Firestore.firestore()
        
        db.collection("flying_sites").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    print("\(document.documentID) => \(document.data())")
                }
                guard let querySnapshot = querySnapshot else {
                    print("Error fetching snapshot results: \(err!)")
                    return
                }
                let models = querySnapshot.documents.map { (document) -> DBFlyingSpot in
                    if let model = DBFlyingSpot(dictionary: document.data()) {
                        return model
                    } else {
                        // Don't use fatalError here in a real app.
                        fatalError("Unable to initialize type \(DBFlyingSpot.self) with dictionary \(document.data())")
                    }
                }
                self.flying_spots = models
                DispatchQueue.main.async{
                    self.renderMapPin()
                }
            }
        }
    }
    
    func renderMapPin() {
        for item in self.flying_spots {
            if item.latitude != nil && item.longtitude != nil {
                let annotation = MKPointAnnotation()
                annotation.coordinate = CLLocationCoordinate2DMake(item.latitude ?? 0, item.longtitude ?? 0)
                annotation.title = item.name
                annotation.subtitle = item.site_info
                self.mapView.addAnnotation(annotation)
            }
        }
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard annotation is MKPointAnnotation else { return nil }

        let identifier = "Annotation"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)

        if annotationView == nil {
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            annotationView!.canShowCallout = true
        } else {
            annotationView!.annotation = annotation
        }

        return annotationView
    }
}
