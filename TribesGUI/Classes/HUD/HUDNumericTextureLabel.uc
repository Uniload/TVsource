class HUDNumericTextureLabel extends HUDElement
	native;

var() config Material FontMaterial;
var() config Array<int> DigitWidths;
var() config Array<int> TrailingSpaces;
var() config Color TextColor;
var() config int DigitHeight;
var() config bool bCenterText;

var private String Data;
var private Array<int> DigitIndex;

native function SetDataString(String NewData);

CPPTEXT
{
	// Internal Native RenderElement function.
	virtual void RenderElement(UCanvas *canvas);
}

defaultproperties
{
	FontMaterial=Texture'HUD.Numbers'
	DigitHeight=12
	TrailingSpaces(0)=3
	DigitWidths(0)=12
	TextColor=(R=255,G=255,B=255,A=255)
}
