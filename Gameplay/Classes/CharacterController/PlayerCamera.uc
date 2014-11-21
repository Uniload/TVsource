class PlayerCamera extends Core.Object
	threaded;

var PlayerCharacterController pcc;

var private float m_firstToThirdAlpha;
var private float m_stateStartTime;
var private float m_stateEndTime;

var float thirdPersonCameraDist;
var float thirdPersonCameraLift;
var float vehicleCameraAbsoluteDist;
var bool bEnabled;

struct TransitionData
{
	var Name state;
	var float time;
};
var private Array<TransitionData> m_transitionChain;

overloaded function construct()
{
	m_firstToThirdAlpha = 1;
}

function clearTransitions()
{
	if (m_transitionChain.Length > 0)
		m_transitionChain.Remove(0, m_transitionChain.Length);
}

function bool isTransitioning()
{
	return m_transitionChain.Length != 0;
}

function int transitionCount()
{
	return m_transitionChain.Length;
}

function transition(Name state, float time)
{
	if (!bEnabled)
		return;

	m_transitionChain.Length = m_transitionChain.Length + 1;
	m_transitionChain[m_transitionChain.Length - 1].state = state;
	m_transitionChain[m_transitionChain.Length - 1].time = time;
}

function firstToThirdTransition(float outTime, float hold, optional float inTime)
{
/*	clearTransitions();
	if (!pcc.bBehindView)
		transition('ZoomOut', outTime);
	transition('Wait', hold);
	transition('ZoomIn', inTime);*/
}

function doZoomOut(float outTime)
{
	clearTransitions();
	transition('ZoomOut', outTime);
}

function doZoomIn(float inTime)
{
	clearTransitions();
	transition('ZoomIn', inTime);
}

function calcView(out vector cameraLocation, out rotator cameraRotation)
{
	local bool bBehindView;
	local float alpha;

	bBehindView = needBehindView();

	if (!bBehindView)
	{
		if (pcc.Pawn != None)
			pcc.CalcFirstPersonView(cameraLocation, cameraRotation);
	}
	else
	{
		alpha = 0.25 + (m_firstToThirdAlpha) * 0.75;

		if (!pcc.IsInState('TribesPlayerDriving'))
		{
			calcCharacterBehindView(cameraLocation, cameraRotation, alpha);
		}
		else
		{
			pcc.CalcBehindView(cameraLocation, cameraRotation, vehicleCameraAbsoluteDist);
		}
	}

	cameraLocation = cameraLocation + pcc.CinematicShakeOffset;
	cameraRotation = cameraRotation + pcc.CinematicShakeRotate;
}

function liftBehindCamera(float alpha, rotator cameraRotation, out vector v)
{
	v.Z = pcc.ViewTarget.CollisionHeight + (thirdPersonCameraLift * alpha);
	v = v >> cameraRotation;
}

function calcCharacterBehindView(out vector cameraLocation, out rotator cameraRotation, float alpha)
{
	local vector View,HitLocation,HitNormal,v;
    local float ViewDist,RealDist;
	local float Dist;

	Dist = alpha * thirdPersonCameraDist * pcc.ViewTarget.Default.CollisionRadius;

	CameraRotation = pcc.Rotation;

	View = vect(1,0,0) >> CameraRotation;

	// allow view over player's head
	liftBehindCamera(alpha, cameraRotation, v);

	// make sure the camera lift will not make us clip
    if (pcc.Trace(HitLocation, HitNormal, CameraLocation + v, CameraLocation, false, vect(10,10,10)) != None)
		v = HitLocation - CameraLocation;

    // add view radius offset to camera location and move viewpoint up from origin (amb)
    RealDist = Dist;

    if( pcc.Trace( HitLocation, HitNormal, (CameraLocation - View * Dist) + v, CameraLocation + v,false,vect(10,10,10) ) != None )
	{
		ViewDist = FMin( (CameraLocation + v - HitLocation) Dot View, Dist );
	}
	else
	{
		ViewDist = Dist;
	}
    
    if ( !pcc.bBlockCloseCamera || !pcc.bValidBehindCamera || (ViewDist > 10 + FMax(pcc.ViewTarget.CollisionRadius, pcc.ViewTarget.CollisionHeight)) )
	{
		pcc.bValidBehindCamera = true;
		pcc.OldCameraLoc = CameraLocation - View * ViewDist;
		pcc.OldCameraLoc += v;
		pcc.OldCameraRot = CameraRotation;
	}
	else
	{
		pcc.SetRotation(pcc.OldCameraRot);
	}

    CameraLocation = pcc.OldCameraLoc; 
    CameraRotation = pcc.OldCameraRot;
}

