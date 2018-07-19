//
//  GooeyMovementShower.swift
//  GooeyEffectSampleDEMO
//
//  Created by Anton Nechayuk on 17.07.18.
//  Copyright © 2018 Anton Nechayuk. All rights reserved.
//

import UIKit


class GooeyMovementShower: UIView, UIGestureRecognizerDelegate {
    
    var gooeyView: GooeyEffectView?
    
    let animationShapeView = UIView()
    let baseLineShapeView = UIView()
    let initialFrame: CGRect
    
    //initial constants
    //these points we need for slide event only (return to default value)
    private let pointFA: CGPoint
    private let initBaseLinePointA: CGPoint
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        
        //set up frame for animationShapeView
        let size = CGSize(width: frame.width - 200, height: 60)
        let origin = CGPoint(x: frame.midX - size.width / 2, y: frame.height - 200)
        initialFrame = CGRect(origin: origin, size: size)
        
        animationShapeView.frame = initialFrame
        animationShapeView.frame.origin.y -= 150
        animationShapeView.clipsToBounds = true
        animationShapeView.layer.cornerRadius = 30
        animationShapeView.backgroundColor = #colorLiteral(red: 0.5098039216, green: 0.4784313725, blue: 0.9019607843, alpha: 1)
        pointFA = animationShapeView.frame.origin
        
        //base line layer
        baseLineShapeView.frame = CGRect(origin: CGPoint(x: 0, y: initialFrame.origin.y),
                                         size: CGSize(width: frame.width, height: max(50, initialFrame.height + 20)))
        baseLineShapeView.clipsToBounds = true
        baseLineShapeView.backgroundColor = #colorLiteral(red: 0.5098039216, green: 0.4784313725, blue: 0.9019607843, alpha: 1)// #colorLiteral(red: 0.3764705882, green: 0.3803921569, blue: 0.431372549, alpha: 1)
        initBaseLinePointA = baseLineShapeView.frame.origin
        
        
        super.init(frame: frame)
        backgroundColor = #colorLiteral(red: 0.2666666667, green: 0.2784313725, blue: 0.3294117647, alpha: 1)
        addSubview(baseLineShapeView)
        addSubview(animationShapeView)
        addTitleLable(frame)
        setupGooeyEffectView()
        addPanGesture()
    }
    
    private func addTitleLable(_ frame: CGRect) {
        let labelView = UILabel()
        labelView.frame.origin = CGPoint(x: 20, y: 140)
        labelView.frame.size = CGSize(width: frame.width - 40, height: 70)
        labelView.adjustsFontSizeToFitWidth = true
        labelView.text = "Example Gooey Effect"
        labelView.font = UIFont.boldSystemFont(ofSize: 30)
        labelView.textAlignment = .center
        labelView.textColor = #colorLiteral(red: 0.9960784314, green: 0.9960784314, blue: 0.9960784314, alpha: 1)
        labelView.backgroundColor = #colorLiteral(red: 0.3764705882, green: 0.3803921569, blue: 0.431372549, alpha: 1)
        labelView.clipsToBounds = true
        labelView.layer.cornerRadius = 5
        addSubview(labelView)
    }
    
    private func addPanGesture() {
        let sgr = UIPanGestureRecognizer(target: self, action: #selector(self.handleSlide))
        sgr.delegate = self
        self.addGestureRecognizer(sgr)
    }
    
    @objc private func handleSlide(gr:UIPanGestureRecognizer) {
        let amountX = gr.translation(in: self).x
        let amountY = gr.translation(in: self).y
        
        moveOnSlide(amountX, amountY)
        
        if gr.state == UIGestureRecognizerState.ended {
            endSlide()
        }
    }
    
    private func moveOnSlide(_ X: CGFloat, _ Y: CGFloat) {
        animationShapeView.frame.origin.x = pointFA.x + X
        animationShapeView.frame.origin.y = pointFA.y + Y
        
        gooeyView?.generateLayersPath(animationViewRect: animationShapeView.frame)
    }
    
    private func endSlide() {
        animationShapeView.frame = initialFrame
        setupGooeyEffectView()
    }
    
    private func setupGooeyEffectView() {
        gooeyView?.removeFromSuperview()
        gooeyView = GooeyEffectView(frame: self.frame,
                                    cornerRadius: (animationShapeView.layer.cornerRadius),
                                    avulsion: min(140, animationShapeView.frame.width),
                                    animationViewRect: animationShapeView.frame,
                                    baseLineRect: baseLineShapeView.frame,
                                    color: animationShapeView.backgroundColor!)
        addSubview(gooeyView!)
    }
}
