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
    open var container = UIView()
    
    public init(indicatorframe: CGRect, style: UIActivityIndicatorViewStyle, containerColor: UIColor) {
        super.init(frame: indicatorframe)
        
        container.backgroundColor = containerColor
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
