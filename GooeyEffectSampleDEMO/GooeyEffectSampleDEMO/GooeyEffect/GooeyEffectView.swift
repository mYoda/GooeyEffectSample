//
//  sampleView.swift
//  GooeyEffect
//
//  Created by Anton Nechayuk on 4/9/17.
//  Copyright © 2017 Anton Nechayuk. All rights reserved.
//

import UIKit

class GooeyEffectView: UIView, UIGestureRecognizerDelegate, CAAnimationDelegate {
    //set debug mode to debug all points during animation
    let debugMode = true
    
    private var shape = CAShapeLayer()
    private let fillColor: UIColor
    private let avulsionDistance: CGFloat
    private var isAfterAvulsion: Bool = false
    private let cornerRadius: CGFloat
    private var heightFigure: CGFloat
    private var widthFigure: CGFloat
    private var pointFigureA: CGPoint
    private var pointFigureB: CGPoint
    private var baseLinePointA: CGPoint
    private var baseLinePointB: CGPoint
    private var baseLineViewRect: CGRect
    private var apexControlLeft: CGPoint = CGPoint.zero
    private var apexControlRight: CGPoint = CGPoint.zero
    private var stopConstriction: Bool = false
    
    private var pointsDictionaryLayers = [String : CAShapeLayer]()
    
