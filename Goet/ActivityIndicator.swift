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
    private var appDelegate: AppDelegate!
    
    public init(indicatorFrame: CGRect, style: UIActivityIndicatorViewStyle, containerFrame: CGRect, color: UIColor) {
        container = UIView(frame: containerFrame)
        appDelegate = UIApplication.shared.delegate as! AppDelegate
        super.init(frame: indicatorFrame)
        
        container.backgroundColor = color
        self.center = container.center
        activityIndicatorViewStyle = style
    }
    
    public convenience init() {
        self.init(
            indicatorFrame: CGRect(x: 0, y: 0,  width: 40, height: 40),
            style: .whiteLarge,
            containerFrame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height),
            color: UIColor.gray.withAlphaComponent(0.8)
        )
    }
    
    required public init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open func start() {
        appDelegate.window?.addSubview(container)
        container.addSubview(self)
        self.startAnimating()
    }
    
    open func stop() {
        self.stopAnimating()
        self.removeFromSuperview()
        container.removeFromSuperview()
    }
    
}
