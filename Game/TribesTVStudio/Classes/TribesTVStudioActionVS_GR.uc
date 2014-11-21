class TribesTVStudioActionVS_GR extends GameRules;

var TribesTVStudioActionVS reportTo;

//add rating for people fighting
function int NetDamage( int OriginalDamage, int Damage, pawn injured, pawn instigatedBy, vector HitLocation, vector Momentum, class<DamageType> DamageType )
{
	if(instigatedBy.PlayerReplicationInfo!=none)
		reportTo.AddRating(instigatedBy.PlayerReplicationInfo.playerId,damage);
	if(injured.PlayerReplicationInfo!=none)
		reportTo.AddRating(injured.PlayerReplicationInfo.playerId,damage);

	if ( NextGameRules != None )
		return NextGameRules.NetDamage( OriginalDamage,Damage,injured,instigatedBy,HitLocation,Momentum,DamageType );
	else 
		return Damage;
}

//lower rating for someone just killed
function ScoreKill(Controller Killer, Controller Killed)
{
	if(killed.PlayerReplicationInfo!=none)
		reportTo.AddRating(killed.PlayerReplicationInfo.playerId,-200);

	if ( NextGameRules != None )
		NextGameRules.ScoreKill(Killer,Killed);
}

defaultproperties
{
}