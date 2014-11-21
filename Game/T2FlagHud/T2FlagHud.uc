class T2FlagHud extends TribesGUI.HUDContainer;

//flag coords
var int FFlagX;
var int FFlagY;
var int EFlagX;
var int EFlagY;

// flag texture
var() config HUDMaterial EnemyMarkerMaterial;
var() config HUDMaterial FriendlyMarkerMaterial;

//resize vars

var float EDistance;
var float FDistance;
var() config float MaxDistance;
Var() config float Size;
var float WorkingSize; //variable changes to reflect distance from view
var float WorkingSize2;
 
function InitElement()
{
  super.InitElement();
}

function UpdateData(ClientSideCharacter c)
{
    super.UpdateData(c);

    // don't show on certain HUDs
    if( TribesRespawnHUDScript(RootHUDScript())!=None || TribesCountdownHUDScript(RootHUDScript())!=None
      || TribesVehicleHUDScript(RootHUDScript())!=None || TribesTurretHUDScript(RootHUDScript())!=None
      || TribesCommandHUDScript(RootHUDScript())!=None )
       bVisible=false;
    else
       bVisible=true;

	if(c.ObjectiveActorData[0].IsFriendly)
        {
          FFlagX = c.ObjectiveActorData[0].ScreenX;
	  FFlagY = c.ObjectiveActorData[0].ScreenY;
          FDistance = c.ObjectiveActorData[0].Distance;

	  EFlagX = c.ObjectiveActorData[1].ScreenX;
	  EFlagY = c.ObjectiveActorData[1].ScreenY;
          EDistance = c.ObjectiveActorData[1].Distance;
        }
        else
        {
          FFlagX = c.ObjectiveActorData[1].ScreenX;
	  FFlagY = c.ObjectiveActorData[1].ScreenY;
          FDistance = c.ObjectiveActorData[1].Distance;

	  EFlagX = c.ObjectiveActorData[0].ScreenX;
	  EFlagY = c.ObjectiveActorData[0].ScreenY;
          EDistance = c.ObjectiveActorData[0].Distance;
        } 
}

function RenderElement(Canvas c)
{


                if(EFlagX > 0 && EFlagX < screenHeight && EFlagY > 0 && EFlagY < screenWidth)
		{	
			if(EDistance > MaxDistance)
			  EDistance = MaxDistance;

                        WorkingSize = Size-(EDistance/MaxDistance)*35.0;
			
			c.CurX = EFlagX-WorkingSize/2;
                        c.CurY = EFlagY-WorkingSize/2;
			RenderHUDMaterial(c, EnemyMarkerMaterial, WorkingSize, WorkingSize);

		}
                if(FFlagX > 0 && FFlagX < screenHeight && FFlagY > 0 && FFlagY < screenWidth)
		{	

			if(FDistance > MaxDistance)
			  FDistance = MaxDistance;

                        WorkingSize2 = Size-(FDistance/MaxDistance)*35.0;
			c.CurX = FFlagX-WorkingSize2/2;
                        c.CurY = FFlagY-WorkingSize2/2;
			RenderHUDMaterial(c, FriendlyMarkerMaterial, WorkingSize2, WorkingSize2);
		}


}

defaultproperties
{
     EnemyMarkerMaterial=(Material=Texture'HUD.UseCorners',DrawColor=(B=20,G=20,R=255,A=170),Style=1,bStretched=True)
     FriendlyMarkerMaterial=(Material=Texture'HUD.UseCorners',DrawColor=(B=20,G=255,R=20,A=170),Style=1,bStretched=True)
     MaxDistance=20000.000000
     Size=50.000000
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
