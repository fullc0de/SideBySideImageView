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
    
    let leftImage = #imageLiteral(resourceName: "before_image")
    let rightImage = #imageLiteral(resourceName: "after_image")

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        let size = CGSize(width: 411.0 * (leftImage.size.width / leftImage.size.height), height: 411.0)
        _ = sideBySideView.setImage(left: leftImage, right: rightImage, displaySize: size, resetPosition: true)
        
        //sideBySideView.enableMinimumHeight = true
        //sideBySideView.minimumHeight = 200.0
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
    
}

