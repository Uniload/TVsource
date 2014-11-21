class UDebugMenuBar extends UWindow.UWindowMenuBar;

var UWindow.UWindowPulldownMenu Game, RModes, Rend, KDraw, Stats, Show, Player, Options;
var UWindow.UWindowMenuBarItem GameItem, RModesItem, RendItem, KDrawItem, StatsItem, ShowItem, PlayerItem, OptionsItem;
#if IG_SHADOWS	// rowan: shadow debug stuff
var UWindow.UWindowMenuBarItem ShadowItem;
var UWindow.UWindowPulldownMenu Shadows;
#endif

var bool bShowMenu;

function Created()
{
	Super.Created();
	
	GameItem = AddItem("&Game");
	Game = GameItem.CreateMenu(class 'UWindowPulldownMenu');
	Game.MyMenuBar = self;
	Game.AddMenuItem("&Load New Map",none);
	Game.AddMenuItem("-",none);
	Game.AddMenuItem("&Connect to..",none);
	Game.AddMenuItem("-",none);
	Game.AddMenuItem("ScreenShot",none);
	Game.AddMenuItem("Flush",none);
	Game.AddMenuItem("Test GUI",none);
	Game.AddMenuItem("-",none);
	Game.AddMenuItem("E&xit",none);

	RModesItem = AddItem("&Render Modes");
	RModes = RModesItem.CreateMenu(class 'UWindowPulldownMenu');
	RModes.MyMenuBar = self;
	RModes.AddMenuItem("&Wireframe",none);
	RModes.AddMenuItem("&Zones",none);
	RModes.AddMenuItem("&Flat Shaded BSP",none);
	RModes.AddMenuItem("&BSP Splits",none);
	RModes.AddMenuItem("&Regular",none);
	RModes.AddMenuItem("&Unlit",none);
	RModes.AddMenuItem("&Lighting Only",none);
	RModes.AddMenuItem("&Depth Complexity",none);
	RModes.AddMenuItem("-",None);
	RModes.AddMenuItem("&Top Down",None);
	RModes.AddMenuItem("&Front",None);
	RModes.AddMenuItem("&Side",None);

	RendItem = AddItem("Render &Commands");
	Rend = RendItem.CreateMenu(class 'UWindowPulldownMenu');
	Rend.MyMenuBar = self;
	Rend.AddMenuItem("&Blend",none);
	Rend.AddMenuItem("&Bone",none);
	Rend.AddMenuItem("&Skin",none);
#if IG_R // rowan: added by Demiurge Studios
	Rend.AddMenuItem("&Actor Collision",none);
	Rend.AddMenuItem("-",None);
	Rend.AddMenuItem("Volumes &All",none);
	Rend.AddMenuItem("Volumes &None",none);
	Rend.AddMenuItem("Bloc&king Volumes",none);
	Rend.AddMenuItem("&Physics Volumes",none);
#endif // IG
#if IG_TRIBES3	// rowan: render detail settings
	Rend.AddMenuItem("-",None);
	Rend.AddMenuItem("Min Spec (GF4MX)",None);
	Rend.AddMenuItem("Med Spec (GF3)",None);
	Rend.AddMenuItem("Rec Spec (GF4)",None);
	Rend.AddMenuItem("Max Spec (GFFX)",None);
#endif

	StatsItem = AddItem("&Stats");
	Stats = StatsItem.CreateMenu(class 'UWindowPulldownMenu');
	Stats.MyMenuBar = self;
	Stats.AddMenuItem("&All",None);
	Stats.AddMenuItem("&None",None);
	Stats.AddMenuItem("-",None);
	Stats.AddMenuItem("&Render",None);
	Stats.AddMenuItem("&Game",None);
	Stats.AddMenuItem("&Hardware",None);
	Stats.AddMenuItem("Ne&t",None);
	Stats.AddMenuItem("Ani&m",None);

	ShowItem = AddItem("Sho&w Commands");
	Show = ShowItem.CreateMenu(class 'UWindowPulldownMenu');
	Show.MyMenuBar = self;
	Show.AddMenuItem("Show &Actors",None);
	Show.AddMenuItem("Show Static &Meshes",None);
	Show.AddMenuItem("Show &Terrain",None);
	Show.AddMenuItem("Show &Fog",None);
	Show.AddMenuItem("Show &Sky",None);
	Show.AddMenuItem("Show &Coronas",None);
	Show.AddMenuItem("Show &Particles",None);
#if IG_R // rowan: 
	Show.AddMenuItem("Show &Decolayers",None);
#endif
			
	OptionsItem = AddItem("&Options");
	Options = OptionsItem.CreateMenu(class 'UWindowPulldownMenu');
	Options.MyMenuBar = self;
	Options.AddMenuItem("&Video",None);
//	Options.AddMenuItem("&Audio",None);
//	Options.AddMenuItem("&Keys",None);

	KDrawItem = AddItem("&Karma Physics");
	KDraw = KDrawItem.CreateMenu(class 'UWindowPulldownMenu');
	KDraw.MyMenuBar = self;
	KDraw.AddMenuItem("&Collision",none);
	KDraw.AddMenuItem("C&ontacts",none);
	KDraw.AddMenuItem("&Triangles",none);
	KDraw.AddMenuItem("Co&m",none);
	KDraw.AddMenuItem("-",none);
	KDraw.AddMenuItem("KStop",none);
	KDraw.AddMenuItem("KStep",none);

#if IG_SHADOWS	// rowan: shadow debug stuff
	ShadowItem = AddItem("Shadows");
	Shadows = ShadowItem.CreateMenu(class 'UWindowPulldownMenu');
	Shadows.MyMenuBar = self;
	Shadows.AddMenuItem("Debug Shadows", None);
	Shadows.AddMenuItem("-",none);	
	Shadows.AddMenuItem("Toggle Volumes", None);
	Shadows.AddMenuItem("Show Bsp", None);
	Shadows.AddMenuItem("Show Static Mesh", None);
	Shadows.AddMenuItem("Show Terrain", None);
	Shadows.AddMenuItem("-",none);	
	Shadows.AddMenuItem("Toggle Light Passes", None);
	Shadows.AddMenuItem("Bsp Passes", None);
	Shadows.AddMenuItem("Static Mesh Passes", None);
	Shadows.AddMenuItem("Terrain Passes", None);
	Shadows.AddMenuItem("Skeletal Passes", None);
#endif

	bShowMenu = true;
	Spacing = 12;
	
}

