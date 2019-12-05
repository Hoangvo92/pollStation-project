//
//  ViewController.swift
//  WorkPlz
//
//  Created by UbiComp on 10/8/19.
//  Copyright © 2019 UbiComp. All rights reserved.
//

import  UIKit
import  MapKit
import  GooglePlaces
import  GoogleMaps
import  CoreLocation
import  SwiftyJSON
import  Alamofire
//import  MJSnackBar


class ViewController: UIViewController, CLLocationManagerDelegate, GMSMapViewDelegate{
    
    let locationManager = CLLocationManager()
    //starting point
    var location1 = CLLocation()
    //destination
    var location2 = CLLocation()
    //places
   // var likelyPlaces = [GMSPlace]()
    //the current selected place
    //var selectedPlace: GMSPlace?
    var selectedRoute: Dictionary<NSObject, AnyObject>!
    
    var overviewPolyline: Dictionary<NSObject, AnyObject>!
    //for the routing
    var rectangle = GMSPolyline()
    //var snackbar: MJSnackBar!
  
    @IBOutlet weak var mapView: GMSMapView!
    var placesClient = GMSPlacesClient()
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //let location: CLLocation = locations.last!
     
        let camera = GMSCameraPosition.camera(withLatitude: (location1.coordinate.latitude),
                                              longitude: (location1.coordinate.longitude),
                                             zoom: 15.0)
   
       
       // mapView = GMSMapView.map(withFrame: view.bounds, camera: camera)
        mapView.camera = camera
        mapView.animate(to: camera)
       // view = mapView
       
        
    }
    //Handle location manager errors
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        locationManager.stopUpdatingLocation();
        print("Error: \(error)")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.requestWhenInUseAuthorization()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
        placesClient = GMSPlacesClient.shared()
        
        // Do any additional setup after loading the view.
        //self.snackbar = MJSnackBar(onView: self.view)
        
        mapView.settings.myLocationButton = true
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Directions", style: .plain, target: self, action: #selector(GetDirections))
        addMarker();
        self.mapView.settings.myLocationButton = true
        self.mapView.settings.compassButton = true
        self.mapView.settings.zoomGestures = true
        //let path = GMSMutablePath(coordinates: [location1.coordinate, location2.coordinate])
        //not run
      //  mapView.addPath(path)
        print("\(location2.coordinate.latitude), \(location2.coordinate.longitude)")
       //drawPath(startLocation: location1, endLocation: location2)
        getRouteSteps(from: location1.coordinate, to: location2.coordinate )
    }
    @objc func GetDirections(){
        print(location1.coordinate)
        
        let url = URL(string: "https://www.google.com/maps/dir/?api=1&origin=+\(location1.coordinate.latitude),\(location1.coordinate.longitude)&destination=\(location2.coordinate.latitude),\(location2.coordinate.longitude)&travelmode=driving")!
        UIApplication.shared.open(url, options: [:], completionHandler: nil)

       
        
    }
    //not run yet
    func addMarker() {
       
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: location1.coordinate.latitude, longitude: location1.coordinate.longitude);
        marker.title = "Starting point";
        //marker.snippet = "America";
        marker.map = mapView;
        //marker.icon = UIImage(named: "pikachu.jpg")!
        marker.icon = self.imageWithImage(image: UIImage(named: "pikachu.jpg")!, scaledToSize: CGSize(width: 50.0, height: 50.0));
        marker.map = mapView;
    }
 
    //adjust size of icon
    func imageWithImage(image:UIImage, scaledToSize newSize:CGSize) -> UIImage{
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
        image.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
        let newImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return newImage
    }
    
    //get the center of mapview
    func getCenterLocation(for mapView: GMSMapView) -> CLLocation {
        let latitude = mapView.camera.target.latitude
        let longitude = mapView.camera.target.longitude
        
        return CLLocation(latitude: latitude, longitude: longitude)
        
    }
    func drawPath(startLocation: CLLocation, endLocation: CLLocation)
    {
        let origin = "\(startLocation.coordinate.latitude),\(startLocation.coordinate.longitude)"
        let destination = "\(endLocation.coordinate.latitude),\(endLocation.coordinate.longitude)"
        
        
        let url = "https://maps.googleapis.com/maps/api/directions/json?origin=\(origin)&destination=\(destination)&mode=driving&key=AIzaSyCa0Q2PqZ5bJJk-RkB3Tx_YOrY1oqZANSI"
        
        Alamofire.request(url).responseJSON { response in
            
            print(response.request as Any)  // original URL request
            print(response.response as Any) // HTTP URL response
            print(response.data as Any)     // server data
            print(response.result as Any)   // result of response serialization
            
            let json = try! JSON(data: response.data!)
            let routes = json["routes"].arrayValue
            
            // print route using Polyline
            for route in routes
            {
                let routeOverviewPolyline = route["overview_polyline"].dictionary
                let points = routeOverviewPolyline?["points"]?.stringValue
                let path = GMSPath.init(fromEncodedPath: points!)
                let polyline = GMSPolyline.init(path: path)
                polyline.strokeWidth = 2
                polyline.strokeColor = UIColor.red
                polyline.map = self.mapView
            }
            
        }
    }
    
    
   
    func getRouteSteps(from source: CLLocationCoordinate2D, to destination: CLLocationCoordinate2D) {
        
        let session = URLSession.shared
        
        let url = URL(string: "https://maps.googleapis.com/maps/api/directions/json?origin=\(source.latitude),\(source.longitude)&destination=\(destination.latitude),\(destination.longitude)&sensor=false&mode=driving&key=AIzaSyCa0Q2PqZ5bJJk-RkB3Tx_YOrY1oqZANSI")!
        
        let task = session.dataTask(with: url, completionHandler: {
            (data, response, error) in
            
            guard error == nil else {
                print(error!.localizedDescription)
                return
            }
            
            guard let jsonResult = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? [String: Any] else {
                
                print("error in JSONSerialization")
                return
                
            }
            
            
            
            guard let routes = jsonResult["routes"] as? [Any] else {
                print("Json error")
                return
            }
            
            guard let route = routes[0] as? [String: Any] else {
               print("routes 0 error")
               return
            }
            
            guard let legs = route["legs"] as? [Any] else {
                return
            }
            
            guard let leg = legs[0] as? [String: Any] else {
                return
            }
            
            guard let steps = leg["steps"] as? [Any] else {
                return
            }
            for item in steps {
                
                guard let step = item as? [String: Any] else {
                    return
                }
                
                guard let polyline = step["polyline"] as? [String: Any] else {
                    return
                }
                
                guard let polyLineString = polyline["points"] as? String else {
                    return
                }
                
                //Call this method to draw path on map
                DispatchQueue.main.async {
                    self.routing(from: polyLineString)
                }
                
            }
        })
        task.resume()
    }
    func routing(from polyStr: String){
        let path = GMSPath(fromEncodedPath: polyStr)
        let polyline = GMSPolyline(path: path)
        polyline.strokeWidth = 3.0
        polyline.map = mapView // Google MapView
        
        
        let cameraUpdate = GMSCameraUpdate.fit(GMSCoordinateBounds(coordinate: location1.coordinate, coordinate: location2.coordinate))
        mapView.moveCamera(cameraUpdate)
        let currentZoom = mapView.camera.zoom
       mapView.animate(toZoom: currentZoom - 1.4)
    }
   
    
    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
        mapView.isMyLocationEnabled = true
    }
    
    func mapView(_ mapView: GMSMapView, willMove gesture: Bool) {
        mapView.isMyLocationEnabled = true
        
        if (gesture) {
            mapView.selectedMarker = nil
        }
    }
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        mapView.isMyLocationEnabled = true
        return false
    }
    
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        print("COORDINATE \(coordinate)") // when you tapped coordinate
    }
    
    func didTapMyLocationButton(for mapView: GMSMapView) -> Bool {
        mapView.isMyLocationEnabled = true
        mapView.selectedMarker = nil
        return false
    }

    
}
//
//extension GMSMutablePath {
  //  convenience init(coordinates: [CLLocationCoordinate2D]) {
    //    self.init()
      //  for coordinate in coordinates {
        //    add(coordinate)
       // }
    //}
//}
//extension GMSMapView {
  //  func addPath(_ path: GMSPath, strokeColor: UIColor? = nil, strokeWidth: CGFloat? = nil, geodesic: Bool? = nil, spans: [GMSStyleSpan]? = nil) {
    //    let line = GMSPolyline(path: path)
      //  line.strokeColor = strokeColor ?? line.strokeColor
        //line.strokeWidth = strokeWidth ?? line.strokeWidth
        //line.geodesic = geodesic ?? line.geodesic
        //line.spans = spans ?? line.spans
        //line.map = self
   // }
//}

