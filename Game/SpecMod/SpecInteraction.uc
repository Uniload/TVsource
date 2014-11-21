class SpecInteraction extends Engine.Interaction Config(SpecMod);

var bool  enabledLookLock;
var int   releaseCount;
var config bool  showHealthBars;
var SpecMutator M;

function Initialize()
{
    enabledLookLock=false;
    releaseCount=0;
}

function SpecPlayerInfo GetSpecPlayerInfo(Pawn p)
{
   local SpecPlayerInfo spi;

   foreach ViewportOwner.Actor.Level.DynamicActors(class'SpecPlayerInfo', spi)
   {
	if(p.PlayerReplicationInfo == spi.PlayerReplicationInfo) return spi;			
   }

   return None;
}


function SpecPlayerInfo GetSpecPlayerInfoByController(Controller c)
{
   local SpecPlayerInfo spi;

   foreach ViewportOwner.Actor.Level.DynamicActors(class'SpecPlayerInfo', spi)
   {
	if(c == spi.Controller) return spi;			
   }

   return None;
}

function ToggleLookLock()
{
    	local SpecPlayerInfo pccSpi;

	pccSpi = GetSpecPlayerInfoByController(ViewportOwner.Actor);
	
        if(enabledLookLock)
	{
		enabledLookLock=false;
		pccSpi.FreeLook(true);
	}
	else
	{
	        enabledLookLock=true;
		pccSpi.FreeLook(false);
	}
}

function bool KeyEvent(EInputKey Key, EInputAction Action, FLOAT Delta)
{ 
    local SpecPlayerInfo pccSpi;
    local Actor closestActor;
    local float spectateSpeed;

    if((Key == IK_P) && (Action == IST_RELEASE))
    {
        releaseCount++;

	if(releaseCount == 2)
	{		
		FindGUIController().OpenMenu("SpecMod.SpecPanel", "SpecPanel", "ShowCameraDialog");
		releaseCount=0;
	}
    }

    if(Key == IK_MouseW)
    {
    	spectateSpeed=ViewportOwner.Actor.SpectateSpeed;

	if(Delta > 0)
	{
	    spectateSpeed += 1000;
	}
	else
	{
	    spectateSpeed -= 1000;
	}

	if(spectateSpeed<500)
	{
 	    spectateSpeed=500;
	}

	ViewportOwner.Actor.SetSpectateSpeed(spectateSpeed);
    }

    if((Key == IK_Ctrl) && (Action == IST_RELEASE))
    {
        releaseCount++;

	// NFI why but unreal performs a release twice. sheer genius.
	if(releaseCount == 2)
	{
		ToggleLookLock();		
		releaseCount=0;
	}
    }

    if((Key == IK_Enter) && (Action == IST_RELEASE))
    {
	releaseCount++;

	if(releaseCount == 2)
	{
		FindGUIController().OpenMenu("SpecMod.SpecPanel");	
		releaseCount=0;
	}
    }

    if((Key == IK_Alt) && (Action == IST_RELEASE) && PlayerCharacterController(ViewportOwner.Actor)!=None)
    {
        releaseCount++;
	
	if(releaseCount == 2)
	{
		if(ViewportOwner.Actor.ViewTarget != ViewportOwner.Actor)
		{					
			DetachFromTarget();
		}
		else
		{		
			closestActor=FindClosestActor();
	
			if(closestActor!=None)
			{
				AttachToTarget(closestActor);
			}
		}	
		
		releaseCount=0;
	}
    }

    return false;
}

function DetachFromTarget()
{
    	local SpecPlayerInfo pccSpi;

	pccSpi = GetSpecPlayerInfoByController(ViewportOwner.Actor);
	pccSpi.DetachFromTarget();
}


function AttachToTargetByName(string name)
{
    	local SpecPlayerInfo pccSpi;

	pccSpi = GetSpecPlayerInfoByController(ViewportOwner.Actor);
	pccSpi.AttachToTargetByName(name);
}

