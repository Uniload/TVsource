class AnimationLayer extends Core.DeleteableObject native;
	

var AnimationState currentAnimationState;       // current animation state
var int alertnessLevel;                         // alertness level of this layer

var int baseIndex;                              // base channel index where layer is placed

var AnimationInterpolator primaryAlpha;         // primary alpha for this layer (scales all other alphas)

var AnimationInterpolator centerAlpha;          // center animation alpha
var AnimationInterpolator forwardAlpha;         // forward animation alpha
var AnimationInterpolator backAlpha;            // back animation alpha
var AnimationInterpolator leftAlpha;            // left animation alpha
var AnimationInterpolator rightAlpha;           // right animation alpha
var AnimationInterpolator upAlpha;              // up animation alpha
var AnimationInterpolator downAlpha;            // down animation alpha

var bool firstUpdate;                           // true if first layer update
var bool redundant;                             // true if layer is redundant (zero alpha)

var bool dominant;                              // true if dominant layer (animation notifies)

var bool hurryUp;                               // true if layer is in hurry up mode (blending to zero alpha in 0.1 secs)


overloaded function construct()
{
    primaryAlpha = new class'AnimationInterpolator'();
    centerAlpha = new class'AnimationInterpolator'();
    forwardAlpha = new class'AnimationInterpolator'();
    backAlpha = new class'AnimationInterpolator'();
    leftAlpha = new class'AnimationInterpolator'();
    rightAlpha = new class'AnimationInterpolator'();
    upAlpha = new class'AnimationInterpolator'();
    downAlpha = new class'AnimationInterpolator'();
    firstUpdate = true;
    redundant = true;
}

