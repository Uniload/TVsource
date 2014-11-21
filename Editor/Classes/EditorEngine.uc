//=============================================================================
// EditorEngine: The UnrealEd subsystem.
// This is a built-in Unreal class and it shouldn't be modified.
//=============================================================================
class EditorEngine extends Engine.Engine
	native
	noexport
	transient;

#exec LOAD FILE=Editor_res.pkg

// Objects.
var const Engine.level       Level;
var const Engine.model       TempModel;
var const Engine.texture     CurrentTexture;
var const Engine.staticmesh  CurrentStaticMesh;
var const Engine.mesh		  CurrentMesh;
var const Core.class       CurrentClass;
var const Core.Object	  Trans;
var const Core.Object	  Results;
var const int         Pad[8];

// Textures.
var const Engine.texture Bad, Bkgnd, BkgndHi, BadHighlight, MaterialArrow, MaterialBackdrop;

// Used in UnrealEd for showing materials
var Engine.staticmesh	TexPropCube;
var Engine.staticmesh	TexPropSphere;

// Toggles.
var const bool bFastRebuild, bBootstrapping;

// Other variables.
var const config int AutoSaveIndex;
var const int AutoSaveCount, Mode, TerrainEditBrush, ClickFlags;
var const float MovementSpeed;
var const Core.package PackageContext;
var const vector AddLocation;
var const plane AddPlane;

// Misc.
var const array<Core.Object> Tools;
var const class BrowseClass;

// Grid.
var const int ConstraintsVtbl;
var(Grid) config bool GridEnabled;
var(Grid) config bool SnapVertices;
var(Grid) config float SnapDistance;
var(Grid) config vector GridSize;

// Rotation grid.
var(RotationGrid) config bool RotGridEnabled;
var(RotationGrid) config rotator RotGridSize;

// Advanced.
var(Advanced) config bool UseSizingBox;
var(Advanced) config bool UseAxisIndicator;
var(Advanced) config float FovAngleDegrees;
var(Advanced) config bool GodMode;
var(Advanced) config bool AutoSave;
var(Advanced) config byte AutosaveTimeMinutes;
var(Advanced) config string GameCommandLine;
var(Advanced) config array<string> EditPackages;
var(Advanced) config bool AlwaysShowTerrain;
var(Advanced) config bool UseActorRotationGizmo;
var(Advanced) config bool LoadEntirePackageWhenSaving;
#if IG_SHARED	// rowan: redraw viewports when moving actors
var(Advanced) config bool RedrawAllViewportsWhenMoving;
#endif

defaultproperties
{
     Bad=Texture'Editor_res.Bad'
     Bkgnd=Texture'Editor_res.Bkgnd'
     BkgndHi=Texture'Editor_res.BkgndHi'
     BadHighlight=Texture'Editor_res.BadHighlight'
     MaterialArrow=Texture'Editor_res.MaterialArrow'
     MaterialBackdrop=Texture'Editor_res.MaterialBackdrop'
     TexPropCube=StaticMesh'Editor_res.TexPropCube'
     TexPropSphere=StaticMesh'Editor_res.TexPropSphere'
     AutoSaveIndex=6
     GridEnabled=True
     SnapDistance=10.000000
     GridSize=(X=16.000000,Y=16.000000,Z=16.000000)
     RotGridEnabled=True
     RotGridSize=(Pitch=1024,Yaw=1024,Roll=1024)
     UseAxisIndicator=True
     FovAngleDegrees=90.000000
     GodMode=True
     AutoSave=True
     AutosaveTimeMinutes=5
     GameCommandLine="-log -console -windowed"
     EditPackages(0)="Core"
     EditPackages(1)="Engine"
     EditPackages(2)="IGEffectsSystem"
     EditPackages(3)="IGVisualEffectsSubsystem"
     EditPackages(4)="IGSoundEffectsSubsystem"
     EditPackages(5)="Editor"
     EditPackages(6)="UWindow"
     EditPackages(7)="GUI"
     EditPackages(8)="TVEd"
     EditPackages(9)="IpDrv"
     EditPackages(10)="UWeb"
     EditPackages(11)="UDebugMenu"
     EditPackages(12)="MojoCore"
     EditPackages(13)="MojoActions"
     EditPackages(14)="PathFinding"
     EditPackages(15)="Scripting"
     EditPackages(16)="AICommon"
     EditPackages(17)="Movement"
     EditPackages(18)="Gameplay"
     EditPackages(19)="TribesGui"
     EditPackages(20)="Tyrion"
     EditPackages(21)="Physics"
     EditPackages(22)="TribesAdmin"
     EditPackages(23)="TribesWebAdmin"
     EditPackages(24)="TribesVoting"
     EditPackages(25)="TribesTVClient"
     EditPackages(26)="TribesTVServer"
     EditPackages(27)="Speedo"
     EditPackages(28)="tvbp_b4"
     CacheSizeMegs=32
     UsePerforce=0
}
