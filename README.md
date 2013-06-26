WLPageViewController
======================

WLPageViewController is a custom implementation of UIPageViewController with scrolling transition support.

WLPageViewController was initially created for iOS 5 wherein UIPageViewController only supported page curl transition. It is still used in iOS 6 or even iOS 7 projects for its synchronous navigation title transition support.

It uses CAKeyframeAnimation to build a damping system to implement inertial scrolling and bouncing. With the introduction of UIKit Dynamics in iOS 7, one might be able to implement it with simpler code. But still, it is a good sample of how to do physics based animation from the ground up.

Demo: http://youtu.be/-y6L3x546q8