    //initial constants
    private let initialPointFigureA: CGPoint
    private let initialPointFigureB: CGPoint
    private let initialBaseLinePointA: CGPoint
    private let initialBaseLinePointB: CGPoint
    
    
    // init View
    // - frame: frame rect of View
    // - cornerRadius: corner radius that used in animation view
    // - avulsion: working distance of the gooey effect
    // - animationViewRect: the rect of the FigureView that will be animated
    // - baseLineRect: the start line for the shape (used for baseLinePoints)
    // - color: used for fillColor of the shapeLayer
    //
    required init(frame: CGRect,
         cornerRadius: CGFloat,
         avulsion: CGFloat,
         animationViewRect: CGRect,
         baseLineRect: CGRect,
         color: UIColor) {
        self.fillColor = color
        self.cornerRadius = cornerRadius
        self.heightFigure = animationViewRect.height
        self.widthFigure = animationViewRect.width
        self.avulsionDistance = avulsion
        self.baseLineViewRect = baseLineRect
        self.pointFigureA = CGPoint(x: animationViewRect.origin.x,
                                    y: animationViewRect.origin.y + heightFigure)
        self.pointFigureB = CGPoint(x: pointFigureA.x + widthFigure,
                                    y: pointFigureA.y)
        self.baseLinePointA = CGPoint(x: max(baseLineRect.origin.x, pointFigureA.x),
                                      y: baseLineRect.origin.y)
        self.baseLinePointB = CGPoint(x:  min(baseLineRect.origin.x + baseLineRect.size.width, pointFigureB.x),
                                      y: baseLineRect.origin.y)
        self.initialBaseLinePointA = baseLinePointA
        self.initialBaseLinePointB = baseLinePointB
        self.initialPointFigureA = pointFigureA
        self.initialPointFigureB = pointFigureB
        
        super.init(frame: frame)
        
        clipsToBounds = true
        backgroundColor = UIColor.clear
        createLayers()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    //MARK: createLayers
    
    //
    //add all needs layers before animation
    //
    private func createLayers() {
        shape = CAShapeLayer()
        shape.path = generateShapePath().cgPath
        shape.fillColor = fillColor.cgColor
        
        layer.addSublayer(shape)
        
        for layer in pointsDictionaryLayers {
            self.layer.addSublayer(layer.value)
            print("added layer: \(layer.key)")
        }
    }
    
    //
    // draw the shape by CGPath
    // - override figure points
    //
    public func generateLayersPath(animationViewRect: CGRect){
        pointFigureA = CGPoint(x: animationViewRect.origin.x, y: animationViewRect.origin.y + animationViewRect.height)
        pointFigureB = CGPoint(x: pointFigureA.x + widthFigure, y: pointFigureA.y)
        shape.path = generateShapePath().cgPath
    }
    
    //
    // Avulsion distance constant
    // sets in init()
    //
    private func getAvulsionDistance() -> CGFloat {
        return avulsionDistance
    }
    
    //
    // Distance betven 2 points on Y axis
    // - used for calculating distance betwen baseLine and bottomLine of animationView
    //
    private func getVerticalDistance(fromBottomPoint bottomP: CGPoint, toTopPoint topP: CGPoint) -> CGFloat {
        return bottomP.y - topP.y
    }
    
    //
    // stopConstriction - Bool constant for control shape constriction
    //
    private func isStopConstriction() -> Bool {
        return stopConstriction
    }

    //MARK: BASE LINE POINTS
    
    //
    // Calculate Base Line Points for shape
    // - used movement on Xaxis
    // - return (point0, point3)
    //
    private func calculateBaseLinePoints() -> (CGPoint, CGPoint) {
        let distance = max(0, getVerticalDistance(fromBottomPoint: initialBaseLinePointA, toTopPoint: pointFigureA))
        let avulsionDistance = getAvulsionDistance()
        let pX = {(from: CGFloat, to: CGFloat, lineSegment: CGFloat) -> CGFloat in
            //calculate coeficient X-axis movement from Xstart to Xfinish while distance <= avulsion
            let coef = abs(to - from) / lineSegment
            
            let p = from < to ? from + coef * distance : from - coef * distance
            return p
        }
        
        let baseLineFigureLimitX_left = baseLineViewRect.origin.x
        let baseLineFigureLimitX_right = baseLineViewRect.origin.x + baseLineViewRect.width
        
        let XfigureMovement = (pointFigureA.x - initialBaseLinePointA.x)
        
        //point0
        let X0start = max(baseLineFigureLimitX_left, initialBaseLinePointA.x - cornerRadius + XfigureMovement)
        let X0finish = max(baseLineFigureLimitX_left, initialBaseLinePointA.x + cornerRadius + XfigureMovement)
        let point0 = CGPoint(x: pX(X0start, X0finish, avulsionDistance),
                             y: initialBaseLinePointA.y)
        
        //point3
        let X3start = min(baseLineFigureLimitX_right, initialBaseLinePointB.x + cornerRadius + XfigureMovement)
        let X3finish = min(baseLineFigureLimitX_right, initialBaseLinePointB.x - cornerRadius + XfigureMovement)
        let point3 = CGPoint(x: pX(X3start, X3finish, avulsionDistance),
                             y: initialBaseLinePointB.y)
        
        //set limit for Xaxis movement
        let limitDistanceBetwenPoints = widthFigure - cornerRadius * 2
        
        if isStopConstriction() ||
            point3.x - point0.x < limitDistanceBetwenPoints
        {
            //old values
            return (baseLinePointA, baseLinePointB)
        }
        
        return (point0, point3)
    }
    
    //
    // calculate points of intercsection betwen two circles
    //
    //
    private func findIntersection(centerCircle1 c1: CGPoint, radiusCircle1 c1r: CGFloat, centerCircle2 c2: CGPoint) -> (CGPoint, CGPoint) {
        //The solution is to find tangents by calculation of intersection of two circles
        // https://www.mathsisfun.com/geometry/construct-circletangent.html
        
        //Intersection of two circles
        //Discussion http://stackoverflow.com/questions/3349125/circle-circle-intersection-points
        //Description http://paulbourke.net/geometry/circlesphere/
        //Objective-c algorithm http://paulbourke.net/geometry/circlesphere/CircleCircleIntersection2.m
        
        //Calculate distance between centres of circle
        let d = c1.minus(c2).length()
        let c2r = d //in our case
        let m = c1r + c2r
        var n = c1r - c2r
        
        if (n < 0) {
            n = n * -1
        }
        
        //No solns
        if (d > m) {
            return (CGPoint.zero, CGPoint.zero)
        }
        //Circle are contained within each other
        if (d < n) {
            return (CGPoint.zero, CGPoint.zero)
        }
        //Circles are the same
        if (d == 0 && c1r == c2r) {
            return (CGPoint.zero, CGPoint.zero)
        }
        
        let a = (c1r * c1r - c2r * c2r + d * d) / (2 * d)
        
        let h = sqrt(c1r * c1r - a * a)
        
        //Calculate point p, where the line through the circle intersection points crosses the line between the circle centers.
        
        var x = c1.x + (a / d) * (c2.x - c1.x)
        var y = c1.y + (a / d) * (c2.y - c1.y)
        let p = CGPoint(x: x, y: y)
        
        //1 Intersection , circles are touching
        if (d == c1r + c2r) {
            return (p, CGPoint.zero)
        }
        
        //2 Intersections
        //Intersection 1
        x = p.x + (h / d) * (c2.y - c1.y)
        y = p.y - (h / d) * (c2.x - c1.x)
        let p1 = CGPoint(x: x, y: y)
        
        //Intersection 2
        x = p.x - (h / d) * (c2.y - c1.y)
        y = p.y + (h / d) * (c2.x - c1.x)
        let p2 = CGPoint(x: x, y: y)
        
        return (p1, p2)
    }
    
    //
    // calculate top left point of shape
    // - used method of intersection betwen two circles
    // -- first circle - centerfigCircle
    // -- second circle - circle from controlPoint
    //
    private func calculateShapePoint1(_ cp:CGPoint, _ point0:CGPoint) -> CGPoint {
        var centerfigCircle = CGPoint(x: pointFigureA.x + cornerRadius,
                                      y: pointFigureA.y - cornerRadius)
        centerfigCircle.y = point0.y - centerfigCircle.y < cornerRadius ? point0.y - cornerRadius : centerfigCircle.y
        centerfigCircle.y = max(centerfigCircle.y, pointFigureA.y + cornerRadius - heightFigure)
        let x3 = (centerfigCircle.x + cp.x) / 2
        let y3 = (centerfigCircle.y + cp.y) / 2
        let c1 = centerfigCircle
        let c2 = CGPoint(x: x3, y: y3)
        let c1r = cornerRadius
        var (_, p2) = findIntersection(centerCircle1: c1, radiusCircle1: c1r, centerCircle2: c2)
        //when something wrong in findIntersection pass left center point
        if p2 == CGPoint.zero {
            p2 = CGPoint(x: centerfigCircle.x - cornerRadius, y: centerfigCircle.y)
        }
        
        return p2
    }
    
    //
    // calculate top right point of shape
    // - used method of intersection betwen two circles
    // -- first circle - centerfigCircle
    // -- second circle - circle from controlPoint
    //
    private func calculateShapePoint2(_ cp:CGPoint, _ point3:CGPoint) -> CGPoint {
        var centerfigCircleRight = CGPoint(x: pointFigureB.x - cornerRadius,
                                            y: pointFigureB.y - cornerRadius)
        centerfigCircleRight.y = point3.y - centerfigCircleRight.y < cornerRadius ? point3.y - cornerRadius : centerfigCircleRight.y
        centerfigCircleRight.y = max(centerfigCircleRight.y, pointFigureA.y + cornerRadius - heightFigure)
        let x3 = (centerfigCircleRight.x + cp.x) / 2
        let y3 = (centerfigCircleRight.y + cp.y) / 2
        let c1 = centerfigCircleRight
        let c2 = CGPoint(x: x3, y: y3)
        let c1r = cornerRadius
        var (p1, _) = findIntersection(centerCircle1: c1, radiusCircle1: c1r, centerCircle2: c2)
        
        if p1 == CGPoint.zero {
            p1 = CGPoint(x: centerfigCircleRight.x - cornerRadius, y: centerfigCircleRight.y)
        }
        
        return p1
    }
    
    //
    // calculate 2 control points for Bezier Path
    // - concavity depends of distance
    // - used movement for concavity effect
    //
    private func calculateControlPoints(from point: CGPoint, movement: pointMovementType) -> (CGPoint, CGPoint) {
        let distance = getVerticalDistance(fromBottomPoint: initialBaseLinePointA, toTopPoint: pointFigureA)
        let k: CGFloat = (widthFigure <= heightFigure) ? 1.05 : 1.3
        var cp1 = point
        if movement == .right {
            let controlPointСoncavity = distance + distance * 0.05
            let deltaX = abs(point.x - pointFigureA.x) / k
            cp1.movePoint(forValue: controlPointСoncavity, forType: .right)
            cp1.x = max(point.x + deltaX, cp1.x)
            
        } else if movement == .left {
            let controlPointСoncavity = max(0, distance + distance * 0.05)
            let deltaX = abs(point.x - pointFigureB.x) / k
            cp1.movePoint(forValue: controlPointСoncavity, forType: .left)
            cp1.x = min(point.x - deltaX, cp1.x)
        }
        
        cp1.y = min(point.y, cp1.y)
        
        var cp2 = point
        cp2.y = pointFigureA.y
        cp2.movePoint(forValue: distance / 4, forType: .Down)
        cp2.x = cp1.x
        cp2.y = min(point.y, cp2.y)
        
        return (cp1, cp2)
    }
   
    //MARK: generate main SHAPE Path
    /*
     
     point1  |-------------------------------| point2
             |                               |
             |-cpLeft2              cpRight2-|
             |                               |
             |-cpLeft1              cpRight1-|
     point0  |_______________________________| point3
     
     
     
     */
    
    //
    // generate shape path 
    // - calculate baseLinePoints (point0, point3)
    // - calculate control points
    // - calculate topLinePoints (point1, point2)
    // - constrinction control
    // - draw the shape by points
    //
    private func generateShapePath() -> UIBezierPath {
        //calculate Xpoints (need to know cornerRadius of figure)
        let distance = max(0, getVerticalDistance(fromBottomPoint: initialBaseLinePointA, toTopPoint: pointFigureA))
        let avulsionDistance = getAvulsionDistance()
        let (point0, point3) = calculateBaseLinePoints()
        baseLinePointA = point0
        baseLinePointB = point3
        //get control points
        var (cpLeft1, cpLeft2)  =  calculateControlPoints(from: point0, movement: .right)
        var (cpRight1, cpRight2) = calculateControlPoints(from: point3, movement: .left)
        var point1 = calculateShapePoint1(cpLeft2, point0)
        var point2 = calculateShapePoint2(cpRight2, point3)
        
        //constriction control
        let constrictionControl = {() -> Void in
            let leftPoints =  self.getCubeCurvePoints(p0: point0, p1: cpLeft1, p2: cpLeft2, p3: point1)
            let rightPoints = self.getCubeCurvePoints(p0: point2, p1: cpRight2, p2: cpRight1, p3: point3)
            //search for curve cross
            var crossed = false
            for lp in leftPoints {
                for rp in rightPoints {
                    let delta = rp.x - lp.x
                    if delta <= 1 {
                        crossed = true
                        break
                    }
                }
            }
            
            if self.isStopConstriction() != crossed {
                self.stopConstriction = crossed
            }
            
            //if true - we'll use old values
            if crossed == true {
                cpLeft2.x = self.apexControlLeft.x
                cpLeft1.x = self.apexControlLeft.x
                
                cpRight2.x = self.apexControlRight.x
                cpRight1.x = self.apexControlRight.x
                
                point1 = self.calculateShapePoint1(cpLeft2, point0)
                point2 = self.calculateShapePoint2(cpRight2, point3)
            } else {
                self.apexControlLeft = cpLeft2
                self.apexControlRight = cpRight2
            }
        }
        
        constrictionControl()
        
        //check is after avulsion
        isAfterAvulsion = {
            if !debugMode {
                if isAfterAvulsion == true {
                    return true
                }
            }
            if distance > avulsionDistance {
                return true
            }
            return false
        }()
        
        print("isAfterAvulsion = \(isAfterAvulsion)")
        //do not need to draw shape under baseLine or after avulsion
        if distance <= -heightFigure ||
            isAfterAvulsion == true {
            
            point1 = CGPoint(x: point0.x, y: baseLinePointA.y)
            point2 = CGPoint(x: point0.x + widthFigure, y: baseLinePointA.y)
            cpLeft1 = point0
            cpLeft2 = point0
            cpRight1 = point3
            cpRight2 = point3
        }
        
        let curvePath = UIBezierPath()
        curvePath.move(to: point0)
        curvePath.addCurve(to: point1, controlPoint1: cpLeft1, controlPoint2: cpLeft2)
        curvePath.addLine(to: point2)
        curvePath.addCurve(to: point3, controlPoint1: cpRight2, controlPoint2: cpRight1)
        
        
        if debugMode {
            //add points for visualization - DEBUG INFO
            addPointsLayer(forkey: "cpLeft1", points: [cpLeft1], radius: 2, color: #colorLiteral(red: 0.8078431487, green: 0.02745098062, blue: 0.3333333433, alpha: 1), opacity: 1)
            addPointsLayer(forkey: "cpLeft2", points: [cpLeft2], radius: 2, color: #colorLiteral(red: 0, green: 0.9768045545, blue: 0, alpha: 1), opacity: 1)
            addPointsLayer(forkey: "cpRight1", points: [cpRight1], radius: 2, color: #colorLiteral(red: 0.8078431487, green: 0.02745098062, blue: 0.3333333433, alpha: 1), opacity: 1)
            addPointsLayer(forkey: "cpRight2", points: [cpRight2], radius: 2, color: #colorLiteral(red: 0, green: 0.9768045545, blue: 0, alpha: 1), opacity: 1)
            addPointsLayer(forkey: "BaseLinePoints", points: [point0, point3], radius: 2, color: #colorLiteral(red: 0.2196078449, green: 0.007843137719, blue: 0.8549019694, alpha: 1), opacity: 1)
            addPointsLayer(forkey: "FigurePoints", points: [point1, point2], radius: 3, color: #colorLiteral(red: 0, green: 0.5898008943, blue: 1, alpha: 1), opacity: 1)
            addPointsLayer(forkey: "FigurePointsAB", points: [pointFigureA, pointFigureB], radius: 3, color: #colorLiteral(red: 0.8901960784, green: 0.6549019608, blue: 0.5058823529, alpha: 1), opacity: 1)
            
            addLineLayer(forKey: "BetweenFigAndCPsleft", fromPoint: cpLeft2, toPoint: point1, color: #colorLiteral(red: 0.1090076491, green: 0.808973074, blue: 0.1021158919, alpha: 1), opacity: 1)
            addLineLayer(forKey: "BetweenFigAndCPsRight", fromPoint: cpRight2, toPoint: point2, color: #colorLiteral(red: 0.1090076491, green: 0.808973074, blue: 0.1021158919, alpha: 1), opacity: 1)
            
            let leftPoints =  getCubeCurveApexPoint(p0: point0, p1: cpLeft1, p2: cpLeft2, p3: point1)
            let rightPoints = getCubeCurveApexPoint(p0: point2, p1: cpRight2, p2: cpRight1, p3: point3)
            
            addPointsLayer(forkey: "ApexLeftPoint", points: [leftPoints], radius: 2, color: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1), opacity: 1)
            addPointsLayer(forkey: "ApexRightPoint", points: [rightPoints], radius: 2, color: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1), opacity: 1)
        }
        
        
        return curvePath
    }
    
    //
    // get Beizer curve points
    // p0 - start point
    // p1 - first control point
    // p2 - second control point
    // p3 - finish point
    //
    private func getCubeCurvePoints(p0: CGPoint, p1: CGPoint, p2: CGPoint, p3: CGPoint) -> [CGPoint] {
        //0 <= t >= 1
        // used t = 0.3...0.7 for fast calculation
        var points: [CGPoint] = []
        for t in stride(from: 0.3, to: 0.7, by: 0.1) {
            let x0 = pow((1-t), 3) * Double(p0.x)
            let x1 = 3 * t * pow((1-t), 2) * Double(p1.x)
            let x2 = 3 * pow(t, 2) * (1-t) * Double(p2.x)
            let x3 = pow(t, 3) * Double(p3.x)
            let X = x0 + x1 + x2 + x3
            
            let y0 = pow((1-t), 3) * Double(p0.y)
            let y1 = 3 * t * pow((1-t), 2) * Double(p1.y)
            let y2 = 3 * pow(t, 2) * (1-t) * Double(p2.y)
            let y3 = pow(t, 3) * Double(p3.y)
            let Y = y0 + y1 + y2 + y3
            points.append(CGPoint(x: X, y: Y))
        }
        
        return points
    }
    
    //
    // get Beizer curve Apex point (Middle of the line)
    // p0 - start point
    // p1 - first control point
    // p2 - second control point
    // p3 - finish point
    //
    private func getCubeCurveApexPoint(p0: CGPoint, p1: CGPoint, p2: CGPoint, p3: CGPoint) -> CGPoint {
        let t = 0.5 //Apex need only, 0 <= t >= 1
        
        let x0 = pow((1-t), 3) * Double(p0.x)
        let x1 = 3 * t * pow((1-t), 2) * Double(p1.x)
        let x2 = 3 * pow(t, 2) * (1-t) * Double(p2.x)
        let x3 = pow(t, 3) * Double(p3.x)
        let X = x0 + x1 + x2 + x3
        
        let y0 = pow((1-t), 3) * Double(p0.y)
        let y1 = 3 * t * pow((1-t), 2) * Double(p1.y)
        let y2 = 3 * pow(t, 2) * (1-t) * Double(p2.y)
        let y3 = pow(t, 3) * Double(p3.y)
        let Y = y0 + y1 + y2 + y3
        
        return CGPoint(x: X, y: Y)
    }
    
    //MARK: debug functions
    
    private func addLineLayer(forKey key: String, fromPoint: CGPoint, toPoint: CGPoint, color: UIColor, opacity: CGFloat){
        let linePath = UIBezierPath()
        linePath.move(to: fromPoint)
        linePath.addLine(to: toPoint)
        
        if let newLayer = pointsDictionaryLayers[key] {
            newLayer.path = linePath.cgPath
        } else {
            pointsDictionaryLayers[key] = CAShapeLayer()
            pointsDictionaryLayers[key]?.fillColor = color.cgColor
            pointsDictionaryLayers[key]?.strokeColor = color.cgColor
            pointsDictionaryLayers[key]?.opacity = Float(opacity)
            pointsDictionaryLayers[key]?.lineWidth = 1
            pointsDictionaryLayers[key]?.path = linePath.cgPath
        }
    }
    
    private func generateCirclePointsPath(forPoints points: [CGPoint], withRadius radius: CGFloat) -> UIBezierPath {
        let pointsPath = UIBezierPath()
        
        for p in points {
            pointsPath.move(to: p)
            pointsPath.addArc(withCenter: p, radius: CGFloat(radius), startAngle: CGFloat(), endAngle: CGFloat.pi * 2, clockwise: true)
        }
        
        
        return pointsPath
    }
    //for debug use this method to add points into self.layer
    private func addPointsLayer(forkey key: String, points: [CGPoint], radius: CGFloat, color: UIColor, opacity: CGFloat) {
        
        if let newLayer = pointsDictionaryLayers[key] {
            newLayer.path = generateCirclePointsPath(forPoints: points, withRadius: radius).cgPath
        } else {
            pointsDictionaryLayers[key] = CAShapeLayer()
            pointsDictionaryLayers[key]?.fillColor = UIColor.clear.cgColor
            pointsDictionaryLayers[key]?.strokeColor = color.cgColor
            pointsDictionaryLayers[key]?.opacity = Float(opacity)
            pointsDictionaryLayers[key]?.lineWidth = 1
            pointsDictionaryLayers[key]?.path = generateCirclePointsPath(forPoints: points, withRadius: radius).cgPath
            
        }
    }
    
    
}
