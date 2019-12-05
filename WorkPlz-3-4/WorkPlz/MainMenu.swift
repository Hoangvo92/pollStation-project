//
//  MainMenu.swift
//  WorkPlz
//
//  Created by UbiComp on 11/21/19.
//  Copyright © 2019 UbiComp. All rights reserved.
//

import UIKit

class MainMenu: UIViewController {

    @IBAction func BallotButton(_ sender: UIButton) {
        
    }
    @IBAction func VoteLocations(_ sender: Any) {
        self.performSegue(withIdentifier: "Location", sender: self)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
       
        
        if(segue.identifier == "Location"){
            let target = segue.destination as? AddressViewController
        }
        
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    @IBAction func LearnAboutCandidates(_ sender: Any) {
   
    
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
