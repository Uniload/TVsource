// ====================================================================
//  Class:  GUI.GUI
// 
//  GUI is an abstract class that holds all of the enums and structs
//  for the UI system 
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

class GUI extends Core.Object
	Abstract instanced native;

// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)

enum eProgressDirection
{
    DIRECTION_LeftToRight,
    DIRECTION_RightToLeft,
    DIRECTION_TopToBottom,
    DIRECTION_BottomToTop,
};

// -- These are set at spawn

var(GUIState) Editinline EditConst	GUIController 	Controller "Callback to the GUIController running the show";
	
enum eMenuState		// Defines the various states of a component
{
	MSAT_Blurry,			// Component has no focus at all
	MSAT_Watched,			// Component is being watched (ie: Mouse is hovering over, etc)  
	MSAT_Focused,			// Component is Focused (ie: selected)
	MSAT_Pressed,			// Component is being pressed
	MSAT_Disabled,			// Component is disabled. (ie: greyed out)
};

enum eTextAlign		// Used for aligning text in a box
{
	TXTA_Left,
	TXTA_Center,
	TXTA_Right,
};

enum eTextCase		// Used for forcing case on text
{
	TXTC_None,
	TXTC_Upper,
	TXTC_Lower,
};

enum eImgStyle		// Used to define the style for an image
{
	ISTY_Normal,
	ISTY_Stretched,
	ISTY_Scaled,
	ISTY_Bound,
	ISTY_Justified,
};

enum eImgAlign		// Used for aligning justified images in a box
{
	IMGA_TopLeft,
	IMGA_Center,
	IMGA_BottomRight,
};

enum eEditMask		// Used to define the mask of an input box
{
	EDM_None,
	EDM_Alpha,
	EDM_Numeric,
};

enum EMenuRenderStyle
{
	MSTY_None,
	MSTY_Normal,
	MSTY_Masked,
	MSTY_Translucent,
	MSTY_Modulated,
	MSTY_Alpha,
	MSTY_Additive,
	MSTY_Subtractive,
	MSTY_Particle,
	MSTY_AlphaZ,
};

enum eIconPosition
{
	ICP_Normal,
	ICP_Center,
	ICP_Scaled,
	ICP_Stretched,
	ICP_Bound,
};

enum eXControllerCodes
{
	XC_Up, XC_Down, XC_Left, XC_Right,
    XC_A, XC_B, XC_X, XC_Y,
    XC_Black, XC_White,
    XC_LeftTrigger, XC_RightTrigger,
    XC_PadUp, XC_PadDown, XC_PadLeft, XC_PadRight,
    XC_Start, XC_Back,
    XC_LeftThumb, XC_RightThumb,
};

// these Globals are used for Dialogue popups
var const int     QBTN_Ok;
var const int     QBTN_Cancel;
var const int     QBTN_Retry;
var const int     QBTN_Continue;
var const int     QBTN_Yes;
var const int     QBTN_No;
var const int     QBTN_Abort;
var const int     QBTN_Ignore;
var const int     QBTN_OkCancel;
var const int     QBTN_AbortRetry;
var const int     QBTN_YesNo;
var const int     QBTN_YesNoCancel;
var const int     QBTN_TimeOut;

enum eListElemDisplay
{
    LIST_ELEM_Item,
    LIST_ELEM_ExtraData,
    LIST_ELEM_ExtraStrData,
    LIST_ELEM_ExtraIntData,
    LIST_ELEM_ExtraBoolData,
};

struct GUIListElem
{
	var string item;
	var object ExtraData;
	var string ExtraStrData;
	var int    ExtraIntData;
	var bool   ExtraBoolData;
};

struct ControlSpec
{
    var() config string ClassName "Name of the class to create";
    var() config string ObjName "Name of the object to be created";
};

static function GUIListElem CreateElement( optional string NewItem, optional Object obj, optional string Str, optional int intData, optional bool bData)
{
    local GUIListElem newElem;

	newElem.Item=NewItem;
	newElem.ExtraData=obj;
	newElem.ExtraStrData=Str;
	newElem.ExtraIntData=intData;
	newElem.ExtraBoolData=bData;

    return newElem;
}

native function CopyConfig( GUIComponent Ctrl );
native function String StripCodes( String InStr );
native function String MakeColorCode( Color clr );

#if IG_TRIBES3	// michaelj:  Integrated UT2004 GUI function
// GUI-wide utility functions
static function bool IsDigit( string Test, optional bool bAllowDecimal )
{
	if ( Test == "" )
		return false;

	while ( Test != "" )
	{
		if ( Asc(Left(Test,1)) > 57 )
			return false;
		if ( Asc(Left(Test,1)) < 48 && !(bAllowDecimal && Left(Test,1) == ".") )
			return false;
		Test = Mid(Test,1);
	}

	return true;
}
#endif

cpptext
{
        virtual void CopyConfig(UGUI* toOther);           // copy the config of this to another component
        static FString StripCodes( FString instr );
        static FString MakeColorCode( FColor theColor );
        
        static int CharToHex( char c );
        static char HexToChar( int i );

}


defaultproperties
{
     QBTN_Ok=1
     QBTN_Cancel=2
     QBTN_Retry=4
     QBTN_Continue=8
     QBTN_Yes=16
     QBTN_No=32
     QBTN_Abort=64
     QBTN_Ignore=128
     QBTN_OkCancel=3
     QBTN_AbortRetry=68
     QBTN_YesNo=48
     QBTN_YesNoCancel=50
     QBTN_TimeOut=256
}
