//
//  SideBySideImageView.swift
//  SideBySideImageView
//
//  Created by Heath Hwang on 29/08/2019.
//  Copyright © 2019 HeathHwang. All rights reserved.
//

import UIKit

class SideBySideImageView: UIView {

    private var leftImageView = UIImageView()
    private var rightImageView = UIImageView()
    private var leftScrollView = UIScrollView()
    private var rightScrollView = UIScrollView()
    private var stackView: UIStackView!
    
    private var handleBaseView: UIView!
    private var handleView = UIView()
    
    private var handleBottomContraint: NSLayoutConstraint!
    
    private var displaySize: CGSize = .zero
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initControls()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initControls()
    }
    
    func setImage(left: UIImage, right: UIImage, displaySize: CGSize) -> Bool {
        if left.size.equalTo(right.size) == false {
            return false
        }
        
        layoutIfNeeded()
        
        let scrollViewSize = leftScrollView.frame.size
        
        self.displaySize = displaySize
        
        leftImageView.image = left
        leftImageView.frame = CGRect(origin: .zero, size: displaySize)
        rightImageView.image = right
        rightImageView.frame = CGRect(origin: .zero, size: displaySize)
        
        let center = CGPoint(x: (displaySize.width - scrollViewSize.width) / 2.0, y: (displaySize.height - scrollViewSize.height) / 2.0)
        leftScrollView.contentSize = displaySize
        leftScrollView.contentOffset = center
        rightScrollView.contentSize = displaySize
        rightScrollView.contentOffset = center

        
        return true
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
    }
    
    private func initControls() {
        
        leftImageView.contentMode = .scaleAspectFit
        rightImageView.contentMode = .scaleAspectFit
        
        leftScrollView.addSubview(leftImageView)
        rightScrollView.addSubview(rightImageView)
        
        leftScrollView.bounces = false
        leftScrollView.maximumZoomScale = 3.0
        leftScrollView.showsVerticalScrollIndicator = false
        leftScrollView.showsHorizontalScrollIndicator = false
        leftScrollView.delegate = self
        
        rightScrollView.bounces = false
        rightScrollView.maximumZoomScale = 3.0
        rightScrollView.showsVerticalScrollIndicator = false
        rightScrollView.showsHorizontalScrollIndicator = false
        rightScrollView.delegate = self
        
        stackView = {
            let stackView = UIStackView(arrangedSubviews: [leftScrollView, rightScrollView])
            stackView.translatesAutoresizingMaskIntoConstraints = false
            stackView.axis = .horizontal
            stackView.alignment = .fill
            stackView.distribution = .fillEqually
            stackView.spacing = 3.0
            addSubview(stackView)
        
            addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[stack]-0-|", options: [], metrics: nil, views: ["stack": stackView]))
            addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[stack]", options: [], metrics: nil, views: ["stack": stackView]))
            
            return stackView
        }()
        
        handleBaseView = {
            let view = UIView()
            view.translatesAutoresizingMaskIntoConstraints = false
            addSubview(view)
            addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[view]-0-|", options: [], metrics: nil, views: ["view": view]))
            addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[stack]-0-[view(30)]-(>=0)-|", options: [], metrics: nil, views: ["view": view, "stack": stackView!]))

            handleBottomContraint = NSLayoutConstraint(item: view, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1.0, constant: 0.0)
            addConstraint(handleBottomContraint)
            
            handleView.translatesAutoresizingMaskIntoConstraints = false
            handleView.backgroundColor = .black
            view.addSubview(handleView)
            handleView.layer.cornerRadius = 1.0
            view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[super]-(<=1)-[handle(30)]", options: .alignAllCenterY,
                                                               metrics: nil, views: ["super": view, "handle": handleView]))
            view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[super]-(<=1)-[handle(2)]", options: .alignAllCenterX,
                                                               metrics: nil, views: ["super": view, "handle": handleView]))
            return view
        }()
    }

}

extension SideBySideImageView: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        if scrollView == leftScrollView {
            return leftImageView
        } else if scrollView == rightScrollView {
            return rightImageView
        }
        return nil
    }
}
