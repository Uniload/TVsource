class TribesDebugHUD extends TribesHUD;

import enum AnimationStateEnum from Gameplay.Character;
import enum MovementState from Gameplay.Ragdoll;

var Pathfinding.PFTestHarness pathfindTestHarness;
var NavigationTestHarness navigationTestHarness;
var string NavigationTestHarnessClass;

// AI Debug stuff
var SquadInfo debugSquadInfo;	// Squad for whom Formation debug info is being displayed

// Weapon debug stuff
var bool playerWeaponDebug;	// Show debug for the current weapon

var Font hugeFont;

//
// Draws the HUD - normally would just call the HUDScript 
// to draw, but this one is used for debug data, so just 
// paint your stuff in here
//
function DrawHUD(Canvas canvas)
{
	if (animationDebug(canvas))
	    return;

    movementDebug(canvas);
}


function bool animationDebug(Canvas canvas)
{
    local int i;
    local int extra;

    local String text;
	local float textWidth;
	local float textHeight;
	
    local float spacingWidth;
    local float spacingHeight;

	local float windowLeft;
	local float windowTop;
	local float windowWidth;
	local float windowHeight;

    local float textLeft;
    local float textTop;
    
	local Rotator windowRotator;
	local Vector windowOffset;
    
    local PlayerCharacterController controller;
    local Gameplay.Character character;

    controller = PlayerCharacterController(PlayerOwner);
    
    if (controller!=None && controller.animationDebugCounter>0)
    {
        character = Gameplay.Character(controller.pawn);
        
        if (character!=None)
        {
            // draw animation view window
        
            windowWidth = Canvas.ClipX;
            windowHeight = Canvas.ClipY;
        
            windowLeft = (Canvas.ClipX - windowWidth) / 2;
            windowTop = (Canvas.ClipY - windowHeight) / 2;
        
            windowRotator.Pitch = 0;
            windowRotator.Roll = 0;
            windowRotator.Yaw = 0;

            windowOffset = Vect(-150,0,0) << windowRotator;
        
            canvas.DrawPortal(windowLeft, windowTop, windowWidth, windowHeight, controller.pawn, controller.pawn.location + windowOffset, windowRotator);

            if (controller.animationDebugCounter>1)
            { 
                // header
            
		        text = "animation system";

    	        canvas.Font = MedFont;

                spacingWidth = Canvas.ClipX / 30;
                spacingHeight = Canvas.ClipY / 30;

		        canvas.SetPos(spacingWidth, spacingHeight);
		        canvas.SetDrawColor(255, 255, 255);
        		
		        canvas.DrawText(text);

                // key data
                    
        	    canvas.Font = SmallFont;

                canvas.TextSize("text", textWidth, textHeight);
       	    
       	        textHeight *= 0.8;
       	    
       	        textLeft = spacingWidth;
       	        textTop = spacingHeight * 3.35;
       	    
		        canvas.SetPos(textLeft, textTop);
		        canvas.DrawText("current state: "$animationStateString(character.animationManager.currentAnimationState));	

		        canvas.SetPos(textLeft, textTop + textHeight);
		        if (character.animationManager.desiredAnimationState!=character.animationManager.currentAnimationState)
		            canvas.DrawText("desired state: "$animationStateString(character.animationManager.desiredAnimationState)$" ["$character.animationManager.desiredAnimationStateTime$"]");
		        else
		            canvas.DrawText("desired state: "$animationStateString(character.animationManager.desiredAnimationState));

		        canvas.SetPos(textLeft, textTop + textHeight*2);
		        if (character.animationManager.adjustedAnimationState!=character.animationManager.currentAnimationState)
		            canvas.DrawText("adjusted state: "$animationStateString(character.animationManager.adjustedAnimationState)$" ["$character.animationManager.adjustedAnimationStateTime$"]");
		        else
		            canvas.DrawText("adjusted state: "$animationStateString(character.animationManager.adjustedAnimationState));

		        canvas.SetPos(textLeft, textTop + textHeight*4);
		        if (character.animationManager.primaryAnimationLayerState!=AnimationState_None)
		            canvas.DrawText("primary layer: "$animationStateString(character.animationManager.primaryAnimationLayerState)$" "$alertnessString(character.animationManager.primaryAnimationLayerAlertness));
		        else
		            canvas.DrawText("primary layer: none");

		        canvas.SetPos(textLeft, textTop + textHeight*5);
		        if (character.animationManager.secondaryAnimationLayerState!=AnimationState_None)
		            canvas.DrawText("secondary layer: "$animationStateString(character.animationManager.secondaryAnimationLayerState)$" "$alertnessString(character.animationManager.secondaryAnimationLayerAlertness));
		        else
		            canvas.DrawText("secondary layer: none");

		        canvas.SetPos(textLeft, textTop + textHeight*7);
		        canvas.DrawText("current alertness: "$alertnessString(character.animationManager.currentAlertnessLevel));

		        canvas.SetPos(textLeft, textTop + textHeight*8);
		        canvas.DrawText("adjusted alertness: "$alertnessString(character.animationManager.adjustedAlertnessLevel));

                extra = 0;

                for (i=0; i<23; i++)
                {
                    if (i==7 || i==14 || i==21)
                        extra ++;
                    
		            canvas.SetPos(textLeft, textTop + textHeight*(11+i+extra));
		            if (character.animationChannels[i].processed!="")
    		            canvas.DrawText("channel "$i$": "$character.animationChannels[i].processed$" ["$character.animationChannels[i].alpha$"]");
    		        else
    		            canvas.DrawText("channel "$i$":");
               } 

                if (character.animationManager.extraAnimationPending)               
                {
		            canvas.SetPos(textLeft, textTop + textHeight*(11+i+extra)+3);
		            canvas.DrawText("extra animation pending: "$character.animationManager.extraAnimationPendingName$" ["$character.animationManager.extraAnimationPendingTime);
		        }
		    }
	    }
	    
	    return true;
	}
	
	return false;
}


