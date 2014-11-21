class TsActionShakeView extends TsCameraAction;

var() Vector amplitude;
var() Vector frequency;
var() Rotator rotAmplitude;
var() Vector rotFrequency		"X,Y,Z = Pitch, Roll, Yaw";
var() float easeIn				"If easeIn/duration/easeOut are all 0, use attack/sustain/decay. Do not use this and shakeAttack/Sustain/Decay together.";
var() float duration			"If easeIn/duration/easeOut are all 0, use attack/sustain/decay. Do not use this and shakeAttack/Sustain/Decay together.";
var() float easeOut				"If easeIn/duration/easeOut are all 0, use attack/sustain/decay. Do not use this and shakeAttack/Sustain/Decay together.";
var() float shakeAttackTime		"easeIn/duration/easeOut must all be 0. Amount of time spent ramping up the shake amount (can be 0)";
var() float shakeSustainTime	"easeIn/duration/easeOut must all be 0. Amount of time spent holding the shake amount steady (can be 0)";
var() float shakeDecayTime		"easeIn/duration/easeOut must all be 0. Amount of time spent ramping down the shake amount (can be 0)";

var Vector randomOffset;
var Vector randomRotOffset;
var float alpha;
var float totalTime;

function bool OnStart()
{
	randomOffset.X = FRand();
	randomOffset.Y = FRand();
	randomOffset.Z = FRand();
	randomRotOffset.X = FRand();
	randomRotOffset.Y = FRand();
	randomRotOffset.Z = FRand();

	totalTime = 0;

	if (!UsesASD())
	{
		resetInterpolation(easeIn, duration, easeOut);
	}

	return true;
}

function bool UsesASD()
{
	return easeIn == 0 && easeOut == 0 && duration == 0;
}

function bool OnTick(float delta)
{
	local float alpha;
	local Vector offset;
	local Vector rotOffset;
	local Rotator finalRot;
	local float pingPongAlpha;
	local bool bFinished;

	if (!UsesASD())
	{
		bFinished = !tickInterpolation(delta, alpha);

		if (alpha >= 0.5)
			pingPongAlpha = 1 - ((alpha - 0.5) * 2);
		else
			pingPongAlpha = alpha * 2;
	}
	else
	{
		totalTime += delta;
		if (totalTime >= GetDuration())
		{
			return true;
		}

		if (totalTime < shakeAttackTime) // attack
			alpha = totalTime / shakeAttackTime;
		else if (totalTime - shakeAttackTime < shakeSustainTime) // sustain
			alpha = 1;
		else // decay
			alpha = 1 - ((totalTime - shakeAttackTime - shakeSustainTime) / shakeDecayTime);

		pingPongAlpha = alpha * alpha;
		interpTime = totalTime;
	}

	// calculate new offset
	offset.X = Sin((interpTime + randomOffset.X) * frequency.X);
	offset.Y = Sin((interpTime + randomOffset.Y) * frequency.Y);
	offset.Z = Sin((interpTime + randomOffset.Z) * frequency.Z);

	rotOffset.X = Sin((interpTime + randomRotOffset.X) * rotFrequency.X);
	rotOffset.Y = Sin((interpTime + randomRotOffset.Y) * rotFrequency.Y);
	rotOffset.Z = Sin((interpTime + randomRotOffset.Z) * rotFrequency.Z);

	offset *= amplitude * pingPongAlpha;
	rotOffset.X *= rotAmplitude.Pitch * pingPongAlpha;
	rotOffset.Y *= rotAmplitude.Roll * pingPongAlpha;
	rotOffset.Z *= rotAmplitude.Yaw * pingPongAlpha;

	finalRot.Pitch = rotOffset.X;
	finalRot.Roll = rotOffset.Y;
	finalRot.Yaw = rotOffset.Z;

	// calculate new camera offset
	PC.CinematicShakeOffset = offset;
	PC.CinematicShakeRotate = finalRot;

	return !bFinished;
}

function OnFinish()
{
	PC.CinematicShakeOffset = vect(0,0,0);
	PC.CinematicShakeRotate = rot(0,0,0);
}

event bool SetDuration(float _duration)
{
	return false;
}

event float GetDuration()
{
	if (UsesASD())
		return shakeAttackTime + shakeSustainTime + shakeDecayTime;
	else
		return duration;
}

defaultproperties
{
	DName			="Shake View"
	Track			="Effects"
	Help			="Shake camera view"
	UsesDuration	=false

  	easeIn			=0
  	duration		=0
  	easeOut			=0
  	
	shakeAttackTime	=0.01
  	shakeSustainTime=0.5
  	shakeDecayTime	=1
  	
	frequency		=(X=100,Y=100,Z=100)
  	amplitude		=(X=25,Y=25,Z=25)
  	rotFrequency	=(X=100,Y=100,Z=100)
  	rotAmplitude	=(Yaw=1250,Pitch=1250,Roll=0)
}