function bool needBehindView()
{
	return pcc.ViewTarget != None && pcc.bBehindView;
}

function update(float delta)
{
//	local int i;

	m_firstToThirdAlpha = 1;

/*	for (i=0; i < m_transitionChain.Length; i++)
		log(i@m_transitionChain[i].state);*/

	if (m_transitionChain.Length > 0)
		startState();
}

function endTransitionState()
{
	m_transitionChain.Remove(0, 1);
	GotoState('');
}

function startState()
{
	m_stateStartTime = pcc.Level.TimeSeconds;
	m_stateEndTime = pcc.Level.TimeSeconds + m_transitionChain[0].time;
	GotoState(m_transitionChain[0].state);
}

// Camera code
state ZoomOut
{
	function BeginState()
	{
		pcc.bBehindView = true;
		m_firstToThirdAlpha = 0;
	}

	function update(float delta)
	{
		m_firstToThirdAlpha = (pcc.Level.TimeSeconds - m_stateStartTime) / (m_stateEndTime - m_stateStartTime);

		if (pcc.Level.TimeSeconds > m_stateEndTime)
			endTransitionState();
	}
}

state ZoomIn
{
	function EndState()
	{
		pcc.bBehindView = false;
		m_firstToThirdAlpha = 1;
	}

	function update(float delta)
	{
		m_firstToThirdAlpha = 1.0 - (pcc.Level.TimeSeconds - m_stateStartTime) / (m_stateEndTime - m_stateStartTime);

		if (pcc.Level.TimeSeconds > m_stateEndTime)
			endTransitionState();
	}
}

state Wait
{
	function update(float delta)
	{
		if (pcc.Level.TimeSeconds > m_stateEndTime)
			endTransitionState();
	}
}

state LevelStartPan
{
	function BeginState()
	{
		pcc.bBehindView = true;
		pcc.bFreeCamera = true;
	}

	function EndState()
	{
		pcc.bBehindView = false;
		pcc.bFreeCamera = false;
		pcc.SetRotation(pcc.Pawn.Rotation);
	}

	function liftBehindCamera(float alpha, rotator cameraRotation, out vector v)
	{
		v.z += pcc.ViewTarget.CollisionHeight;
	}

	function update(float delta)
	{
		local float totalLength;
		local float progress;
		local Rotator rot;
		local float startYaw;
		local float endYaw;
		
		totalLength = m_stateEndTime - m_stateStartTime;
		progress = pcc.Level.TimeSeconds - m_stateStartTime;
		if (progress > totalLength * 0.6)
		{
			m_firstToThirdAlpha = (progress - totalLength * 0.6) / (totalLength * 0.4);
			m_firstToThirdAlpha = 1 - (m_firstToThirdAlpha * m_firstToThirdAlpha);
		}
		else
			m_firstToThirdAlpha = 1;

		startYaw = pcc.Pawn.Rotation.Yaw + 40960;
		endYaw = pcc.Pawn.Rotation.Yaw;

		rot.Yaw = startYaw + (endYaw - startYaw) * (progress / totalLength);
		pcc.SetRotation(rot);

		if (pcc.Level.TimeSeconds > m_stateEndTime)
			endTransitionState();
	}
}

defaultproperties
{
	thirdPersonCameraDist = 10
	thirdPersonCameraLift = 48
	vehicleCameraAbsoluteDist = 800
	bEnabled = true
}