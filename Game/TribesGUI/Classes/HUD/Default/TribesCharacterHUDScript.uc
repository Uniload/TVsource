class TribesCharacterHUDScript extends TribesInGameHUDScript;

// weapons
var HUDWeaponIcon fallbackWeapon;
var HUDWeaponIcon weapons[3];
var HUDDeployableIcon deployable;
var HUDCarryableIcon carryable;

// other items
var HUDHealthKitIcon healthKit;
var HUDPackIcon pack;
var HUDGrenadesIcon grenades;

var HUDLoadoutMenu		loadoutMenu;
var HUDContainer		loadoutMenuContainer;
var LoadoutMenu			rootLoadoutMenuObject;
var String				rootLoadoutMenuObjectName;
var bool				bOldLoadoutSelection;
var PlayerProfile		ActiveProfile;

//
// Initalises the component
//
overloaded function Construct()
{
	super.Construct();

	// weapon bar
	fallbackWeapon = HUDWeaponIcon(AddElement("TribesGUI.HUDWeaponIcon", "default_FallbackWeapon"));
	fallbackWeapon.weaponIdx = -1;
	weapons[0] = HUDWeaponIcon(AddElement("TribesGUI.HUDWeaponIcon", "default_weapon0"));
	weapons[0].weaponIdx = 0;
	weapons[1] = HUDWeaponIcon(AddElement("TribesGUI.HUDWeaponIcon", "default_weapon1"));
	weapons[1].weaponIdx = 1;
	weapons[2] = HUDWeaponIcon(AddElement("TribesGUI.HUDWeaponIcon", "default_weapon2"));
	weapons[2].weaponIdx = 2;
	deployable = HUDDeployableIcon(AddElement("TribesGUI.HUDDeployableIcon", "default_deployable"));
	carryable = HUDCarryableIcon(AddElement("TribesGUI.HUDCarryableIcon", "default_Carryable"));

	// item bar
	pack		= HUDPackIcon(AddElement("TribesGUI.HUDPackIcon", "default_pack"));
	grenades	= HUDGrenadesIcon(AddElement("TribesGUI.HUDGrenadesIcon", "default_grenades"));

	loadoutMenuContainer = HUDContainer(AddElement("TribesGUI.HUDContainer", "default_LoadoutMenuContainer"));
	loadoutMenu = HUDLoadoutMenu(loadoutMenuContainer.AddElement("TribesGUI.HUDLoadoutMenu", "default_LoadoutMenu"));
	RegisterKeyEventReceptor(loadoutMenu);

	// load up the root menu (only once!)
	rootLoadoutMenuObject = LoadoutMenu(FindObject("RootLoadoutMenu", class'TribesGUI.LoadoutMenu'));
	if(rootLoadoutMenuObject == None)
	{
		rootLoadoutMenuObject = new (None, "RootLoadoutMenu") class'TribesGUI.LoadoutMenu';
		rootLoadoutMenuObject.InitMenu();
		loadoutMenu.InitMenu(rootLoadoutMenuObject, None, loadoutMenuContainer);
	}
}

function UpdateData(ClientSideCharacter c)
{
	super.UpdateData(c);

	// always cancel the menu if we are not enabled
	if(! c.bLoadoutSelection)
		loadoutMenu.CancelAll();
	else if(bOldLoadoutSelection != c.bLoadoutSelection)
	{
		rootLoadoutMenuObject.RefreshMenu(c.loadoutNames, c.loadoutEnabled);
		loadoutMenu.OpenMenu();
	}

	bOldLoadoutSelection = c.bLoadoutSelection;
}