function string animationStateString(Character.AnimationStateEnum state)
{
	switch (state)
	{
        case AnimationState_None:       return "none";
	    case AnimationState_Stand:      return "stand";
	    case AnimationState_Walk:       return "walk";
	    case AnimationState_Run:        return "run"; 
	    case AnimationState_Sprint:     return "sprint";
	    case AnimationState_Ski:        return "ski";
	    case AnimationState_Slide:      return "slide";
	    case AnimationState_Stop:       return "stop";
	    case AnimationState_Airborne:   return "airborne";
	    case AnimationState_AirControl: return "aircontrol";
	    case AnimationState_Thrust:     return "thrust";
	    case AnimationState_Swim:       return "swim";
	}
}


function string alertnessString(Rook.AlertnessLevels level)
{
	switch (level)
	{
        case Alertness_Combat:  return "combat";
        case Alertness_Alert:   return "alert";
        case Alertness_Neutral: return "neutral";
	}
}


function bool movementDebug(Canvas canvas)
{
    local float spacingWidth;
    local float spacingHeight;

    local string text;
    local float textWidth;
    local float textHeight;
    local float speedTextWidth;
    local float speedTextHeight;
    local float textLeft;
    local float textTop;
    
    local int speed;
    local float speedAlpha;

    local Character character;
    local PlayerCharacterController controller;

	character = Character(PlayerOwner.ViewTarget);
	if (character != None)
		controller = PlayerCharacterController(character.controller);    
	
	if (character!=None && character.Physics==PHYS_Movement && controller!=None && controller.movementDebugCounter>0)
	{
        spacingWidth = Canvas.ClipX / 30;
        spacingHeight = Canvas.ClipY / 30;

        if (controller.movementDebugCounter>1)
        {
            // header
        
		    text = "movement system";

    	    canvas.Font = MedFont;

		    canvas.SetPos(spacingWidth, spacingHeight);
		    canvas.SetDrawColor(255, 255, 255);
        	
		    canvas.DrawText(text);

            // states
                
        	canvas.Font = SmallFont;

            canvas.TextSize("text", textWidth, textHeight);
       	
       	    textHeight *= 0.8;
       	
       	    textLeft = spacingWidth;
       	    textTop = spacingHeight * 3.35;
       	
		    canvas.SetPos(textLeft, textTop);
		    canvas.DrawText("movement state: "$movementStateString(character.movement));	

            // speeds

		    canvas.SetPos(textLeft, textTop + textHeight*2);
		    canvas.DrawText("total speed: "$character.movementSpeed$" kph");	

		    canvas.SetPos(textLeft, textTop + textHeight*3);
		    canvas.DrawText("horizontal speed: "$character.movementHorizontalSpeed$" kph");	

		    canvas.SetPos(textLeft, textTop + textHeight*4);
		    canvas.DrawText("vertical speed: "$character.movementVerticalSpeed$" kph");	

		    canvas.SetPos(textLeft, textTop + textHeight*5);
		    canvas.DrawText("tangential speed: "$character.movementTangentialSpeed$" kph");	

		    canvas.SetPos(textLeft, textTop + textHeight*6);
		    canvas.DrawText("directional speed: "$character.movementDirectionalSpeed$" kph");	

            // altitude

		    canvas.SetPos(textLeft, textTop + textHeight*8);
		    canvas.DrawText("altitude: "$character.movementAltitude$" meters");	

            // context

		    canvas.SetPos(textLeft, textTop + textHeight*10);
		    canvas.DrawText("collided: "$int(character.movementCollided));
		    
		    canvas.SetPos(textLeft, textTop + textHeight*11);
		    canvas.DrawText("close: "$int(character.movementClose));
		    
		    canvas.SetPos(textLeft, textTop + textHeight*12);
		    canvas.DrawText("touching: "$int(character.movementTouching));
		    
		    canvas.SetPos(textLeft, textTop + textHeight*13);
		    canvas.DrawText("grounded: "$int(character.movementGrounded));
		    
		    canvas.SetPos(textLeft, textTop + textHeight*14);
		    canvas.DrawText("airborne: "$int(character.movementAirborne));
		    
		    canvas.SetPos(textLeft, textTop + textHeight*15);
		    canvas.DrawText("water: "$int(character.movementWater));
		    
		    canvas.SetPos(textLeft, textTop + textHeight*16);
		    canvas.DrawText("underwater: "$int(character.movementUnderWater));
		    
		    canvas.SetPos(textLeft, textTop + textHeight*17);
		    canvas.DrawText("zero-g: "$int(character.movementZeroGravity));
		    
		    canvas.SetPos(textLeft, textTop + textHeight*18);
		    canvas.DrawText("elevator: "$int(character.movementElevator));
		    
		    // internal flags
		    
		    canvas.SetPos(textLeft, textTop + textHeight*20);
		    canvas.DrawText("resting: "$int(character.movementResting));
		    
		    canvas.SetPos(textLeft, textTop + textHeight*21);
		    canvas.DrawText("dynamic: "$int(character.movementDynamic));
		    
		    canvas.SetPos(textLeft, textTop + textHeight*22);
		    canvas.DrawText("pushing: "$int(character.movementPushing));
		    
		    // floor normal
		    
		    canvas.SetPos(textLeft, textTop + textHeight*24);
		    canvas.DrawText("floor normal: "$character.movementNormal.x$", "$character.movementNormal.y$", "$character.movementNormal.z);
		    
            // chaos scales

		    canvas.SetPos(textLeft, textTop + textHeight*26);
		    canvas.DrawText("splash chaos: "$character.movementSplashChaos);

		    canvas.SetPos(textLeft, textTop + textHeight*27);
		    canvas.DrawText("impulse chaos: "$character.movementImpulseChaos);

            // water data
		    
		    canvas.SetPos(textLeft, textTop + textHeight*30);
		    canvas.DrawText("water penetration: "$character.movementWaterPenetration);
		    
		    // character dimensions
		    
		    canvas.SetPos(textLeft, textTop + textHeight*32);
		    canvas.DrawText("sphere radius: "$character.movementSphereRadius);
		    
		    canvas.SetPos(textLeft, textTop + textHeight*33);
		    canvas.DrawText("sphyll radius: "$character.movementSphyllRadius);
		    
		    canvas.SetPos(textLeft, textTop + textHeight*34);
		    canvas.DrawText("shyll half height: "$character.movementSphyllHalfHeight);
        }
        
        // draw speedo in bottom right
        
        speed = int(character.movementSpeed);
        if (speed<10)
            text = "  "$string(speed)$ " kph";
        else if (speed<100)
            text = " "$string(speed)$" kph";
        else
            text = string(speed)$" kph";

    	canvas.Font = hugeFont;

		canvas.TextSize(text, speedTextWidth, speedTextHeight);

		canvas.SetPos(canvas.ClipX-speedTextWidth-spacingWidth/6, canvas.ClipY-speedTextHeight-spacingHeight/6);
		
		speedAlpha = speed / 30.0 * 255.0;
		if (speedAlpha<1)
		    speedAlpha = 1;
		else if (speedAlpha>255)
		    speedAlpha = 255;
		    
		if (character.movementAirborne)
		    speedAlpha = 255;
		
		canvas.SetDrawColor(255, 255, 255, speedAlpha);
    	
		canvas.DrawText(text);	
            
		return true;
	}
	
	return false;
}

