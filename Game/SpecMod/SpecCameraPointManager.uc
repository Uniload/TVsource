class SpecCameraPointManager extends Core.Object PerObjectConfig config(SpecMod);

var array<SpecCameraPoint> CameraPoints;
var config array<String> CameraPointNames;

function EnsureCameras()
{
	local int i;

	if(CameraPointNames.Length == CameraPoints.Length)
	{
		return;
	}

	for(i=0; i<CameraPointNames.Length; i++)
	{
		CameraPoints.Insert(i, 1);
		CameraPoints[i]=new(None, self.Name$"_"$CameraPointNames[i]) class'SpecCameraPoint';
	}
}

function AddCamera(string name, Vector location, rotator rotation)
{
	local SpecCameraPoint cp;

	EnsureCameras();

	cp = new(None, self.Name$"_"$name) class'SpecCameraPoint';
	cp.Initialize(location, rotation);

	CameraPoints.Insert(CameraPoints.Length, 1);
	CameraPoints[CameraPoints.Length-1]=cp;

	CameraPointNames.Insert(CameraPointNames.Length, 1);
	CameraPointNames[CameraPointNames.Length-1]=name;

	CameraPoints[CameraPointNames.Length-1].SaveConfig();
	SaveConfig();
}

function RemoveCamera(string name)
{
	local SpecCameraPoint cp;
	local int i;

	EnsureCameras();

	for(i=0; i<cameraPoints.Length; i++)
	{
		if(CameraPointNames[i] == name)
		{
			CameraPoints.Remove(i, 1);
			CameraPointNames.Remove(i, 1);
			break;
		}
	}

	SaveConfig();
}

function SpecCameraPoint FindCamera(string name)
{
	local int i;

	EnsureCameras();

	for(i=0; i<CameraPoints.Length; i++)
	{
		if(CameraPointNames[i] == name) break;
	}

	if(i<CameraPoints.Length)
		return CameraPoints[i];

	return None;		
}