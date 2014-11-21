///////////////////////////////////////////////////////////////////////////////
// this interface is used when we want to be a client of the Shot notification system
// clients are stored in the ShotNotifier of an AI

interface IShotNotification;

/////////////////////////////////////////////////
/// IShotNotification Signature
/////////////////////////////////////////////////

function OnShooterFiredShot(Pawn Shooter, Actor projectile);

defaultproperties
{
}