function string movementStateString(Ragdoll.MovementState movementState)
{
	switch (movementState)
	{
	    case MovementState_Stand:       return "stand";
	    case MovementState_Walk:        return "walk";
	    case MovementState_Run:         return "run";
	    case MovementState_Sprint:      return "sprint";
	    case MovementState_Ski:         return "ski";
	    case MovementState_Slide:       return "slide";
	    case MovementState_Stop:        return "stop";
	    case MovementState_Airborne:    return "airborne";
	    case MovementState_AirControl:  return "aircontrol";
	    case MovementState_Thrust:      return "thrust";
	    case MovementState_Swim:        return "swim";
	    case MovementState_Float:       return "float";
	    case MovementState_Skim:        return "skim";
	    case MovementState_ZeroGravity: return "zero-g";
	    case MovementState_Elevator:    return "elevator";
        default:                        return "unknown?";
	}
}


// Key events - might want these for turning on and off 
// specific debug views.
function bool KeyType( EInputKey Key, optional string Unicode )
{
	if(HUDscript != None)
		return HUDScript.KeyType(Key, Unicode, response);
	return false;
}

function bool KeyEvent( EInputKey Key, EInputAction Action, FLOAT Delta )
{
	if(HUDscript != None)
		return HUDScript.KeyEvent(Key, Action, delta, response);
	return false;
}