function AttachToTarget(Actor actor)
{
    	local SpecPlayerInfo pccSpi;

	pccSpi = GetSpecPlayerInfoByController(ViewportOwner.Actor);
	pccSpi.AttachToTarget(actor);

	ViewportOwner.Actor.SetViewTarget(actor);
	ViewportOwner.Actor.ClientSetViewTarget(actor);
}

function AttachToCameraByName(string name)
{
	local SpecCameraPoint p;

	p=M.CameraManager.FindCamera(name);

	if(p==None)
	{
		ViewportOwner.Actor.ClientMessage("Found no camera matching "$name);
	}

	AttachToCamera(p.Location, p.Rotation);
}

function AttachToCamera(Vector v, Rotator r)
{
    	local SpecPlayerInfo pccSpi;

	pccSpi = GetSpecPlayerInfoByController(ViewportOwner.Actor);
	pccSpi.AttachToCamera(v, r);

	ViewportOwner.Actor.SetViewTarget(ViewportOwner.Actor);
	ViewportOwner.Actor.ClientSetViewTarget(ViewportOwner.Actor);

	ViewportOwner.Actor.SetLocation(v);
	ViewportOwner.Actor.SetRotation(r);
}

function PostRender(canvas Canvas)
{
   local array<SpecCameraPoint> test;
   local SpecPlayerInfo pccSpi;
   local bool render;
   local Vector X,Y,Z;
   local float distance;
   local Pawn  P;

   Canvas.SetPos(10, Canvas.SizeY-80);
   Canvas.SetDrawColor(255,255,255);
   Canvas.DrawText("Mouse Wheel: Increase / decrease roaming speed");

   Canvas.SetPos(10, Canvas.SizeY-65);
   Canvas.SetDrawColor(255,255,255);
   Canvas.DrawText("P: Create new camera point");

   Canvas.SetPos(10, Canvas.SizeY-50);
   Canvas.SetDrawColor(255,255,255);
   Canvas.DrawText("Ctrl: Toggle 'look where player looks'");

   Canvas.SetPos(10, Canvas.SizeY-35);
   Canvas.SetDrawColor(255,255,255);
   Canvas.DrawText("Alt: Attach to closest player / Detach from player");

   Canvas.SetPos(10, Canvas.SizeY-20);
   Canvas.SetDrawColor(255,255,255);
   Canvas.DrawText("Enter: Show menu");

   if(showHealthBars == false)
   { 
	return;
   }

   if(GetSpecPlayerInfoByController(ViewportOwner.Actor).AttachedActor!=None)
   {
	return;
   }
	
   // Get vectors for where the player is aiming on each axis
   GetAxes(ViewportOwner.Actor.Rotation, X, Y, Z);

   foreach ViewportOwner.Actor.VisibleActors(class'Pawn', P)
   {	
	render = true;

        if (P == None)
	{
            return;
	}
	
	if(Rook(P) == None)
	{
 	   render=false;
	}

	if(BaseDevice(P) != None && BaseDevice(P).bCanBeDamaged == false)
	{
           render=false;
	}

	if(Character(P) == None && Vehicle(P) == None && BaseDevice(P) == None)
	{
	   render=false;
	}

	if(P.health <= 0)
	{
	   render=false;
	}
	
	// Only deal with actor's within the ~45 degrees in front of the player
    	if (render == true && normal(X) dot normal(P.Location - ViewportOwner.Actor.Location) >= 0.7)
    	{      		
	   RenderPawnDisplay(P.health, Canvas, Rook(P));
    	}
   }
}


