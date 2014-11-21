//=============================================================================
// ServerLogoInteraction
// Copyright 2003 by Wormbo <wormbo@onlinehome.de>
// Ported to TV by Byte <byte@tsncentral.com>
//
// Displays a logo for players connecting.
//=============================================================================
class ServerLogoInteraction extends Engine.Interaction
    dependson(mutLogoServer);

//=============================================================================
// Constants
//=============================================================================

const STY_Alpha = 5;

//=============================================================================
// Variables
//=============================================================================

var mutLogoServer ServerLogo;
var Material   LogoMaterial;
var float      StartupTime;

var bool bDisplayingLogo;
var bool bFadingIn, bDisplaying, bFadingOut;

//=============================================================================
// Remove
//
// Unregisters the interaction.
//=============================================================================

function Remove()
{
  LogoMaterial = None;
  ServerLogo = None;
  Master.RemoveInteraction(Self);
}

//=============================================================================
// NotifyLevelChange
//
// Removes the interaction on level change.
//=============================================================================

event NotifyLevelChange()
{
  Remove();
}


//=============================================================================
// PostRender
//
// Draws the logo.
//=============================================================================

event PostRender(Canvas C)
{
  local float AlphaFadeIn;
  local float AlphaFadeOut;
  local float X, Y, OffsetX, OffsetY, LScale;

  if ( ServerLogo == None || ServerLogo.RLogoResources.Logo == "" )
    return;

  if ( LogoMaterial == None && ServerLogo.RLogoResources.Logo != "" )
  {
    LogoMaterial = Material(DynamicLoadObject(ServerLogo.RLogoResources.Logo, class'Material'));
    if ( LogoMaterial == None )
    {
      Remove();
      return;
    }

    return;
  }

  if ( StartupTime == 0 || !bDisplayingLogo )
    StartupTime = ServerLogo.Level.TimeSeconds;

  AlphaFadeIn  = FClamp(ServerLogo.Level.TimeSeconds - StartupTime,
      0, ServerLogo.RFadeInDuration)
      / ServerLogo.RFadeInDuration;
  AlphaFadeOut = FClamp(ServerLogo.Level.TimeSeconds - (StartupTime
      + ServerLogo.RFadeInDuration + ServerLogo.RDisplayDuration),
      0, ServerLogo.RFadeOutDuration)
      / ServerLogo.RFadeOutDuration;

  C.Reset();
  C.Style = STY_Alpha;
  C.DrawColor = ServerLogo.RLogoColor;

  if ( AlphaFadeIn < 1.0 )
  {
    bDisplayingLogo = True;
    if ( !bFadingIn ) {
      bFadingIn = True;
    }

    C.DrawColor.A = FadeIn(AlphaFadeIn, 0, ServerLogo.RLogoColor.A, ServerLogo.RFadeInAlphaTransition);
  }
  else if ( AlphaFadeOut == 0 )
  {
    bDisplayingLogo = True;
    if ( !bDisplaying ) {
      bDisplaying = True;
    }

    C.DrawColor.A = ServerLogo.RLogoColor.A;
  }
  else if ( AlphaFadeOut < 1.0 )
  {
    bDisplayingLogo = True;
    if ( !bFadingOut ) {
      bFadingOut = True;
    }

    C.DrawColor.A = FadeOut(AlphaFadeOut, ServerLogo.RLogoColor.A, 0, ServerLogo.RFadeOutAlphaTransition);
  }
  else
  {
    Remove();
    return;
  }
    X = ServerLogo.RLogoResources.LogoX;
    Y = ServerLogo.RLogoResources.LogoY;
    OffsetX = ServerLogo.RLogoResources.LogoOffsetX;
    OffsetY = ServerLogo.RLogoResources.LogoOffsetY;

    LScale = ServerLogo.RLogoResources.LogoScale;

    C.SetPos((C.ClipX*X)+OffsetX, (C.ClipY*Y)+OffsetY);
	C.DrawTileScaled(LogoMaterial, LScale, LScale);
}


//=============================================================================
// FadeIn
//
// Fades a value between a start value and an end value using the specified
// fading method to apply.
//=============================================================================

function float FadeIn(float Alpha, float Start, float End, MutLogoServer.EFadeTransition Method)
{
  switch (Method) {
  Case FT_None:
    return End;
  Case FT_Linear:
    return Lerp(Alpha, Start, End);
  Case FT_Square:
    return Lerp(Square(Alpha), Start, End);
  Case FT_Sqrt:
    return Lerp(Sqrt(Alpha), Start, End);
  Case FT_ReverseSquare:
    return Lerp(1-Square(1-Alpha), Start, End);
  Case FT_ReverseSqrt:
    return Lerp(1-Sqrt(1-Alpha), Start, End);
  Case FT_Sin:
    return Lerp(0.5 - 0.5 * Cos(Alpha * Pi), Start, End);
  Case FT_Smooth:
    return Smerp(Alpha, Start, End);
  Case FT_SquareSmooth:
    return Smerp(Square(Alpha), Start, End);
  Case FT_SqrtSmooth:
    return Smerp(Sqrt(Alpha), Start, End);
  Case FT_ReverseSquareSmooth:
    return Smerp(1-Square(1-Alpha), Start, End);
  Case FT_ReverseSqrtSmooth:
    return Smerp(1-Sqrt(1-Alpha), Start, End);
  Case FT_SinSmooth:
    return Smerp(0.5 - 0.5 * Cos(Alpha * Pi), Start, End);
  }
}


//=============================================================================
// FadeOut
//
// Like FadeIn, but reversed direction.
//=============================================================================

function float FadeOut(float Alpha, float Start, float End, MutLogoServer.EFadeTransition Method)
{
  if ( Method == FT_None )
    return Start;
  else
    return FadeIn(Alpha, Start, End, Method);
}

//=============================================================================
// Default Properties
//=============================================================================

defaultproperties
{
     bVisible=True
}
