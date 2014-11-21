// ConsoleCommandManager
// Put console commands here if they should be executable in multiplayer as well as singleplayer
class ConsoleCommandManager extends Engine.CheatManager
	native;

// Show AI debug info for a character
exec function debugAI( optional Name aiLabel )
{
	local PlayerCharacter pc;
	local Rook rook;

	pc = PlayerCharacter(Level.GetLocalPlayerController().Pawn);
	//rook = Rook(pcc.viewTarget);

	forEach AllActors(class'Rook', rook)
		if ( (aiLabel == '' && !rook.IsHumanControlled() && pc.IsInVisionCone( rook, 3000 ) )
			|| (aiLabel != '' && (aiLabel == rook.label || aiLabel == rook.name )))
		{
			log( "Toggling AI debug on" @ rook.name @ "(" @ rook.label @ "):" @ !rook.bShowTyrionCharacterDebug );
			rook.bShowTyrionCharacterDebug = !rook.bShowTyrionCharacterDebug;
			rook.bShowTyrionMovementDebug = !rook.bShowTyrionMovementDebug;
			rook.bShowTyrionWeaponDebug = !rook.bShowTyrionWeaponDebug;
		}
}

exec function debugNav( optional Name aiLabel )
{
	local PlayerCharacter pc;
	local Rook rook;

	pc = PlayerCharacter(Level.GetLocalPlayerController().Pawn);

	forEach AllActors(class'Rook', rook)
		if ( (aiLabel == '' && !rook.IsHumanControlled() && pc.IsInVisionCone( rook, 3000 ) )
			|| (aiLabel != '' && (aiLabel == rook.label || aiLabel == rook.name )))
		{
			log( "Toggling Navigation debug on" @ rook.name @ "(" @ rook.label @ "):" @ !rook.bShowNavigationDebug );
			rook.bShowNavigationDebug = !rook.bShowNavigationDebug;
		}
}

exec function disableAI( optional Name aiLabel )
{
	local Pawn pawn;
	local SquadInfo squad;

	forEach AllActors(class'Pawn',pawn)
		if ( aiLabel == '' || aiLabel == pawn.label || aiLabel == pawn.name )
		{
			log( "Shutting down" @ pawn.name @ "(" @ pawn.label @ ")" );
			level.AI_Setup.setAILOD( pawn, AILOD_None );
		}

	forEach AllActors(class'SquadInfo',squad)
		if ( aiLabel == '' || aiLabel == squad.label || aiLabel == squad.name )
		{
			log( "Shutting down" @ squad.name @ "(" @ squad.label @ ")" );
			squad.AI_LOD_Level = AILOD_None;
		}
}

exec function debugSensing( optional Name aiLabel )
{
	local Rook rook;

	forEach AllActors(class'Rook', rook)
		if ( (aiLabel == '' )
			|| (aiLabel != '' && (aiLabel == rook.label || aiLabel == rook.name )))
		{
			log( "Toggling bShowSensingDebug on" @ rook.name @ "(" @ rook.label @ "):" @ !rook.bShowSensingDebug );
			rook.bShowSensingDebug = !rook.bShowSensingDebug;
		}
}

exec function debugLOA( optional Name aiLabel )
{
	local Rook rook;

	forEach AllActors(class'Rook', rook)
		if ( (aiLabel == '' )
			|| (aiLabel != '' && (aiLabel == rook.label || aiLabel == rook.name )))
		{
			log( "Toggling bShowLOADebug on" @ rook.name @ "(" @ rook.label @ "):" @ !rook.bShowLOADebug );
			rook.bShowLOADebug = !rook.bShowLOADebug;
		}
}

exec function debugJS( optional Name aiLabel )
{
	local Rook rook;

	forEach AllActors(class'Rook', rook)
		if ( (aiLabel == '' )
			|| (aiLabel != '' && (aiLabel == rook.label || aiLabel == rook.name )))
		{
			log( "Toggling bShowJSDebug on" @ rook.name @ "(" @ rook.label @ "):" @ !rook.bShowJSDebug );
			rook.bShowJSDebug = !rook.bShowJSDebug;
		}
}

exec function logNavigationSystem( optional Name aiLabel )
{
	local Rook rook;

	forEach AllActors(class'Rook',rook)
		if ( aiLabel == '' || aiLabel == rook.label || aiLabel == rook.name )
		{
			log( "Setting" @ rook.name @ "(" @ rook.label @ ") logNavigationSystem to" @ !rook.logNavigationSystem );
			rook.logNavigationSystem = !rook.logNavigationSystem;
		}
}

exec function logCersei( optional Name aiLabel )
{
	logNavigationSystem( aiLabel );
}

