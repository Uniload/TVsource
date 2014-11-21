//=============================================================================
// Mutator.
//
// Mutators allow modifications to gameplay while keeping the game rules intact.  
// Mutators are given the opportunity to modify player login parameters with 
// ModifyLogin(), to modify player pawn properties with ModifyPlayer(), to change 
// the default weapon for players with GetDefaultWeapon(), or to modify, remove, 
// or replace all other actors when they are spawned with CheckRelevance(), which 
// is called from the PreBeginPlay() function of all actors except those (Decals, 
// Effects and Projectiles for performance reasons) which have bGameRelevant==true.
//=============================================================================
class Mutator extends Info
	native
	dependson(GameInfo);

var Mutator NextMutator;
//var class<Weapon> DefaultWeapon;
var string DefaultWeaponName;
var() string      		ConfigMenuClassName;
var() string            GroupName; // Will only allow one mutator with this tag to be selected.
var() localized string  FriendlyName;
var() localized string  Description;
var bool bUserAdded;
var bool bAddToServerPackages;		// if true, the package this mutator is in will be added to serverpackages at load time

/* Don't call Actor PreBeginPlay() for Mutator 
*/
event PreBeginPlay()
{
	if ( !MutatorIsAllowed() )
		Destroy();
}

function bool MutatorIsAllowed()
{
	return !Level.IsDemoBuild() || Class==class'Mutator';
}

function Destroyed()
{
	local Mutator M;
	
	// remove from mutator list
	if ( Level.Game.BaseMutator == self )
		Level.Game.BaseMutator = NextMutator;
	else
	{
		for ( M=Level.Game.BaseMutator; M!=None; M=M.NextMutator )
			if ( M.NextMutator == self )
			{	
				M.NextMutator = NextMutator;
				break;
			}
	}
	Super.Destroyed();
}

// Gives the mutator an opportunity to replace an actor after it is spawned.
// Either return the original actor, a replacement actor created with the ReplaceWith function, or 'None' to destroy the actor.
function Actor ReplaceActor(Actor Other)
{
	return Other;
}

function Mutate(string MutateString, PlayerController Sender)
{
	if ( NextMutator != None )
		NextMutator.Mutate(MutateString, Sender);
}

function ModifyLogin(out string Portal, out string Options)
{
	if ( NextMutator != None )
		NextMutator.ModifyLogin(Portal, Options);
}

//Notification that a player is exiting
function NotifyLogout(Controller Exiting)
{
	if (NextMutator != None)
		NextMutator.NotifyLogout(Exiting);
}

/* called by GameInfo.RestartPlayer()
	change the players jumps, etc. here
*/
function ModifyPlayer(Pawn Other)
{
	if ( NextMutator != None )
		NextMutator.ModifyPlayer(Other);
}

function AddMutator(Mutator M)
{
	if ( NextMutator == None )
		NextMutator = M;
	else
		NextMutator.AddMutator(M);
}

/* ReplaceWith()
Call this function (usually called from "ShouldReplace") to replace an actor Other with an actor of aClass.
*/
function Actor ReplaceWith(actor Other, string aClassName)
{
	local Actor A;
	local class<Actor> aClass;

	if ( aClassName == "" )
		return None;
		
	aClass = class<Actor>(DynamicLoadObject(aClassName, class'Class'));
	if ( aClass != None )
		A = Spawn(aClass,Other.Owner,Other.Tag,Other.Location, Other.Rotation);

	if ( A != None )
	{
		A.event = Other.event;
		A.Tag = Other.Tag;
	}
	
	return A;
}

/* Force game to always keep this actor, even if other mutators want to get rid of it
*/
function bool AlwaysKeep(Actor Other)
{
	if ( NextMutator != None )
		return ( NextMutator.AlwaysKeep(Other) );
	return false;
}

function bool IsRelevant(Actor Other, out Actor Replacement)
{
	local bool bRelevant;

	Replacement = ReplaceActor(Other);
	
	bRelevant = Replacement == Other;
	
	if ( bRelevant && (NextMutator != None) )
		bRelevant = NextMutator.IsRelevant(Other, Replacement);

	return bRelevant;
}

singular event bool CheckRelevance(Actor Other, out Actor Replacement)
{
	local bool bResult;

	if ( AlwaysKeep(Other) )
		return true;

	// allow mutators to remove actors
	bResult = IsRelevant(Other, Replacement);

	return bResult;
}

//
// Called when a player sucessfully changes to a new class
//
function PlayerChangedClass(Controller aPlayer)
{
	if ( NextMutator != None )
	NextMutator.PlayerChangedClass(aPlayer);
}

//
// server querying
//
function GetServerDetails( out GameInfo.ServerResponseLine ServerState )
{
	// append the mutator name.
	local int i;
	i = ServerState.ServerInfo.Length;
	ServerState.ServerInfo.Length = i+1;
	ServerState.ServerInfo[i].Key = "Mutator";
	ServerState.ServerInfo[i].Value = GetHumanReadableName();
}

function GetServerPlayers( out GameInfo.ServerResponseLine ServerState )
{
}

function ServerTraveling(string URL, bool bItems)
{
	if (NextMutator != None)
    	NextMutator.ServerTraveling(URL,bItems);
}

defaultproperties
{
}
