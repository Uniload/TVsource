//-----------------------------------------------------------
//
//-----------------------------------------------------------
class staticFunctions extends Core.Object abstract;
import enum EHorizontalAlignment from TribesGUI.HUDElement;
import enum EVerticalAlignment from TribesGUI.HUDElement;

static function calculateHUDElementStartingPosition(HUDElement e, bool setVal, optional out float outX, optional out float outY)
{
   /*
    e.ParentElement
    e.screenWidth;
    e.screenHeight;
    e.offsetX;
    e.offsetY;
    e.horizontalAlignment;
    e.horizontalFill;
    e.verticalAlignment;
    e.verticalFill;
    e.width;
    e.height;
    */

    local float X;
    local float Y;
    X=0;
    Y=0;

    if(e.ParentElement!=none)
    {
        calculateHUDElementStartingPosition(e.ParentElement, true);

        //log(e.name $ " have horizontalAlignment=" $ e.horizontalAlignment $ " and verticalAlignment=" $ e.verticalAlignment, 'calculateHUDElementStartingPosition');

        switch(e.horizontalAlignment)
        {
            case EHorizontalAlignment.HALIGN_Left:
                 X=e.ParentElement.posX + e.ParentElement.offsetX + e.offsetX;
                 break;
            case EHorizontalAlignment.HALIGN_Center:
                 X=e.ParentElement.posX + e.ParentElement.offsetX + e.offsetX + (e.ParentElement.width / 2) - (e.width / 2);
                 break;
            case EHorizontalAlignment.HALIGN_Right:
                 X=e.ParentElement.posX + e.ParentElement.offsetX + e.ParentElement.width + e.offsetX - e.width;
                 break;
            /*
            case EHorizontalAlignment.HALIGN_None: break;
        	case EHorizontalAlignment.HALIGN_Relative: break;
        	case EHorizontalAlignment.HALIGN_Previous: break;
    	    case EHorizontalAlignment.HALIGN_Next: break;
            */
        }

        switch(e.verticalAlignment)
        {
            case EVerticalAlignment.VALIGN_Top:
                 Y=e.ParentElement.posY + e.ParentElement.offsetY + e.offsetY;
                 break;
            case EVerticalAlignment.VALIGN_Middle:
                 Y=e.ParentElement.posY + e.ParentElement.offsetY + e.offsetY + (e.ParentElement.height / 2) - (e.height / 2);
                 break;
            case EVerticalAlignment.VALIGN_Bottom:
                 Y=e.ParentElement.posY+e.ParentElement.offsetY + e.ParentElement.height + e.offsetY - e.height;
                 break;
            /*
            case EVerticalAlignment.VALIGN_None: break;
        	case EVerticalAlignment.VALIGN_Relative: break;
        	case EVerticalAlignment.VALIGN_Previous: break;
        	case EVerticalAlignment.VALIGN_Next: break;
            */
        }
    }
    else
    {//no Parent Element, using screen size

        //log(e.name $ " have horizontalAlignment=" $ e.horizontalAlignment $ " and verticalAlignment=" $ e.verticalAlignment $" and have no parents", 'calculateHUDElementStartingPosition');

        switch(e.horizontalAlignment)
        {
            case EHorizontalAlignment.HALIGN_Left:
                 X=e.offsetX;
                 break;
            case EHorizontalAlignment.HALIGN_Center:
                 X=(e.screenWidth / 2) + e.offsetX - (e.width / 2);
                 break;
            case EHorizontalAlignment.HALIGN_Right:
                 X=e.screenWidth + e.offsetX - e.width;
                 break;
            /*
            case EHorizontalAlignment.HALIGN_None: break;
        	case EHorizontalAlignment.HALIGN_Relative: break;
        	case EHorizontalAlignment.HALIGN_Previous: break;
    	    case EHorizontalAlignment.HALIGN_Next: break;
            */
        }

        switch(e.verticalAlignment)
        {
            case EVerticalAlignment.VALIGN_Top:
                 Y=e.offsetY;
                 break;
            case EVerticalAlignment.VALIGN_Middle:
                 Y=(e.screenHeight / 2) + e.offsetY - (e.height / 2);
                 break;
            case EVerticalAlignment.VALIGN_Bottom:
                 Y=e.screenHeight + e.offsetY - e.height;
                 break;
            /*
            case EVerticalAlignment.VALIGN_None: break;
        	case EVerticalAlignment.VALIGN_Relative: break;
        	case EVerticalAlignment.VALIGN_Previous: break;
        	case EVerticalAlignment.VALIGN_Next: break;
            */
        }
        e.SetWidth(e.screenWidth);
        e.SetHeight(e.screenHeight);
    }

    if(setVal)
    {
        e.posX=X;
        e.posY=Y;
    }

    //log("Position for " $ e.name $ " have been set to : X=" $ X $ " , Y=" $ Y, 'calculateHUDElementStartingPosition');

    outX=X;
    outY=Y;
}

static function removeElement(HUDContainer c, HUDElement e)
{
    local int i;
    i = whereIsElement(c,e);
    if(i>=0)
        c.RemoveElementAt(i);
}

static function int whereIsElement(HUDContainer c, HUDElement e)
{
    local int i;

	for(i = 0; i < c.children.Length; ++i)
	{
		if(c.children[i] == e)
			return i;
	}

	return -1;
}

static function string leadingZeros(int value, int MinDisplayDigits)
{
    local string res;
    local int paddingCount, i;

    res $= value;
    paddingCount = MinDisplayDigits - Len(res);
    for(i = 0; i < paddingCount; i++)
        res = "0" $ res;
    return(res);
}

defaultproperties
{
}