exec function logTyrion( optional Name aiLabel )
{
	local Pawn pawn;
	local SquadInfo squad;

	forEach AllActors(class'Pawn',pawn)
		if ( aiLabel == '' || aiLabel == pawn.label || aiLabel == pawn.name )
		{
			log( "Setting" @ pawn.name @ "(" @ pawn.label @ ") logTyrion to" @ !pawn.logTyrion );
			pawn.logTyrion = !pawn.logTyrion;
		}

	forEach AllActors(class'SquadInfo',squad)
		if ( aiLabel == '' || aiLabel == squad.label || aiLabel == squad.name)
		{
			log( "Setting" @ squad.name @ "(" @ squad.label @ ") logTyrion to" @ !squad.logTyrion );
			squad.logTyrion = !squad.logTyrion;
		}
}

exec function logDLM( optional Name aiLabel )
{
	local Pawn pawn;

	forEach AllActors(class'Pawn',pawn)
		if ( aiLabel == '' || aiLabel == pawn.label || aiLabel == pawn.name )
		{
			log( "Setting" @ pawn.name @ "(" @ pawn.label @ ") logDLM to" @ !pawn.logDLM );
			pawn.logDLM = !pawn.logDLM;
		}
}


// showFirstPersonGun
exec function showFirstPersonGun(bool b)
{
	local Character c;
	
	c = Character(Level.GetLocalPlayerController().Pawn);

	if (c != None)
	{
		c.Weapon.bHidden = !b;

		if (c.arms != None)
			c.arms.bHidden = !b;
	}
}

// showHUD
exec function showHUD(bool b)
{
	Level.GetLocalPlayerController().myHud.bHideHud = !b;
}

// toggleWatermark
exec native function toggleWatermark();

// !!!temporary
exec function setRoundTime(float t)
{
	MultiplayerGameInfo(Level.Game).roundInfo.currentRound().duration = t;
}

// switchTeam
exec function switchTeam()
{
	PlayerCharacterController(Outer).switchTeam();
}

// changeTeam
exec function changeTeam(int i)
{
	PlayerCharacterController(Outer).changeTeam(i);
}

// spectate
exec function spectate(optional String playerName)
{
	PlayerCharacterController(Outer).spectate(playerName);
}

// Set actor state
exec function SetState(name actorName, name newState)
{
	local Actor A;

	ForEach DynamicActors(class'Actor', A)
	{
		if(A.Name == ActorName)
		{
			ClientMessage("Set state of " $A.name $" to " $newState);
			A.GotoState(newState);
		}
	}
}

////////////////////////////////////////////////////////
// test methods for unified physics interface

// 'get' methods test: dumps values to the log
exec function UnifiedGetMethodsTest(name ActorName)
{
	local Actor A;

	ForEach DynamicActors(class'Actor', A)
	{
		if(A.Name == ActorName)
		{
			log("Actor properties: " $A.name);
			log("GetMass: " $A.unifiedGetMass());
			log("GetPosition: " $A.unifiedGetPosition());
			log("GetVelocity: " $A.unifiedGetVelocity());
			log("GetAcceleration: " $A.unifiedGetAcceleration());
		}
	}	
}

// add impulse at position
exec function AddImpulseAtPosition(name ActorName, float magnitude)
{
	AddImpulse(ActorName, magnitude, 5.0);
}

// add impulse
exec function AddImpulse(name ActorName, float magnitude, float offset)
{
	local vector Impulse;
	local vector Position;
	local Actor A;

	Impulse.X = 0;
	Impulse.Y = 0;
	Impulse.Z = magnitude;

	ForEach DynamicActors(class'Actor', A)
	{
		if(A.Name == ActorName)
		{
			if(offset > 0)
			{
				Position *= 0;
				Position.X = offset;
				Position += A.Location;
				A.unifiedAddImpulseAtPosition(Impulse, Position);
			}
			else
				A.unifiedAddImpulse(Impulse);
			ClientMessage("Added impulse to actor " $A.name);
		}
	}
}

// add force at position
exec function AddForceAtPosition(name ActorName, float magnitude, float offset)
{
	AddForce(ActorName, magnitude, 5.0);
}

// add force
exec function AddForce(name ActorName, float magnitude, float offset)
{
	local vector Force;
	local vector Position;
	local Actor A;

	Force.X = 0;
	Force.Y = 0;
	Force.Z = magnitude;

	ForEach DynamicActors(class'Actor', A)
	{
		if(A.Name == ActorName)
		{
			if(offset > 0)
			{
				Position *= 0;
				Position.X = offset;
				Position += A.Location;
				A.unifiedAddForceAtPosition(Force, Position);
			}
			else
				A.unifiedAddForce(Force);
			ClientMessage("Added Force to actor " $A.name);
			ClientMessage("Force was " $Force);
		}
	}
}

// add torque
exec function AddTorque(name ActorName, float magnitude)
{
	local vector Torque;
	local Actor A;

	Torque.X = 0;
	Torque.Y = 0;
	Torque.Z = magnitude;

	ForEach DynamicActors(class'Actor', A)
	{
		if(A.Name == ActorName)
		{
			A.unifiedAddTorque(Torque);
			ClientMessage("Added Torque to actor " $A.name);
		}
	}
}

