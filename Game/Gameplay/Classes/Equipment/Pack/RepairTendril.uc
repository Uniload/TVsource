class RepairTendril extends Core.DeleteableObject;

var Actor target;
var Emitter system;
var Pawn originator;
var IRepairClient client;

function BeamEmitter getBeamEmitter()
{
	local int i;

	if (system == None)
		return None;

	for (i = 0; i < system.Emitters.Length; i++)
	{
		if (BeamEmitter(system.Emitters[i]) != None)
		{
			return BeamEmitter(system.Emitters[i]);
		}
	}
}

function update()
{
	local Vector targetPos;
	local BeamEmitter effect;

	if (system == None)
		return;

	effect = getBeamEmitter();

	if (effect == None)
		return;

	targetPos = getTargetPos();

	system.SetLocation(client.getFXTendrilOrigin(targetPos));

	if (effect.BeamEndPoints.Length >= 1)
	{
		effect.DetermineEndPointBy = PTEP_OffsetAsAbsolute;
		effect.BeamEndPoints[effect.BeamEndPoints.Length - 1].Offset.X.Min = targetPos.X;
		effect.BeamEndPoints[effect.BeamEndPoints.Length - 1].Offset.X.Max = targetPos.X;
		effect.BeamEndPoints[effect.BeamEndPoints.Length - 1].Offset.Y.Min = targetPos.Y;
		effect.BeamEndPoints[effect.BeamEndPoints.Length - 1].Offset.Y.Max = targetPos.Y;
		effect.BeamEndPoints[effect.BeamEndPoints.Length - 1].Offset.Z.Min = targetPos.Z;
		effect.BeamEndPoints[effect.BeamEndPoints.Length - 1].Offset.Z.Max = targetPos.Z;
	}
}

function Vector getTargetPos()
{
	return client.getFXTendrilTarget(target); //target.unifiedGetPosition();
}