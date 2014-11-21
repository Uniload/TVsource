//-----------------------------------------------------------
//
//-----------------------------------------------------------
class TribesTVStudioMenuInteraction extends Interaction;

#exec texture IMPORT NAME=tviIcon FILE=Textures/Icon.pcx GROUP="MENU" MIPS=ON FLAGS=2 MASKED=1

#exec texture IMPORT NAME=tviCamPov FILE=Textures/pov.pcx GROUP="MENU" MIPS=ON FLAGS=2 MASKED=1
#exec texture IMPORT NAME=tviCamFree FILE=Textures/free.pcx GROUP="MENU" MIPS=ON FLAGS=2 MASKED=1
#exec texture IMPORT NAME=tviCamChase FILE=Textures/chase.pcx GROUP="MENU" MIPS=ON FLAGS=2 MASKED=1
#exec texture IMPORT NAME=tviCamChaseRot FILE=Textures/chaserot.pcx GROUP="MENU" MIPS=ON FLAGS=2 MASKED=1
#exec texture IMPORT NAME=tviCamGeneral FILE=Textures/cam-general.pcx GROUP="MENU" MIPS=ON FLAGS=2 MASKED=1

#exec texture IMPORT NAME=tviTargetVC FILE=Textures/targets-vc.pcx GROUP="MENU" MIPS=ON FLAGS=2 MASKED=1
#exec texture IMPORT NAME=tviTargetBlue FILE=Textures/targets-blue.pcx GROUP="MENU" MIPS=ON FLAGS=2 MASKED=1
#exec texture IMPORT NAME=tviTargetRed FILE=Textures/targets-red.pcx GROUP="MENU" MIPS=ON FLAGS=2 MASKED=1
#exec texture IMPORT NAME=tviTargetRedFlag FILE=Textures/targets-redflag.pcx GROUP="MENU" MIPS=ON FLAGS=2 MASKED=1
#exec texture IMPORT NAME=tviTargetBlueFlag FILE=Textures/targets-blueflag.pcx GROUP="MENU" MIPS=ON FLAGS=2 MASKED=1
#exec texture IMPORT NAME=tviTargetBomb FILE=Textures/targets-bomb.pcx GROUP="MENU" MIPS=ON FLAGS=2 MASKED=1

#exec texture IMPORT NAME=tviMirrorGeneral FILE=Textures/mirror-general.pcx GROUP="MENU" MIPS=ON FLAGS=2 MASKED=1
#exec texture IMPORT NAME=tviMirrorOff FILE=Textures/mirror-off.pcx GROUP="MENU" MIPS=ON FLAGS=2 MASKED=1

#exec texture IMPORT NAME=tviVC5Sec FILE=Textures/vc-5sec.pcx GROUP="MENU" MIPS=ON FLAGS=2 MASKED=1
#exec texture IMPORT NAME=tviVCSearch FILE=Textures/vc-search.pcx GROUP="MENU" MIPS=ON FLAGS=2 MASKED=1
#exec texture IMPORT NAME=tviVCFlag FILE=Textures/vc-flagrun.pcx GROUP="MENU" MIPS=ON FLAGS=2 MASKED=1
#exec texture IMPORT NAME=tviVCBomb FILE=Textures/vc-bomb.pcx GROUP="MENU" MIPS=ON FLAGS=2 MASKED=1

#exec texture IMPORT NAME=tviOptWatermark FILE=Textures/opt-watermark.pcx GROUP="MENU" MIPS=ON FLAGS=2 MASKED=1
#exec texture IMPORT NAME=tviOptNotext FILE=Textures/opt-notext.pcx GROUP="MENU" MIPS=ON FLAGS=2 MASKED=1
#exec texture IMPORT NAME=tviOptNextedge FILE=Textures/opt-nextedge.pcx GROUP="MENU" MIPS=ON FLAGS=2 MASKED=1

#exec texture IMPORT NAME=tviClose FILE=Textures/close.pcx GROUP="MENU" MIPS=ON FLAGS=2 MASKED=1

var float OriginX, OriginY;
var float Margin, Tab;
var float LineSize;
var int LineSpace;
var TribesTVStudioMenuItem backitem;
var bool mouseClick;		//Sets to true on mouseclick
var bool needClose;
var bool needUpdate;		//Hack for running updatemenu more often

var float IconMargin;
var int IconsPerRowH;
var float SideMargin;

var bool visible;

var bool showText;
var bool showIcons;
var int iconBorder;			//0=down, 1=top, 2=left, 3=right
var int newIconBorder;
//var bool nomouse;

var TribesTVStudioMenuItem menu;   	//Points to the root
var TribesTVStudioMenuItem curMenu;	//Points to the currently active

