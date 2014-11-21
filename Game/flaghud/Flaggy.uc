/*******************************************************************************
	Handles FlagHUD implementation   								      <br />

	(c) 2004, Jeremiah "Byte" Fulbright
	Released under the Open Unreal Mod License
	http://wiki.beyondunreal.com/wiki/OpenUnrealModLicense

	<!-- $Id: Flaggy.uc,v1.0 2004/10/17 03:30 jfulbright Exp $ -->
*******************************************************************************/
class Flaggy extends TribesGUI.HUDContainer;

var FlagMessages FlagHandler;

var LabelElement FriendlyTeamLabel;
var LabelElement EnemyTeamLabel;

var LabelElement FriendlyFlagStatus;
var LabelElement EnemyFlagStatus;

var HUDContainer FriendlyFlag;
var HUDContainer EnemyFlag;

var LabelElement SeparatorA;
var LabelElement SeparatorB;

var bool bFriendlyDropped;
var bool bEnemyDropped;
var bool bInitialTeam;
var bool bNeedUpdate;

var string currentTeam;

var float FriendlyCounter;
var float EnemyCounter;
var float FriendlyStart;
var float EnemyStart;
var float FFlagTime;
var float EFlagTime;

function InitElement()
{
    super.InitElement();

    // look for our data class, if not found, assume we werent initialized
    flagHandler = FlagMessages(FindObject("ext_FlagHUDSupport", class'FlagHUD.FlagMessages'));

    // nobody home
    if(flagHandler==None)
    {
        log("FlagHUD v1.00 - Initialized", 'FlagHUD');

        FlagHandler = FlagMessages(AddElement("FlagHUD.FlagMessages", "ext_FlagHUDSupport"));

        FriendlyFlag = HUDContainer(AddElement("TribesGUI.HUDContainer", "ext_FriendlyFlagContainer"));
        FriendlyFlagStatus = LabelElement(FriendlyFlag.AddElement("TribesGUI.LabelElement", "ext_FriendlyFlagLabel"));

        EnemyFlag = HUDContainer(AddElement("TribesGUI.HUDContainer", "ext_EnemyFlagContainer"));
        EnemyFlagStatus = LabelElement(EnemyFlag.AddElement("TribesGUI.LabelElement", "ext_EnemyFlagLabel"));

        // teams
        FriendlyTeamLabel = LabelElement(FriendlyFlag.AddElement("TribesGUI.LabelElement", "ext_FriendlyTeamLabel"));
        FriendlyTeamLabel.textColor = FlagHandler.FriendlyColor;
        FriendlyTeamLabel.bVisible = FlagHandler.bTeamNames;

        EnemyTeamLabel = LabelElement(EnemyFlag.AddElement("TribesGUI.LabelElement", "ext_EnemyTeamLabel"));
        EnemyTeamLabel.textColor = FlagHandler.EnemyColor;
        EnemyTeamLabel.bVisible = FlagHandler.bTeamNames;

        // separator
        SeparatorA = LabelElement(FriendlyFlag.AddElement("TribesGUI.LabelElement", "ext_FriendlySeparator"));
        SeparatorA.bVisible = FlagHandler.bSeparators;
        SeparatorA.setText(FlagHandler.Separator);

        SeparatorB = LabelElement(EnemyFlag.AddElement("TribesGUI.LabelElement", "ext_EnemySeparator"));
        SeparatorB.setText(FlagHandler.Separator);
        SeparatorB.bVisible = FlagHandler.bSeparators;

        // variable init
        FFlagTime=30.000000;
        EFlagTime=30.000000;

        // set flag status to blank till first update
        if(FriendlyFlagStatus.GetText()~="")
           FriendlyFlagStatus.SetText("...");
        if(EnemyFlagStatus.GetText()~="")
           EnemyFlagStatus.SetText("...");

        //setup delegate calls
        FlagHandler.OnFlagTaken=FlagTaken;
        FlagHandler.OnFlagReturned=FlagReturned;
        FlagHandler.OnFlagDropped=FlagDropped;
        FlagHandler.OnFlagCaptured=FlagCaptured;
    }

    class'FlagMessages'.Static.StaticSaveConfig();
}

function UpdateData(ClientSideCharacter c)
{
    local int i, minutes, seconds;
    local int fflag, eflag;

    super.UpdateData(c);

    if(bVisible)
        bVisible=false;

    for(i=0; i<FlagHandler.FlagHUDClass.Length; i++)
    {
        if(string(c.GameClass) == FlagHandler.FlagHUDClass[i])
            bVisible=true;
    }

	minutes = c.countDown / 60.0;
	seconds = c.countDown - minutes * 60.0;

    if(bFriendlyDropped)
    {
      FriendlyCounter = FriendlyStart - c.countDown;
      fflag = FFlagTime - FriendlyCounter;

      FriendlyFlagStatus.textColor=FlagHandler.FriendlyDroppedColor;
      FriendlyFlagStatus.setText(FlagHandler.FieldBegin@fflag@FlagHandler.FieldEnd);

      // reset it
      if(fflag<=0)
         FlagReturned("Field","AllyMessage");
    }

    if(bEnemyDropped)
    {
      EnemyCounter = EnemyStart - c.countDown;
      eflag = EFlagTime - EnemyCounter;

      EnemyFlagStatus.textColor=FlagHandler.EnemyDroppedColor;
      EnemyFlagStatus.setText(FlagHandler.FieldBegin@eflag@FlagHandler.FieldEnd);

      // reset it
      if(eflag<=0)
         FlagReturned("Field","EnemyMessage");
    }

    // sets current team
    if(!bInitialTeam)
    {
       currentTeam=c.ownTeam;
       bInitialTeam=true;
       bNeedUpdate=true;
    }

    // delay hack
    if(!bNeedUpdate)
       TeamChange(c);

    if(c.ownTeam!=currentTeam)
       TeamChange(c);

    // set team names
    FriendlyTeamLabel.SetText(c.ownTeam);
    EnemyTeamLabel.SetText(c.otherTeam);
}

