//=============================================================================
// ScriptedTexture: A scriptable Unreal texture
// This is a built-in Unreal class and it shouldn't be modified.
//=============================================================================
class ScriptedTexture extends BitmapMaterial
	native;

var const transient int			RenderTarget;
var const transient Viewport	RenderViewport;

var Actor				Client;
var() bool				bSerializeClient;

#if IG_EXTERNAL_CAMERAS
// if true will call PreScriptedTextureRendered on the client
var bool                bNotifyClientBeforeRendering;
#endif

var transient int		Revision;
var transient const int	OldRevision;
#if IG_TRIBES3	// rowan: handle bad hardware that doesnt set render targets
var transient int		Invalid;
#endif


// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)

native final function SetSize(int Width,int Height);

native final function DrawText(int StartX,int StartY,coerce string Text,Font Font,Color Color);
native final function TextSize(coerce string Text,Font Font,out int Width,out int Height);
native final function DrawTile(float X,float Y,float XL,float YL,float U,float V,float UL,float VL,Material Material,Color Color);

#if IG_EXTERNAL_CAMERAS
native final function DrawPortal(int X, int Y, int Width, int Height, Actor CamActor, vector CamLocation, rotator CamRotation, optional int FOV, optional bool ClearZ, optional bool RenderPlayer);
#else
native final function DrawPortal(int X,int Y,int Width,int Height,Actor CamActor,vector CamLocation,rotator CamRotation,optional int FOV,optional bool ClearZ);
#endif // IG_EXTERNAL_CAMERAS

cpptext
{
	void Render(FRenderInterface* RI);

	virtual void Serialize( FArchive& Ar );
	virtual UBitmapMaterial* Get(FTime Time,UViewport* Viewport);
	virtual FBaseTexture* GetRenderInterface();
	virtual void Destroy();
	virtual void PostEditChange();
    
	// IG_SHARED note: we have moved code out of execSetSize() and into its own function in UnScriptedTexture.cpp
    void SetSize(INT Width, INT Height);

}


defaultproperties
{
     MaterialType=MT_ScriptedTexture
}
