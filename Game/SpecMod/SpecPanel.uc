class SpecPanel extends TribesGUI.TribesGUIPage;

var GUIButton Background;
var GUIMultiColumnListBox TeamOneList;
var GUIMultiColumnListBox TeamTwoList;
var GUIMultiColumnListBox CameraList;
var GUICheckBoxButton BarCheckbox;
var GUILabel BarLabel;
var GUILabel TeamOneGenLabel;
var GUILabel TeamTwoGenLabel;
var GUIButton RemoveCameraPoint;

var float pollingDelay;
var bool selectionChanged;
var GUIMultiColumnListBox selectedList;

function InitializeList(GUIMultiColumnListBox list, string caption)
{
	local GUIMultiColumnList column;

	list.ListNames.Insert(0,1);
	list.ListNames[0]="Name";
	list.InitComponent(Self);

	column=list.FindColumn("Name");
	column.ColumnWidth=0.770058;
	column.HeaderHeight=25.0;
	column.WinTop=0.0;
	column.WinLeft=0.0;
	column.WinWidth=1;
	column.WinHeight=1;

	column.MCButton.Caption=caption;
	column.MCButton.StyleName="STY_StretchedButton";
	column.MCButton.WinTop=0.0;
	column.MCButton.WinLeft=0.0;
	column.MCButton.WinWidth=1;
	column.MCButton.WinHeight=1;
	column.MCButton.RenderWeight=0.9;
	column.MCButton.InitComponent(column);

	column.MCList.DisplayItem=LIST_ELEM_ExtraStrData;
	column.MCList.bVisibleWhenEmpty=True;
	column.MCList.StyleName="STY_Browser";
	column.MCList.WinTop=0.0;
	column.MCList.WinLeft=0.0;
	column.MCList.WinWidth=1;
	column.MCList.WinHeight=1;
	column.MCList.bAllowHTMLTextFormatting=True;
	column.MCList.RenderWeight=1.0;
	column.MCList.InitComponent(column);

	column.MCList.OnClick=ListOnClick;
}

function OnConstruct(GUIController MyController)
{
	local TeamInfo teamInfo;
	local string teams[2];
	local int i;

    	Super.OnConstruct(MyController);

	i=0;

	foreach Controller.ViewportOwner.Actor.DynamicActors(class'GamePlay.TeamInfo', teamInfo)
	{
		teams[i]=teamInfo.localizedName;
		i++;
	}

	Background=GUIButton(AddComponent("GUI.GUIButton", self.Name$"_BG", true));
	Background.WinTop=-0.01;
	Background.WinLeft=-0.01;
	Background.WinWidth=0.179;
	Background.WinHeight=1.02;
	Background.bBoundToParent=true;
	Background.bScaleToParent=true;
	Background.bNeverFocus=true;
	Background.bCaptureMouse=false;
	Background.ClickKeyCode=-1;
	Background.StyleName="STY_StretchedButton";
	Background.RenderWeight=0.0;
	Background.InitComponent(Self);

	TeamOneList=GUIMultiColumnListBox(AddComponent("GUI.GUIMultiColumnListBox", self.Name$"TeamOneList", true));
	TeamOneList.WinTop=0.02;
	TeamOneList.WinLeft=0.007;
	TeamOneList.WinWidth=0.15;
	TeamOneList.WinHeight=0.25;
	TeamOneList.RenderWeight=1.0;
	InitializeList(TeamOneList, teams[0]);

	TeamOneGenLabel=GUILabel(AddComponent("GUI.GUILabel", self.Name$"_TeamOneGenLabel", true));
	TeamOneGenLabel.WinTop=0.28;
	TeamOneGenLabel.WinLeft=0.03;
	TeamOneGenLabel.WinWidth=0.34;
	TeamOneGenLabel.WinHeight=0.03;
	TeamOneGenLabel.RenderWeight=1.0;
	TeamOneGenLabel.bDontCenterVertically=true;
	TeamOneGenLabel.InitComponent(Self);

	TeamTwoList=GUIMultiColumnListBox(AddComponent("GUI.GUIMultiColumnListBox", self.Name$"_TeamTwoList", true));
	TeamTwoList.WinTop=0.32;
	TeamTwoList.WinLeft=0.007;
	TeamTwoList.WinWidth=0.15;
	TeamTwoList.WinHeight=0.25;
	TeamTwoList.RenderWeight=1.0;
	InitializeList(TeamTwoList, teams[1]);

	TeamTwoGenLabel=GUILabel(AddComponent("GUI.GUILabel", self.Name$"_TeamTwoGenLabel", true));
	TeamTwoGenLabel.WinTop=0.58;
	TeamTwoGenLabel.WinLeft=0.03;
	TeamTwoGenLabel.WinWidth=0.34;
	TeamTwoGenLabel.WinHeight=0.03;
	TeamTwoGenLabel.RenderWeight=1.0;
	TeamTwoGenLabel.bDontCenterVertically=true;
	TeamTwoGenLabel.InitComponent(Self);

	CameraList=GUIMultiColumnListBox(AddComponent("GUI.GUIMultiColumnListBox", self.Name$"_CameraList", true));
	CameraList.WinTop=0.62;
	CameraList.WinLeft=0.007;
	CameraList.WinWidth=0.15;
	CameraList.WinHeight=0.25;
	CameraList.RenderWeight=1.0;
	InitializeList(CameraList, "Cameras");

	RemoveCameraPoint=GUIButton(AddComponent("GUI.GUIButton", self.Name$"_RemoveCameraPoint", true));
	RemoveCameraPoint.WinTop=0.88;
	RemoveCameraPoint.WinLeft=0.007;
	RemoveCameraPoint.WinWidth=0.15;
	RemoveCameraPoint.WinHeight=0.03;	
	RemoveCameraPoint.RenderWeight=1.0;
	RemoveCameraPoint.bDontCenterVertically=true;
	RemoveCameraPoint.Caption="Remove";
	RemoveCameraPoint.OnClick=RemoveCameraClick;
	RemoveCameraPoint.InitComponent(Self);

	BarCheckBox=GUICheckBoxButton(AddComponent("GUI.GUICheckBoxButton", self.Name$"_BarCheckBox", true));
	BarCheckBox.StyleName="STY_CheckboxButton";
	BarCheckBox.WinTop=0.94;
	BarCheckBox.WinLeft=0.007;
	BarCheckBox.WinWidth=0.02;
	BarCheckBox.WinHeight=0.02;
	BarCheckBox.RenderWeight=1.0;
	BarCheckBox.OnChange=BarCheckOnChange;
	BarCheckBox.bChecked=FindSpecInteraction().showHealthBars;
	BarCheckBox.InitComponent(Self);

	BarLabel=GUILabel(AddComponent("GUI.GUILabel", self.Name$"_BarLabel", true));
	BarLabel.WinTop=0.94;
	BarLabel.WinLeft=0.03;
	BarLabel.WinWidth=0.14;
	BarLabel.WinHeight=0.03;
	BarLabel.RenderWeight=1.0;
	BarLabel.Caption="Show Health";
	BarLabel.bDontCenterVertically=true;
	BarLabel.InitComponent(Self);
}

