// This keeps Event Messages from showing while in RespawnHUD and thus
// being removed before HUD can catch and parse the messages
class RespawnHUDScript extends TribesGUI.TribesRespawnHUDScript;

defaultproperties
{
     bEventMessagesEnabled=False
     ExtensionSpecs(0)=(elementName="ext_FlagHudContainer",ClassName="FlagHUD.Flaggy")
     ExtensionSpecs(1)=(elementName="ext_SpeedHudContainer",ClassName="SpeedBar.SpeedHud")
     ExtensionSpecs(2)=(elementName="ext_PingHudContainer",ClassName="PingHUD.Ping")
     resFontNames(0)="DefaultSmallFont"
     resFontNames(1)="Tahoma8"
     resFontNames(2)="Tahoma8"
     resFontNames(3)="Tahoma10"
     resFontNames(4)="Tahoma12"
     resFontNames(5)="Tahoma12"
     resFonts(0)=Font'Engine_res.Res_DefaultFont'
     resFonts(1)=Font'TribesFonts.Tahoma8'
     resFonts(2)=Font'TribesFonts.Tahoma8'
     resFonts(3)=Font'TribesFonts.Tahoma10'
     resFonts(4)=Font'TribesFonts.Tahoma12'
     resFonts(5)=Font'TribesFonts.Tahoma12'
}
