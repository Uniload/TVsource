class PointOfInterest extends Engine.Actor
	placeable;

var(PointOfInterest) String				LabelTextLocalisationTag;
var(PointOfInterest) localized String	LabelText;
var(PointOfInterest) class<RadarInfo>	RadarInfoClass;

var bool								bPointEnabled;

simulated function PostBeginPlay()
{
	super.PostBeginPlay();

	if(LabelTextLocalisationTag != "")
		LabelText = LocalizeMapText("Objectives", LabelTextLocalisationTag);
}

simulated function class GetRadarInfoClass()
{
	return RadarInfoClass;
}

defaultproperties
{
     bPointEnabled=True
     bHidden=True
}