// add velocity
exec function AddVelocity(name ActorName, float magnitude)
{
	local vector Velocity;
	local Actor A;

	Velocity.X = 0;
	Velocity.Y = 0;
	Velocity.Z = magnitude;

	ForEach DynamicActors(class'Actor', A)
	{
		if(A.Name == ActorName)
		{
			A.unifiedAddVelocity(Velocity);
			ClientMessage("Added velocity to actor " $A.Name);
		}
	}
}

// set velocity
exec function SetVelocity(name ActorName, float magnitude)
{
	local vector Velocity;
	local Actor A;

	Velocity.X = 0;
	Velocity.Y = 0;
	Velocity.Z = magnitude;

	ForEach DynamicActors(class'Actor', A)
	{
		if(A.Name == ActorName)
		{
			A.unifiedSetVelocity(Velocity);
			ClientMessage("Set velocity of actor " $A.Name);
		}
	}
}

// set acceleration
exec function SetAcceleration(name ActorName, float magnitude)
{
	local vector Acceleration;
	local Actor A;

	Acceleration.X = 0;
	Acceleration.Y = 0;
	Acceleration.Z = magnitude;

	ForEach DynamicActors(class'Actor', A)
	{
		if(A.Name == ActorName)
		{
			A.unifiedSetAcceleration(Acceleration);
			ClientMessage("Set acceleration of actor " $A.Name);
		}
	}
}

// set position
exec function SetPosition(name ActorName, float posX, float posY, float posZ)
{
	local vector Position;
	local Actor A;

	Position.X = posX;
	Position.Y = posY;
	Position.Z = posZ;

	ForEach DynamicActors(class'Actor', A)
	{
		if(A.Name == ActorName)
		{
			A.unifiedSetPosition(Position);
			ClientMessage("Set position of actor " $A.Name);
		}
	}
}

// offset position
exec function OffsetPosition(name ActorName, /*float posX, float posY, */float posZ)
{
	local vector Position;
	local Actor A;

	ForEach DynamicActors(class'Actor', A)
	{
		if(A.Name == ActorName)
		{
			Position = A.Location;
//			Position.X += posX;
//			Position.Y += posY;
			Position.Z += posZ;

			A.unifiedSetPosition(Position);
			ClientMessage("Set position of actor " $A.Name);
		}
	}
}

// set mass
exec function SetMass(name ActorName, float newMass)
{
	local Actor A;

	ForEach DynamicActors(class'Actor', A)
	{
		if(A.Name == ActorName)
		{
			A.unifiedSetMass(newMass);
			ClientMessage("Set mass of actor " $A.Name);
		}
	}
}

// allow the player to modify the hud
exec function toggleModifyHUD()
{
	local GUIController c;

	c = GUIController(Outer.Player.GUIController);

	c.bDesignMode = !c.bDesignMode;
	c.bPlayerDesignMode = c.bDesignMode;
}
exec function modCharVis(name characterName, name mode)
{
	local Character c;

	ForEach DynamicActors(class'Character', c)
	{
		if(c.Name == characterName)
		{
			if(c.visualisation == None)
			{
				c.visualisation = Spawn(class'CharacterVisualisation', , , c.Location, Rot(0, 0, 0));
				c.visualisation.SetCharacter(c);
			}

			if(mode == 'single')
			{
//				c.visualisation.setHidden(false);
				c.visualisation.setFullMode(true);
				ClientMessage("Changed visualisation of character " $c.name $" to single");
			}
			else if(mode == 'double')
			{
//				c.visualisation.setHidden(false);
				c.visualisation.setFullMode(false);
				ClientMessage("Changed visualisation of character " $c.name $" to double");
			}
			else if(mode == 'off')
			{
				c.visualisation.setHidden(true);
				ClientMessage("Changed visualisation of character " $c.name $" to off");
			}

		}
	}
	
}

exec function DebugEffectEvent(name EffectEvent)
{
	EffectsSystem(Level.EffectsSystem).DebugEffectEvent[EffectsSystem(Level.EffectsSystem).DebugEffectEvent.length] = EffectEvent;
}

exec function applySkin(string skinPath)
{
	local class<SkinInfo> skin;

	if (Character(Pawn) == None)
		return;

	if (skinPath != "")
	{
		skin = class<SkinInfo>(DynamicLoadObject(skinPath, class'class'));
		if (skin == None)
		{
			ClientMessage("That skin was not found.");
			return;
		}
		else if (!skin.static.isApplicable(Pawn.Mesh))
		{
			ClientMessage("That skin is not applicable to your current mesh ("$Pawn.Mesh$")");
			return;
		}
	}
	else
	{
		skin = class'SkinInfo';
	}

	PlayerCharacterController(Outer).serverSetSkin(skinPath, Pawn.Mesh);
}

