//
//  AnimationLayer.swift
//  ShapeAnimation
//
//  Created by Zhang Yungui on 15/1/29.
//  Copyright (c) 2015 github.com/rhcad. All rights reserved.
//

import SwiftGraphics

#if os(OSX)
    public typealias DisplayLink = CDisplayLink
#else
    public typealias DisplayLink = CADisplayLink
#endif

public class AnimationLayer : CALayer {
    
    public var properties:[(key:String, min:CGFloat)]! {
        didSet { keys = properties.map { $0.key } }
        willSet {
            if properties == nil {
                for (key, min) in newValue {
                    setValue(min, forKey:key)
                }
            }
        }
    }
    public var draw:((AnimationLayer, CGContext) -> Void)?
    public var animationCreated:((String, CABasicAnimation) -> Void)?
    public var didStart:(() -> Void)?
    public var didStop :(() -> Void)?
    
    private var keys:[String]! = nil
    public  var timer:DisplayLink?
    private var animations:[CAAnimation] = []
    
    public func getProperty(key:String) -> CGFloat {
        if let layer = presentationLayer() as? CALayer {
            if let value = layer.valueForKey(key) as? NSNumber {
                return CGFloat(value.floatValue)
            }
        }
        return minValue(key)
    }
    
    public func setProperty(value: AnyObject?, key: String) {
        setValue(value, forKey:key)
    }
    
    // MARK: Implementation
    
    private func minValue(key:String) -> CGFloat {
        for (k, min) in properties {
            if key == k {
                return min
            }
        }
        return 0
    }
    
    override public init() {
        super.init()
    }
    
    override public init(layer: AnyObject) {
        super.init(layer: layer)
        if let layer = layer as? AnimationLayer {
            self.properties = layer.properties
            self.animationCreated = layer.animationCreated
            self.draw = layer.draw
        }
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func animationDidStart(anim:CAAnimation) {
        if let animation = anim as? CAPropertyAnimation {
            if keys != nil && keys.contains(animation.keyPath!) {
                animations.append(animation)
                if timer == nil {
                    didStart?()
#if os(iOS)
                    timer = CADisplayLink(target:self, selector:Selector("animationLoop"))
                    timer!.addToRunLoop(NSRunLoop.mainRunLoop(), forMode:NSDefaultRunLoopMode)
#else
                    timer = CDisplayLink()
                    timer!.displayLinkBlock = { _ in
                        if (!self.paused) {
                            self.setNeedsDisplay()
                        }
                    }
                    timer!.start()
#endif
                }
            }
        }
    }
    
    override public func animationDidStop(anim:CAAnimation, finished:Bool) {
        if let index = animations.indexOf(anim) {
            animations.removeAtIndex(index)
            if animations.isEmpty {
#if os(iOS)
                timer!.invalidate()
#else
                timer!.stop()
#endif
                timer = nil
                didStop?()
            }
        }
    }
    
    // Called when layer's property changes.
    override public func actionForKey(event: String) -> CAAction? {
        if keys != nil && keys.contains(event) {
            let animation = CABasicAnimation(keyPath:event)
            animation.fromValue = getProperty(event)
            animation.delegate = self
            animation.duration = 1.0
            animationCreated?(event, animation)
            addAnimation(animation, forKey:event)
            return animation
        }
        return super.actionForKey(event)
    }
    
    // Timer Callback
    internal func animationLoop() {
        setNeedsDisplay()
    }
    
    // Layer Drawing
    override public func drawInContext(ctx: CGContext) {
        super.drawInContext(ctx)
        CGContextSetAllowsAntialiasing(ctx, true)
        CGContextSetShouldAntialias(ctx, true)
        draw?(self, ctx)
    }
    
}

public extension ShapeView {
    
    public func addAnimationLayer(frame frame:CGRect, properties:[(key:String, min:CGFloat)],
                                    draw:((AnimationLayer, CGContext) -> Void)) -> AnimationLayer
    {
        let layer = AnimationLayer()
        layer.properties = properties
        layer.draw = draw
        addSublayer(layer, frame:frame)
        return layer
    }
    
}