simulated event PostBeginPlay()
{
	local class<NavigationTestHarness> navigationTestClassInstance;

	Super.PostBeginPlay();

	Label = 'HUD';

	// spawn and initialise pathfinding system test harness
	pathfindTestHarness = spawn(class'PFTestHarness', self);
	pathfindTestHarness.initialise(self);

	// spawn and initialise navigation system test harness
	navigationTestClassInstance = class<NavigationTestHarness>(DynamicLoadObject(NavigationTestHarnessClass, class'Class'));
	navigationTestHarness = spawn(navigationTestClassInstance, self);
	navigationTestHarness.initialise(self);
}

simulated event WorldSpaceOverlays()
{
	local Rook viewTarget;

	// for jetting/skiing debug
	local int i;
	local Vector X;
	local Vector Y;
	local Vector Z;
	local Vector loc;
	local Vector lastLoc;
	local Vector directionXY;
	local float velocityXY;
	local float velocityZ;
	local float RTK;
	local int pointsN;

	Super.WorldSpaceOverlays();

	pathfindTestHarness.drawDebug();

	viewTarget = Rook(PlayerOwner.ViewTarget);

	if (bShowDebugInfo && viewTarget != None && viewTarget.Controller != None)
	{
		viewTarget.Controller.displayWorldSpaceDebug(self);
		viewTarget.displayWorldSpaceDebug(self);
	}

	// Squad (Formations) debug
	if ( debugSquadInfo != None )
		for ( i = 0; i < debugSquadInfo.pawns.length; i++ )
			Draw3DLine(Rook(debugSquadInfo.pawns[i]).Location, Rook(debugSquadInfo.pawns[i]).desiredLocation, class'Canvas'.Static.MakeColor(200, 255, 200) );

	// Sensing debug
	if ( viewTarget != None && viewTarget.bShowSensingDebug )
		viewTarget.DrawVisionCone( self );

	// jetpacking/skiing debug
	if ( viewTarget != None && viewTarget.bShowJSDebug && viewTarget.Controller != None )
	{
		// display simulated path of character were he to stop jetpacking now
		// (done here and not in displayWorldSpaceDebugJettingSkiing
		// so it can be displayed for player characters, too)
		RTK = 0.1;				// time in seconds between trajectory points
		pointsN = 50;			// number of points

		loc = viewTarget.Location;
		viewTarget.GetAxes( Character(viewTarget).motor.getMoveRotation(), X, Y, Z );	// X is direction
		directionXY.X = X.X;
		directionXY.Y = X.Y;
		directionXY /= VSize( directionXY );	// normalize
		velocityXY = sqrt( viewTarget.Velocity.X * viewTarget.Velocity.X + viewTarget.Velocity.Y * viewTarget.Velocity.Y );
		velocityZ = viewTarget.Velocity.Z;;

		for ( i = 0; i < pointsN; i++ )
		{
			lastLoc = loc;

			velocityZ -= RTK * (9.81f*80.0f);
			loc.Z = loc.Z + RTK * velocityZ;
			loc = loc + directionXY * RTK * velocityXY;

			Draw3DLine( lastLoc, loc, class'Canvas'.Static.MakeColor(255, 0, 0));
		}
	}

	if(playerWeaponDebug)
	{
		if (Character(PlayerOwner.ViewTarget) != None && Character(PlayerOwner.ViewTarget).weapon != None)
		{
			Character(PlayerOwner.ViewTarget).weapon.drawDebug(self);
		}
	}
}

