class promodHeadShotStatThreshold extends Gameplay.ModeInfo;

function OnHeadShot(Pawn instigatedBy, Pawn target, class<DamageType> damageType, float amount)
{
	local projectileDamageStat pds;

	// Don't track friendly or weak head shots
	if (Rook(instigatedBy).team() == Rook(target).team())
		return;

	if (getProjectileDamageStat(damageType, pds, PDS_Headshot))
		Tracker.awardStat(instigatedBy.Controller, pds.headShotStatClass, target.Controller);
}

defaultproperties
{
}
