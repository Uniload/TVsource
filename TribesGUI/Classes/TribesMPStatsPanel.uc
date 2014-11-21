// ====================================================================
//  Class:  TribesGui.TribesMPStatsPanel
//  Parent: TribesGUIPage
//
//  Menu to load map from entry screen.
// ====================================================================

class TribesMPStatsPanel extends TribesMPEscapePanel
     ;

var(TribesGui) private EditInline Config GUIMultiColumnListBox StatsListBox "A component of this page which has its behavior defined in the code for this page's class.";
var(TribesGui) private EditInline Config GUILabel offenseLabel "A component of this page which has its behavior defined in the code for this page's class.";
var(TribesGui) private EditInline Config GUILabel defenseLabel "A component of this page which has its behavior defined in the code for this page's class.";
var(TribesGui) private EditInline Config GUILabel styleLabel "A component of this page which has its behavior defined in the code for this page's class.";
var(TribesGui) private EditInline Config GUILabel totalLabel "A component of this page which has its behavior defined in the code for this page's class.";

var() localized string	defenseString;
var() localized string	offenseString;
var() localized string	styleString;

function InitComponent(GUIComponent Owner)
{
	Super.InitComponent(Owner);

	OnActivate= InternalOnActivate;
	OnDeActivate = InternalOnDeActivate;
}

function string createEquation(int offense, int defense, int style)
{
	local string s;

	if (offense == 0 && defense == 0 && style == 0)
		return "-";

	if (offense > 0)
	{
		s = s $ offense @ offenseString;
		if (defense > 0 || style > 0)
			s = s $ ", ";
	}
	if (defense > 0)
	{
		s = s $ defense @ defenseString;
		if (style > 0)
			s = s $ "  +  ";
	}
	if (style > 0)
	{
		s = s $ style @ styleString;
	}

	return s;
}

function UpdateStats()
{
	local tribesReplicationInfo TRI;
	local int i;
	local int totalPoints;
	local int offensePoints, defensePoints, stylePoints;
	local int totalOffense, totalDefense, totalStyle;
	local string equation;

	TRI = tribesReplicationInfo(PlayerOwner().playerReplicationInfo);

	if (TRI == None)
		return;

	StatsListBox.Clear();
	for (i=0; i < TRI.statDataList.Length; i++)
	{
		if (TRI.statDataList[i].statClass.default.Description != "")
			StatsListBox.AddNewRowElement( "Name",, TRI.statDataList[i].statClass.default.Description);
		else
			continue;
		//	StatsListBox.AddNewRowElement( "Name",, TRI.statDataList[i].statClass.default.acronym);
		offensePoints = TRI.statDataList[i].statClass.default.offensePointsPerStat;
		defensePoints = TRI.statDataList[i].statClass.default.defensePointsPerStat;
		stylePoints = TRI.statDataList[i].statClass.default.stylePointsPerStat;
		equation = createEquation(offensePoints, defensePoints, stylePoints);
		StatsListBox.AddNewRowElement( "Number",, string(TRI.statDataList[i].amount));
		StatsListBox.AddNewRowElement( "Equation",, equation);

		totalPoints = TRI.statDataList[i].amount * (offensePoints + defensePoints + stylePoints);
		StatsListBox.AddNewRowElement( "Total",, string(totalPoints));
		StatsListBox.PopulateRow( "Name" );

		totalOffense += TRI.statDataList[i].amount * offensePoints;
		totalDefense += TRI.statDataList[i].amount * defensePoints;
		totalStyle += TRI.statDataList[i].amount * stylePoints;
	}

	offenseLabel.Caption = string(totalOffense);
	defenseLabel.Caption = string(totalDefense);
	styleLabel.Caption = string(totalStyle);
	totalLabel.Caption = string(totalOffense + totalDefense + totalStyle);
}

function TribesReplicationInfo OwnerTRI()
{
	return tribesReplicationInfo(PlayerOwner().playerReplicationInfo);
}

function InternalOnActivate()
{
	// Start requesting stat updates
	OwnerTRI().requestStatInit();
	OwnerTRI().requestStatUpdates();
	UpdateStats();
	SetTimer( 1, true );
}

function InternalOnDeactivate()
{
	SetTimer( 0, false);
}

function Timer()
{
	OwnerTRI().requestStatUpdates();
	UpdateStats();
}

defaultproperties
{
	offenseString		= "Offense"
	defenseString		= "Defense"
	styleString			= "Style"
}