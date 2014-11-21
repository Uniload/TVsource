class AnimationInterpolator extends Core.DeleteableObject native;
	

var bool interpolating;                         // true if currently interpolating

var float interpolatedValue;                    // current interpolated value

var float startValue;                           // start value for interpolation
var float destinationValue;                     // destination value for interpolation

var float interpolationTime;                    // duration of interpolation in seconds
var float interpolationTimeAccumulator;         // accumulated time in seconds since interpolation started
