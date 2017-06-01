//
//  ActivityIndicator.swift
//  Goet
//
//  Created by Zhe Cui on 5/23/17.
//  Copyright © 2017 Zhe Cui. All rights reserved.
//

import Foundation
import UIKit

open class IndicatorWithContainer: UIActivityIndicatorView {
    open var container: UIView!
    
    public init(indicatorframe: CGRect, center: CGPoint, style: UIActivityIndicatorViewStyle, containerFrame: CGRect, color: UIColor) {
        container = UIView(frame: containerFrame)
        container.backgroundColor = color
        
        super.init(frame: indicatorframe)
        
        self.center = center
        activityIndicatorViewStyle = style
    }
    
    required public init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open func start() {
        container.addSubview(self)
        self.startAnimating()
    }
    
    open func stop() {
        self.stopAnimating()
        self.removeFromSuperview()
    }
    
}