var string Title;

var TribesTVStudioTestController tvc;
var bool bIgnoreKeys;

function setControllerOwner (TribesTVStudioTestController t)
{
	tvc = t;
}

//do nothing when not active
function Timer ()
{
}

state MenuVisible {

	function bool KeyType( EInputKey Key, optional string Unicode )
	{
		if (bIgnoreKeys)
			return true;

		return false;
	}

	function bool KeyEvent( EInputKey Key, EInputAction Action, FLOAT Delta )
	{

		if (Action == IST_Press)
			bIgnoreKeys=false;

		if (showIcons) {
			//Steal mouse movement
			if (Action == IST_Axis)
				return true;

			//Handle mouseclicks
			if (Key == IK_LeftMouse) {
				if (Action == IST_Press) {
					mouseCLick = true;
				}
				return true;
			}
		}

		if (Action != IST_Press)
			return false;

		//don't handle keys if we're not showing text menu
		if (!showText)
			return false;

		if (Key == IK_Escape)
		{
			return HandleInput (-1);
		}
		if (Key == IK_Space)
		{
			return HandleInput(100);
		}

		switch (Key) {
			case IK_1: return HandleInput (1);
			case IK_2: return HandleInput (2);
			case IK_3: return HandleInput (3);
			case IK_4: return HandleInput (4);
			case IK_5: return HandleInput (5);
			case IK_6: return HandleInput (6);
			case IK_7: return HandleInput (7);
			case IK_8: return HandleInput (8);
			case IK_9: return HandleInput (9);
			case IK_0: return HandleInput (10);
			case IK_A: return HandleInput (11);
			case IK_B: return HandleInput (12);
			case IK_C: return HandleInput (13);
			case IK_D: return HandleInput (14);
			case IK_E: return HandleInput (15);
			case IK_F: return HandleInput (16);
			case IK_G: return HandleInput (17);
			case IK_H: return HandleInput (18);
			case IK_I: return HandleInput (19);
			case IK_J: return HandleInput (20);
			case IK_K: return HandleInput (21);
			case IK_L: return HandleInput (22);
			case IK_M: return HandleInput (23);
			case IK_N: return HandleInput (24);
			case IK_O: return HandleInput (25);
			case IK_P: return HandleInput (26);
			case IK_Q: return HandleInput (27);
			case IK_R: return HandleInput (28);
			case IK_S: return HandleInput (29);
			case IK_T: return HandleInput (30);
			case IK_U: return HandleInput (31);
			case IK_V: return HandleInput (32);
			case IK_W: return HandleInput (33);
			case IK_X: return HandleInput (34);
			case IK_Y: return HandleInput (35);
			case IK_Z: return HandleInput (36);
		}

		return false;
	}

	//Returns a 1 character representation of the number for the menu (1-36 ok)
	function string GetNumText (int nr)
	{
		if (nr < 10)
			return string (nr);
		if (nr == 10)
			return "0";
		return chr (asc ("A") + (nr - 11));
	}

	function bool isMouseInBox (int x, int y, int xs, int ys)
	{
		return ((ViewPortOwner.WindowsMouseX >= x) &&
  				(ViewPortOwner.WindowsMouseX < x + xs) &&
  				(ViewPortOwner.WindowsMouseY >= y) &&
  				(ViewPortOwner.WindowsMouseY < y + ys));
	}

	function bool isMouseInRelBox (canvas canvas, float x, float y, float xs, float ys)
	{
		return isMouseInBox (x * Canvas.ClipX, y * canvas.ClipY, xs * canvas.ClipX, ys * canvas.ClipY);
	}

	function DrawCurrentArray( canvas Canvas, bool sizing, out float XMax, out float YMax )
	{
		local int i;
		local float XPos, YPos;
		local float XL, YL;
		local TribesTVStudioMenuItem cur;

		XPos = (Canvas.ClipX * (OriginX+Margin));
		YPos = Canvas.ClipY * (OriginY+Margin);
		Canvas.SetDrawColor(255,255,255,255);

		i = 1;

		//Add the back option
		if (curMenu != menu) {
			cur = backItem;
			backItem.next = curMenu;
		} else {
			cur = curMenu;
		}

		while (cur != none)
		{
			if (!cur.icononly) {
				Canvas.SetPos(XPos, YPos);
				if(!sizing) {

					if (showIcons && (isMouseInBox (Xpos, Ypos, XMax - (Margin * Canvas.ClipX), LineSpace))) {
						Canvas.SetDrawColor (255, 255, 255, 255);
						//menu.butgrip menu.buttonbob
						Canvas.DrawRect (texture 'InterfaceContent.Menu.ButtonBob', XMax - (Margin * Canvas.ClipX), LineSpace);
						//Canvas.DrawTileStretched(texture 'InterfaceContent.SPMenu.SP_Final', XMax - (Margin * Canvas.ClipX), LineSpace);

						if (mouseClick) {
							HandleItem (cur);
						}
					}

					Canvas.SetPos(XPos, YPos);
					Canvas.SetDrawColor(128,255,128,255);
					Canvas.DrawText(GetNumText(i)$"-", false);

					if (cur.mstate == TribesTVStudio_On)      //active
						Canvas.SetDrawColor(0,255,0,255);
					if (cur.mstate == TribesTVStudio_Off)      //inactive
						Canvas.SetDrawColor(255,0,0,255);
					if (cur.mstate == TribesTVStudio_None)      //neither
						Canvas.SetDrawColor(255,255,255,255);

					Canvas.SetPos(XPos + tab, YPos);
					Canvas.DrawText(cur.text, false);
				}
				else {
					Canvas.TextSize(cur.text, XL, YL);
					XMax = Max(XMax, XPos + XL + Tab);
					YMax = Max(YMax, YPos + YL);
				}

				YPos += LineSpace;
				i++;				
			}
			cur = cur.next;
		}
	}

	function HorizTextSize (canvas Canvas, string text, out float xs, out float ys)
	{
		local int i;
		local float xl, yl;
	
		xs = 0;
		ys = 0;
		
		Canvas.TextSize ("W", xs, yl);
		Canvas.TextSize ("a", xl, yl);
		ys = yl * len (text);		
		ys /= 1.5;
	}

	function HorizDrawText (canvas Canvas, string text)
	{
		local int i;
		local string c;
		local float xs, ys;
		local float x, y;
		local float xl, yl;
		
		Canvas.TextSize ("W", xs, ys);		
		x = Canvas.CurX;
		y = Canvas.CurY;
		ys /= 1.5;
		
		for (i = 0; i < Len (text); ++i) {
			c = Mid (text, i, 1);
			Canvas.TextSize (c, xl, yl);
			Canvas.SetPos (x + (xs - xl) / 2.0, y);
			Canvas.DrawText (c);
			y += ys;
		}
	}

	function PostRender( canvas Canvas )
	{
		local float XL, YL, x, y;
		local float XMax, YMax;
		local int i, j;
		local int numrows;
		local int perrow;
		local int NumOptions;
		local TribesTVStudioMenuItem cur;
		local string hint;
		
		local int IconsPerRow;								//Updated to be either for horizontal or vertical
		local float scaleW, scaleH;							//compensates for the aspect ration
		local float iconWidth, iconHeight;					//Calculatewd width and height of the icon menu
		local float iconMarginW, iconMarginH;				//same as above for the margins
		local float sideMarginW, sideMarginH;
		local float iconSpaceW, iconSpaceH;
		local float iconSpaceX, iconSpaceY;					//Non-rotated spaces..
		local float iconMarginX, iconMarginY;
		local float IconScale;
		local float IconX, IconY;							//Saves calculations
		local bool WasInside;								//True if an icon was highlighted

		if (!visible)
			return;

   		Canvas.Style = tvc.ERenderStyle.STY_Alpha;		

		Canvas.Font = class'UT2MidGameFont'.static.GetMidGameFont(Canvas.ClipX); // Update which font to use.
		iconBorder = newIconBorder;

		if (showText) {

			Canvas.TextSize("10-", XL, YL);
			LineSpace = YL * 1.1;
			Tab = XL;

			// First we figure out how big the bounding box needs to be
			XMax = 0;
			YMax = 0;
			DrawCurrentArray( canvas, true, XMax, YMax);
			Canvas.TextSize(Title, XL, YL);
			XMax = Max(XMax, Canvas.ClipX*(OriginX+Margin) + XL);
			YMax = Max(YMax, (Canvas.ClipY*OriginY) - (1.2*LineSpace) + YL);
			// XMax, YMax now contain to maximum bottom-right corner we drew to.

			// Then draw the box
			XMax -= Canvas.ClipX * OriginX;
			YMax -= Canvas.ClipY * OriginY;
			Canvas.SetDrawColor(255,255,255,255);
			Canvas.SetPos(Canvas.ClipX * OriginX, Canvas.ClipY * OriginY);
			Canvas.DrawTileStretched(texture 'InterfaceContent.Menu.BorderBoxD', XMax + (Margin*Canvas.ClipX), YMax + (Margin*Canvas.ClipY));

			// Then actually draw the stuff
			DrawCurrentArray( canvas, false, XMax, YMax);

			// Finally, draw a nice title bar.
			Canvas.SetDrawColor(255,255,255,255);
			Canvas.SetPos(Canvas.ClipX*OriginX, (Canvas.ClipY*OriginY) - (1.5*LineSpace));
			Canvas.DrawTileStretched(texture 'InterfaceContent.Menu.BorderBoxD', XMax + (Margin*Canvas.ClipX), (1.5*LineSpace));

			Canvas.SetDrawColor(255,255,128,255);
			Canvas.SetPos(Canvas.ClipX*(OriginX+Margin), (Canvas.ClipY*OriginY) - (1.2*LineSpace));
			Canvas.DrawText(Title);
		}
		
		//If only the text menu is to be used, do final processing and exit
		if (!showIcons) {
			mouseClick = false;		
			if (needUpdate) {
				needUpdate = false;
				UpdateMenu ();
			}			
			if (needClose)
				GotoState ('');
			return;
		}

		//The icon menu:

		//Find total number of rows needed
		numoptions = 0;
		cur = menu;
		while (cur != none) {
			if (cur.icon != none)
				NumOptions++;
			cur = cur.Iterate ();
		}

        //We now have the total number of icons to display, calculated the needed rows (or columns)
        //depending on docking
        if (iconBorder < 2) {
        	IconsPerRow = IconsPerRowH;
        	ScaleW = 1;
        	ScaleH = Canvas.ClipX / Canvas.ClipY;
        }
        else {
        	ScaleW = Canvas.ClipX / Canvas.ClipY; //vände
        	ScaleH = 1;
        	IconsPerRow = (IconsPerRowH / ScaleW) + 1;
        }
        	
		i = NumOptions;
		numrows = 1;
		while (i > IconsPerRow) {
			i -= IconsPerRow;
			numrows++;
		}

		//Icons per row/column
		perrow = (numoptions / numrows);
		if (perrow * numrows < numoptions)
			perrow++;

		//Update some variables to compensate for docking
		IconMarginW = IconMargin * ScaleW;
		IconMarginH = IconMargin * ScaleH * 2;      	//Blir bättre med *2 av nån anledning :)
		SideMarginW = SideMargin * ScaleW;
		SideMarginH = SideMargin * ScaleH;

		IconWidth = (float(PerRow) / float(IconsPerRow));      //former XMax
		IconSpaceW = ((IconWidth - SideMarginW*2.0) / float(PerRow)) - (IconMarginW * 2.0);
		
		if (iconBorder < 2) {
			IconSpaceH = IconSpaceW * scaleH;
			IconSpaceX = IconSpaceW;
			IconSpaceY = IconSpaceH;
			IconMarginX = IconMarginW;
			IconMarginY = IconMarginH;
		}
		else {
			IconSpaceH = IconSpaceW / ScaleW;
			IconSpaceX = IconSpaceH;
			IconSpaceY = IconSpaceW;			
			IconMarginX = IconMarginH;
			IconMarginY = IconMarginW;			
		}

		//former ymax
		IconHeight = ((IconSpaceH + IconMarginH) * float(numrows)) + (SideMarginH * 2.0) - IconMarginH;

        //Log ("iconspace: " $ iconspace $ " - iconscale: " $ iconscale);

		Canvas.SetDrawColor (255, 255, 255, 255);
		
		//Position the icon menu according to current docking
		switch (iconBorder) {
			case 0: iconx = 0.5 - (IconWidth / 2); icony = 1 - IconHeight; break;
			case 1: iconx = 0.5 - (IconWidth / 2); icony = 0; break;
			case 2: iconx = 0; icony = 0.5 - (IconWidth / 2); break;
			case 3: iconx = 1 - IconHeight; icony = 0.5 - (IconWidth / 2); break;
		
/*			case 0: Canvas.SetPos ((0.5 - (IconWidth / 2)) * Canvas.ClipX, (1 - IconHeight) * Canvas.ClipY); break;
			case 1: Canvas.SetPos ((0.5 - (IconWidth / 2)) * Canvas.ClipX, 0); break;
			case 2: Canvas.SetPos (0, (0.5 - (IconWidth / 2)) * Canvas.ClipY); break;
			case 3: Canvas.SetPos ((1 - IconHeight) * Canvas.ClipX, (0.5 - (IconWidth / 2)) * Canvas.ClipY); break; */
		}
		Canvas.SetPos (iconX * Canvas.Clipx, icony * canvas.clipy);		
		
		//and draw either horisontally or vertically
		if (iconBorder < 2)
			Canvas.DrawTileStretched (texture'InterfaceContent.Menu.BorderBoxD', IconWidth * Canvas.ClipX, IconHeight * Canvas.ClipY);
		else
			Canvas.DrawTileStretched (texture'InterfaceContent.Menu.BorderBoxD', IconHeight * Canvas.ClipX, IconWidth * Canvas.ClipY);


        //Now the background panel is drawn, continue with the icons
			
		cur = menu;
		j = 0;
		
		//Calculate the starting position for the drawing (x, y in "absolute" coordinates)
		switch (iconBorder) {
			case 0: x = (0.5 - (IconWidth / 2)) + SideMarginW; y = (1 - IconHeight) + SideMarginH; break;
			case 1: x = (0.5 - (IconWidth / 2)) + SideMarginW; y = SideMarginH; break;
			case 2: x = SideMarginH; y = (0.5 - (IconWidth / 2)) + SideMarginW; break;
			case 3: x = (1 - IconHeight) + SideMarginH; y = (0.5 - (IconWidth / 2)) + SideMarginW; break;
		}

		WasInside = false;		
		for (i = 0; i < numoptions; ++i) {
			while ((cur != none) && (cur.icon == none))			//First check should not really be needed
				cur = cur.Iterate ();

			if (isMouseInRelBox (canvas, x, y, IconSpaceX, IconSpaceY)) {
				WasInside = true;
				Canvas.SetPos ((x - IconMarginX) * Canvas.ClipX, (y - IconMarginY) * Canvas.ClipY);
				Canvas.SetDrawColor (255, 255, 255, 255);
				canvas.DrawRect (texture 'editor.badhighlight', (IconSpaceX + IconMarginX * 2.0) * Canvas.ClipX, (IconSpaceY + IconMarginY * 2.0) * Canvas.ClipY);

				if (mouseClick) {
					HandleItem (cur);
				}

				//Draw a hint
				hint = cur.text;
				if (cur.parent != none)
					hint = cur.parent.text $ " - " $ hint;

				if (iconBorder < 2) {
					Canvas.TextSize(hint, XL, YL);
					xl += (SideMarginW * 2.0) * Canvas.ClipX;
					yl += (SideMarginH * 2.0) * Canvas.ClipY;
				}
				else {
					HorizTextSize(Canvas, hint, XL, YL);
					xl += (SideMarginH * 2.0) * Canvas.ClipX;
					yl += (SideMarginW * 2.0) * Canvas.ClipY;				
				}
				
				Canvas.SetDrawColor(255,255,255,255);
				switch (iconBorder) {
					case 0:	Canvas.SetPos ((0.5 - (IconWidth / 2)) * Canvas.ClipX, (1 - IconHeight) * Canvas.ClipY - yl); break;
					case 1:	Canvas.SetPos ((0.5 - (IconWidth / 2)) * Canvas.ClipX, (IconHeight) * Canvas.ClipY); break;
					case 2: Canvas.SetPos (IconHeight * Canvas.ClipX, (0.5 - (IconWidth / 2)) * Canvas.ClipY); break;
					case 3: Canvas.SetPos ((1 - IconHeight) * Canvas.ClipX - xl, (0.5 - (IconWidth / 2)) * Canvas.ClipY); break;
				}
				Canvas.DrawTileStretched(texture 'InterfaceContent.Menu.BorderBoxD', xl, yl);

				Canvas.SetDrawColor(255,255,128,255);
				Canvas.SetPos (Canvas.CurX + (SideMarginW * Canvas.ClipX), Canvas.CurY + (SideMarginH * Canvas.ClipY));
				if (iconborder < 2)
					Canvas.DrawText (hint); 
				else
					HorizDrawText (Canvas, hint);
			}
		
			Canvas.SetPos (x * Canvas.clipx, y * Canvas.ClipY);

			if (cur.mstate == TribesTVStudio_Off) {
				Canvas.SetDrawColor (128, 128, 128, 255);
			}
			else {
				Canvas.SetDrawColor (255, 255, 255, 255);
			}
										
			if (iconBorder < 2)
				IconScale = (IconSpaceW * Canvas.ClipX) / float(cur.icon.USize);			
			else
				IconScale = (IconSpaceH * Canvas.ClipX) / float(cur.icon.USize);			 
//			cur.icon.bMasked = true;
			Canvas.DrawIcon (cur.icon, IconScale);
				
			cur = cur.Iterate ();
			j++;
			
			switch (iconBorder) {
				case 0: 
				case 1: x += IconSpaceW + IconMarginW * 2.0; break;
				case 2: 
				case 3: y += IconSpaceW + IconMarginW * 2.0; break;
			}
			
			//New row?
			if (j >= perrow) {
				j = 0;
				switch (iconBorder) {
					case 0: 
					case 1: x = (0.5 - (IconWidth / 2)) + SideMarginW; y += IconSpaceH + IconMarginH; break;
					case 2:
					case 3: y = (0.5 - (IconWidth / 2)) + SideMarginW; x += IconSpaceH + IconMarginH; break;
				}
				if ((i + perrow) >= numoptions) {
					switch (iconBorder) {
						case 0:
						case 1: x += IconSpaceW / 2.0; break;
						case 2:
						case 3: y += IconSpaceW / 2.0; break;
					}					
				}
			}
			
		}

		//Check if the mouse is inside the panel (but outside any clickable thing)
/*		
		if (!WasInside) {
			if (iconBorder < 2) {
				xl = IconWidth; yl = IconHeight;
			}
			else {
				yl = IconWidth; xl = IconHeight;
			}
				
			if (isMouseInRelBox (canvas, iconx, icony, xl, yl)) {
				Canvas.SetPos (iconx * Canvas.ClipX, icony * Canvas.ClipY);
				Canvas.SetDrawColor (255, 64, 64, 255);
				Canvas.DrawTileStretched(texture 'InterfaceContent.Menu.BorderBoxD', xl * Canvas.ClipX, yl * Canvas.ClipY);				
			}
		} */

		//Finally draw a mouse cursor
		Canvas.SetDrawColor(255,255,255,255);
		Canvas.SetPos(ViewPortOwner.WindowsMouseX, ViewPortOwner.WindowsMouseY);
		Canvas.DrawIcon (texture 'InterfaceContent.Menu.MouseCursor', 1);

		if (needUpdate) {
			needUpdate = false;
			UpdateMenu ();
		}

		//Clicks are only valid one frame
		mouseClick = false;
		if (needClose)
			GotoState ('');
	}

	function bool HandleInput (int key)
	{
		local int i;
		local TribesTVStudioMenuItem cur;

		//Check for "back" (only works with 1 depth menus atm.. probably enough)
		if (menu == curMenu) {
			if (key == 100) {
				gotoState ('');
				return true;
			}
		}
		else {
			if ((key == 100) || (key == 1)) {
				curMenu = menu;
				return true;
			}
		}

		//Check for "close" (esc)
		if (key == -1) {
			GotoState ('');
			return true;
		}

		//Otherwise, check the actual item selected
		cur = curMenu;
		if (curMenu == menu)
			i = 1;
		else
			i = 2;

		for (i = i; i < key; ++i) {  	//Leaving i = i empty doesn't compile..
			cur = cur.next;
			if (cur == none)
				return false;			//Keypress outside the current range
		}

		HandleItem (cur);

		return true;
	}

	//Handles a click on an item (either by the key menu or the mouse menu)
	function HandleItem (TribesTVStudioMenuItem item)
	{
		//tvc.clientmessage ("Handling " $ item.text);

		//Submenu?
		if (item.child != none) {
			curMenu = item.child;
			return;
		}

		//Back?
		if (item == backitem) {
			curMenu = menu;
			return;
		}

		switch (item.hid) {
			case 1:			//Camera mode
				tvc.SetCamMode (item.lid);
				break;
			case 2:			//Target menu
				if (item.lid == 3)
					tvc.forcedTarget = "";
				else
					tvc.forcedTarget = item.text;
				tvc.FindCameraTarget();
				if(tvc.camTarget!=none)
					tvc.camTargetPos=tvc.camTarget.location;
				tvc.Timer();
				break;
			case 3:			//Meta camera menu
				switch (item.lid) {
					case 1: visible = !visible; break;
					case 2: tvc.SetMetaCamera (""); break;
					case 3: tvc.SetMetaCamera (item.text); break;
				}
				break;
			case 4:			//View controller menu
				if (item.mstate == TribesTVStudio_On) {
					tvc.setViewSelector (item.lid, false);
					item.mstate = TribesTVStudio_Off;
				}
				else {
					tvc.setViewSelector (item.lid, true);
					item.mstate = TribesTVStudio_On;
				}
				break;
			case 5:			//Options menu
				switch (item.lid) {
					case 1:
						if (item.mstate == TribesTVStudio_On) {
							tvc.tvh.showWatermark = false;
							item.mstate = TribesTVStudio_Off;
						}
						else {
							tvc.tvh.showWatermark = true;
							item.mstate = TribesTVStudio_On;
						}
						break;
					case 2:
						if (item.mstate == TribesTVStudio_On) {
							showIcons = false;
							item.mstate = TribesTVStudio_Off;
						}
						else {
							showIcons = true;
							item.mstate = TribesTVStudio_On;
						}
						break;
					case 3:
						if (item.mstate == TribesTVStudio_On) {
							showText = true;
							item.mstate = TribesTVStudio_Off;
						}
						else {
							showText = false;
							item.mstate = TribesTVStudio_On;
						}
						break;
					case 4:
						newIconBorder++;
						if (newIconborder > 3)
							newIconBorder = 0;
						break;					
				}
				break;
			case 6:			//Close
				needClose = true;
				break;
		}
		
		needUpdate = true;
	}

	function TribesTVStudioMenuItem CreateItem (string text, optional int hid, optional int lid, optional texture icon)
	{
		local TribesTVStudioMenuItem tmp;

		tmp = new class'TribesTVStudioMenuItem';
		tmp.text = text;
		tmp.hid = hid;
		tmp.lid = lid;
		tmp.icon = icon;
/*		if (icon == none)
			tmp.icon = texture'tviIcon'; */

		return tmp;
	}

	//Updates and add entries as necessary
	//Should be called often
	function UpdateMenu ()
	{
		local PlayerReplicationInfo con;
		local TribesTVStudioMenuItem cur, tmp, tmp2;
		local bool updcur;
		local int i;
		local texture tex;

		cur = menu;
		while (cur != none) {
			switch (cur.hid) {

				case 1:				//Camera menu
					tmp = cur.child;
					while (tmp != none) {
						if (tmp.lid == tvc.camSysMode)
							tmp.mstate = TribesTVStudio_On;
						else
							tmp.mstate = TribesTVStudio_Off;
						tmp = tmp.next;
					}
					break;

				case 2:				//Target menu
					tmp = cur.child;
					updcur = (cur.child == curMenu);

					//Update the playerlist, using existing spots if possible
					//assertion: there is always at least one entry with lid != 2 at the end of the list
					foreach tvc.AllActors(class'PlayerReplicationInfo', con) {
						if(!con.bOnlySpectator) {
							if ((con.team != none) && (con.team.teamindex == 0))
								tex = texture'tviTargetRed';
							else
								tex = texture'tviTargetBlue';

							if (tmp.lid == 2) {
								tmp.text = con.playername;
								tmp.mstate = TribesTVStudio_None;
								tmp.icon = tex;
								tmp = tmp.next;
							} else {
								tmp2 = CreateItem (con.playername, 2, 2);
								cur.child = tmp.addBefore (cur.child, tmp2);
								if (updcur)
									curMenu = cur.child;
							}
						}
					}

				    //If there are any extra playerspots still in the list, remove them
				    while (tmp.lid == 2) {
				    	tmp2 = tmp.next;
				    	cur.child = tmp.deleteHere (cur.child);
						if (updcur)
							curMenu = cur.child;
						tmp = tmp2;
				    }

				    //Now select the active one
				    tmp = cur.child;
				    updcur = false;
				    while (tmp.lid != 3) {
				    	if (tvc.forcedTarget == tmp.text) {
							updcur = true;
							tmp.mstate = TribesTVStudio_On;
				    	}
				    	else {
				    		tmp.mstate = TribesTVStudio_Off;
				    	}
				    	tmp = tmp.next;
				    }
				    //assertion: tmp.lid == 3, which is "let vc decide"
				    if (!updcur) {
				    	tmp.mstate = TribesTVStudio_On;
				    }
				    else {
				    	tmp.mstate = TribesTVStudio_Off;
				    }

					break;

				case 3:				//Meta camera menu
					tmp = cur.child;

					//Start with setting correct state of the "disabled" entry
					tmp = tmp.next;
					if (tvc.mcActive == -1)
						tmp.mstate = TribesTVStudio_On;
					else
						tmp.mstate = TribesTVStudio_Off;

					tmp = tmp.next;		//There is always at least 2 entries in the list

					//Update the cameralist
					for (i = 0; i < 64; ++i) {
						if (tvc.mcNames[i] != "") {
							if (tmp != none) {
								tmp.text = tvc.mcNames[i];
								tmp2 = tmp;
								tmp = tmp.next;
							}
							else {
								tmp2 = CreateItem (tvc.mcNames[i], 3, 3, texture'tviMirrorGeneral');
								cur.child.addNext (tmp2);
							}

							//Set the state
							if (tvc.mcActive == i)
								tmp2.mstate = TribesTVStudio_On;
							else
								tmp2.mstate = TribesTVStudio_Off;
						}
					}

				    //If there are any extra camera spots still in the list, delete them
				    while (tmp != none) {
				    	tmp2 = tmp.next;
				    	cur.child = tmp.deleteHere (cur.child);
						tmp = tmp2;
				    }

					break;
			}
			cur = cur.next;
		}
	}

	//This creates the menu and adds only the static entries
	//The entries that can vary on runtime are added by UpdateMenu
	function CreateMenu ()
	{
		local TribesTVStudioMenuItem cur, tmp;
		local int i;
		local xBlueFlagBase flagbase;
		local xBombFlag bomb;

		//Start with the camera modes
		menu = CreateItem ("Camera mode", 1);
		for (i = 0; i < 6; ++i) {
			if (tvc.sysnames[i] != "") {
				menu.AddChild (CreateItem (tvc.sysnames[i], 1, i, texture'tviCamGeneral'));
			}
		}
		menu.addChild (CreateItem ("Chasecam", 1, 6, texture'tviCamChase'));
		menu.addChild (CreateItem ("Floatcam", 1, 7, texture'tviCamChaseRot'));
		menu.addChild (CreateItem ("POV cam", 1, 8, texture'tviCamPov'));
		menu.addChild (CreateItem ("Free flight", 1, 9, texture'tviCamFree'));

		//Now the target menu
		cur = CreateItem ("Target", 2);
		menu.addNext (cur);
		foreach tvc.AllActors(class'xBlueFlagBase', flagbase) {
			cur.addChild (CreateItem ("Blue Flag", 2, 1, texture'tviTargetBlueFlag'));
			cur.addChild (CreateItem ("Red Flag", 2, 1, texture'tviTargetRedFlag'));
		}
		foreach tvc.AllActors(class'xBombFlag', bomb) {
			cur.addChild (CreateItem ("The Bomb", 2, 1, texture'tviTargetBomb'));
		}
		cur.addChild (CreateItem ("Let VC decide", 2, 3, texture'tviTargetVC'));

		//Metacamera menu
		cur = CreateItem ("Mirror camera", 3);
		menu.addNext (cur);
		cur.addChild (CreateItem ("Hide/show menu", 3, 1));
		cur.addChild (CreateItem ("Disabled", 3, 2, texture'tviMirrorOff'));

		//Viewcontroller
		cur = CreateItem ("View controller", 4);
		menu.addNext (cur);
		for (i = 0; i < 10; ++i) {
			if (tvc.vsNames[i] != "") {
				tmp = CreateItem (tvc.vsNames[i], 4, i, tvc.vsIcons[i]);
				tmp.mstate = TribesTVStudio_Off;
				cur.addChild (tmp);
			}
		}

		//options
		cur = CreateItem ("Options", 5);
		menu.addNext (cur);
		tmp = CreateItem ("Show watermark", 5, 1, texture'tviOptWatermark');
		tmp.mstate = TribesTVStudio_Off;
		cur.addChild (tmp);
		tmp = CreateItem ("Show icon menu", 5, 2);
		tmp.mstate = TribesTVStudio_On;
		cur.addChild (tmp);
		tmp = CreateItem ("Hide text menu", 5, 3, texture'tviOptNotext');
		tmp.mstate = TribesTVStudio_Off;
		tmp.icononly = true;
		cur.addChild (tmp);		
		tmp = CreateItem ("Next docking edge", 5, 4, texture'tviOptNextedge');
		cur.addChild (tmp);

		//Close
		cur = CreateItem ("Close", 6, 0, texture'tviClose');
		menu.addNext (cur);

		//temp

		
		backitem = CreateItem ("Go back");
	}

    function BeginState()
    {
		Log ("TribesTVStudio: interaction begin");
		if (menu == none) {
			CreateMenu ();
		}
		curMenu = menu;
		UpdateMenu ();

		visible = true;
		needClose = false;

		bVisible = True;
		bIgnoreKeys = true;
    }

    function EndState ()
    {
		bVisible = False;
    }
    
    function Timer ()
    {
    	UpdateMenu ();
    }

}

function string GetNextTarget(string curTarget)
{
	local TribesTVStudioMenuItem cur, tmp;
	local string newName;
	local bool first,getNext;

	first=true;
	getNext=false;

	cur = menu;
	while (cur != none) {
		if(cur.hid==2) {			//Target menu
			tmp = cur.child;

			while(tmp!=none){
				if(first){
					newName=tmp.text;
					first=false;
				}
				if(getNext){
					if(tmp.text!="Let VC decide")
						newName=tmp.text;
					getNext=false;
					break;
				}
				if(tmp.text==curTarget)
					getNext=true;

				tmp=tmp.next;
			}
			break;
		}
		cur = cur.next;
	}
	return newName;
}

DefaultProperties
{
	bActive=True

	showText=True
	showIcons=true

    OriginX=0.01
    OriginY=0.3
    Margin=0.015

	IconMargin=0.002
	SideMargin=0.015
	IconsPerRowH=20

    Title="TribesTribesTVStudiotudio"
}
