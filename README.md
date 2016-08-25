# MapViewAnimation
在地图上实现的简陋动画UIView Animation,Core Animation(如何在地图上做动画)
CAKeyFrameAnimation

  
  for (int i = 0; i<[points count]; i++)
      {
        TracingPoint * tp = points[i];
        
        //position
        MAMapPoint p = MAMapPointForCoordinate(tp.coordinate);
        [xvalues addObjectsFromArray:@[@(p.x), @(p.x)]];//stop for turn
        [yvalues addObjectsFromArray:@[@(p.y), @(p.y)]];

        //angle
        double currDir = [Util fixNewDirection:tp.course basedOnOldDirection:preDir];
        [rvalues addObjectsFromArray:@[@(preDir * DegToRad), @(currDir * DegToRad)]];
        
        //distance
        dis[i] = MAMetersBetweenMapPoints(p, preLoc);
        sumOfDistance = sumOfDistance + dis[i];
        dis[i] = sumOfDistance;
        
        //record pre
        preLoc = p;
        preDir = currDir;
    }
    
    //   add animation.
     CAKeyframeAnimation *xanimation = [CAKeyframeAnimation animationWithKeyPath:MapXAnimationKey];
     xanimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
      xanimation.values   = xvalues;
      xanimation.keyTimes = times;
     xanimation.duration = duration;
     xanimation.delegate = self;
     xanimation.fillMode = kCAFillModeForwards;
