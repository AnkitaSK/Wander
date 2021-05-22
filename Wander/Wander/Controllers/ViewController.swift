//
//  ViewController.swift
//  Wander
//
//  Created by Ankita on 21.05.21.
//

import UIKit

class ViewController: UITableViewController {

    let viewModel = WNPhotoViewModel()
    override func viewDidLoad() {
        super.viewDidLoad()
        AppConfigHandler.provider.handleApiConfig()
        // Do any additional setup after loading the view.
        
        viewModel.getPhoto(lat: 49.902550, long: 10.884520, accuracy: 16, radius: 0.2)
    }


    
}

