//
//  AddressViewController.swift
//  WorkPlz
//
//  Created by UbiComp on 10/14/19.
//  Copyright © 2019 UbiComp. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit
import GooglePlaces
import Firebase
import SwiftyJSON
import GoogleMaps
//creat a truct to save database
struct PollList:Codable{
    var Address:String
    var City: String
    
    
    var Name : String
    var Room : String
    var Zip: String
    var Logitude: Double
    var Latitude: Double
    
    init() {
        Address = ""
        City = ""
        Name = ""
        Logitude = 0.0000
        Latitude = 0.00000
        Zip = ""
        Room = ""
    }
    
}
class Location: Comparable{
    
    
    
    
    var address   : String
    var Name : String
    var latitude  : Double
    var longitude : Double
    var State :  String
    var location  :CLLocation
    var MeterFromLocation: CLLocationDistance
    
    init(){
        self.address = ""
        self.latitude = 0.0
        self.longitude = 0.0
        self.State = "Texas"
        self.location = CLLocation(latitude: self.latitude, longitude: self.longitude)
        self.MeterFromLocation = 0.0
        Name = ""
        
    }
    
    func getLat( latitude: Double) {
        self.latitude = latitude;
    }
    func getLong ( longitude: Double) {
        self.longitude = longitude;
    }
    func getaddress (address: String){
        self.address = address;
    }
    
    func distance(to location: CLLocation) -> CLLocationDistance {
        return location.distance(from: self.location)/1.609
        //return distance in miles
    }
    static func < (lhs: Location , rhs: Location) -> Bool{
        return lhs.MeterFromLocation < rhs.MeterFromLocation
        
    }
}
extension Location:Equatable{
    static func == (lhs: Location, rhs: Location) -> Bool {
        return
            lhs.address == rhs.address &&
                lhs.location == rhs.location &&
                lhs.latitude == rhs.latitude &&
                lhs.longitude == rhs.longitude &&
                lhs.Name == rhs.Name
        
        
    }
}
extension Location: Hashable{
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(address)
        hasher.combine(location)
        hasher.combine(Name)
        hasher.combine(longitude)
        hasher.combine(latitude)
        hasher.combine(MeterFromLocation)
    }
    
}
extension Array where Element: Hashable {
    func removingDuplicates() -> [Element] {
        var addedDict = [Element: Bool]()
        
        return filter {
            addedDict.updateValue(true, forKey: $0) == nil
        }
    }
    
    mutating func removeDuplicates() {
        self = self.removingDuplicates()
    }
}
class AddressViewController: UIViewController,CLLocationManagerDelegate,GMSMapViewDelegate {
    lazy var geocode = CLGeocoder()
    
