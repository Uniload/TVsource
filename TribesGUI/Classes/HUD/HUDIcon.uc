class HUDIcon extends HUDElement;

var config HUDMaterial IconMaterial;
var config int	FixedIconWidth;
var config int	FixedIconHeight;

function RenderElement(Canvas c)
{
	local int drawWidth, drawHeight;

	super.RenderElement(c);

	drawWidth = width;
	drawHeight = height;
	if(FixedIconWidth > 0)
		drawWidth = FixedIconWidth;
	if(FixedIconHeight > 0)
		drawHeight = FixedIconHeight;

	RenderHUDMaterial(c, IconMaterial, drawWidth, drawHeight);
}

function SetFixedIconSize(int newWidth, int newHeight)
{
	FixedIconWidth = newWidth;
	FixedIconHeight = newHeight;
}

defaultproperties
{
	IconMaterial=(DrawColor=(R=255,G=255,B=255,A=255),style=1)
}