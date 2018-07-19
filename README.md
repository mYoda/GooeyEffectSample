# GooeyEffectSample
Example how to make gooey effect

<img align="left" width="615" src="/ReadmeSources/1.png" />
<img   width="235" src="/ReadmeSources/Gooey.gif" />
   
      
---
### Theory
The main idea is to draw a shape between views ( baseView and animationView ) using Bézier curves. This shape will imitate the 'gooey effect'.

Bézier curve:
https://en.wikipedia.org/wiki/B%C3%A9zier_curve

The solution is to find tangents by calculation of intersection of two circles
https://www.mathsisfun.com/geometry/construct-circletangent.html
        
Circles and spheres theory:
http://paulbourke.net/geometry/circlesphere/

### Usage

  1. Run DEMO project
  2. Swipe Up-Down on the screen
  
* Disable debug-mode to hide debug points:
``` swift
class GooeyEffectView: UIView, UIGestureRecognizerDelegate, CAAnimationDelegate {
    //set debug mode to debug all points during animation
    let debugMode = true
    
```    