    var resultsViewController: GMSAutocompleteResultsViewController?
    var searchController: UISearchController?
    var resultView: UITextView?
    var Polls = [PollList]()
    var Locations = [Location]()
    var rootDatabse:DatabaseReference!
    //a list of search result
    var locationManager = CLLocationManager()
    var CurrentLocation = CLLocation()
    var SearchResult = [CLGeocoder]()
    var closestLocation = Location()
    var SortedLocation = [Location]()
    //to clear all markers
    
    
    @IBOutlet weak var MapView: GMSMapView!
    
   
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]){
        locationManager.stopUpdatingLocation()
        let location = locations.last! as CLLocation
        CurrentLocation = location
        let camera = GMSCameraPosition.camera(withLatitude: CurrentLocation.coordinate.latitude, longitude: CurrentLocation.coordinate.longitude, zoom: 15)
        MapView.camera = camera
        print("Current location is  \(CurrentLocation)")
        rootDatabse = Database.database().reference()
        
        
        
        retrivePollls()
        
    
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to find user's location: \(error.localizedDescription)")
    }
    func getDistance(){
        
        for i in 0 ..< Polls.count{
             let geolocation = Location()
              geolocation.latitude = Polls[i].Latitude
              geolocation.longitude = Polls[i].Latitude
              geolocation.address = Polls[i].Address
              geolocation.Name = Polls[i].Name
              geolocation.location = CLLocation(latitude: Polls[i].Latitude, longitude: Polls[i].Logitude)
              geolocation.MeterFromLocation =  geolocation.distance(to: self.CurrentLocation)
            
            Locations.append(geolocation)
            
        }
        
        
        
    }
    func getClosest() -> Location{
         getDistance()
         SortedLocation = Locations.sorted()
        
        //print(Locations.description)
        closestLocation = SortedLocation.first!
        Locations.removeAll()
        ///Polls.removeAll()
        return closestLocation
        
        
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if(!(SortedLocation.isEmpty)){
//            let camera = GMSCameraPosition.camera(withLatitude: CurrentLocation.coordinate.latitude, longitude: CurrentLocation.coordinate.longitude, zoom: 15)
//
//            let cameraUpdate = GMSCameraUpdate.fit(GMSCoordinateBounds(coordinate: CurrentLocation.coordinate, coordinate: closestLocation.location.coordinate), withPadding: 50.0)
//            MapView.moveCamera(cameraUpdate)
//            MapView.animate(with: cameraUpdate)
//            MapView.camera = camera
//            print(closestLocation)
            
     
            
        }
        
        
        
    }
    
    @IBAction func GetCurrentLocation(_ sender: Any) {
    
        if CLLocationManager.locationServicesEnabled() == true {
            if CLLocationManager.authorizationStatus() == .restricted || CLLocationManager.authorizationStatus() == .denied || CLLocationManager.authorizationStatus() == .notDetermined{
                locationManager.requestWhenInUseAuthorization()
            }
            
        } else {
            print("Please turn on location services or GPS!")
        }
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.delegate = self
        locationManager.requestLocation()
        locationManager.startUpdatingLocation()
       
    }
    
    
    
    func retrivePollls(){
        
        
        rootDatabse.ref.observe(.value, with: { snapshot in
            
            for child in snapshot.children {
                
                let snap = child as! DataSnapshot
                let polldata = snap.value as! [String: Any]
                var poll = PollList()
                poll.Address = polldata["Address"] as! String
                poll.City = polldata["City"] as! String
                poll.Name = polldata["Name"] as! String
                poll.Room = polldata["Room"] as! String
                poll.Zip = polldata["Zip"] as! String
                poll.Latitude = polldata["Latitude"] as! Double
                poll.Logitude = polldata["Longitude"] as! Double
                self.Polls.append(poll)
            }
            
          
            let ClosestPoll = self.getClosest()
            self.addNavigationButton()
            print(" closest poll is \(ClosestPoll.location.coordinate) ")
            self.getRouteSteps(from: self.CurrentLocation.coordinate, to: ClosestPoll)
            let tabView = self.tabBarController?.viewControllers![3] as! PollingStationList
            tabView.sortedLocation = self.SortedLocation
            tabView.currentLocation = self.CurrentLocation
            
            
        })
        
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        Directions.isEnabled = false
        resultsViewController = GMSAutocompleteResultsViewController()
        resultsViewController?.delegate = self
        MapView.delegate = self
        searchController = UISearchController(searchResultsController: resultsViewController)
        searchController?.searchBar.placeholder = "Search Addresss "
        searchController?.searchResultsUpdater = resultsViewController
        
        // Put the search bar in the navigation bar.
        searchController?.searchBar.sizeToFit()
        searchController?.delegate = self
        navigationItem.titleView = searchController?.searchBar
        
        // When UISearchController presents the results view, present it in
        // this view controller, not one further up the chain.
        definesPresentationContext = true
        
        // Prevent the navigation bar from being hidden when searching.
        searchController?.hidesNavigationBarDuringPresentation = false
        // Do any additional setup after loading the view.
        if CLLocationManager.locationServicesEnabled() == true {
            if CLLocationManager.authorizationStatus() == .restricted || CLLocationManager.authorizationStatus() == .denied || CLLocationManager.authorizationStatus() == .notDetermined{
                locationManager.requestWhenInUseAuthorization()
            }
            
        } else {
            print("Please turn on location services or GPS!")
        }
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.delegate = self
        locationManager.requestLocation()
        locationManager.startUpdatingLocation()
        
       
        
       
      
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if(!(SortedLocation.isEmpty)){
            getRouteSteps(from: CurrentLocation.coordinate, to: closestLocation)
            let latitude = (CurrentLocation.coordinate.latitude + closestLocation.location.coordinate.latitude) / 2
            let longitude = (CurrentLocation.coordinate.longitude+closestLocation.location.coordinate.longitude)/2
            let camera = GMSCameraPosition.camera(withLatitude: latitude, longitude:longitude, zoom: 80)

            let cameraUpdate = GMSCameraUpdate.fit(GMSCoordinateBounds(coordinate: CurrentLocation.coordinate, coordinate: closestLocation.location.coordinate), withPadding: 50.0)
//            MapView.moveCamera(cameraUpdate)
//            MapView.animate(with: cameraUpdate)
            MapView.animate(to: camera)
           // getRouteSteps(from: CurrentLocation.coordinate, to: closestLocation)

            
        }
    
    }