function RemoveCameraClick(GUIComponent Sender)
{
	local SpecInteraction interaction;

	interaction=FindSpecInteraction();

	interaction.M.CameraManager.RemoveCamera(CameraList.FindColumn("Name").MCList.GetExtra());
}

function BarCheckOnChange(GUIComponent Sender)
{
	local SpecInteraction interaction;

	interaction=FindSpecInteraction();

	interaction.showHealthBars=GUICheckBoxButton(Sender).bChecked;
	interaction.SaveConfig();
}

function InitComponent(GUIComponent MyOwner)
{
	Super.InitComponent(MyOwner);

	RemoveCameraPoint.bVisible=false;

	OnActivate=InternalOnActivate;
	OnShow=InternalOnShow;
	OnHide=InternalOnHide;
	OnPopupReturned=InternalOnPopupReturned;
	bEscapeable=true;
}


function ShowCameraPointNameDialog()
{
	Controller.OpenMenu("TribesGui.TribesDefaultTextEntryPopup", "TribesDefaultTextEntryPopup", "Enter a name for this camera viewpoint", "Name:");
}

event HandleParameters(string Param1, string Param2, optional int param3)
{
    	if(Param1 == "ShowCameraDialog")
    	{
		ShowCameraPointNameDialog();
    	}
}

function InternalOnPopupReturned(GUIListElem returnObj, optional string Passback)
{
	local SpecCameraPointManager m;
	local SpecInteraction i;
	local SpecCameraPoint p;
	local Vector v;

	i=FindSpecInteraction();
	m=i.M.CameraManager;

	m.AddCamera(returnObj.item, i.ViewportOwner.Actor.Location, i.ViewportOwner.Actor.Rotation);
}

function InternalOnActivate()
{
	UpdateTeamLists();
	UpdateCameraPoints();
}

function InternalOnShow()
{
	SetTimer(pollingDelay, true);
}

function InternalOnHide()
{
    	KillTimer();
}

function Timer()
{
	UpdateCameraPoints();
	UpdateTeamLists();
}

function ListOnClick(GUIComponent Sender)
{
	if(selectedList!=None)
	{
		selectedList.SetIndex(-1);
	}

	selectedList = GUIMultiColumnListBox(Sender.MenuOwner.MenuOwner);
	selectionChanged = true;
}