//------------------------------------------------------------------------
// draws a 3D box

function draw3DBox(Vector minCorner, Vector maxCorner, color lineColor)
{
	local Vector a;
	local Vector b;
	local Vector c;

	local Vector d;
	local Vector e;
	local Vector f;

	// Oh - I'm sure someone will tell me about a better way to perform these initializations...
	a.x = maxCorner.x;
	a.y = minCorner.y;
	a.z = minCorner.z;
	b.x = maxCorner.x;
	b.y = maxCorner.y;
	b.z = minCorner.z;
	c.x = minCorner.x;
	c.y = maxCorner.y;
	c.z = minCorner.z;

	d.x = minCorner.x;
	d.y = maxCorner.y;
	d.z = maxCorner.z;
	e.x = minCorner.x;
	e.y = minCorner.y;
	e.z = maxCorner.z;
	f.x = maxCorner.x;
	f.y = minCorner.y;
	f.z = maxCorner.z;

	// lower rectangle (in z)
	Draw3DLine(minCorner, a, lineColor);
	Draw3DLine(a,         b, lineColor);
	Draw3DLine(b,         c, lineColor);
	Draw3DLine(c, minCorner, lineColor);

	// upper rectangle (in z)
	Draw3DLine(maxCorner, d, lineColor);
	Draw3DLine(d,         e, lineColor);
	Draw3DLine(e,         f, lineColor);
	Draw3DLine(f, maxCorner, lineColor);

	// connecting vertical struts
	Draw3DLine(minCorner, e, lineColor);
	Draw3DLine(a,         f, lineColor);
	Draw3DLine(b, maxCorner, lineColor);
	Draw3DLine(c,         d, lineColor);
}

