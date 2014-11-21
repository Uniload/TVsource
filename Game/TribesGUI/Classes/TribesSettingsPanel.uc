// ====================================================================
//  Class:  TribesGui.TribesSettingsPanel
//  Parent: TribesGUIPage
//
//  Menu to load map from entry screen.
// ====================================================================

class TribesSettingsPanel extends TribesGUIPanel
     Abstract
	 native;

var protected bool bLoadingSettings;

/*function LoadSettings();
function SaveSettings();

function InitComponent(GUIComponent MyOwner)
{
	Super.InitComponent(MyOwner);
    OnShow=InternalOnShow;
    OnHide=InternalOnHide;
}

function InternalOnShow()
{
    bLoadingSettings=true;
    LoadSettings();
    bLoadingSettings=false;
    GUIPage(MenuOwner.MenuOwner).OnDlgReturned=InternalDlgReturned;
}

function InternalOnHide()
{
    SaveSettings();
}

final function ApplySetting( String Setting )
{
    InternalApplySetting( Setting );
    SaveSettings();
}

final function ApplyDangerousSetting( String Passback, String Caption )
{
log("dkaplan >>> ApplyDangerousSetting( "$Passback$", "$Caption$")");
    GUIPage(MenuOwner.MenuOwner).OpenDlg( Caption, QBTN_OkCancel, "Confirm"$Passback );
}

final function InternalDlgReturned( int returnButton, optional string Passback )
{
log("dkaplan >>> InternalDlgReturned( "$returnButton$", "$Passback$")");
    if( returnButton == QBTN_Cancel ||
        returnButton == QBTN_TimeOut )
    {
        bLoadingSettings=true;
        LoadSettings();
        bLoadingSettings=false;
        if( InStr( Passback, "Test" ) >= 0 )
        {
            Passback = Right(Passback, ( Len(Passback) - 4 ) );
            InternalApplySetting( Passback, true );
        }
        return;
    }
    AssertWithDescription( returnButton == QBTN_OK, "Return value from confirmation dialog was not valid in TribesVideoSettingsPanel.");
    if( InStr( Passback, "Confirm" ) >= 0 )
    {
        Passback = Right(Passback, ( Len(Passback) - 7 ) );
        InternalApplySetting( Passback );
        GUIPage(MenuOwner.MenuOwner).OpenDlg( "Please confirm that the new settings are good.", QBTN_OkCancel, "Test"$Passback, 5.0 );
        return;
    }
    SaveSettings();
}

function InternalApplySetting( string Setting, optional bool bDontSave );*/

function OnOptionsEnding()
{
	TribesOptionsMenu(MenuOwner.MenuOwner).EndOptions();
}

defaultproperties
{
    WinLeft=0.05
    WinTop=0.21333
    WinHeight=0.66666
    WinWidth=0.875
}