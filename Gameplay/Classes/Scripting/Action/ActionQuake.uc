class ActionQuake extends Scripting.Action;

var() actionnoresolve Vector cameraAmplitude;
var() actionnoresolve Vector cameraFrequency;
var() actionnoresolve Rotator cameraRotAmplitude;
var() actionnoresolve Vector cameraRotFrequency		"X,Y,Z = Pitch, Roll, Yaw";

var() Name actorQuakeOrigin							"Actor whose position is taken as the origin of the quake (can be a trigger or any other actor)";
var() float quakeRadius								"Quake's radius of effect";
var() float quakeMagnitude							"Strength of the quake in force units";
var() float quakeAttackTime							"Amount of time spent ramping up the quake magnitude (can be 0)";
var() float quakeSustainTime						"Amount of time spent holding the quake magnitude steady (can be 0)";
var() float quakeDecayTime							"Amount of time spent ramping down quake magnitude (can be 0)";
var() float quakeVerticalMax						"Maximum vertical distance from the quake origin that still affects objects. You may need to set this to stop your quake affecting objects through the floor above it. Measured from the quake origin to 'quakeVerticleMax' units upwards. Objects below the quake's z origin will never be affected. 0 to disable.";
var() float characterForceScale						"Forces applied to characters are scaled by this amount.";

var() float forceApplyFrequency						"Number of times per second that the quake force is applied to surrounding objects.";

latent function Variable execute()
{
	local float alpha;
	local float startTime;
	local Vector randomOffset;
	local Vector randomRotOffset;
	local PlayerCharacterController pcc;
	local float totalTime;
	local Vector offset;
	local Vector rotOffset;
	local Rotator finalRot;
	local float nextForceApply;
	local Actor a;
	local Vector quakeOrigin;
	local float scaledMagnitude;
	local Vector quakeImpulse;

	Super.execute();

	pcc = PlayerCharacterController(parentScript.Level.GetLocalPlayerController());

	if (pcc != None)
	{
		a = parentScript.findByLabel(class'Actor', actorQuakeOrigin);
		if (a == None)
		{
			SLog("Quake action: Couldn't find actor"@actorQuakeOrigin);
			return None;
		}

		quakeOrigin = a.Location;

		randomOffset.X = FRand();
		randomOffset.Y = FRand();
		randomOffset.Z = FRand();
		randomRotOffset.X = FRand();
		randomRotOffset.Y = FRand();
		randomRotOffset.Z = FRand();
		startTime = parentScript.Level.TimeSeconds;

		nextForceApply = 0;

		do
		{
			totalTime = parentScript.Level.TimeSeconds - startTime;
			if (totalTime >= duration())
			{
				break;
			}

			if (totalTime < quakeAttackTime) // attack
				alpha = totalTime / quakeAttackTime;
			else if (totalTime - quakeAttackTime < quakeSustainTime) // sustain
				alpha = 1;
			else // decay
				alpha = 1 - ((totalTime - quakeAttackTime - quakeSustainTime) / quakeDecayTime);

			alpha = alpha * alpha;

			// calculate new offset
			offset.X = Sin((totalTime + randomOffset.X) * cameraFrequency.X);
			offset.Y = Sin((totalTime + randomOffset.Y) * cameraFrequency.Y);
			offset.Z = Sin((totalTime + randomOffset.Z) * cameraFrequency.Z);

			rotOffset.X = Sin((totalTime + randomRotOffset.X) * cameraRotFrequency.X);
			rotOffset.Y = Sin((totalTime + randomRotOffset.Y) * cameraRotFrequency.Y);
			rotOffset.Z = Sin((totalTime + randomRotOffset.Z) * cameraRotFrequency.Z);

			offset *= cameraAmplitude * alpha;
			rotOffset.X *= cameraRotAmplitude.Pitch * alpha;
			rotOffset.Y *= cameraRotAmplitude.Roll * alpha;
			rotOffset.Z *= cameraRotAmplitude.Yaw * alpha;

			finalRot.Pitch = rotOffset.X;
			finalRot.Roll = rotOffset.Y;
			finalRot.Yaw = rotOffset.Z;

			// calculate new camera offset
			pcc.CinematicShakeOffset = offset;
			pcc.CinematicShakeRotate = finalRot;
			
			// apply forces to objects in radius
            if (alpha > 0 && totalTime >= nextForceApply)
			{
				nextForceApply = totalTime + (1.0 / forceApplyFrequency);
				ForEach parentScript.Level.CollidingActors(class'Actor', a, quakeRadius, quakeOrigin)
				{
					if (quakeVerticalMax > 0 && a.Location.z - quakeOrigin.z > 0 && a.Location.z - quakeOrigin.z > quakeVerticalMax)
						continue;

					scaledMagnitude = (quakeMagnitude * alpha) * Sqrt(1.0f - FMin(1.0, (VSize(a.Location - quakeOrigin) / quakeRadius)));

					if (a.IsA('Character'))
					{
						// apply half force to characters, they bounce around too much
						scaledMagnitude *= characterForceScale;
					}

					quakeImpulse.x = -0.5 + FRand();
					quakeImpulse.y = -0.5 + FRand();
					quakeImpulse.z = 1;
					quakeImpulse /= VSize(quakeImpulse);

					a.unifiedAddImpulse(quakeImpulse * scaledMagnitude);
				}
			}

			Sleep(0);
		}
		until (false);

		pcc.CinematicShakeOffset = Vect(0,0,0);
		pcc.CinematicShakeRotate = Rot(0,0,0);
	}
	else
	{
		SLog("Couldn't get the players controller");
	}

	return None;
}

function float duration()
{
	return quakeAttackTime + quakeSustainTime + quakeDecayTime;
}

// editorDisplayString
function editorDisplayString(out string s)
{
	s = "Level Quake";
}

defaultproperties
{
	cameraFrequency		=(X=100,Y=100,Z=100)
  	cameraAmplitude		=(X=25,Y=25,Z=25)
  	cameraRotFrequency	=(X=100,Y=100,Z=100)
  	cameraRotAmplitude	=(Yaw=1250,Pitch=1250,Roll=0)

	quakeAttackTime		= 0.01
  	quakeSustainTime	= 1
  	quakeDecayTime		= 2
	quakeRadius			= 1024
	quakeMagnitude		= 100000
	characterForceScale = 0.5

	forceApplyFrequency = 1

	returnType			= None
	actionDisplayName	= "Quake"
	actionHelp			= "Shakes the camera and surrounding objects"
	category			= "AudioVisual"
}