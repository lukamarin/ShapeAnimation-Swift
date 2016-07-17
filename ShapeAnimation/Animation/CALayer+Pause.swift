//
//  CALayer+Pause.swift
//  ShapeAnimation
//
//  Created by Zhang Yungui on 15/1/20.
//  Copyright (c) 2015 github.com/rhcad. All rights reserved.
//

import SwiftGraphics

public extension CALayer {
    
    public var paused:Bool {
        get {
            return speed == 0.0
        }
        set {
            if newValue && !paused {
                let pausedTime = convertTime(CACurrentMediaTime(), fromLayer:nil)
                speed = 0.0
                timeOffset = pausedTime
            }
            else if !newValue && paused {
                let pausedTime = timeOffset
                speed = 1.0
                timeOffset = 0.0
                beginTime = 0.0
                beginTime = convertTime(CACurrentMediaTime(), fromLayer:nil) - pausedTime
            }
            gradientLayer?.paused = newValue
#if os(iOS)
            if let layer = self as? AnimationLayer {
                layer.timer?.paused = newValue
            }
#endif
        }
    }
    
}

public extension ShapeView {
    
    public var paused:Bool {
        get {
            var ret = false
            enumerateLayers { layer in
                ret = ret || layer.paused
            }
            return ret
        }
        set {
            enumerateLayers { layer in
                layer.paused = newValue
            }
        }
    }
    
    public func stop() {
        enumerateLayers { layer in
            layer.removeAllAnimations()
        }
    }
    
}
