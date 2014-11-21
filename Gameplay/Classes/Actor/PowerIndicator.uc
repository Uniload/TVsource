class PowerIndicator extends Engine.StaticMeshActor
	placeable;

var() Array<Material>	powerOffMaterials;

var() editdisplay(displayActorLabel) editcombotype(enumBaseInfo) BaseInfo ownerBase;

var bool basePowerOn;
var bool localBasePowerOn;

replication
{
	reliable if(Role == ROLE_Authority)
		basePowerOn;
}

function string displayActorLabel(Actor t)
{
	return string(t.label);
}

function enumBaseInfo(Engine.LevelInfo l, Array<BaseInfo> a)
{
	local BaseInfo b;

	ForEach DynamicActors(class'BaseInfo', b)
	{
		a[a.length] = b;
	}
}

function setPower(bool powerIsOn)
{
	if (powerIsOn)
		powerOn();
	else
		powerOff();

	basePowerOn = powerIsOn;
}

simulated function PostNetReceive()
{
	if (localBasePowerOn != basePowerOn)
	{
		localBasePowerOn = basePowerOn;

		if (localBasePowerOn)
			powerOn();
		else
			powerOff();
	}
}

simulated function powerOff()
{
	Skins = powerOffMaterials;
	TriggerEffectEvent('PowerOff');
}

simulated function powerOn()
{
	Skins.Length = 0;
	UnTriggerEffectEvent('PowerOff');
}

simulated function destroyed()
{
	super.destroyed();

	if (!localBasePowerOn)
		UnTriggerEffectEvent('PowerOff');
}

defaultproperties
{
	BasePowerOn = true
	localBasePowerOn = true

	bNetNotify = true

	bStatic = false
	StaticMesh = StaticMesh'BaseObjects.PowerSign'

	bNetInitialRotation = true

	powerOffMaterials(0) = None
	powerOffMaterials(1) = Shader'BaseObjects.PowerSignFXRedShader'
	powerOffMaterials(2) = Shader'BaseObjects.PowerSign_OffShader'
	powerOffMaterials(3) = Shader'BaseObjects.PowerSignLightOnShader'
}