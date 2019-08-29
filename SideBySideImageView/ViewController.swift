//
//  ViewController.swift
//  SideBySideImageView
//
//  Created by Heath Hwang on 29/08/2019.
//  Copyright © 2019 HeathHwang. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var sideBySideView: SideBySideImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        let leftImage = #imageLiteral(resourceName: "before_image")
        let rightImage = #imageLiteral(resourceName: "after_image")
        
        let size = CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width * (leftImage.size.height / leftImage.size.width))
        _ = sideBySideView.setImage(left: leftImage, right: rightImage, displaySize: size)
        
    }


    @IBAction func buttonTouched(_ sender: Any) {
        print("fwefw")
    }
}

