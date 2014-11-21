//=============================================================================
// ServerLogo
// Copyright 2003 by Wormbo <wormbo@onlinehome.de>
// Ported to TV by Byte <byte@tsncentral.com>
//
// Replicated the information for a logo displayed for players connecting.
//=============================================================================
class MutLogoServer extends Engine.Mutator
    config
    placeable
    hidecategories(Display,Advanced,Sound,Mutator,Events);


//=============================================================================
// Enums
//=============================================================================

enum EFadeTransition {
  FT_None,
  FT_Linear,
  FT_Square,
  FT_Sqrt,
  FT_ReverseSquare,
  FT_ReverseSqrt,
  FT_Sin,
  FT_Smooth,
  FT_SquareSmooth,
  FT_SqrtSmooth,
  FT_ReverseSquareSmooth,
  FT_ReverseSqrtSmooth,
  FT_SinSmooth
};


//=============================================================================
// Structs
//=============================================================================
// replicated as a struct to make sure everything arrives at the same time
struct TRepResources {
  var string Logo;
  var float LogoX;
  var float LogoY;
  var float LogoOffsetX;
  var float LogoOffsetY;
  var float LogoScale;
};


//=============================================================================
// Configuration
//=============================================================================

var(Logo)           config string          Logo;
var(Logo)           config color           LogoColor;
var(Logo)           config float           LogoX, LogoY, LogoOffsetX, LogoOffsetY;
var(Logo)           config float           LogoScale;

var(LogoTransition) config float           FadeInDuration;
var(LogoTransition) config float           DisplayDuration;
var(LogoTransition) config float           FadeOutDuration;
var(LogoTransition) config float           InitialDelay;
var(LogoTransition) config EFadeTransition FadeInAlphaTransition;
var(LogoTransition) config EFadeTransition FadeOutAlphaTransition;

//=============================================================================
// Variables
//=============================================================================

var() const editconst string Build;

var TRepResources   RLogoResources;
var color           RLogoColor;

var float           RFadeInDuration;
var float           RDisplayDuration;
var float           RFadeOutDuration;
var float           RInitialDelay;
var EFadeTransition RFadeInAlphaTransition;
var EFadeTransition RFadeOutAlphaTransition;

var float SpawnTime;
var bool bReceivedVars;


//=============================================================================
// Replication
//=============================================================================

replication
{
  reliable if ( Role == ROLE_Authority )
    RLogoResources, RLogoColor, RFadeInAlphaTransition, RFadeOutAlphaTransition,
    RFadeInDuration, RDisplayDuration, RFadeOutDuration, RInitialDelay;
}


//=============================================================================
// PostBeginPlay
//
// Replicate all config variables.
//=============================================================================

simulated function PostBeginPlay()
{
  Super.PostBeginPlay();

  if ( Role == ROLE_Authority )
  {
    log(" ");
    log("ServerLogoTV build"@Build, 'ServerLogo');
    log("Copyright 2003 by Wormbo <wormbo@onlinehome.de>", 'ServerLogo');
    log("Ported to Tribes - 2004 by Byte <byte@tsncentral.com>", 'ServerLogo');
    log(" ");
    SaveConfig();
    RLogoResources.Logo = Logo;
    RLogoResources.LogoX = LogoX;
    RLogoResources.LogoY = LogoY;
    RLogoResources.LogoOffsetX = LogoOffsetX;
    RLogoResources.LogoOffsetY = LogoOffsetY;
    RLogoResources.LogoScale = LogoScale;
    RLogoColor = LogoColor;

    RFadeInAlphaTransition = FadeInAlphaTransition;
    RFadeOutAlphaTransition = FadeOutAlphaTransition;
    if ( FadeInAlphaTransition > FT_None )
      RFadeInDuration = FadeInDuration;
    RDisplayDuration = DisplayDuration;
    if ( FadeOutAlphaTransition > FT_None )
      RFadeOutDuration = FadeOutDuration;
    RInitialDelay = InitialDelay;
  }
}


//=============================================================================
// PostNetBeginPlay
//
// Replicate all config variables.
//=============================================================================

simulated function PostNetBeginPlay()
{
  bReceivedVars = True;
  Enable('Tick');
}


//=============================================================================
// Tick
//
// Initialize the Interaction and load the logo texture.
//=============================================================================

simulated function Tick(float DeltaTime)
{
  local PlayerController LocalPlayer;
  local Interaction MyInteraction;

  if ( !bReceivedVars || Level.NetMode == NM_DedicatedServer )
  {
    Disable('Tick');
    return;
  }
  else if ( RLogoResources.Logo == "" )
  {
    return;
  }
  else if ( SpawnTime == 0.0 )
    SpawnTime = Level.TimeSeconds;

  if ( Level.TimeSeconds - SpawnTime < RInitialDelay )
    return;

  LocalPlayer = Level.GetLocalPlayerController();

  if ( LocalPlayer != None )
  {
       MyInteraction = LocalPlayer.Player.InteractionMaster.AddInteraction(string(class'ServerLogoInteraction'), LocalPlayer.Player);
       LocalPlayer.ClientMessage( "This Server is running ServerLogoTV "$Build);
       LocalPlayer.ClientMessage( "http://byte.zenegg.com");
  }

  if ( ServerLogoInteraction(MyInteraction) != None )
       ServerLogoInteraction(MyInteraction).ServerLogo = Self;

  Disable('Tick');
}


//=============================================================================
// GetServerDetails
//
// Don't show in server details.
//=============================================================================

function GetServerDetails(out GameInfo.ServerResponseLine ServerState);


//=============================================================================
// Default Properties
//=============================================================================

defaultproperties
{
     Logo="GUITribes.PoweredByGamespy"
     LogoColor=(B=255,G=255,R=255,A=255)
     LogoY=0.500000
     LogoScale=0.250000
     FadeInDuration=3.000000
     DisplayDuration=5.000000
     FadeOutDuration=1.500000
     InitialDelay=8.000000
     FadeInAlphaTransition=FT_ReverseSquareSmooth
     FadeOutAlphaTransition=FT_SquareSmooth
     Build="1.2"
     GroupName="ServerLogo"
     FriendlyName="ServerLogo TV"
     Description="Displays a logo on clients that connected to the server."
     bAlwaysRelevant=True
     RemoteRole=ROLE_SimulatedProxy
     bNetNotify=True
}