function RenderPawnDisplay(float health, canvas Canvas, Rook p)
{
	local Color oldColor;
	local int healthBarHeight, shieldBarHeight;
	local float healthPerc;
        local vector ScreenLocation;
	local float barWidth;
	local float healthMax;
   	local SpecPlayerInfo spiRes;
	local float x;
	local float y;
	local float distance;

	distance=VSize(P.Location-ViewportOwner.Actor.Location);		

	if(distance > 5000)
	{
		return;
	}
 
	healthMax = p.HealthMaximum;
	barWidth = 10 + (25-(distance/200));

	ScreenLocation = WorldToScreen(P.location, Canvas.Viewport.Actor.Location, ViewportOwner.Actor.GetViewRotation());

	healthBarHeight = 4 - (distance/1000);
	shieldBarHeight = 2;
	
	// render the status meter	
	x = ScreenLocation.X-barWidth/2-1;
	y = ScreenLocation.Y+8;

	Canvas.SetPos(x, y);
	Canvas.SetDrawColor(p.team().TeamColor.R*0.8,p.team().TeamColor.G*0.8,p.team().TeamColor.B*0.8);
	Canvas.DrawBox(Canvas, barWidth+1, healthBarHeight+1);

	Canvas.SetPos(x+1, y+1);
	Canvas.SetDrawColor(p.team().TeamColor.R,p.team().TeamColor.G,p.team().TeamColor.B);
	Canvas.DrawRect(Canvas.WhiteTex, barWidth*(health/healthMax), healthBarHeight);

	y = y + healthBarHeight + 3;
	
	// get our extended player info class
	spiRes = GetSpecPlayerInfo(p);

	if(spiRes != None && spiRes.energyMax > 0)
	{
	    // render jetpack meter
            Canvas.SetPos(x, y);
            Canvas.SetDrawColor(200,200,200);
            Canvas.DrawBox(Canvas, barWidth+1, healthBarHeight+1);

            Canvas.SetPos(x+1, y+1);
            Canvas.SetDrawColor(255,255,255);
            Canvas.DrawRect(Canvas.WhiteTex, barWidth*(spiRes.energy/spiRes.energyMax), healthBarHeight);

	    y = y + healthBarHeight + 3;
        }

	if(P.PlayerReplicationInfo != None)
	{
		Canvas.SetPos(x, y);
            	Canvas.SetDrawColor(255,255,255);
		Canvas.DrawText(P.PlayerReplicationInfo.PlayerName);
	}
}

function Actor FindClosestActor()
{
   local float distance;
   local Actor closestActor;
   local float closestDistance;
   local bool  render;
   local Pawn  P;

   closestDistance = 1000000000;

   foreach ViewportOwner.Actor.VisibleActors(class'Pawn', P)
   {	
	render = true;
	
	if(Rook(P) == None)
	{
 	   render=false;
	}

	if(BaseDevice(P) != None && BaseDevice(P).bCanBeDamaged == false)
	{
           render=false;
	}

	if(Character(P) == None && Vehicle(P) == None && BaseDevice(P) == None)
	{
	   render=false;
	}

	if(P.health <= 0)
	{
	   render=false;
	}
	
	distance = VSize(P.Location-ViewportOwner.Actor.Location);

	if(Character(P) != None)
	{
		if(distance < closestDistance)
		{
			closestDistance = distance;
			closestActor = P;
		}
	}
    }	

    return closestActor;
}

function TribesGUI.TribesGUIController FindGUIController()
{
 	local int i;

        for(i=0; i<ViewportOwner.Actor.Player.InteractionMaster.GlobalInteractions.Length; i++)
	{
		if(ViewportOwner.Actor.Player.InteractionMaster.GlobalInteractions[i].Class==class'TribesGUI.TribesGUIController')
		{
			return TribesGUI.TribesGUIController(ViewportOwner.Actor.Player.InteractionMaster.GlobalInteractions[i]);
		}		
	}

	return None;
}

function RegisterMutator(SpecMutator mut) {
  // Set instance of the mutator that has add this Interaction
  M = mut;
}

Function Tick(Float TimeDelta) {

  // If mutator that responsible for
  // adding this Interaction is gone
  if(M == None) {
    // Remove this Interaction (destroy self)
    Master.RemoveInteraction(Self);
  }
}

defaultproperties
{
	bActive=True
	bVisible=True
  	bRequiresTick=True,
	showHealthBars=true
}