// navigation test harness hooks
exec function restartNavigationTest()
{
	navigationTestHarness.restart();
}
exec function markNavigationPoint()
{
	navigationTestHarness.markPoint();
}
exec function toggleNavigationTest()
{
	navigationTestHarness.toggleEnabled();
}

// pathfinding test harness hooks
exec function pathfindDebug()
{
	pathfindTestHarness.pathfindDebug();
}
exec function pathfindMarkPoint()
{
	pathfindTestHarness.pathfindMarkPoint();
}
exec function showPathNodes()
{
	pathfindTestHarness.showPathNodes();
}
exec function showReach()
{
	pathfindTestHarness.toggleShowReach();
}
exec function pathfindDiagnostics()
{
	pathfindTestHarness.diagnostics();
}
exec function pathfindStep()
{
	pathfindTestHarness.toggleStep();
}
exec function traversalCheck()
{
	pathfindTestHarness.toggleTraversalCheck();
}
exec function pathfindNextStep()
{
	pathfindTestHarness.Step();
}
exec function showNavigationQuadtree()
{
	pathfindTestHarness.toggleShowQuadtree();
}
exec function markPointHere()
{
	pathfindTestHarness.markPointHere();
}

// vehicle test hooks
exec function showVehiclePhysics()
{
	local Vehicle vehicleInstance;
	vehicleInstance = Vehicle(playerOwner.Pawn);
	if (vehicleInstance == None)
		log("Not Driving a Vehicle");
	else
		vehicleInstance.toggleShowPhysicsDebug();
}

//-----------------------------------------------------------------------------
// Show squad debug info for a SquadInfo
// 'index' is the index of the rook in level

exec function debugSquad( int index )
{
	local SquadInfo squad;
	local Rook rook;
	local int actorindex;
	local int i;

	if ( index < 0 && debugSquadInfo != None )
	{
		for ( i = 0; i < debugSquadInfo.pawns.length; i++ )
		{
			rook = Rook(debugSquadInfo.pawns[i]);
			rook.bShowSquadDebug = false;
		}
		debugSquadInfo = None;
	}
	else
	{
		actorIndex = 0;
		foreach AllActors( class'SquadInfo', squad )
		{
			log("Squad.name: " $ squad.name );
			if ( actorIndex == index )
			{
				if ( debugSquadInfo != None )
					for ( i = 0; i < debugSquadInfo.pawns.length; i++ )
					{
						rook = Rook(debugSquadInfo.pawns[i]);
						rook.bShowSquadDebug = false;
					}
				debugSquadInfo = squad;
				for ( i = 0; i < debugSquadInfo.pawns.length; i++ )
				{
					rook = Rook(debugSquadInfo.pawns[i]);
					rook.bShowSquadDebug = true;
				}
			}
			actorIndex++;
		}

		log( "debugSquadInfo:" @ debugSquadInfo );
	}
}

exec function debugPlayerWeapon()
{
	playerWeaponDebug = true;
}

// Temporary function to quickly display shadowed text
simulated function drawShadowedText(canvas Canvas, String text, int x, int y)
{
	Canvas.Font = SmallFont;
	Canvas.SetPos(x+1, y+1);
	Canvas.SetDrawColor(80, 80, 80);
	Canvas.DrawText(text);
	Canvas.SetPos(x, y);
	Canvas.SetDrawColor(255, 255, 255);
	Canvas.DrawText(text);
}

// Temporary function to quickly display shadowed text
simulated function drawJustifiedShadowedText(canvas Canvas, String text, int x, int y, int x1, int y1, int justify)
{
	local Color color;

	color = Canvas.DrawColor;

	Canvas.Font = SmallFont;
	Canvas.SetDrawColor(80, 80, 80);
	Canvas.DrawTextJustified(text, justify, x+1, y+1, x1, y1);
	Canvas.SetDrawColor(color.r, color.g, color.b, color.a);
	Canvas.DrawTextJustified(text, justify, x, y, x1, y1);
}

