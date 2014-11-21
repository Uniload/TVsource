//-----------------------------------------------------------
//
//-----------------------------------------------------------
class TribesTVSpectator extends Gameplay.PlayerCharacterController;

var string TribesTVOverideUpdate;
var string TribesTVFreeFlight;
var string TribesTVLastTargetName;
var string TribesTVPos;

import enum EPhysics from Engine.Actor;

DefaultProperties
{
	bAllActorsRelevant=true
	TribesTVOverideUpdate="false"
	TribesTVFreeFlight="false"
}

// TRIBESTV TODO - PlayerCharacterController will be required most likely! (fusion movement!)

function LongClientAdjustPosition
(
    float TimeStamp,
    name newState,
    EPhysics newPhysics,
    float NewLocX,
    float NewLocY,
    float NewLocZ,
    float NewVelX,
    float NewVelY,
    float NewVelZ,
    Actor NewBase,
    float NewFloorX,
    float NewFloorY,
    float NewFloorZ
)
{
	local Actor myTarget;
	local actor target;         // TRIBESTV TODO - target?

	Super.LongClientAdjustPosition(TimeStamp, newState, newPhysics, NewLocX,NewLocY,NewLocZ,NewVelX,newVelY, newVelZ, NewBase, NewFloorX, NewFloorY, NewFloorZ);

//	ClientMessage(getstatename());
	if(TribesTVOverideUpdate=="true")
	{
		bUpdatePosition=false;
//		ClientMessage("Adjust position overridden by TribesTVreplication");
		if(TribesTVFreeFlight=="true")
		{
			bBehindView=false;
			SetViewTarget(self);
			SetLocation(vector(TribesTVPos));
			if(pawn!=none)
			{
				Pawn.SetLocation(vector(TribesTVPos));
			}
		} 
		else 
		{
			target=GetPawnFromName(TribesTVLastTargetName);
			if(myTarget!=none)
				SetViewTarget(myTarget);		
		}
	}
}

simulated function Pawn GetPawnFromName(string name)
{
	local Pawn tempPawn;

	foreach AllActors(class'Pawn',tempPawn)
	{
		if(tempPawn.PlayerReplicationInfo!=none && tempPawn.PlayerReplicationInfo.PlayerName==name)
		{
			return tempPawn;
			break;
		}
	}
	return none;
}

state Spectating
{
    simulated function PlayerMove(float DeltaTime)
    {
		local Actor myTarget;

		if(TribesTVOverideUpdate=="true" && !(TribesTVFreeFlight=="true"))
		{
			myTarget=GetPawnFromName(TribesTVLastTargetName);
			if(myTarget!=none)
			{
				SetViewTarget(myTarget);
				TargetViewRotation=myTarget.rotation;
			}
		}
		Super.PlayerMove(DeltaTime);
	}
}
