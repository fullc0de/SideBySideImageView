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
    
//    let leftImage = #imageLiteral(resourceName: "before_image_port")
//    let rightImage = #imageLiteral(resourceName: "after_image_port")

    let leftImage = #imageLiteral(resourceName: "before_image_land")
    let rightImage = #imageLiteral(resourceName: "after_image_land")

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        let size = CGSize(width: 411.0 * (leftImage.size.width / leftImage.size.height), height: 411.0)
        _ = sideBySideView.setImage(left: leftImage, right: rightImage, displaySize: size, resetPosition: true)
        
//        sideBySideView.enableMinimumHeight = true
//        sideBySideView.minimumHeight = 300.0
    }


    @IBAction func resetPosTouched(_ sender: Any) {
        _ = sideBySideView.setImage(left: sideBySideView.leftImage!,
                                    right: sideBySideView.rightImage!,
                                    displaySize: sideBySideView.originImageSize, resetPosition: true)
    }
    
    @IBAction func keepPosTouched(_ sender: Any) {
        _ = sideBySideView.setImage(left: sideBySideView.rightImage!,
                                    right: sideBySideView.leftImage!,
                                    displaySize: sideBySideView.originImageSize, resetPosition: false)
    }
    
    @IBAction func toggleSpaceTouched(_ sender: Any) {
        sideBySideView.separatorSpace = sideBySideView.separatorSpace == 0.0 ? 3.0 : 0.0
    }
    
    
}

