# GooeyEffectSample
Example how to make gooey effect

<img  width="700" src="/ReadmeSources/1.png" />

---
### Theory
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
