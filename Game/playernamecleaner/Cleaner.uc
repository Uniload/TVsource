class Cleaner extends Engine.Mutator
	config
    placeable
    hidecategories(Display,Advanced,Sound,Mutator,Events);
	
var(Filter) config bool bStripColorTags;
var(Filter) config array<string> FilterList "Strings to remove from player names. * is wildcard";

var(Filter) localized float TimerInterval;
var(Filter) localized string wildCard;

simulated function PostBeginPlay()
{
	Super.PostBeginPlay();
	if ( Role == ROLE_Authority )
	{
		log(" ");
		log("Player Namer Cleaner ", 'ServerAddon');
		log("Copyright 2007 by Fabian Schlieper <mail@fabi-s.de>", 'ServerAddon');
		log(" ");
		SaveConfig();
		SetTimer(TimerInterval, true);
		Enable('Timer');
	}
}

function string stripCodes(string str)
{
    local int StartPos;
	local int EndPos;
	local string rightStr;
	
	StartPos = InStr(str, "[C=");
	rightStr = Right(str, StartPos);
    EndPos = InStr(rightStr, "]") + StartPos + 3 - 1;		// 3 is length of "[C="
    while( StartPos != -1 && StartPos < EndPos )
    {
        str = Left( str, StartPos ) $ Mid( str, EndPos + 1);
		StartPos = InStr(str, "[C=");
		rightStr = Right(str, StartPos);
        EndPos = InStr(rightStr, "]") + StartPos + 3 - 1;
    }

	StartPos = InStr(str, "[\C]");
	while( StartPos != -1 )
	{
		str = Left( str, StartPos ) $ Mid( str, StartPos + 4 );
		StartPos = InStr(str, "[\C]");
	}

    return str;
}

function string applyFilter( string n, string filter )
{
	local string LeftFilter;
	local string RightFilter;
	
    local int StartPos;
	local int EndPos;
	
	local string rightStr;
	
	LeftFilter = Left(filter, InStr(filter,wildCard));
	RightFilter = Mid(filter, InStr(filter,wildCard) + Len(wildCard) );
	
	//LogString("left filter: '"$LeftFilter$"'; right filter is: '"$RightFilter$"'"); 
	
	if(Len(LeftFilter) == 0 && InStr(n, RightFilter) != -1)
		return Mid(n, InStr(n, RightFilter) + Len(RightFilter));	

	StartPos = InStr(n, LeftFilter);		
	rightStr = Mid(n, StartPos + Len(LeftFilter) );
	EndPos = InStr( rightStr , RightFilter ) + StartPos + Len(RightFilter) - 1;
	
    while( StartPos != -1 && StartPos < EndPos )
    {
        n = Left( n, StartPos ) $ Mid( n, EndPos + Len(RightFilter) + 1 );
		StartPos = InStr(n, LeftFilter);
		rightStr = Mid(n, StartPos + Len(LeftFilter) );
		EndPos = InStr( rightStr , RightFilter ) + StartPos + Len(RightFilter) - 1;
	}
	
	return n;
}

function ClientMessage(string text)
{
	local Controller C;

	for ( C=Level.ControllerList; C!=None; C=C.NextController )
		if ( (PlayerController(C) != None) )
				PlayerController(C).ClientMessage(text);
}

function Timer()
{
	local Controller P;
	local string PName, OldPName;
	local int clTagPos;
	local int clTagClosePos;
	local string clTag;
	
	local int i;
	
	for ( P=Level.ControllerList; P!=None; P=P.NextController )
	{
		if(	PlayerController(P) != None && P.PlayerReplicationInfo != None)
		{
			OldPName = P.PlayerReplicationInfo.PlayerName;
			PName = OldPName;
			
			if(bStripColorTags)
			{
				PName = stripCodes(PName);
				
				
				clTagPos = InStr(PName, "[c=");
				while( clTagPos != -1 )
				{
					clTagClosePos = InStr(PName, "]");				
					if(clTagClosePos == -1) break;					
					clTag = Mid(PName, clTagPos,  (clTagClosePos - clTagPos + 1) );
					PName = Repl(PName, clTag, "", false);
					clTagPos = InStr(PName, "[c=");
				}
			}
			

			for( i = 0; i < FilterList.length; ++i)
			{
				if( InStr(FilterList[i], wildCard) != -1 )
					PName = applyFilter(PName, FilterList[i]);
				else
					PName = Repl(PName, FilterList[i], "", false);
			}			
			
			if(PName != OldPName)
			{
				Level.Game.ChangeName( P, PName, true );
				ClientMessage(OldPName$" has been renamed to "$PName$" by Player-NameCleaner");
			}
		}
	}
}


function GetServerDetails(out GameInfo.ServerResponseLine ServerState);

defaultproperties
{
     bStripColorTags=True
     filterList(0)="[c]"
     filterList(1)="[\c]"
     filterList(2)="[/c]"
     filterList(3)="[c="
     filterList(4)="[u]"
     filterList(5)="[\u]"
     TimerInterval=20.000000
     Wildcard="*"
     GroupName="ServerAddon"
     bAlwaysRelevant=True
     bNetNotify=True
}
