class SpecPlayerInfo extends Engine.ReplicationInfo;

var float Energy;
var float EnergyMax;
var PlayerReplicationInfo PlayerReplicationInfo;
var PlayerCharacterController Controller;
var Actor AttachedActor;
var bool  IsFreeLook;

replication
{
    unreliable if ( Role == ROLE_Authority )
	AttachedActor,
	PlayerReplicationInfo,
	Controller,
        Energy,
	EnergyMax;

    reliable if (Role<ROLE_Authority)
	AttachToCamera,
	AttachToTargetByName,
	DetachFromTarget,
	AttachToTarget,
	FreeLook;	
}

simulated function DetachFromTarget()
{
    local Vector V;
    local float speed;

    if(Role==ROLE_Authority)
    {	
	 V.X = AttachedActor.Location.X;
	 V.Y = AttachedActor.Location.Y;
	 V.Z = AttachedActor.Location.Z;

	 Controller.SetViewTarget(Controller);
	 Controller.ClientSetViewTarget(Controller);
	 Controller.SetLocation(AttachedActor.Location);

	 speed=VSize(AttachedActor.Velocity)*0.9;

	 if(speed>0)
	 {
	 	Controller.SetSpectateSpeed(speed);
	 }
	
	 AttachedActor=None;
    }
}

simulated function AttachToCamera(Vector location, Rotator rotation)
{	
	if(Role==ROLE_Authority)
    	{	
		Controller.SetViewTarget(Controller);
	 	Controller.ClientSetViewTarget(Controller);
		Controller.SetLocation(location);
		Controller.SetRotation(rotation);
	}
}

simulated function AttachToTargetByName(string targetName)
{
    local Pawn P;

    if(Role==ROLE_Authority)
    {
	for (P = Level.PawnList; P != None; P = P.NextPawn)
	{
    		if(P.PlayerReplicationInfo!=None && P.PlayerReplicationInfo.PlayerName == targetName)
		{
			AttachedActor=P;
			Controller.SetViewTarget(P);
			Controller.ClientSetViewTarget(P);
			return;
		}
	}
    }
}

simulated function AttachToTarget(Actor target)
{
    if(Role==ROLE_Authority)
    {
	AttachedActor=target;
	Controller.SetViewTarget(AttachedActor);
	Controller.ClientSetViewTarget(AttachedActor);
    }
}

simulated function FreeLook(bool enabled)
{
    if(Role==ROLE_Authority)
    {
    	IsFreeLook=enabled;
    }
}

defaultproperties
{
    IsFreeLook=true
}