function SetHelp(string NewHelpText)
{
}

function ShowHelpItem(UWindow.UWindowMenuBarItem I)
{
}

function BeforePaint(Canvas C, float X, float Y)
{
	Super.BeforePaint(C, X, Y);
}

function DrawItem(Canvas C, UWindow.UWindowList Item, float X, float Y, float W, float H)
{
	C.SetDrawColor(255,255,255);	
	if(UWindowMenuBarItem(Item).bHelp) W = W - 16;

	UWindowMenuBarItem(Item).ItemLeft = X;
	UWindowMenuBarItem(Item).ItemWidth = W;
	LookAndFeel.Menu_DrawMenuBarItem(Self, UWindowMenuBarItem(Item), X, Y, W, H, C);
}

function DrawMenuBar(Canvas C)
{
	local float W, H;
	local string VersionText;
	LookAndFeel.Menu_DrawMenuBar(Self, C);

	C.Font = Root.Fonts[F_Normal];

	C.SetDrawColor(0,0,0);

#if IG_SHARED // glenn: 
	VersionText = "[Debug Menu] Build "@GetLevel().BuildVersion;
#else
	VersionText = "[Debug Menu] Version "@GetLevel().EngineVersion;
#endif

	TextSize(C, VersionText, W, H);
	ClipText(C, WinWidth - W - 20, 3, VersionText);
}

function LMouseDown(float X, float Y)
{
	if(X > WinWidth - 13) GetPlayerOwner().ConsoleCommand("togglefullscreen");
	Super.LMouseDown(X, Y);
}
function NotifyQuitUnreal()
{
	local UWindow.UWindowMenuBarItem I;

	for(I = UWindowMenuBarItem(Items.Next); I != None; I = UWindowMenuBarItem(I.Next))
		if(I.Menu != None)
			I.Menu.NotifyQuitUnreal();
}

