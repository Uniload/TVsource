//
// Shows a speedo in the hud
//
class HUDSpeedo extends TribesGUI.HUDContainer;

// sub components
var HUDNumericTextureLabel	SpeedLabel;
var LabelElement			UnitsLabel;

// unit configuration
var config String	UnitsText;				// text displayed after the value (eg: KM/h)
var config float	UnitsRatio;				// ratio of these units to unreal units
var config int		VisibleThreshold;		// Speed you have to be travelling for the speedo to be visible
var config int		VisibleThresholdRange;	// range below VisibleThreshold through which the speedo will fade in

var int Velocity;

function InitElement()
{
	SpeedLabel = HUDNumericTextureLabel(AddElement("TribesGUI.HUDNumericTextureLabel", "ext_Speedo_SpeedLabel"));
	UnitsLabel = LabelElement(AddElement("TribesGUI.LabelElement", "ext_Speedo_UnitsLabel"));
}

function UpdateData(ClientSideCharacter csc)
{
	local String VelocityText;

	Velocity = int(csc.Velocity) * UnitsRatio;
	if( Velocity < 10 )
		VelocityText = "00"$string(Velocity);
	else if( Velocity < 100 )
		VelocityText = "0"$string(Velocity);
	else
		VelocityText = string(Velocity);

	SetAlpha(FClamp((Velocity - VisibleThreshold - VisibleThresholdRange) / VisibleThresholdRange, 0.0, 1.0));

	SpeedLabel.SetDataString(VelocityText);
	UnitsLabel.SetText(UnitsText);
}

defaultproperties
{
	UnitsText="KM/h"
	UnitsRatio=1.0
	VisibleThreshold=30
	VisibleThresholdRange=10
}