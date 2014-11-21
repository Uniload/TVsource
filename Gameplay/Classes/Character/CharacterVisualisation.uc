class CharacterVisualisation extends Engine.Actor;

var Character character;

var SphereVisActor fullSphere;
var SphereVisActor lowerSphere;
var SphereVisActor upperSphere;

var vector upperCenterOffset;
var vector lowerCenterOffset;

function SetCharacter(Character c)
{
	character = c;

	// create the full sphere visualisation
	fullSphere = spawn(class'SphereVisActor', , , Location, Rot(0, 0, 0));
	fullSphere.radius = character.OctreeBoxRadii.z;

	lowerSphere = spawn(class'SphereVisActor', , , Location, Rot(0, 0, 0));
	lowerSphere.radius = fullSphere.radius / 1.5;
	lowerCenterOffset.Z = fullSphere.radius - lowerSphere.radius;

	upperSphere = spawn(class'SphereVisActor', , , Location, Rot(0, 0, 0));
	upperSphere.radius = fullSphere.radius / 1.5;
	upperCenterOffset.Z = fullSphere.radius - upperSphere.radius - upperSphere.Radius;
}

function SetFullMode(bool full)
{
	if(full)
	{
		fullSphere.bHidden = false;
		upperSphere.bHidden = true;
		lowerSphere.bHidden = true;
	}
	else
	{
		upperSphere.bHidden = false;
		lowerSphere.bHidden = false;
		fullSphere.bHidden = true;
	}
}

function SetHidden(bool hidden)
{
	bHidden = hidden;

	upperSphere.bHidden = hidden;
	lowerSphere.bHidden = hidden;
	fullSphere.bHidden = hidden;
}

function Tick(float Delta)
{
	SetLocation(character.Location);

	fullSphere.SetDrawScale(fullSphere.radius / 64);
	upperSphere.SetDrawScale(upperSphere.radius / 64);
	lowerSphere.SetDrawScale(lowerSphere.radius / 64);

	fullSphere.SetSphereCenter(Location);
	lowerSphere.SetSphereCenter(Location + lowerCenterOffset);
	upperSphere.SetSphereCenter(Location + upperCenterOffset);
}

defaultproperties
{
	StaticMesh = None
}