// draws the current team and player scores
simulated function drawScores(Canvas C, optional int y)
{
	local PlayerCharacterController PC;
	local float textSizeX, textSizeY;
	local int i, j, x;
	local Array<int> scoreVals;
	local Array<string> scoreNames;
	local Array<TribesReplicationInfo> sortedTRIList;
	local PlayerReplicationInfo P;
	local Character char;
	local TeamInfo team;

	PC = PlayerCharacterController(PlayerOwner);
	if (PC == None)
		return;

	char = Character(PlayerOwner.Pawn);
	if (char == None)
		return;

	C.Font = SmallFont;
	C.TextSize("W", textSizeX, textSizeY);

	// Team Scores
	scoreNames.Length = 0;
	scoreVals.Length = 0;
	C.SetDrawColor(255, 255, 255);
	ForEach DynamicActors(class'TeamInfo', team)
	{
		// sort by score
		i = 0;
		if ( scoreVals.length > 0 )
			while ( i < scoreVals.length && scoreVals[i] > team.Score )
				i++;

		scoreVals.Insert(i, 1);
		scoreVals[i] = team.Score;
		scoreNames.Insert(i, 1);
		scoreNames[i] = string(team.Label);
	}

	if (y == 0)
	{
		y = 0.1 * C.ClipY;
	}

	x = 0.1 * C.ClipX;

	C.SetPos(x + (0.8 * C.ClipX * 0.0), y - textSizeY - 3);
	C.DrawText("Team");

	C.SetPos(x + (0.8 * C.ClipX * 0.22), y - textSizeY - 3);
	C.DrawText("Score");

	C.SetPos(x, y);
	C.DrawRect(C.WhiteTex, 0.8 * C.ClipX, 1);

	C.SetPos(x + (0.8 * C.ClipX * 0.22) - 5, y - textSizeY);
	C.DrawRect(C.WhiteTex, 1, (scoreVals.Length + 1) * textSizeY);

	y += 2;

	for (i = 0; i < scoreVals.Length; i++)
	{
		if (scoreNames[i] == string(char.team().Label))
			C.SetDrawColor(255, 0, 0);
		else
			C.SetDrawColor(255, 255, 255);

		drawJustifiedShadowedText(C, scoreNames[i], x + (0.8 * C.ClipX * 0.0), y, x + (0.8 * C.ClipX * 0.7), y + 0.03 * C.ClipY, 0);
		drawJustifiedShadowedText(C, string(scoreVals[i]), x + (0.8 * C.ClipX * 0.22), y, x + (0.8 * C.ClipX * 1.0), y + 0.03 * C.ClipY, 0);

		y += 0.03 * C.ClipY;
	}

	y += 40;

	// Player Scores
	scoreNames.Length = 0;
	scoreVals.Length = 0;
	C.SetDrawColor(255, 255, 255);

	for (j = 0; j < PlayerOwner.GameReplicationInfo.PRIArray.Length; j++)
	{
		P = tribesReplicationInfo(PlayerOwner.GameReplicationInfo.PRIArray[j]);

		// sort by score
		i = 0;
		if ( scoreVals.length > 0 )
			while ( i < scoreVals.length && scoreVals[i] > P.Score )
				i++;

		sortedTRIList.Insert(i, 1);
		sortedTRIList[i] = tribesReplicationInfo(P);
		scoreVals.Insert(i, 1);
		scoreVals[i] = P.Score;
		scoreNames.Insert(i, 1);
		scoreNames[i] = P.PlayerName;
	}

	x = 0.1 * C.ClipX;

	C.SetPos(x + (0.8 * C.ClipX * 0.0), y - textSizeY - 3);
	C.DrawText("Player");

	C.SetPos(x + (0.8 * C.ClipX * 0.22), y - textSizeY - 3);
	C.DrawText("Score");


	C.SetPos(x + (0.8 * C.ClipX * 0.22 + 60), y - textSizeY - 3);
	C.DrawText("O");

	C.SetPos(x + (0.8 * C.ClipX * 0.22 + 90), y - textSizeY - 3);
	C.DrawText("D");

	C.SetPos(x + (0.8 * C.ClipX * 0.22 + 120), y - textSizeY - 3);
	C.DrawText("S");

	for (j=0; j < sortedTRIList[0].statDataList.Length; j++)
	{
		C.SetPos(x + (0.8 * C.ClipX * 0.22 + 180 + j*50), y - textSizeY - 3);
		C.DrawText(char.tribesReplicationInfo.statDataList[j].statClass.default.acronym);
	}

	C.SetPos(x, y);
	C.DrawRect(C.WhiteTex, 0.8 * C.ClipX, 1);

	C.SetPos(x + (0.8 * C.ClipX * 0.22) - 5, y - textSizeY);
	C.DrawRect(C.WhiteTex, 1, (scoreVals.Length + 1) * textSizeY);

	y += 2;

	P = char.tribesReplicationInfo;

	for (i = 0; i < sortedTRIList.Length; i++)
	{
		if (sortedTRIList[i].PlayerName == P.PlayerName)
			C.SetDrawColor(255, 0, 0);
		else
			C.SetDrawColor(255, 255, 255);

		drawJustifiedShadowedText(C, sortedTRIList[i].PlayerName, x + (0.8 * C.ClipX * 0.0), y, x + (0.8 * C.ClipX * 0.7), y + 0.03 * C.ClipY, 0);
		drawJustifiedShadowedText(C, string(int(sortedTRIList[i].Score)), x + (0.8 * C.ClipX * 0.22), y, x + (0.8 * C.ClipX * 1.0), y + 0.03 * C.ClipY, 0);
		drawJustifiedShadowedText(C, string(sortedTRIList[i].offenseScore), x + (0.8 * C.ClipX * 0.22+60), y, x + (0.8 * C.ClipX * 1.0), y + 0.03 * C.ClipY, 0);
		drawJustifiedShadowedText(C, string(sortedTRIList[i].defenseScore), x + (0.8 * C.ClipX * 0.22+90), y, x + (0.8 * C.ClipX * 1.0), y + 0.03 * C.ClipY, 0);
		drawJustifiedShadowedText(C, string(sortedTRIList[i].styleScore), x + (0.8 * C.ClipX * 0.22+120), y, x + (0.8 * C.ClipX * 1.0), y + 0.03 * C.ClipY, 0);
		for (j=0; j < sortedTRIList[i].statDataList.Length; j++)
		{
			drawJustifiedShadowedText(C, string(sortedTRIList[i].statDataList[j].amount), x + (0.8 * C.ClipX * 0.22 + 180 + j*50), y, x + (0.8 * C.ClipX * 1.0), y + 0.03 * C.ClipY, 0);
		}
		y += 0.03 * C.ClipY;
	}
}