// simple function to swap text quickly
function TeamChange(ClientSideCharacter c)
{
      local string tmp1, tmp2;
      local color color1, color2;
      local float start1, start2;

      if(bNeedUpdate)
      {
         // set new team
         currentTeam=c.ownTeam;
         bNeedUpdate=false;
         return;
      }

      // store current
      tmp1 = FriendlyFlagStatus.GetText();
      color1 = FriendlyFlagStatus.textColor;
      start1 = FriendlyStart;

      tmp2 = EnemyFlagStatus.GetText();
      color2 = EnemyFlagStatus.textColor;
      start2 = EnemyStart;

      // keeps us from changing colors if both say Home
      if(tmp1~=FlagHandler.HomeString && tmp2~=FlagHandler.HomeString)
      {
       color2 = FriendlyFlagStatus.textColor;
       color1 = EnemyFlagStatus.textColor;
      }

      if(tmp1~=FlagHandler.HomeString)
         color1 = FlagHandler.EnemyColor;
      if(tmp2~=FlagHandler.HomeString)
         color2 = FlagHandler.FriendlyColor;

      // replace current
      FriendlyFlagStatus.setText(tmp2);
      FriendlyFlagStatus.textColor=color2;
      FriendlyStart = start2;

      EnemyFlagStatus.setText(tmp1);
      EnemyFlagStatus.textColor=color1;
      EnemyStart = start1;

      // if both are true, then we don't need to adjust
      if(bFriendlyDropped && bEnemyDropped)
      {
         bNeedUpdate=true;
         return;
      }

      // switch around variables
      if(bFriendlyDropped && !bEnemyDropped)
      {
         bEnemyDropped=true;
         bFriendlyDropped=false;
      }
      else if (bEnemyDropped && !bFriendlyDropped)
      {
         bEnemyDropped=false;
         bFriendlyDropped=true;
      }

      bNeedUpdate=true;
}

function FlagTaken(string Player, string Team)
{
  if(FlagHandler.bLogEvents)
    log("Player: "$Player$" Event: Grabbed Flag", 'FlagEvent');

  if(Team~="AllyMessage")
  {
     EnemyFlagStatus.setText(Player);
     EnemyFlagStatus.textColor=FlagHandler.FriendlyColor;
     bEnemyDropped=false;

  }
  else if(Team~="EnemyMessage")
  {
     FriendlyFlagStatus.setText(Player);
     FriendlyFlagStatus.textColor=FlagHandler.EnemyColor;
     bFriendlyDropped=false;
  }
}

function FlagReturned(string Player, string Team)
{
  if(FlagHandler.bLogEvents)
    log("Player: "$Player$" Event: Returned Flag", 'FlagEvent');

  if(Team~="AllyMessage")
  {
     FriendlyFlagStatus.setText(FlagHandler.HomeString);
     FriendlyFlagStatus.textColor=FlagHandler.FriendlyColor;
     bFriendlyDropped=false;
     FFlagTime=30;
  }
  else if(Team~="EnemyMessage")
  {
     EnemyFlagStatus.setText(FlagHandler.HomeString);
     EnemyFlagStatus.textColor=FlagHandler.EnemyColor;
     bEnemyDropped=false;
     EFlagTime=30;
  }
}

function FlagDropped(string Player, string Team, int StartTime)
{
  if(FlagHandler.bLogEvents)
    log("Player: "$Player$" Event: Dropped Flag", 'FlagEvent');

  if(Team~="AllyMessage")
  {
     EnemyFlagStatus.setText("");
     EnemyFlagStatus.textColor=FlagHandler.FriendlyColor;
     bEnemyDropped=true;
     EnemyStart=StartTime;
  }
  else if(Team~="EnemyMessage")
  {
     FriendlyFlagStatus.setText("");
     FriendlyFlagStatus.textColor=FlagHandler.EnemyColor;
     bFriendlyDropped=true;
     FriendlyStart=StartTime;
  }
}

function FlagCaptured(string Player, string Team)
{
  if(FlagHandler.bLogEvents)
    log("Player: "$Player$" Event: Captured Flag", 'FlagEvent');

  if(Team~="AllyMessage")
  {
     EnemyFlagStatus.setText(FlagHandler.HomeString);
     EnemyFlagStatus.textColor=FlagHandler.EnemyColor;
     bEnemyDropped=false;
  }
  else if(Team~="EnemyMessage")
  {
     FriendlyFlagStatus.setText(FlagHandler.HomeString);
     FriendlyFlagStatus.textColor=FlagHandler.FriendlyColor;
     bFriendlyDropped=false;
  }
}

defaultproperties
{
     resFontNames(0)="DefaultSmallFont"
     resFontNames(1)="Tahoma8"
     resFontNames(2)="Tahoma8"
     resFontNames(3)="Tahoma10"
     resFontNames(4)="Tahoma12"
     resFontNames(5)="Tahoma12"
     resFonts(0)=Font'Engine_res.Res_DefaultFont'
     resFonts(1)=Font'TribesFonts.Tahoma8'
     resFonts(2)=Font'TribesFonts.Tahoma8'
     resFonts(3)=Font'TribesFonts.Tahoma10'
     resFonts(4)=Font'TribesFonts.Tahoma12'
     resFonts(5)=Font'TribesFonts.Tahoma12'
}