//    override func viewDidAppear(_ animated: Bool) {
//        super.viewDidAppear(animated)
//
////        Directions.isEnabled = false
//
//
//    }
    
       //not run yet
    func addMarkers( from source: CLLocationCoordinate2D, to destination: Location) {
        MapView.clear()// to clear extra markers on the maps
        let location1 = CLLocation(latitude: source.latitude, longitude: source.longitude)
        
        let url = URL(string: "https://www.google.com/maps/dir/?api=1&origin=+\(source.latitude),\(source.longitude)&destination=\(destination.location.coordinate.latitude),\(destination.location.coordinate.longitude)&travelmode=driving")!
        
        
        //add destination marker
           let marker2 = GMSMarker()
                 marker2.position = CLLocationCoordinate2D(latitude: destination.location.coordinate.latitude, longitude: destination.location.coordinate.longitude);
       
            marker2.title = destination.Name
           marker2.map = MapView;
         marker2.userData = url
           marker2.icon = self.imageWithImage(image: UIImage(named: "destination.png")!, scaledToSize: CGSize(width: 50.0, height: 50.0));
        
           marker2.map = MapView;
       }
    
       //adjust size of icon
       func imageWithImage(image:UIImage, scaledToSize newSize:CGSize) -> UIImage{
           UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
           image.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
           let newImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
           UIGraphicsEndImageContext()
           return newImage
       }
    func getRouteSteps(from source: CLLocationCoordinate2D, to destination: Location) {
        addMarkers( from: source, to: destination);//
        let session = URLSession.shared
        
        let url = URL(string: "https://maps.googleapis.com/maps/api/directions/json?origin=\(source.latitude),\(source.longitude)&destination=\(destination.location.coordinate.latitude),\(destination.location.coordinate.longitude)&sensor=false&mode=driving&key=AIzaSyCa0Q2PqZ5bJJk-RkB3Tx_YOrY1oqZANSI")!
        
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
//
//              let closestPoll = self.getClosest()
//            let cameraUpdate = GMSCameraUpdate.fit(GMSCoordinateBounds(coordinate: self.CurrentLocation.coordinate, coordinate: closestPoll.location.coordinate))
//
//            self.self.MapView.moveCamera(cameraUpdate)
        })
        task.resume()
    }
    func routing(from polyStr: String){
        let path = GMSPath(fromEncodedPath: polyStr)
        let polyline = GMSPolyline(path: path)
        polyline.strokeWidth = 3.0
        polyline.map = MapView // Google MapView
        //let closestPoll = getClosest()
        
//        var bounds = GMSCoordinateBounds()
//        let marker1 = GMSMarker()
//        marker1.position = CLLocationCoordinate2D(latitude: CurrentLocation.coordinate.latitude,longitude: CurrentLocation.coordinate.longitude)
//        marker1.map = self.MapView
//        let marker2 = GMSMarker()
//        marker2.position = CLLocationCoordinate2D(latitude: closestPoll.location.coordinate.latitude,longitude: closestPoll.location.coordinate.longitude)
//        marker2.map = self.MapView
//        bounds.includingCoordinate(marker1.position)
//        bounds.includingCoordinate(marker2.position)
//        var gms = GMSPath(fromEncodedPath: polyStr)
//        print(CurrentLocation.coordinate)
//        print(closestPoll.location.coordinate)
//        MapView.animate(with: .fit(bounds, withPadding: 30.0))
//        MapView.setMinZoom(1, maxZoom: 15)
        //prevent to over zoom on fit and animate if bounds be too small
        
//        let update = GMSCameraUpdate.fit(bounds, withPadding: 50)
//        MapView.animate(with: update)
//
//        MapView.setMinZoom(1, maxZoom: 20) // allow the user zoom in more than level 15 again
//        let update = GMSCameraUpdate.fit(bounds, withPadding: 60)
//        MapView.animate(with: update)
//        MapView.animate(with: update)
//        let cameraUpdate = GMSCameraUpdate.fit(GMSCoordinateBounds(coordinate: CurrentLocation.coordinate, coordinate: closestPoll.location.coordinate))
//        MapView.moveCamera(cameraUpdate)
//        let currentZoom = MapView.camera.zoom
//        MapView.animate(toZoom: currentZoom)
        let closestPoll = self.getClosest()
       let cameraUpdate = GMSCameraUpdate.fit(GMSCoordinateBounds(coordinate: CurrentLocation.coordinate, coordinate: closestPoll.location.coordinate))
        
        MapView.animate(with: cameraUpdate)
        print("Complete")
    }
    func degToRads(deg: Double)-> Double
    {
        return deg * .pi / 180.0
    }
    func RadsToDeg(rads: Double) -> Double{
        return rads * 180.0 / .pi
        
    }
    func getBearingBetweenTwoPoints(point1: CLLocationCoordinate2D, point2: CLLocationCoordinate2D ) ->Double{
        let lat1 = degToRads(deg: point1.latitude)
        let long1 = degToRads(deg: point1.longitude)
        let lat2 = degToRads(deg: point2.latitude)
        let long2 = degToRads(deg: point2.longitude)
        
        let dlong = long2-long1
        
        let y = sin(dlong) * cos(lat2)
        let x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dlong)
        let radiansBearing = atan2(y,x)
        return RadsToDeg(rads: radiansBearing)
        
        
        
        
        
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
    
     func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool{
        mapView.isMyLocationEnabled = true
        mapView.delegate = self
        
        let actionSheetAlert = UIAlertController(title: "Google Maps", message: "Would you like to open Google Maps? ", preferredStyle: .actionSheet)
        actionSheetAlert.addAction(UIAlertAction(title: "Okay", style: .default, handler: { _ in
            
            UIApplication.shared.open(marker.userData as! URL, options: [:], completionHandler: nil)
        }))
        actionSheetAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { _ in
            self.dismiss(animated: true, completion: nil)
        }))
        self.present(actionSheetAlert, animated: true, completion: nil)
        return mapView.selectedMarker == marker
    }
    
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        
        
        
        print("COORDINATE \(coordinate)") // when you tapped coordinate
    }
    
    func didTapMyLocationButton(for mapView: GMSMapView) -> Bool {
        mapView.isMyLocationEnabled = true
        mapView.selectedMarker = nil
        return false
    }

    func addNavigationButton(){
//        Directions.isEnabled = true
//        Directions.target = self
//        Directions.action = #selector(GetDirections)
    }
   override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)
    
   
    
    }
  
    
