//
//  MySlider.swift
//  CQAVPlayer
//
//  Created by white on 2021/8/5.
//

import UIKit

class MySlider: UISlider {

    let slider_y_bound:CGFloat = 40
    let slider_x_bound:CGFloat = 30
    var lastBounds:CGRect?
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func thumbRect(forBounds bounds: CGRect, trackRect rect: CGRect, value: Float) -> CGRect {
        let result = super.thumbRect(forBounds: bounds, trackRect: rect, value: value)
        lastBounds = result
        return result
    }
//    检查点击事件
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        var result = super.hitTest(point, with: event)
        if result != self {
            if point.y >= -15 && point.y < CGFloat((lastBounds?.size.height ?? 0.0) + slider_y_bound) && point.x >= 0 && point.x < self.bounds.width{
                result = self
            }
        }
        return result
    }
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        var result = super.point(inside: point, with: event)
        if !result {
            if point.x >= CGFloat((lastBounds?.origin.x ?? 0.0) - slider_x_bound)
                && point.x <= ((lastBounds?.origin.x ?? 0.0) + (lastBounds?.size.width ?? 0.0) + slider_x_bound) && point.y >= -slider_y_bound && point.y < ((lastBounds?.size.height ?? 0.0) + slider_y_bound){
                result = true
            }
        }
        return result
    }
}
