//
//  CAShapeLayer+Gradient.swift
//  ShapeAnimation
//
//  Created by Zhang Yungui on 15/1/29.
//  Copyright (c) 2015 github.com/rhcad. All rights reserved.
//

import SwiftGraphics
import SwiftUtilities

private var GradientLayerKey = 12

public extension CAShapeLayer {
    public var gradient: Gradient? {
        get {
            if let layer = gradientLayer {
                if path!.isClosed {
                    var style = Gradient()
                    style.colors = layer.colors as! [CGColor]!
                    if let locations = layer.locations {
                        style.locations = locations.map {CGFloat($0 as NSNumber)}
                    }
                    style.orientation = (layer.startPoint, layer.endPoint)
                    style.axial = layer.type == kCAGradientLayerAxial
                    return style
                }
            }
            return nil
        }
        set {
            apply(newValue)
        }
    }
    
    public func apply(newStyle:Gradient?) {
        if newStyle?.colors != nil && path!.isClosed {
            let style = newStyle!
            let gradientLayer = CAGradientLayer()
            let maskLayer = CAShapeLayer()
            
            maskLayer.frame = bounds
            maskLayer.path = path
            maskLayer.strokeColor = nil
            
            gradientLayer.colors = style.colors!
            gradientLayer.locations = style.locations
            if let orientation = style.orientation {
                gradientLayer.startPoint = orientation.0
                gradientLayer.endPoint = orientation.1
            }
            if style.axial {
                gradientLayer.type = kCAGradientLayerAxial
            }
            gradientLayer.frame = frame
            gradientLayer.mask = maskLayer
            gradientLayer.contentsScale = self.contentsScale
            gradientLayer.setAffineTransform(affineTransform())
            
            superlayer!.addSublayer(gradientLayer)
            fillColor = nil
            self.gradientLayer = gradientLayer
        } else {
            self.gradientLayer = nil
        }
    }
}

public extension CALayer {
    
    public var gradientLayer: CAGradientLayer? {
        get {
            let defv:CAGradientLayer? = nil
            return getAssociatedWrappedObject(self, key: &GradientLayerKey, defaultValue: defv)
        }
        set {
            if let oldlayer = gradientLayer {
                oldlayer.removeAllAnimations()
                oldlayer.removeFromSuperlayer()
            } else if newValue == nil {
                return
            }
            weak var layer = newValue
            setAssociatedWrappedObject(self, key: &GradientLayerKey, value: layer)
        }
    }
}
