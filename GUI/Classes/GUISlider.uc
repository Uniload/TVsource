// ====================================================================
//  Class:  GUI.GUISlider
//
//  Written by Joe Wilcox
//  (c) 2002, Epic Games, Inc.  All Rights Reserved
// ====================================================================
/*=============================================================================
	In Game GUI Editor System V1.0
	2003 - Irrational Games, LLC.
	* Dan Kaplan
=============================================================================*/
#if !IG_GUI_LAYOUT
#error This code requires IG_GUI_LAYOUT to be defined due to extensive revisions of the origional code. [DKaplan]
#endif
/*===========================================================================*/

class GUISlider extends GUIComponent
        HideCategories(Menu,Object)
		Native;

// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)

var(GUISlider) config  float 		MinValue, MaxValue "Bounds for the slider";
var(GUISlider) config  string		CaptionStyleName "Name of the caption style";
var(GUISlider) config  string		LeftStyleName "Name of the left style";
var(GUISlider) config  string		RightStyleName "Name of the right style";
var(GUISlider) config  string		ButtonStyleName "Name of the button style";
var(GUISlider) config  float		Value "Slider's initial value";
var(GUISlider) config  float		Step "Step value for incrementing the slider";
var(GUISlider) editinline  GUIStyles	CaptionStyle "The actual caption style";
var(GUISlider) config  bool		bIntSlider "Are the values bound to be ints";
var(GUISlider) config  bool		    bDisplayAsPercentage "Should the value be displayed in text form as a percentage?";
var(GUISlider) editinline  GUIStyles	LeftStyle "The style displayed left of the button";
var(GUISlider) editinline  GUIStyles	RightStyle "The style displayed right of the button";
var(GUISlider) editinline  GUIStyles	ButtonStyle "The style displayed for the button";
var(GUISlider) config  float		SliderHeightPercent "Sliders height as a percentage of the total component height";
var(GUISlider) config  float		ButtonWidthPixels "The buttons width in pixels (at 800x600)";
var(GUISlider) config  eTextAlign	CaptionJustification "How the caption is justified";

#if IG_TRIBES3 // dbeswick:
var float		UpdateFreq;
var float LastChangeMessage;
#endif

delegate string OnDrawCaption()
{
    local float ModifiedValue;
    local float Range;
    local string OptionalText;

    if (bDisplayAsPercentage)
    {
        // Convert to percentage 
        Range = (MaxValue - MinValue);
        ModifiedValue = (1 - (Range - Value)) / Range; // convert to 0-1 decimal percentage
        ModifiedValue *= 100; // convert to 0-100% percentage
        //log(Name$": Value = "$Value$" Max = "$MaxValue$" Min = "$MinValue$" Range = "$Range$" ModifiedValue = "$ModifiedValue);
    }
    else
        ModifiedValue = Value;

    if (bDisplayAsPercentage)
        OptionalText = "%";

	if (bIntSlider || bDisplayAsPercentage) 
		return "("$int(ModifiedValue)$OptionalText$")";
	else
		return "("$ModifiedValue$OptionalText$")";
}

function SetValue(float NewValue)
{
	if (NewValue<MinValue) NewValue=MinValue;
	if (NewValue>MaxValue) NewValue=MaxValue;

	if (bIntSlider)
		Value = int(NewValue);
	else
		Value = NewValue;
}

function InitComponent(GUIComponent MyOwner)
{
	Super.InitComponent(MyOwner);
	OnCapturedMouseMove=InternalCapturedMouseMove;
	OnKeyEvent=InternalOnKeyEvent;
	OnMousePressed=InternalOnMousePressed;
#if IG_TRIBES3 // dbeswick:
	OnMouseRelease=InternalOnMousePressed;
#endif
	OnXControllerEvent = InternalOnXControllerEvent;

	CaptionStyle = Controller.GetStyle(CaptionStyleName);
	LeftStyle = Controller.GetStyle(LeftStyleName);
	RightStyle = Controller.GetStyle(RightStyleName);
	ButtonStyle = Controller.GetStyle(ButtonStyleName);

	Assert( CaptionStyle != None );
	Assert( LeftStyle != None );
	Assert( RightStyle != None );
	Assert( ButtonStyle != None );
}


function bool InternalCapturedMouseMove(float deltaX, float deltaY)
{
	local float Perc, OldValue;

	OldValue = Value;

	if ( (Controller.MouseX >= Bounds[0]) && (Controller.MouseX<=Bounds[2]) )
	{
		Perc = ( Controller.MouseX - ActualLeft()) / ActualWidth();
		Perc = FClamp(Perc,0.0,1.0);
		Value = ( (MaxValue - MinValue) * Perc) + MinValue;
		if (bIntSlider)
			Value = int(Value);
	}
	else if (Controller.MouseX < Bounds[0])
		Value = MinValue;
	else if (Controller.MouseX > Bounds[2])
		Value = MaxValue;

	Value = FClamp(Value,MinValue,MaxValue);

#if IG_TRIBES3 // dbeswick:
	if (LastChangeMessage >= 1)
	{
		LastChangeMessage = 0;
		if (1.0 / UpdateFreq > 0)
			SetTimer(1.0 / UpdateFreq);
		OnChange(self);
	}
#endif

	return true;
}

function bool InternalOnKeyEvent(out byte Key, out byte State, float delta)
{
	if ( (Key==0x25 || Key==0x64) && (State==1) )	// Left
	{
		if (bIntSlider)
			Adjust(-1);
		else
			Adjust(-0.01);
		return true;
	}

	if ( (Key==0x27 || Key==0x66) && (State==1) ) // Right
	{
		if (bIntSlider)
			Adjust(1);
		else
			Adjust(0.01);
		return true;
	}

	return false;
}

function bool InternalOnXControllerEvent(byte Id, eXControllerCodes iCode)
{
 	if (iCode == XC_Left || iCode == XC_PadLeft || iCode == XC_X)
    {
    	Adjust(Step*-1);
        return true;
    }

    else if (iCode == XC_Right || iCode == XC_PadRight || iCode == XC_Y)
    {
    	Adjust(Step);
        return true;
    }

    return false;

}


function Adjust(float amount)
{
	local float Perc;
	Perc = (Value-MinValue) / (MaxValue-MinValue);
	Perc += amount;
	Perc = FClamp(Perc,0.0,1.0);
	Value = ( (MaxValue - MinValue) * Perc) + MinValue;
	FClamp(Value,MinValue, MaxValue);
	OnChange(self);
}

event Click()
{
	Super.Click();
	OnChange(self);
}

function InternalOnMousePressed(GUIComponent Sender)
{
#if IG_TRIBES3 // dbeswick:
	LastChangeMessage = 1;
#endif
	InternalCapturedMouseMove(0,0);
}

#if IG_TRIBES3 // dbeswick:
function Timer()
{
	LastChangeMessage = 1;
}
#endif

cpptext
{
		void Draw(UCanvas* Canvas);

}


defaultproperties
{
     CaptionStyleName="STY_SliderCaption"
     LeftStyleName="STY_SliderLeft"
     RightStyleName="STY_SliderRight"
     ButtonStyleName="STY_SliderButton"
     Step=1.000000
     SliderHeightPercent=1.000000
     ButtonWidthPixels=16.000000
     UpdateFreq=30.000000
     StyleName="sty_sliderstyle"
     WinHeight=0.030000
     bCaptureMouse=True
     bRequireReleaseClick=True
     bTabStop=True
     OnClickSound=CS_Click
}