// drawBox
function drawBox(canvas C, int x, int y, int w, int h, optional int size)
{
	if (size == 0)
		size = 1;

	C.SetPos(X, Y);
	C.DrawRect(C.WhiteTex, size, h);
	C.DrawRect(C.WhiteTex, w, size);
	C.SetPos(X + w, Y);
	C.DrawRect(C.WhiteTex, size, h);
	C.SetPos(X, Y + h);
	C.DrawRect(C.WhiteTex, w+size, size);
	C.SetPos(X, Y);
}

// LocalizedMessage
simulated function LocalizedMessage( class<LocalMessage> Message, optional int Switch, optional Core.Object Related1, optional Core.Object Related2, optional Core.Object OptionalObject, optional string CriticalString, optional string OptionalString )
{
	PlayerOwner.ClientMessage( Message.static.GetString(Switch, Related1, Related2, OptionalObject, OptionalString) );
}


//=============================================================================

defaultProperties
{
	NavigationTestHarnessClass = "Tyrion.ConcreteNavigationTest"

	ConsoleMessagePosY = 0.6
	ConsoleMessageCount=8

	HUDScriptType = "TribesGUI.TribesDebugHUDScript"

    hugeFont = font'TribesFonts.Tahoma24'	
}

//hugeFont = font'UWindowFonts.TahomaB30'
