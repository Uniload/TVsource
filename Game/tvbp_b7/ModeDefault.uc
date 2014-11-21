

defaultproperties
{
     ArtPackage="tvbp_art_b7"
     SoundPackage="tvbp_sounds_b7"
     StatTrackerClass=Class'AdvancedStatTracker'
     QuickInvConfigClass=Class'QuickInvDefault'
     teamKillStat=Class'StatClasses.StatTeamKill'
     highestSpeedStat=Class'StatClasses.StatHighestSpeed'
     projectileDamageStats(0)=(damageTypeClass=Class'EquipmentClasses.ProjectileDamageTypeSniperRifle',headShotStatClass=Class'StatClasses.StatHeadShot')
     extendedProjectileDamageStats(0)=(damageTypeClass=Class'EquipmentClasses.ProjectileDamageTypeSpinfusor',extendedStatClass=Class'StatClasses.ExtendedStatMidairDisc')
     extendedProjectileDamageStats(1)=(damageTypeClass=Class'EquipmentClasses.ProjectileDamageTypeExplosion',extendedStatClass=Class'StatClasses.ExtendedStatFastExplosive')
     baseDeviceDestroyStats(0)=(statClass=Class'StatClasses.StatDestroyGenerator',baseDeviceClass=Class'BaseObjectClasses.BasePowerGenerator')
     baseDeviceDestroyStats(1)=(statClass=Class'StatClasses.StatDestroySensor',baseDeviceClass=Class'BaseObjectClasses.BaseSensor')
     baseDeviceRepairStats(0)=(statClass=Class'StatClasses.StatRepairGenerator',baseDeviceClass=Class'BaseObjectClasses.BasePowerGenerator')
     baseDeviceRepairStats(1)=(statClass=Class'StatClasses.StatRepairSensor',baseDeviceClass=Class'BaseObjectClasses.BaseSensor')
     roundInfoClass=Class'ModeDefaultRoundInfo'
     gameHints(0)="HINT:  Press and hold '%Button bLoadoutSelection%' at an Inventory Station to access quick favorites.  Press '%Use%' to see a full menu.  You can set favorites by accessing the tabs at the top of the full menu."
     gameHints(1)="HINT:  Press and hold '%Button bQuickChat%' to see a list of quick chat categories.  While holding '%Button bQuickChat%', navigate the menus by pressing the associated keys."
     gameHints(2)="HINT:  The Chaingun gradually heats up and becomes less accurate if you hold the trigger down.  It is cooled down by travelling quickly or going through water."
     gameHints(3)="HINT:  Explosive weapons are more effective against vehicles than bullet weapons."
     gameHints(4)="HINT:  Look for Deployable Stations in your base.  Walk up to a station and press '%Use%' to pick up its deployable.  It shows up in your equipment list, and you can then press '%equipDeployable%' to equip it and '%Fire%' to deploy it."
     gameHints(5)="HINT:  Press and hold '%altFire%' to throw a Hand Grenade.  The longer you hold it, the further the grenade will be thrown.  Get more Hand Grenades by visiting an Inventory Station."
     gameHints(6)="HINT:  Different vehicles take different amounts of time to respawn.  A vehicle will respawn at its pad when the pad's posts have sunk all the way into the ground."
     gameHints(7)="HINT:  Visit an Inventory Station to change your armor, get a pack, and pick new weapons.  You're at a disadvantage if you don't take some time to get new equipment."
     gameHints(8)="HINT:  When you kill enemies they drop health kits.  Pick them up to get some health back."
     gameHints(9)="HINT:  Watch your ammo supply.  Get more ammo by walking over dropped weapons, visiting an Inventory Station, or visiting a Resupply Station."
     gameHints(10)="HINT:  You can swap your current weapon with a weapon on the ground by standing over it and pressing '%Use%'."
     gameHints(11)="HINT:  If your team's base has a Sensor it will allow you to see enemies on your radar.  You won't see enemies on your radar if you don't have a Sensor, if your Sensor has been destroyed, or if your power is down."
     gameHints(12)="HINT:  If your team's base has a power Generator, don't let it get destroyed!  None of the equipment in your base will work until your Generator has been repaired.  Destroy the enemy Generator to get an advantage."
     gameHints(13)="HINT:  You can get a Repair Pack from an Emergency Station when the power is out.  Emergency Stations can usually be found in your base on a wall near other equipment. They cannot be damaged or lose power."
     gameHints(14)="HINT:  You can ski across the surface of the water if you're going fast enough at a shallow angle."
     gameHints(15)="HINT:  Press '%Ski%' to ski and '%Jetpack%' to jet.  You can acquire very high speeds by skiing into a valley and jetting up and over the other side.  Do this repeatedly to keep going even faster."
     gameHints(16)="HINT:  You can turn and fire your Spinfusor at your own feet in order to get a quick speed boost at the expense of health."
     gameHints(17)="HINT:  Base equipment is often shielded for extra protection.  When targeting a piece of base equipment, a white bar indicates that it has shields.  Shields automatically regenerate unless the power is out."
     gameHints(18)="HINT:  Shoot an enemy in the head with the Sniper Rifle to deal extra damage."
     gameHints(19)="HINT:  You can press '%Button bZoom%' at any time to zoom in on a target.  This capability is not limited to any particular weapon."
     gameHints(20)="HINT:  You can toggle the zoom level of your radar by pressing '%CycleRadarZoomScale%'.  Use this feature to see more or less detail in your radar."
     gameHints(21)="HINT:  Press and hold '%Button bObjectives%' to display a large overhead map and look at your objectives."
     gameHints(22)="HINT:  Each armor type has a special weapon that only it can use.  Lights have Sniper Rifles, Mediums have Bucklers, and Heavies have Mortars."
     gameHints(23)="HINT:  You can press '%Use%' while at a Spawn Tower in order to instantly teleport to another Spawn Tower.  You can't teleport while carrying a game object.  Spawn Towers can't be destroyed."
     gameHints(24)="HINT:  Be sure to get a Pack from an Inventory Station!  The different Pack types are Energy, Shield, Speed and Repair.  Each Pack gives you a passive ability and an active ability.  Press '%activatePack%' to use the active ability."
     gameHints(25)="HINT:  You can boost the Tank into the air by pressing '%Jetpack%' and you can slide it down hills by pressing '%Ski%'."
     gameHints(26)="HINT:  You can make the Rover go faster by pressing and holding '%Jetpack%', but you have less control while doing so.  Pressing and holding '%Ski%' activates the Rover's hand brake."
     gameHints(27)="HINT:  When you pickup a game object such as a flag, it appears in your equipment list.  Press '%equipCarryable%' to equip it, then press and hold '%Fire%' to throw it."
     gameHints(28)="HINT:  Base equipment's health is divided in two. The left section represents the functional status, the right represents damage. To operate, the equipment requires the left section to be intact. To destroy the equipment, remove the right hand section."
     gameHints(29)="HINT:  The Grappler is a versatile tool. Use it to swing through enclosed spaces, rapidly change direction, snatch dropped equipment, hang from vehicles or latch on to other players."
     gameHints(30)="HINT:  The pilots of the Fighter and Rover can be damaged independently of the vehicles themselves. If you pilot these vehicles, be sure to watch your own health bar as well as that of the vehicle."
     gameHints(31)="HINT:  When manning a vehicle, a manifest is displayed in your HUD. You can instantly switch to any empty position by pressing the position's corresponding number key."
     gameHints(32)="HINT:  The Fighter is the only vehicle that is not damaged by water. The other vehicles will take continuous damage if they are more than half submerged."
     gameHints(33)="HINT:  Some weapons do not use ammunition. The Blaster, Burner and Energy Blade draw from your energy supply instead. The Sniper Rifle uses both energy and ammunition."
     gameHints(34)="HINT:  The Sniper Rifle has limited ammunition, but it also will use up your entire supply of energy with each shot. The more energy you have available for it to use, the more damage it will inflict."
     gameHints(35)="HINT:  Press 'F1' at any time during a game for a Help screen. This will show your current key bindings and describes each element of the HUD."
     gameHints(36)="HINT:  If you hit an obstacle at speed or misjudge a landing, you may receive damage from the collision. Lights are more vulnerable to this kind of damage, Heavies less so."
     gameHints(37)="HINT:  If your team's Rover has been driven off it's pad, or if your team has stolen the enemy's Rover, you will be able to spawn in it. It will appear in the Respawn Menu as a selectable spawn location."
     gameHints(38)="HINT:  You can steal an enemy vehicle, but only if it has been previously used and abandoned by the enemy."
     gameHints(39)="HINT:  Sometimes it is advantageous to respawn at your base even when you have not been killed. Press '%Respawn true%' at any time to open the Respawn Menu, then select a spawn location."
     gameHints(40)="HINT:  The Buckler is a skillful weapon with offensive and defensive capability. Press '%Fire%' to throw it like a guidable boomerang. When held, it will deflect both frontal fire and other players."
     gameHints(41)="HINT:  Try the Repair Pack. Its passive effect will cause you to constantly heal at a slow rate. Activate it with '%activatePack%' to repair nearby objects or players that are on your team."
     gameHints(42)="HINT:  Try the Speed Pack. Its passive effect will allow you to run and shoot slightly faster than normal. Activate it with '%activatePack%' to run and shoot much faster than normal for a short time."
     gameHints(43)="HINT:  Try the Shield Pack. Its passive effect will slightly reduce the amount of damage you receive. Activate it with '%activatePack%' to greatly reduce the amount of damage you receive for a short time."
     gameHints(44)="HINT:  Try the Energy Pack. Its passive effect will slightly increase the rate at which your energy reserve recharges. Activate it with '%activatePack%' for a brief rocket boost."
     gameHints(45)="HINT:  During play, press '%ShowMyStats%' to bring up the details of your achievements in the current game. If you have Stat Tracking turned on in your profile, these will be added to your persistent stats after each match."
     gameHints(46)="HINT:  You can initialize or participate in a vote on the Admin screen, which is accessed by pressing '%ShowAdmin%' during a match."
     gameHints(47)="HINT:  By default, teams are represented in your HUD using relative colors - green is always friendly, red is always enemy. You can change them to absolute team colors by opening the Controls tab of the Options menu."
     gameHints(48)="HINT:  Look for Base Turrets near your bases. There are Mortar, Burner, Sentry and Anti-Aircraft Base Turrets. To function, they must be powered and manned. Enter a turret by walking up to it and pressing '%Use%'."
     gameHints(49)="HINT:  There are five kinds of Deployable: Turret, Mine, Inventory Station, Repairer and Catapult. Think carefully about where you deploy them. A badly placed or unused Deployable is a wasted resource!"
     gameHints(50)="HINT:  Friendly Energy Barriers can be moved through, enemy Energy Barriers can not. Neither will allow projectiles, vehicles or players carrying game objects to pass. "
     equipmentLifeTime=20.000000
}
