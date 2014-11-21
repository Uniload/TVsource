// ====================================================================
//  Class:  TribesGameStats
//  Parent: Engine.GameStats
//
//  the GameStats object is used to send individual stat events to the
//  stats server.  Each game should spawn a GameStats object if it 
//  wishes to have stat logging.
//
// ====================================================================

class TribesGameStats extends Engine.GameStats;

// KillEvents occur when a player kills, is killed, suicides
function KillEvent(string Killtype, PlayerReplicationInfo Killer, PlayerReplicationInfo Victim, class<DamageType> Damage)
{
	local string out;
	
	if ( Victim.bBot || Victim.bOnlySpectator || ((Killer != None) && Killer.bBot) )
		return;

	out = ""$Header()$Killtype$Chr(9);

	// KillerNumber and KillerDamagetype
	if (Killer!=None)
	{
		out = out$Controller(Killer.Owner).PlayerNum$Chr(9);
		// KillerWeapon no longer used, using damagetype
		out = out$GetItemName(string(Damage))$Chr(9);
	}
	else
		out = out$"-1"$Chr(9)$GetItemName(string(Damage))$Chr(9);	// No PlayerNum -> -1, Environment "deaths"

	// VictimNumber and VictimWeapon
	out = out$Controller(Victim.Owner).PlayerNum$Chr(9)$GetItemName(string(PlayerCharacterController(Victim.Owner).GetLastWeapon()));

	// Type killers tracked as player event (redundant Typing, removed from kill line)
	if ( PlayerController(Victim.Owner)!= None && PlayerController(Victim.Owner).bIsTyping)
	{
		if ( PlayerController(Killer.Owner) != PlayerController(Victim.Owner) )	
			SpecialEvent(Killer, "type_kill");						// Killer killed typing victim
	}

	Logf(out);
}

defaultproperties
{
}