function NotifyBeforeLevelChange()
{
	local UWindow.UWindowMenuBarItem I;

	for(I = UWindowMenuBarItem(Items.Next); I != None; I = UWindowMenuBarItem(I.Next))
		if(I.Menu != None)
			I.Menu.NotifyBeforeLevelChange();
}

function NotifyAfterLevelChange()
{
	local UWindow.UWindowMenuBarItem I;

	for(I = UWindowMenuBarItem(Items.Next); I != None; I = UWindowMenuBarItem(I.Next))
		if(I.Menu != None)
			I.Menu.NotifyAfterLevelChange();
}

function MenuCmd(int Menu, int Item)
{
	Super.MenuCmd(Menu, Item);
}

function WindowEvent(WinMessage Msg, Canvas C, float X, float Y, int Key) 
{
	switch(Msg) 
	{
		case WM_KeyDown:
		
		
			if (Key==27 || Key==19) // GRR
			{
				if (Selected == None)
				{
					Root.GotoState('');
				}

				return;
			}
			break;
	}
	Super.WindowEvent(Msg, C, X, Y, Key);
	
}
	
function Paint(Canvas C, float MouseX, float MouseY)
{
	local float X, W, H;
	local UWindow.UWindowMenuBarItem I;

	DrawMenuBar(C);

	for( I = UWindowMenuBarItem(Items.Next);I != None; I = UWindowMenuBarItem(I.Next) )
	{
		C.Font = Root.Fonts[F_Normal];
		TextSize( C, RemoveAmpersand(I.Caption), W, H );
	
		if(I.bHelp)
		{
			DrawItem(C, I, (WinWidth - (W + Spacing)), 1, W + Spacing, 14);
		}
		else
		{
			DrawItem(C, I, X, 1, W + Spacing, 14);
			X = X + W + Spacing;
		}		
	}
}

