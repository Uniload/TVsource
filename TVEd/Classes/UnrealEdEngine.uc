class UnrealEdEngine extends Editor.EditorEngine
	native
	noexport
	transient;

#exec LOAD FILE=Engine_res.pkg

var const int	NotifyVtbl;
var const int	hWndMain;

defaultproperties
{
     AutoSaveIndex=7
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
}
