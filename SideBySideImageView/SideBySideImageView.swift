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
    
    private var initialDisplaySize: CGSize = .zero
    
    /// if this property is false, the view calculates the minimum height of a visible area automatically when the handle is moved for shrinking images.
    /// if the property is true, `minimumHeight` become available with this purpose. Default value is false.
    var enableMinimumHeight: Bool = false
    
    /// This is only used when `enableMinimumHeight` is true.
    var minimumHeight: CGFloat = 0.0
    
    /// The image which is assigned to the left side of the view.
    var leftImage: UIImage? {
        return leftImageView.image
    }
    
    /// The image which is assigned to the right side of the view.
    var rightImage: UIImage? {
        return rightImageView.image
    }
    
    /// This property returns the size which has been passed to `setImage(left:right:displaySize:resetPosition)` as parameter named `displaySize`.
    var originImageSize: CGSize {
        return initialDisplaySize
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initControls()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initControls()
    }
    
    func setImage(left: UIImage, right: UIImage, displaySize: CGSize, resetPosition: Bool) -> Bool {
        if left.size.equalTo(right.size) == false {
            return false
        }
        
        layoutIfNeeded()
        
        let isFirstTime = leftImageView.image == nil
        
        initialDisplaySize = displaySize
        
        leftImageView.image = left
        rightImageView.image = right

        if resetPosition {
            handleBottomContraint.constant = 0.0
        }
        
        if isFirstTime || resetPosition {
            let contentOffset = CGPoint(x: (displaySize.width - leftScrollView.frame.width) / 2.0, y: (displaySize.height - leftScrollView.frame.height) / 2.0)
            leftScrollView.zoomScale = 1.0
            leftScrollView.contentOffset = contentOffset
            rightScrollView.zoomScale = 1.0
            rightScrollView.contentOffset = contentOffset

            leftScrollView.contentSize = displaySize
            rightScrollView.contentSize = displaySize
            
            leftImageView.frame = CGRect(origin: .zero, size: displaySize)
            rightImageView.frame = CGRect(origin: .zero, size: displaySize)
        }

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
        
        leftScrollView.bouncesZoom = false
        leftScrollView.maximumZoomScale = 3.0
        leftScrollView.showsVerticalScrollIndicator = false
        leftScrollView.showsHorizontalScrollIndicator = false
        leftScrollView.delegate = self
        
        rightScrollView.bouncesZoom = false
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
            addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-(>=0)-[view]", options: [], metrics: nil, views: ["view": view]))
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
        
        let gesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(recognizer:)))
        handleBaseView.addGestureRecognizer(gesture)
    }

    @objc func handlePanGesture(recognizer: UIPanGestureRecognizer) {
        switch recognizer.state {
        case .changed:
            let delta = recognizer.translation(in: self)
            let minimumHeight = enableMinimumHeight ? self.minimumHeight : leftScrollView.frame.size.width * (initialDisplaySize.height / initialDisplaySize.width)
            let minimumSpace = self.frame.height - minimumHeight - handleBaseView.frame.height
            let bottomSpace = -(handleBottomContraint.constant + delta.y)
            
            var contentSize: CGSize = leftScrollView.contentSize
            var contentOffset: CGPoint = leftScrollView.contentOffset
            var shrinkRatio: CGFloat = 1.0
            
            if bottomSpace <= minimumSpace && bottomSpace >= 0 {
                shrinkRatio = (leftScrollView.bounds.height + delta.y) / leftScrollView.bounds.height
                handleBottomContraint.constant = -(bottomSpace)
                //
                // the following code makes `translation` value be delta.
                //
                recognizer.setTranslation(.zero, in: self)
            } else if bottomSpace > minimumSpace {
                shrinkRatio = minimumHeight / leftScrollView.bounds.size.height
                handleBottomContraint.constant = -minimumSpace
            } else if bottomSpace < 0 {
                shrinkRatio = (self.frame.height - handleBaseView.frame.height) / leftScrollView.bounds.size.height
                handleBottomContraint.constant = 0
            }
            
            let transform = CGAffineTransform(scaleX: shrinkRatio, y: shrinkRatio)
            contentSize = contentSize.applying(transform)
            contentOffset = leftScrollView.bounds.applying(transform).origin
            contentOffset = CGPoint(x: max(contentOffset.x, 0), y: max(contentOffset.y, 0))

            leftScrollView.contentSize = contentSize
            leftScrollView.contentOffset = contentOffset
            rightScrollView.contentSize = contentSize
            rightScrollView.contentOffset = contentOffset
            leftImageView.frame.size = contentSize
            rightImageView.frame.size = contentSize

        default:
            break
        }
    }
    
    private var isLeftDragging: Bool = false
    private var isLeftZooming: Bool = false
    private var isRightDragging: Bool = false
    private var isRightZooming: Bool = false
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
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        setDragState(targetScrollView: scrollView, state: true)
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if decelerate == false {
            setDragState(targetScrollView: scrollView, state: false)
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        setDragState(targetScrollView: scrollView, state: false)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        sync(baseLineScrollView: scrollView)
    }
    
    func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
        setZoomState(targetScrollView: scrollView, state: true)
    }
    
    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        setZoomState(targetScrollView: scrollView, state: false)
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        sync(baseLineScrollView: scrollView)
    }
    
    private func setDragState(targetScrollView: UIScrollView, state: Bool) {
        if targetScrollView == leftScrollView {
            isLeftDragging = state
        } else if targetScrollView == rightScrollView {
            isRightDragging = state
        }
    }
    
    private func setZoomState(targetScrollView: UIScrollView, state: Bool) {
        if targetScrollView == leftScrollView {
            isLeftZooming = state
        } else if targetScrollView == rightScrollView {
            isRightZooming = state
        }
    }
    
    private func sync(baseLineScrollView: UIScrollView) {
        if baseLineScrollView == leftScrollView {
            if isLeftDragging || isLeftZooming {
                rightScrollView.contentOffset = leftScrollView.contentOffset
                rightScrollView.zoomScale = leftScrollView.zoomScale
            }
        } else if baseLineScrollView == rightScrollView {
            if isRightDragging || isRightZooming {
                leftScrollView.contentOffset = rightScrollView.contentOffset
                leftScrollView.zoomScale = rightScrollView.zoomScale
            }
        }
    }
}