function MenuItemSelected(UWindow.UWindowBase Sender, UWindow.UWindowBase Item)
{
	local UWindowPulldownMenu Menu;
	local UWindowPulldownMenuItem I;
	
	Menu = UWindowPulldownMenu(Sender);
	I = UWindowPulldownMenuItem(Item);

	if (Menu!=None)
	{
		switch (Menu)
		{
			case Game:
				switch (I.Tag)
				{
					case 1 :
						// Open the Map Menu
						Root.ShowModal(Root.CreateWindow(class'UDebugMapListWindow', (Root.WinWidth/2)-200, (Root.WinHeight/2)-107, 400, 214, self));
						return;						
						break;
					
					case 3 :
						// Open the Map Menu
						Root.ShowModal(Root.CreateWindow(class'UDebugOpenWindow', (Root.WinWidth/2)-150,(Root.WinHeight/2)-45, 300,90, self));
						return;						
						break;
										
					case 5 : Root.ConsoleCommand("Shot"); break;
					case 6 : Root.ConsoleCommand("Flush"); break;
					case 7 :
						GetPlayerOwner().ClientOpenMenu("GUI.JoeTest");
						break;						
					case 9 : Root.ConsoleCommand("Quit"); break;
				}
				break;
			case RModes:
				if (I.Tag < 9)
					Root.ConsoleCommand("RMode "$I.Tag);
				else if (I.Tag >9)
					Root.ConsoleCommand("RMode "$I.Tag+3);
					
				break;
				
			case Rend:
				switch (I.Tag)
				{
					case 1 : Root.ConsoleCommand("rend blend"); break;    
					case 2 : Root.ConsoleCommand("rend bone"); break;    
					case 3 : Root.ConsoleCommand("rend skin"); break;
#if IG_R // rowan: added by Demiurge Studios
					case 4 : Root.ConsoleCommand("rend collision"); break;
					case 6 : Root.ConsoleCommand("rend volume all"); break;
					case 7 : Root.ConsoleCommand("rend volume none"); break;
					case 8 : Root.ConsoleCommand("rend volume blocking"); break;
					case 9 : Root.ConsoleCommand("rend volume physics"); break;
#endif // IG
#if IG_TRIBES3	// rowan: control render detail
					case 11: Root.ConsoleCommand("renderdetail 0"); break;
					case 12: Root.ConsoleCommand("renderdetail 1"); break;
					case 13: Root.ConsoleCommand("renderdetail 2"); break;
					case 14: Root.ConsoleCommand("renderdetail 3"); break;
#endif
				}
				break;
			
			case Stats:
				switch (I.Tag)
				{
					case 1 : Root.ConsoleCommand("stat All");break;     
					case 2 : Root.ConsoleCommand("stat NONE");break;     
					case 4 : Root.ConsoleCommand("stat RENDER");break;     
					case 5 : Root.ConsoleCommand("stat GAME");break;     
					case 6 : Root.ConsoleCommand("stat HARDWARE");break;     
					case 7 : Root.ConsoleCommand("stat NET");break;     
					case 8 : Root.ConsoleCommand("stat ANIM");break;
				}
				break;
				
			case Show:
				switch (I.Tag)
				{
					case 1 : Root.ConsoleCommand("show Actors"); break;  
					case 2 : Root.ConsoleCommand("show StaticMeshes"); break;  
					case 3 : Root.ConsoleCommand("show Terrain"); break;  
					case 4 : Root.ConsoleCommand("show Fog"); break;  
					case 5 : Root.ConsoleCommand("show Sky"); break;  
					case 6 : Root.ConsoleCommand("show Coronas"); break;  
					case 7 : Root.ConsoleCommand("show Particles"); break;  
#if IG_R // rowan: 
					case 8 : Root.ConsoleCommand("show Decolayers"); break;  
#endif
				}
				break;
			
			case Options:
				switch (I.tag)
				{
					case 1 : // Video Menu
								
						Root.ShowModal(Root.CreateWindow(class'UDebugVideoWindow', Options.WinLeft, 20, 220, 100, self));
						return;						
						break;

					case 2 : break; // Audio Menu
					case 3 : break; // Input Menu
				}
				break;
				
			case KDraw:
				switch (I.tag)
				{ 
					case 1 : Root.ConsoleCommand("kdraw Collision"); break; 
					case 2 : Root.ConsoleCommand("kdraw Contacts"); break; 
					case 3 : Root.ConsoleCommand("kdraw Triangles"); break; 
					case 4 : Root.ConsoleCommand("kdraw Com"); break; 
					case 6 : Root.ConsoleCommand("kdraw KStop"); break; 
					case 7 : Root.ConsoleCommand("kdraw KStep"); break;
				}
				break;
				
#if IG_SHADOWS // rowan: pass to shadow console commands
			case Shadows:
				switch (I.tag)
				{
					
					case 1: Root.ConsoleCommand("debugshadows t"); break;				// "Debug Shadows"
					case 2: break; // "-"	
					case 3: Root.ConsoleCommand("disablevolumes t"); break;				// "Toggle Volumes"
					case 4: Root.ConsoleCommand("disablevolumes bsp t"); break;			// "Show Bsp"
					case 5: Root.ConsoleCommand("disablevolumes staticmesh t"); break;	// "Show Static Mesh"
					case 6: Root.ConsoleCommand("disablevolumes terrain t"); break;		// "Show Terrain"
					case 7: break; // "-"	
					case 8: Root.ConsoleCommand("disablelightpasses t"); break;				// "Toggle Light Passes"
					case 9: Root.ConsoleCommand("disablelightpasses bsp t"); break;			// "Bsp Passes"
					case 10: Root.ConsoleCommand("disablelightpasses staticmesh t"); break;	// "Static Mesh Passes"
					case 11: Root.ConsoleCommand("disablelightpasses terrain t"); break;		// "Terrain Passes"
					case 12: Root.ConsoleCommand("disablelightpasses skeletal t"); break;	// "Skeletal Passes"			
				}
				break;
#endif
		}
	}
	Root.GotoState('');
 
}

defaultproperties
{
}

