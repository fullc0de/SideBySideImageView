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
    
    var separatorSpace: CGFloat = 3.0 {
        didSet {
            if stackView != nil {
                stackView.spacing = separatorSpace
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initControls()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initControls()
    }
    
    /// This method updates two images.
    /// - Parameters:
    ///     - left: an image on left side.
    ///     - right: an image on right side.
    ///     - displaySize: an initial size of two images.
    ///     - resetPosition: a flag whether previous position and scaling will be kept or not. if `displaySize` is different from the size previously used, this parameter will be forcely changed to `true`.
    /// - Returns:
    ///     - if it returns `false`, it means that invalid parameters have been passed.
    func setImage(left: UIImage, right: UIImage, displaySize: CGSize, resetPosition: Bool) -> Bool {
        if left.size.equalTo(right.size) == false {
            return false
        }
        
        layoutIfNeeded()
        
        let isFirstTime = leftImageView.image == nil
        let isDisplaySizeChanged = initialDisplaySize != displaySize
        
        initialDisplaySize = displaySize
        
        leftImageView.image = left
        rightImageView.image = right
        
        if resetPosition || isDisplaySizeChanged {
            handleBottomContraint.constant = 0.0
        }
        
        if isFirstTime || resetPosition || isDisplaySizeChanged {
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
    
    /// This method creates snapshot image which is scaled relavant to original scale factor.
    /// - Parameters:
    ///     - boundSize: a bound used for fitting the output image in it. `.zero` means not to use it.
    ///     - completionHandler: This is called when processing has been finished
    /// - Returns:
    ///   a snapshot image with the separator. if it returns `nil`, that indicates an error occurs during cropping.
    func snapshot(boundSize: CGSize = .zero, completionHandler: @escaping (UIImage?) -> Void) {
        guard let leftImage = leftImageView.image, let rightImage = rightImageView.image else {
            completionHandler(nil)
            return
        }
        
        let scale = leftImageView.image!.size.width / leftImageView.frame.size.width
        let transform = CGAffineTransform(scaleX: scale, y: scale)
        let validRect = leftScrollView.bounds.applying(transform)
        
        let space = separatorSpace
        DispatchQueue.global(qos: .background).async {
            guard let leftCGImage = leftImage.cgImage?.cropping(to: validRect), let rightCGImage = rightImage.cgImage?.cropping(to: validRect) else {
                DispatchQueue.main.async {
                    completionHandler(nil)
                }
                return
            }
            
            let leftCropped = UIImage(cgImage: leftCGImage)
            let rightCropped = UIImage(cgImage: rightCGImage)
            
            var outImageSize = CGSize(width: validRect.width * 2, height: validRect.height)
            var scale: CGFloat = 1.0
            if boundSize != .zero {
                scale = min(boundSize.width / outImageSize.width, boundSize.height / outImageSize.height)
                outImageSize = outImageSize.applying(CGAffineTransform(scaleX: scale, y: scale))
            }
            
            outImageSize.width = floor(outImageSize.width) + space
            outImageSize.height = floor(outImageSize.height)
            
            UIGraphicsBeginImageContextWithOptions(outImageSize, true, 0.0)
            defer { UIGraphicsEndImageContext() }
            
            if let context = UIGraphicsGetCurrentContext() {
                context.setFillColor(UIColor.white.cgColor)
                context.fill(CGRect(origin: .zero, size: outImageSize))
                let leftWidth = floor(validRect.width) * scale
                let rightWidth = floor(validRect.width) * scale
                leftCropped.draw(in: CGRect(x: 0, y: 0, width: Int(leftWidth), height: Int(outImageSize.height)))
                rightCropped.draw(in: CGRect(x: Int(outImageSize.width) - Int(rightWidth), y: 0, width: Int(rightWidth), height: Int(outImageSize.height)))
                
                let output = UIGraphicsGetImageFromCurrentImageContext()
                DispatchQueue.main.async {
                    completionHandler(output)
                }
            } else {
                DispatchQueue.main.async {
                    completionHandler(nil)
                }
            }
        }
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
            
            let currentContentSize = leftScrollView.contentSize
            var newContentSize = leftScrollView.contentSize
            var newContentOffset = leftScrollView.contentOffset
            
            if bottomSpace <= minimumSpace && bottomSpace >= 0 {
                let shrinkScale = (leftScrollView.bounds.height + delta.y) / leftScrollView.bounds.height
                newContentSize = newContentSize.applying(CGAffineTransform(scaleX: shrinkScale, y: shrinkScale))
                handleBottomContraint.constant = -(bottomSpace)
                recognizer.setTranslation(.zero, in: self)
                
            } else if bottomSpace > minimumSpace {
                let minimumWidth = minimumHeight * (initialDisplaySize.width / initialDisplaySize.height)
                let transform = CGAffineTransform(scaleX: leftScrollView.zoomScale, y: leftScrollView.zoomScale)
                newContentSize = CGSize(width: minimumWidth, height: minimumHeight).applying(transform)
                handleBottomContraint.constant = -minimumSpace
                
            } else if bottomSpace < 0 {
                let maximumHeight = self.frame.height - handleBaseView.frame.height
                let maximumWidth = maximumHeight * (initialDisplaySize.width / initialDisplaySize.height)
                let transform = CGAffineTransform(scaleX: leftScrollView.zoomScale, y: leftScrollView.zoomScale)
                newContentSize = CGSize(width: maximumWidth, height: maximumHeight).applying(transform)
                handleBottomContraint.constant = 0
            }
            
            let transform = CGAffineTransform(scaleX: newContentSize.width / currentContentSize.width,
                                              y: newContentSize.height / currentContentSize.height)
            newContentOffset = leftScrollView.bounds.applying(transform).origin
            newContentOffset = CGPoint(x: max(newContentOffset.x, 0), y: max(newContentOffset.y, 0))
            
            leftScrollView.contentSize = newContentSize
            leftScrollView.contentOffset = newContentOffset
            rightScrollView.contentSize = newContentSize
            rightScrollView.contentOffset = newContentOffset
            leftImageView.frame.size = newContentSize
            rightImageView.frame.size = newContentSize
            
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
