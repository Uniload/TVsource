class compGrapplerProjectile extends Gameplay.GrapplerProjectile;

var float Health;

var class<Emitter> ProjFXClass;

var Emitter projfx;

var float burningDamagerPerSecond;

var bool bLastHook;
var Grappler source;

simulated function PostNetBeginPlay()
{
         super.PostNetBeginPlay();

         // 01/02/05
     //projfx = Spawn(ProjFXClass);
      //  projfx.SetBase(self);
}


simulated function Destroyed()
{
	if(projfx!=none)
        {
		//projfx.Disabled = true;

		//projfx.Destroy();
	}

        Super.Destroyed();
}



function PostTakeDamage(float Damage, Engine.Pawn EventInstigator, vector HitLocation, vector Momentum, class<Engine.DamageType> DamageType, optional float projectileFactor)
{
	log(health);
	
	Health -= Damage;
	log(health);
	if(Health <= 0) Destroy();

	Super.PostTakeDamage(Damage, EventInstigator, HitLocation, Momentum, DamageType, projectileFactor);
}

simulated function simulatedAttach(Actor Other, vector TouchLocation)
{
//flashy effect

	//projfx = Spawn(ProjFXClass);
	//projfx.SetBase(self);

	Super.simulatedAttach(Other, TouchLocation);

	SetCollision(True, True, True);
}

defaultproperties
{
     Health=25.000000
     ProjFXClass=Class'FX.FX_Ball_Alive'
     burningDamagerPerSecond=55.000000
     bCanBeDamaged=True
     bProjTarget=True
}