function UpdateCameraPoints()
{
	local SpecInteraction interaction;
	local string selection;
	local int i;

	selection=CameraList.FindColumn("Name").MCList.GetExtra();
	interaction=FindSpecInteraction();

	CameraList.Clear();

	for (i=0; i<interaction.M.CameraManager.CameraPoints.Length; i++)
	{
		CameraList.AddNewRowElement("Name",,  interaction.M.CameraManager.CameraPointNames[i]);
		CameraList.PopulateRow();
	}

	// Re-select old selection
	if(selection != "")
	{
		CameraList.FindColumn("Name").MCList.FindExtra(selection);
	}
}

function UpdateTeamLists()
{
	local TribesReplicationInfo P;
	local string selection1;
	local string selection2;
	local float currentTop;
	local int j;

	selection1=TeamOneList.FindColumn("Name").MCList.GetExtra();
	selection2=TeamTwoList.FindColumn("Name").MCList.GetExtra();

	// Update the tables
	TeamOneList.Clear();
	TeamTwoList.Clear();

	/*
	for (j=0; j<10; j++)
	{
		TeamTwoList.AddNewRowElement("Name",, "MrPants"$j);
		TeamTwoList.PopulateRow();

		TeamOneList.AddNewRowElement("Name",, "MrPants"$j);
		TeamOneList.PopulateRow();
	}
	*/

	for (j=0; j<PlayerOwner().GameReplicationInfo.PRIArray.Length; j++)
	{
		P=TribesReplicationInfo(PlayerOwner().GameReplicationInfo.PRIArray[j]);

		if (P == None || P.PlayerName == "" || DemoController(P.Owner) != None || P.bIsSpectator==true)
		{
			continue;
		}

		// Don't display webadmin
		if (P.PlayerName ~= "WebAdmin")
			continue;

		if (P.Team.LocalizedName == TeamTwoList.FindColumn("Name").MCButton.Caption)
		{
			TeamTwoList.AddNewRowElement("Name",,  TribesGUIController(Controller).EncodePlayerName(self, P));
			TeamTwoList.PopulateRow();
		}
		else
		{
			TeamOneList.AddNewRowElement("Name",,  TribesGUIController(Controller).EncodePlayerName(self, P));
			TeamOneList.PopulateRow();
		}
	}

	// Re-select old selection
	if(selection1 != "")
	{
		TeamOneList.FindColumn("Name").MCList.FindExtra(selection1);
	}

	if(selection2 != "")
	{
		TeamTwoList.FindColumn("Name").MCList.FindExtra(selection2);
	}
}

function bool OnDraw(canvas Canvas)
{
	local SpecInteraction interaction;
	local SpecTeamInfo teamInfo;
	local float health;

	if(selectedList==CameraList)
	{
		RemoveCameraPoint.bVisible=true;
	}
	else
	{
		RemoveCameraPoint.bVisible=false;
	}

	interaction=FindSpecInteraction();

	if(selectionChanged)
	{
		if(selectedList==CameraList)
		{
			FindSpecInteraction().AttachToCameraByName(selectedList.FindColumn("Name").MCList.GetExtra());
		}
		else
		{
			FindSpecInteraction().AttachToTargetByName(selectedList.FindColumn("Name").MCList.GetExtra());
		}

		selectionChanged=false;
	}
	
	foreach Controller.ViewportOwner.Actor.Level.DynamicActors(class'SpecTeamInfo', teamInfo)
	{
		if(teamInfo.localizedName==TeamOneList.FindColumn("Name").MCButton.Caption)
		{
			health=(teamInfo.GeneratorHealthTotal/teamInfo.GeneratorHealthMaxTotal)*100;
			TeamOneGenLabel.Caption="Gens: "$int(health)$"%";
		}
		else
		if(teamInfo.localizedName==TeamTwoList.FindColumn("Name").MCButton.Caption)
		{
			health=(teamInfo.GeneratorHealthTotal/teamInfo.GeneratorHealthMaxTotal)*100;
			TeamTwoGenLabel.Caption="Gens: "$int(health)$"%";
		}
	}
}

function SpecInteraction FindSpecInteraction()
{
 	local int i;

        for(i=0; i<Controller.ViewportOwner.LocalInteractions.Length; i++)
	{
		if(Controller.ViewportOwner.LocalInteractions[i].Class==class'SpecMod.SpecInteraction')
		{
			return SpecMod.SpecInteraction(Controller.ViewportOwner.LocalInteractions[i]);
		}
	}

	return None;
}

defaultproperties
{
	pollingDelay=0.5,
	selectionChanged=false,
	bEscapeable=true,
	WinLeft=0,
    	WinTop=0,
    	WinHeight=1,
   	WinWidth=1
}
