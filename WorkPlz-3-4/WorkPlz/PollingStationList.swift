//
//  PollingStationList.swift
//  WorkPlz
//
//  Created by UbiComp on 10/14/19.
//  Copyright © 2019 UbiComp. All rights reserved.
//

import UIKit

import GoogleMaps
import CoreLocation
import Alamofire
import SwiftyJSON
import Firebase
import GooglePlaces



class PollingStationList: UITableViewController {
    
    var currentLocation:  CLLocation?
    //to save destination
    var destination:Location?
    //to perform table
  
    var resultView: UITextView?
    var Closest10 : [Location]?//get the first 10 values of <temp>
    
    var closest : CLLocation?
    var sortedLocation : [Location]?//get the first 10 values of <temp>
    var selectedLocation : Location?
    
    //Use made-up function to create a custom list-erase later after having database
    //get data
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //tableView.reloadData()
        //sortedLocation?.removeDuplicates()
        Closest10 = Array(sortedLocation![0..<10])
         tableView.reloadData()
        tableView.backgroundView = UIImageView(image: UIImage(named: "Component6.png"))
        // Uncomment the following line to preserve selection between presentations
       
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        //First, get string data from firebase
      
     
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
    
        return Closest10!.count
    }
    
    
    
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "PCELL",for: indexPath)
        
        
        let poll = cell.viewWithTag(1) as! UILabel
        let distance = cell.viewWithTag(2) as! UILabel
        //replace with search result later
        
       
        poll.text = (sortedLocation?[indexPath.row].Name)!
        distance.text = String(format:"%.4f miles ",(sortedLocation![indexPath.row].MeterFromLocation)/1000)
      
        
        return cell;
    }
    //just some makeup function, delete later after passing data
   
    
   
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //replace with a true search result later
        selectedLocation = Closest10?[indexPath.row]
        destination = selectedLocation
        let firstview =  (tabBarController?.viewControllers![0] as! UINavigationController).viewControllers[0] as! AddressViewController
        firstview.closestLocation = destination!
        firstview.CurrentLocation = currentLocation!
        firstview.SortedLocation = sortedLocation!
        
//        firstview.getRouteSteps(from: firstview.CurrentLocation.coordinate, to: firstview.closestLocation)
        self.tabBarController!.selectedIndex = 0

    }
  
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if(segue.identifier=="toMap"){
//            if let  nextViewController = segue.destination as firstview
//            {
//
//            }
//            let firstview =  (tabBarController?.viewControllers![0] as! UINavigationController).viewControllers[0] as! AddressViewController
//            firstview.closestLocation = destination!
//            firstview.CurrentLocation = currentLocation!
//            firstview.SortedLocation = sortedLocation!
//            firstview.getRouteSteps(from: firstview.CurrentLocation.coordinate, to: firstview.closestLocation)
//
//        }
//    }
    
    
    
    /*
     override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
     let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
     
     // Configure the cell...
     
     return cell
     }
     */
    
    /*
     // Override to support conditional editing of the table view.
     override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the specified item to be editable.
     return true
     }
     */
    
    /*
     // Override to support editing the table view.
     override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
     if editingStyle == .delete {
     // Delete the row from the data source
     tableView.deleteRows(at: [indexPath], with: .fade)
     } else if editingStyle == .insert {
     // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
     }
     }
     */
    
    /*
     // Override to support rearranging the table view.
     override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
     
     }
     */
    
    /*
     // Override to support conditional rearranging of the table view.
     override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the item to be re-orderable.
     return true
     }
     */
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}

