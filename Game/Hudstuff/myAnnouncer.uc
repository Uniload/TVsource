//******************************************************************************
//* myAnnouncer 0.4 by Cactusbone
//* 20 november 2004
//*
//* This allows classes to send Announcement to a single Announcer
//* instead of having a lot of messagePane everywhere
//* This will also Replace the Default Announcer to display Friendly / Enemy
//* instead of tribesnames
//******************************************************************************

class myAnnouncer extends TribesGUI.HUDMessagePane;

//DO NOT CHANGE ORDER - some script might use that order to get what they want
//(for example, ingHUD does)
//Except for Not_Above or Not_Team_Specific which should not be used that way ;)
enum EStatus
{
     //Sensor And Generator
	Unknown,
	Online,
	UnderAttack,
	Destroyed,
	//Flag
	Captured,
	Returned,
	Stolen,
	Dropped, //not in messages O_o
    Not_Above
};

//DO NOT CHANGE ORDER
enum EType
{
     Generator,
     Sensor,
     Flag,
     Not_Above
};

//DO NOT CHANGE ORDER
enum ESide
{
     Friend,
     Foe,
     Not_Team_Specific
};


struct SHandler
{
     var Etype typeToReport;
     var AnnouncerHandler handler;
     var bool bShouldStillDisplay;
};

var() Array<SHandler> handlers;
var string currentTeam; //stores the current team name


//config variables
var config color FriendlyColor;
var config color EnemyColor;
var config color fallbackColor;
var config string FriendlyPlayers;
var config string Friendly;
var config string EnemyPlayers;
var config string Enemy;
var config bool bDisplayGeneratorAnnounce;
var config bool bDisplaySensorAnnounce;
var config bool bDisplayFlagAnnounce;
var config bool bDisplayOtherAnnounce;

function InitElement()
{
	super.InitElement();
	log("myAnnouncer 0.4 - Initialized",'myAnnouncer');
}

function registerHandlerForType(Etype ThetypeToReport, AnnouncerHandler TheHandler, bool bThisShouldStillDisplay)
{
    local SHandler temp;
    temp.typeToReport = ThetypeToReport;
    temp.handler = TheHandler;
    temp.bShouldStillDisplay = bThisShouldStillDisplay;
    handlers[handlers.length] = temp;
}

function UpdateData(ClientSideCharacter c)
{ // if we dont do that, we get into an infinite loop
    super.UpdateData(c);
}

function GetNewMessages(ClientSideCharacter c)
{
    local int i,j, max ;
    local bool toNotDisplay;
    local string announcement;
    local color currentColor;
    local ESide side;
    local EType type;
    local EStatus status;

    // Don't display any event messages in single player
	if (ClassIsChildOf(c.GameClass, class'SinglePlayerGameInfo'))
		return;

    //if team changed, let all handlers knows about it
    if(currentTeam!=c.ownTeam)
    {
        for(i = 0; i < handlers.length; i++)
            handlers[i].handler.teamChanged(c);
        currentTeam=c.ownTeam;
    }
    max = 0;
    max = c.Announcements.Length;//maybe a loop error around here

	//Message management
    for(i = 0; i < max; i++)
	{
	   side=ESide.Not_Team_Specific;
       if(InStr(c.Announcements[i],c.ownTeam)>=0)
          side=ESide.Friend;
       else if(InStr(c.Announcements[i],c.otherTeam)>=0)
          side=ESide.Foe;

       type=EType.Not_Above;
       if(InStr(c.Announcements[i], "flag")>=0)
          type=EType.Flag;
       else if(InStr(c.Announcements[i], "generator")>=0)
          type=EType.Generator;
       else if(InStr(c.Announcements[i], "sensor")>=0)
          type=EType.Sensor;

       status=EStatus.Not_Above;
       if(InStr(c.Announcements[i], "captured")>=0)
          status=EStatus.Captured;
       else if(InStr(c.Announcements[i], "returned")>=0)
          status=EStatus.Returned;
       else if(InStr(c.Announcements[i], "stolen")>=0)
          status=EStatus.Stolen;
       else if(InStr(c.Announcements[i], "online")>=0)
          status=EStatus.Online;
       else if(InStr(c.Announcements[i], "under attack")>=0)
          status=EStatus.UnderAttack;
       else if(InStr(c.Announcements[i], "destroyed")>=0 || InStr(c.Announcements[i], "offline")>=0)
          status=EStatus.Destroyed;

       toNotDisplay=false;
       for(j = 0 ; j < handlers.length; j++)
       {
           if(type==handlers[j].typeToReport)
           {
               handlers[j].handler.getMessage(type,side,status,c);
               toNotDisplay = toNotDisplay || (!handlers[j].bShouldStillDisplay);
           }
       }

       if(!toNotDisplay)
       {//we have to display it ourselves
           announcement=c.Announcements[i];
           currentColor=fallbackColor;
           if(side==ESide.Friend)
           {//teamColor and label change
               announcement = Repl(announcement,c.ownTeam $ "s",FriendlyPlayers,false);
               announcement = Repl(announcement,c.ownTeam,Friendly,false);
               currentColor=FriendlyColor;
           }
           else if(side==ESide.Foe)
           {//teamColor and label change
               announcement = Repl(announcement,c.otherTeam $ "s",EnemyPlayers,false);
               announcement = Repl(announcement,c.otherTeam,Enemy,false);
               currentColor=EnemyColor;
           }
           if((bDisplayGeneratorAnnounce && type==EType.Generator) ||
              (bDisplaySensorAnnounce && type==EType.Sensor) ||
              (bDisplayFlagAnnounce && type==EType.Flag) ||
              (bDisplayOtherAnnounce && type==EType.Not_Above))
           {
               AddCustomAnnouncement(announcement,currentColor);
           }
       }
    }
}

//inspired from Blei RelAnnouncer Code
function AddCustomAnnouncement(string announcement,color announcementcolor)
{
	local HUDTextMessage newMessage;
	if(announcement!="")
	{
	    //newMessage = HUDTextMessage(MessagePool.AllocateObject(class'HUDTextMessage'));
	    newMessage = new(None) class'HUDTextMessage';
	    newMessage.SetText(TemplateMessageLabelName, announcement);
	    newMessage.SetTextColor(announcementcolor);
	    AddMessage(newMessage);
	}
}

//Removes the corrupt file error
event NotifyLevelChange()
{
    class'staticFunctions'.static.removeElement(self.ParentElement, self);
}

defaultproperties
{
     currentTeam="foo"
     friendlyColor=(G=255,A=255)
     enemyColor=(R=255,A=255)
     fallbackColor=(B=255,G=255,R=255,A=255)
     FriendlyPlayers="Friendly Players"
     Friendly="Friendly"
     EnemyPlayers="Enemy Players"
     enemy="Enemy"
     bDisplayGeneratorAnnounce=True
     bDisplaySensorAnnounce=True
     bDisplayFlagAnnounce=True
     bDisplayOtherAnnounce=True
     TemplateMessageLabelName="default_AnnouncementLabel"
     MaxMessages=3
     SecondsPerWord=0.600000
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