//    @IBOutlet weak var Directions: UIBarButtonItem!
    
    
    @objc func GetDirections(){       
        let url = URL(string: "https://www.google.com/maps/dir/?api=1&origin=+\(CurrentLocation.coordinate.latitude),\(CurrentLocation.coordinate.longitude)&destination=\(closestLocation.location.coordinate.latitude),\(closestLocation.location.coordinate.longitude)&travelmode=driving")!
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
        
        
        
    }

    
    
   
  
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
extension AddressViewController: GMSAutocompleteResultsViewControllerDelegate {
    func resultsController(_ resultsController: GMSAutocompleteResultsViewController,
                           didAutocompleteWith place: GMSPlace) {
        searchController?.isActive = false
        // Do something with the selected place.
        
        CurrentLocation =  CLLocation(latitude: place.coordinate.latitude,longitude: place.coordinate.longitude)
        let camera = GMSCameraPosition.camera(withLatitude: CurrentLocation.coordinate.latitude, longitude: CurrentLocation.coordinate.longitude, zoom: 15)
        MapView.camera = camera
        rootDatabse = Database.database().reference()
        retrivePollls()
       
    }
    
    func resultsController(_ resultsController: GMSAutocompleteResultsViewController,
                           didFailAutocompleteWithError error: Error){
        // TODO: handle the error.
        print("Error: ", error.localizedDescription)
    }
    
    // Turn the network activity indicator on and off again.
    func didRequestAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func didUpdateAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        dismiss(animated: true, completion: nil)
    }

}
extension AddressViewController:UISearchControllerDelegate{
    func didDismissSearchController(_ searchController: UISearchController) {
        if(!(SortedLocation.isEmpty)){
            let tabView = self.tabBarController?.viewControllers![3] as! PollingStationList
            tabView.sortedLocation = SortedLocation
            tabView.currentLocation = CurrentLocation
        
        }
    
    }
}
