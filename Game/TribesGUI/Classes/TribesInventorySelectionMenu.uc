// ====================================================================
//  Class:  TribesGui.TribesInventorySelectionMenu
//
//  Menu to load map from entry screen.
// ====================================================================

class TribesInventorySelectionMenu extends TribesGUIPage;

import enum EInputKey from Engine.Interactions;
import enum EInputAction from Engine.Interactions;

//
// Struct holding parameters for laying out buttons
//
struct ButtonParams
{
	var() config float	gutter			"Gutter space between buttons";
	var() config int	rows			"Number of rows for the buttons";
	var() config int	columns			"Number of Columns for the buttons";
	var() config string	styleName		"Button style";
};

// Armor buttons array and layout parameters
var(TribesGui) private array<TribesInventoryArmorButton>	ArmorButtons			"Array of Armor buttons available for selection";
var(TribesGui) private EditInline Config GUIPanel			ArmorButtonsContainer	"Container to place the armor buttons within";
var(TribesGUI) private EditInline Config ButtonParams		ArmorParams				"Layout parameters for the armor button region";

// Pack buttons array and layout parameters
var(TribesGui) private array<TribesInventoryPackButton>		PackButtons				"Array of Pack buttons available for selection";
var(TribesGui) private EditInline Config GUIPanel			PackButtonsContainer	"Container to place the pack buttons within";
var(TribesGUI) private EditInline Config ButtonParams		PackParams				"Layout parameters for the packs button region";

// Weapon buttons array and layout parameters
var(TribesGui) private array<TribesInventoryWeaponButton>	WeaponButtons			"Array of Weapon buttons available for selection";
var(TribesGui) private EditInline Config GUIPanel			WeaponButtonsContainer	"Container to place the weapon buttons within";
var(TribesGUI) private EditInline Config ButtonParams		WeaponParams			"Layout parameters for the weapons button region";

// Loadout buttons array and layout parameters
var(TribesGui) private array<TribesInventoryLoadoutButton>	LoadoutButtons			"Array of Loadout buttons available for selection";
var(TribesGui) private EditInline Config GUIPanel			LoadoutButtonsContainer	"Container to place the loadout buttons within";
var(TribesGUI) private EditInline Config ButtonParams		LoadoutParams			"Layout parameters for the loadout button region";

// Weapon slot buttons layout parameters
var(TribesGui) private EditInline Config GUIPanel			WeaponSlotsContainer	"Container to place the weapon slot buttons within";
var(TribesGUI) private EditInline Config ButtonParams		WeaponSlotParams		"Layout parameters for the weapon slot button region";

// title
var(TribesGUI) private EditInline Config GUILabel	TitleLabel						"Title at the top of the window";

// buttons
var(TribesGui) private EditInline Config GUIButton	LoadoutGroupUpButton	"Press to go up one loadout group";
var(TribesGui) private EditInline Config GUIButton	LoadoutGroupDownButton	"Press to go down one loadout group";
var(TribesGui) private EditInline Config GUIButton	ResetLoadoutButton		"Press to reset the current loadout";
var(TribesGui) private EditInline Config GUIButton	DoneButton				"Press to apply the selected loadout and exit the screen";
var(TribesGui) private EditInline Config GUIButton	NextSkinButton			"Press to show the next available skin for th character";
var(TribesGui) private EditInline Config GUIButton	PreviousSkinButton		"Press to show the previous available skin for th character";
// watched item info
var(TribesGUI) private EditInline Config GUILabel	WatchedItemNameLabel	"Displayed the name of the currently watched item";
var(TribesGUI) private EditInline Config GUILabel	WatchedItemInfoLabel	"Displays info about the currently watched item";
var(TribesGUI) private EditInline Config GUIImage	WatchedItemIcon			"Displays an icon for the currently watched item";
// watched loadout info
var(TribesGUI) private EditInline Config GUIImage	WatchedLoadoutArmorIcon		"Displays an icon for the currently watched loadout armor";
var(TribesGUI) private EditInline Config GUIImage	WatchedLoadoutPackIcon		"Displays an icon for the currently watched loadout pack";
var(TribesGUI) private EditInline Config GUIImage	WatchedLoadoutWeaponIcon1	"Displays an icon for the currently watched loadout weapon slot 1";
var(TribesGUI) private EditInline Config GUIImage	WatchedLoadoutWeaponIcon2	"Displays an icon for the currently watched loadout weapon slot 2";
var(TribesGUI) private EditInline Config GUIImage	WatchedLoadoutWeaponIcon3	"Displays an icon for the currently watched loadout weapon slot 3";

// character view container
var(TribesGui) private EditInline Config GUIPanel	CharacterContainer;

// viewport container for teh external view
var(TribesGui) private EditInline Config GUIPanel	ExternalViewportPanel		"Container where the external view will be drawn";

// localised string values
var(TribesGUI) localized String	ArmorText			"Armor label string (defaults to '1 - Select Armor')";
var(TribesGUI) localized String	PackText			"Pack label string (defaults to '2 - Select Pack')";
var(TribesGUI) localized String	WeaponText			"Pack label string (defaults to '3 - Select Weapon')";
var(TribesGUI) localized String	AcceptText			"Info label string (defaults to '4 - Accept Changes & Exit')";
var(TribesGUI) localized String	currentLoadoutText	"Text of the current loadout tab (defaults to 'Current')";
var(TribesGUI) localized String TitleText			"Text of the title";

// general configuration variables
var(TribesGUI) Config bool	bAutoAdvanceSlotSelection	"Whether to advance to the next weapon slot automatically after applyin a weapon";
var(TribesGUI) Config bool	bSwapDuplicateWeaponSlots	"Whether to swap weapons in slots when a duplicate weapon is selected";
var(TribesGUI) Config int	MaxLoadoutSlots				"Max number of loadout available in total";
var(TribesGUI) Config int	NumVisibleLoadoutSlots		"Max number of loadout slots to display in one row";
var(TribesGUI) Config int	NumWeaponSlots				"Max number of weapon slots available";
var(TribesGUI) Config int	MaxLoadoutNameLength		"Max number of characters in a loadout name";

// data we need to operate
var InventoryStationAccess		inventory;
var PlayerCharacterController	characterController;
var Character					playerCharacter;
var PlayerProfile				activeProfile;
var TeamInfo					playerTeam;

var InventoryStationAccess.InventoryStationLoadout	selectedLoadout;
var InventoryStationAccess.InventoryStationWeapon	NoWeapon;

var Array<class<SkinInfo> >				availableSkins;
var int									currentSkinIndex;
var int									lastAppliedWeaponSlotIndex;
var GUIEditBox							loadoutEditBox;
var TribesInventoryLoadoutButton		CurrentLoadoutTab;
var Array<TribesInventoryWeaponSlot>	WeaponSlots;
var TribesInventoryWeaponSlot			SelectedWeaponSlot;
var TribesInventoryWeaponButton			SelectedWeaponButton;
var TribesInventoryLoadoutButton		SelectedLoadoutButton;
var TribesInventoryLoadoutButton		editedLoadoutButton;
var TribesInventoryCharacterView		CharacterView;
var HUDHealthBar						healthBar;
var HUDEnergyBar						energyBar;
var HUDContainer						healthEnergyContainer;
var ClientSideCharacter					clientData;
var int									currentLoadoutArrayStart;
var class<InventoryStationAccess>		lastAccessClass;
var bool								bUseProfiles;

var Rotator								PreviousCameraRotation;
var bool								bOldBehindView;
var Material							ExternalViewportSurround;

// These variables are set when the menu needs to be used outside of a level,
// eg: to edit loadouts within the GUI menu system
var bool								bNotInGame;
var bool								bIsFemale;

const CURRENT_LOADOUT_SLOT = -1;

// ------------------------------------------------------------------
// TUTORIAL FUNCTIONS
// ------------------------------------------------------------------

function FlashArmor(class<CombatRole> ItemClass, float Duration)
{
	local int index;
	local TribesInventoryButton TutorialButton;

	if(inventory.bInventoryTutorial)
	{
		TutorialButton = FindArmorButton(ItemClass, index);

		if(TutorialButton != None)
		{
			TutorialButton.EnableComponent();
			inventory.roles[index].bEnabled = true;
			TutorialButton.DoFlash(PlayerOwner().Level.TimeSeconds, Duration);
		}
	}
}

function FlashWeapon(class<Weapon> ItemClass, float Duration)
{
	local int index;
	local TribesInventoryButton TutorialButton;

	if(inventory.bInventoryTutorial)
	{
		TutorialButton = FindWeaponButton(itemClass, index);

		if(TutorialButton != None)
		{
			TutorialButton.EnableComponent();
			inventory.weapons[index + inventory.numFallbackWeapons].bEnabled = true;
			TutorialButton.DoFlash(PlayerOwner().Level.TimeSeconds, Duration);
		}
	}
}

function EnableExit()
{
	DoneButton.EnableComponent();
}

// ------------------------------------------------------------------
// END TUTORIAL FUNCTIONS
// ------------------------------------------------------------------

function InitComponent(GUIComponent MyOwner)
{
	local String TeamClassName, InvAccessClassName;
	local class<TeamInfo> TeamClass;
	local int i, loadout;

	super.InitComponent(MyOwner);

	// need to receive the activate event to install the current loadout
	OnActivate = InternalOnActivate;	
	OnWatched = OnPageWatched;
	OnKeyEvent = InternalOnKeyEvent;
	OnClick = InternalOnClick;

	// 
	LoadoutButtonsContainer.OnWatched = OnPageWatched;
	ArmorButtonsContainer.OnWatched = OnPageWatched;
	PackButtonsContainer.OnWatched = OnPageWatched;
	WeaponButtonsContainer.OnWatched = OnPageWatched;

	// config the main control buttons
	DoneButton.OnClick = OnExitInventory;
	LoadoutGroupUpButton.OnClick = OnLoadoutGroupUp;
	LoadoutGroupDownButton.OnClick = OnLoadoutGroupDown;
	ResetLoadoutButton.OnClick = OnLoadoutReset;
	NextSkinButton.OnClick = OnSkinNext;
	PreviousSkinButton.OnClick = OnSkinPrevious;

	// character view
	CharacterView = TribesInventoryCharacterView(characterContainer.AddComponent("TribesGUI.TribesInventoryCharacterView", "", true));
	CharacterView.WinTop = 0;
	CharacterView.WinLeft = 0;
	CharacterView.WinWidth = 1;
	CharacterView.WinHeight = 1;

	// health/energy bar
	healthEnergyContainer = new(None, "default_inventoryHealthEnergyGroup") class'TribesGUI.HUDContainer';
	healthBar = HUDHealthBar(healthEnergyContainer.AddElement("TribesGUI.HUDHealthBar", "default_inventoryHealth"));
	energyBar = HUDEnergyBar(healthEnergyContainer.AddElement("TribesGUI.HUDEnergyBar", "default_inventoryEnergy"));
	clientData = new class'ClientSideCharacter';
	healthEnergyContainer.LocalData = clientData;
	energyBar.LocalData = clientData;
	healthBar.LocalData = clientData;
	healthEnergyContainer.relativePosX = characterContainer.Winleft;
	healthEnergyContainer.relativePosY = characterContainer.WinTop;

	//
	// loadout setup: we make the buttons once, and then assign 
	// their data whenever the user enters the station
	//
	CurrentLoadoutTab = TribesInventoryLoadoutButton(LoadoutButtonsContainer.AddComponent("TribesGUI.TribesInventoryLoadoutButton", "CurrentLoadoutTab", true));
	CurrentLoadoutTab.OnClick = OnLoadoutClick;
	CurrentLoadoutTab.OnWatched = OnLoadoutWatched;
	CurrentLoadoutTab.OnMousePressed = InternalOnMousePressed;
	CurrentLoadoutTab.slotIndex = CURRENT_LOADOUT_SLOT;
	CurrentLoadoutTab.Caption = currentLoadoutText;
	CurrentLoadoutTab.SetEmpty(false);

	LoadoutButtons[0] = CurrentLoadoutTab;
	loadout = 1;

	// pull the loadouts out of the player profile & make up the buttons
	for(i = 0; i < MaxLoadoutSlots; i++)
	{
		LoadoutButtons[loadout] = TribesInventoryLoadoutButton(LoadoutButtonsContainer.AddComponent("TribesGUI.TribesInventoryLoadoutButton", 
			"LoadoutButton"$i, true));
		LoadoutButtons[loadout].OnClick = OnLoadoutClick;
		LoadoutButtons[loadout].OnWatched = OnLoadoutWatched;
		LoadoutButtons[loadout].OnMousePressed = InternalOnMousePressed;
		LoadoutButtons[loadout].slotIndex = i;
		LoadoutButtons[loadout].SetEmpty(true);

		loadout++;
	}
	currentLoadoutArrayStart = 0;
	UpdateLoadoutTabs();

	// This only gets called in the precaching, so we can spawn a default
	// inv station and use it to precache the buttons onto the interface now
	TeamClassName = "GameClasses.TeamInfoImperial";
	InvAccessClassName = "BaseObjectClasses.InventoryStationAccessDefault";

	lastAccessClass = Class<InventoryStationAccess>(DynamicLoadObject(InvAccessClassName, class'Class'));
	inventory = PlayerOwner().spawn(lastAccessClass);
	inventory.clientSetupInventoryStation(None);
	TeamClass = Class<TeamInfo>(DynamicLoadObject(TeamClassName, class'Class'));
	playerTeam = PlayerOwner().spawn(teamClass);
	if(TribesGUIController(Controller).profileManager == None)
	{
		// create the ProfileManager
		TribesGUIController(Controller).profileManager = new class'TribesGUI.ProfileManager';
		TribesGUIController(Controller).profileManager.LoadProfiles(TribesGUIController(Controller));
	}
	activeProfile = TribesGUIController(Controller).profileManager.GetActiveProfile();

	ConfigureInventoryStation();

	inventory.Destroy();
	inventory = None;
	playerTeam.Destroy();
	playerTeam = None;
}

function ConfigureInventoryStation()
{
	local int i, j;

	//
	// Remove all the components first
	//
	for(i = 0; i < ArmorButtons.Length; ++i)
		ArmorButtonsContainer.RemoveComponent(ArmorButtons[i]);

	for(i = 0; i < WeaponSlots.Length; ++i)
		WeaponSlotsContainer.RemoveComponent(WeaponSlots[i]);

	for(i = 0; i < WeaponButtons.Length; ++i)
		WeaponButtonsContainer.RemoveComponent(WeaponButtons[i]);

	for(i = 0; i < PackButtons.Length; ++i)
		PackButtonsContainer.RemoveComponent(PackButtons[i]);

	//
	// Now we can add all new components as defined by the
	// inventory station access class
	//

	// pull the combat roles out of the inventory & make up the buttons
	for(i = 0; i < inventory.roles.Length; i++)
	{
		ArmorButtons[i] = TribesInventoryArmorButton(ArmorButtonsContainer.AddComponent("TribesGUI.TribesInventoryArmorButton", 
			String(inventory.roles[i].combatRoleClass.name), true));

		ArmorButtons[i].SetArmorData(playerTeam, inventory.roles[i]);

		ArmorButtons[i].OnClick = OnArmorClick;
		ArmorButtons[i].OnWatched = OnArmorWatched;
		ArmorButtons[i].OnMousePressed = InternalOnMousePressed;

		if(! inventory.roles[i].bEnabled)
			ArmorButtons[i].DisableComponent();
	}
	ApplyButtonParams(ArmorButtons, ArmorParams);

	// weapon slots
	for(i = 0; i < inventory.maxWeapons; ++i)
	{
		WeaponSlots[i] = TribesInventoryWeaponSlot(WeaponSlotsContainer.AddComponent("TribesGUI.TribesInventoryWeaponSlot", "WeaponSlot"$i, true));
		//		WeaponSlots[i].OnClick = OnSelectWeaponSlot;
		WeaponSlots[i].OnAssign = OnAssignWeapon;
		WeaponSlots[i].OnMousePressed = InternalOnMousePressed;
		WeaponSlots[i].slotIndex = i;
	}
	ApplyButtonParams(WeaponSlots, WeaponSlotParams);
	//	WeaponSlots[0].SetChecked(true);

	// pull the weapons out of the inventory & make up the buttons
	for(i = 0; i < inventory.weapons.Length; i++)
	{
		if(i >= inventory.numFallbackWeapons)
		{
			WeaponButtons[j] = TribesInventoryWeaponButton(WeaponButtonsContainer.AddComponent("TribesGUI.TribesInventoryWeaponButton", 
				String(inventory.weapons[i].weaponClass.name), true));

			WeaponButtons[j].SetWeaponData(inventory.weapons[i]);
			WeaponButtons[j].OnClick = OnWeaponClick;
			WeaponButtons[j].OnWatched = OnWeaponWatched;
			WeaponButtons[j].OnMousePressed = InternalOnMousePressed;

			if(! inventory.weapons[i].bEnabled)
				WeaponButtons[j].DisableComponent();

			j++;
		}
	}
	ApplyButtonParams(WeaponButtons, WeaponParams);

	// pull the packs out of the inventory & make up the buttons
	for(i = 0; i < inventory.packs.Length; i++)
	{
		PackButtons[i] = TribesInventoryPackButton(PackButtonsContainer.AddComponent("TribesGUI.TribesInventoryPackButton", 
			String(inventory.packs[i].packClass.name), true));

		PackButtons[i].SetPackData(inventory.packs[i]);

		PackButtons[i].OnClick = OnPackClick;
		PackButtons[i].OnWatched = OnPackWatched;
		PackButtons[i].OnMousePressed = InternalOnMousePressed;

		if(! inventory.packs[i].bEnabled)
			PackButtons[i].DisableComponent();
	}
	ApplyButtonParams(PackButtons, PackParams);
}

//
// Hack fix for focusing problem: when the edit box is open, the
// many buttons which are bNeverFocus don't focus, thus they dont
// send the event to the edit box. All of those buttons send their
// mouse pressed event here to catch it.
//
function InternalOnMousePressed(GUIComponent Sender)
{
	OnLoadoutEditFocusLost(loadoutEditBox);
	super.OnMousePressed(Sender);
}

function ApplyButtonParams(Array<GUIComponent> buttons, ButtonParams params, optional int startIndex)
{
	local int i;
	local int currentRow, currentColumn;
	local float buttonWidth, buttonHeight;
	local float VerticalGutter, HorizontalGutter;

	if(buttons[0] == None)
		return;

	HorizontalGutter = params.gutter / buttons[0].MenuOwner.ActualWidth();
	VerticalGutter = params.gutter / buttons[0].MenuOwner.ActualHeight();

	buttonWidth = (1.0 - (HorizontalGutter * (params.columns - 1))) / params.columns;
	buttonHeight = (1.0 - (VerticalGutter * (params.rows - 1))) / params.rows;

	for(i = 0; i < buttons.Length; i++)
	{
		// hide any buttons outside the column allowance
		// or not in the specified range
		if(currentColumn >= params.columns || currentRow >= params.Rows || i < startIndex)
		{
			buttons[i].bCanBeShown = false;
			buttons[i].Hide();
		}
		else
		{
			// apply positional parameters
			buttons[i].WinLeft = currentColumn * (buttonWidth + HorizontalGutter);
			buttons[i].WinTop = currentRow * (buttonHeight + VerticalGutter);
			buttons[i].WinWidth = buttonWidth;
			buttons[i].WinHeight = buttonHeight;

			// update the style
			buttons[i].StyleName = params.styleName;
			buttons[i].Style = Controller.GetStyle(buttons[i].StyleName);
			if(TribesInventoryWeaponSlot(buttons[i]) != None)	// Hack: weapon slots dont work this way, they need the init component
				buttons[i].InitComponent(buttons[i].MenuOwner);

			// show it
			buttons[i].SetDirty();
			buttons[i].bCanBeShown = true;
			buttons[i].Show();

			// increment row and check for a new column
			currentColumn++;
			if(currentColumn >= params.columns)
			{
				currentColumn = 0;
				currentRow++;
			}
		}
	}
}

function UpdateWeaponSlots(int NewNumSlots)
{
	Clamp(NewNumSlots, 1, inventory.maxWeapons);

	if(NumWeaponSlots != NewNumSlots)
	{
		NumWeaponSlots = NewNumSlots;
		WeaponSlotParams.Columns = NumWeaponSlots;
		ApplyButtonParams(WeaponSlots, WeaponSlotParams);
	}
}

function UpdateLoadoutTabs()
{
	if(! inventory.bCanUseCustomLoadouts)
		return;

	OnLoadoutEditFocusLost(LoadoutEditBox);
	ApplyButtonParams(LoadoutButtons, LoadoutParams, currentLoadoutArrayStart);
}

function OnClientDraw(Canvas C)
{
	local float percentageHealth;
	local string NewString;
	local int minutes, seconds;
	local int viewX, viewY;

	local vector Location;
	local Actor ViewActor;

	super.OnClientDraw(C);

	//
	// This is hacky, but it works: The base gui page wont receive Watched events
	// unless its state is MSAT_Blurry, and I need them to reset the info view
	// when a component is Unwatched, so this is a great place to make sure it is
	// set every frame.
	//
	MenuState = MSAT_Blurry;

	if(healthEnergyContainer != None)
	{
		// update the characters client side info, as this wont be happening
		// while we are in the interface, and update the percentage of user
		// health to display
		if(playerCharacter != None)
		{
			characterController.clientSideChar.health = playerCharacter.health;
			characterController.clientSideChar.healthMaximum = playerCharacter.healthMaximum;
			characterController.clientSideChar.healthInjectionAmount = playerCharacter.GetHealthInjectionAmount();
			percentageHealth = FClamp(characterController.clientSideChar.health / characterController.clientSideChar.healthMaximum, 0.0, 1.0);
			if(percentageHealth >= 1.0)
				playerCharacter.StopHealthInjection();
		}
		else
		{
			percentageHealth = 1.0;
		}

		// update the clientData with out armor values for health & energy (the clientData points
		// to PlayerCharacterController.clientSideChar)
		clientData.levelTimeSeconds = PlayerOwner().Level.timeSeconds;
		if(selectedLoadout.role.combatRoleClass != None && selectedLoadout.role.combatRoleClass.default.armorClass != None)
		{
			clientData.healthMaximum = selectedLoadout.role.combatRoleClass.default.armorClass.default.health;
			// apply the health modifier
			if(SinglePlayerCharacter(playerCharacter) != None)
			{
				clientData.healthMaximum *= SinglePlayerCharacter(playerCharacter).healthModifier;
				if(playerCharacter.bApplyHealthFilter)
                    if (TribesGUIController(Controller).GuiConfig.CurrentCampaign!=none)
					    clientData.healthMaximum *= SinglePlayerGameInfo(playerCharacter.Level.Game).difficultyMods[TribesGUIController(Controller).GuiConfig.CurrentCampaign.selectedDifficulty].playerHealthMultiplier;
			}

			// The value in the energy bar needs to be synced with the movement config by the designers!!!!
			clientData.bShowEnergyBar = true;
			clientData.energyMaximum = selectedLoadout.role.combatRoleClass.default.armorClass.default.energy;
			clientData.energy = selectedLoadout.role.combatRoleClass.default.armorClass.default.energy;
		}
		else if(playerCharacter != None)
			clientData.healthMaximum = playerCharacter.healthMaximum;
		clientData.health = percentageHealth * clientData.healthMaximum;

		// draw the health & energy bars
		healthEnergyContainer.UpdateData(clientData);
		healthEnergyContainer.ForceNeedsLayout();
		if(healthEnergyContainer.bNeedsLayout)
			healthEnergyContainer.DoLayout(c);
		healthEnergyContainer.Render(C);
	}

	//
	// Draw the external view...
	//
	if( characterController != None && characterController.Pawn != None )
	{
		viewX = ExternalViewportPanel.ActualLeft();
		viewY = ExternalViewportPanel.ActualTop();
		characterController.InventoryCalcView(ViewActor, Location, PreviousCameraRotation);

		C.DrawPortalScaled( viewX, viewY, 
							ExternalViewportPanel.ActualWidth(), ExternalViewportPanel.ActualHeight(), 
							ViewActor, Location, PreviousCameraRotation);

		C.DrawColor = C.MakeColor(255, 255, 255, 255);
		c.Style = 1;
		C.SetPos(viewX, viewY);
		C.DrawTileStretched(ExternalViewportSurround, ExternalViewportPanel.ActualWidth(), ExternalViewportPanel.ActualHeight());
	}

	// If there's a countdown, show it in the title since you'll get kicked out when it ends
	// Stole display code from the countdown timer; would be nice if this was centralized somewhere
	//
	// Note from Paul: this could have been done by creating a 
	// Countdown HUD Element and displaying it, just like the 
	// energy bars above.
	//
	if (characterController != None && characterController.clientSideChar.bRoundCountingDown)
	{
		NewString = "";

		minutes = characterController.RoundInfo.replicatedRemainingCountDown / 60.0;
		seconds = characterController.RoundInfo.replicatedRemainingCountDown - minutes * 60.0;

		if(minutes < 10)
			NewString = "0";

		NewString $= minutes $ ":";

		if (seconds < 10)
			NewString $= "0";

		NewString $= seconds;

		TitleLabel.Caption = TitleText $ " - " $ NewString;
	}
	else
		TitleLabel.Caption = TitleText;
}

function OnPageWatched(GUIComponent Sender)
{
	WatchedItemNameLabel.Caption = "";
	WatchedItemInfoLabel.Caption = "";
	WatchedItemIcon.Image = None;
	WatchedLoadoutArmorIcon.Image = None;
	WatchedLoadoutPackIcon.Image = None;
	WatchedLoadoutWeaponIcon1.Image = None;
	WatchedLoadoutWeaponIcon2.Image = None;
	WatchedLoadoutWeaponIcon3.Image = None;
}

function InternalOnClick(GUIComponent Sender)
{
	if(editedLoadoutButton != None && loadoutEditBox != None)
		OnLoadoutEditFocusLost(loadoutEditBox);
}

//
//
//
Delegate bool OnCapturedMouseMove(float deltaX, float deltaY)
{
	OnPageWatched(self);
	return false;
}

function InternalOnActivate()
{
	local InventoryStationAccess.InventoryStationLoadout loadout;
	local CustomPlayerLoadout activeLoadout;
	local TribesInventoryArmorButton armorButton;
	local int i, w;
	local bool bCurrentArmorUnavailable;

	activeProfile = TribesGUIController(Controller).profileManager.GetActiveProfile();

	if(! bNotInGame)
	{
		characterController = PlayerCharacterController(PlayerOwner());
		if(characterController == None)
		{
			warn("No character controller when activating inventory station");
			return;
		}

		if(characterController.inventoryStation == None)
		{
			warn("No InventoryStationAccess when activating inventory station");
			return;
		}

		playerCharacter = characterController.character;
		inventory = characterController.inventoryStation;
		if(characterController.IsSinglePlayer())
		{
			playerTeam = playerCharacter.team();
			bIsFemale = playerCharacter.bIsFemale;
		}
		else
		{
			playerTeam = TribesReplicationInfo(characterController.PlayerReplicationInfo).team;
			bIsFemale = characterController.PlayerReplicationInfo.bIsFemale;
		}

		//
		// Get the loadout the user entered with and 
		// convert it to an inventory loadout
		//
		bUseProfiles = ! characterController.IsSinglePlayer();
		loadout = inventory.GetCurrentUserLoadout();
		if(bUseProfiles)
			ConvertToCustomLoadout(loadout, activeLoadout);

		PreviousCameraRotation = characterController.Rotation;
		bOldBehindView = characterController.bBehindView;
		characterController.bBehindView = true;
	}
	else
		bUseProfiles = true;

	CharacterView.InitCharacterProperties(playerTeam, bIsFemale);

	//
	// Reconfigure the inventory station if necesary
	//
	if(lastAccessClass == None || lastAccessClass != inventory.class)
	{
		ConfigureInventoryStation();
		lastAccessClass = inventory.class;
	}

	//
	// Reconfigure the loadouts every activate - this is really important
	//
	if(! inventory.bCanUseCustomLoadouts)
	{
		// hide all loadout related data
		CurrentLoadoutTab.bCanBeShown = false;
		CurrentLoadoutTab.Hide();

		LoadoutButtonsContainer.bCanBeShown = false;
		LoadoutButtonsContainer.Hide();

		LoadoutGroupUpButton.bCanBeShown = false;
		LoadoutGroupUpButton.Hide();

		LoadoutGroupDownButton.bCanBeShown = false;
		LoadoutGroupDownButton.Hide();

		ResetLoadoutButton.bCanBeShown = false;
		ResetLoadoutButton.Hide();
	}
	else
	{
		// hide all loadout related data
		CurrentLoadoutTab.bCanBeShown = true;
		CurrentLoadoutTab.Show();

		LoadoutButtonsContainer.bCanBeShown = true;
		LoadoutButtonsContainer.Show();

		LoadoutGroupUpButton.bCanBeShown = true;
		LoadoutGroupUpButton.Show();

		LoadoutGroupDownButton.bCanBeShown = true;
		LoadoutGroupDownButton.Show();

		ResetLoadoutButton.bCanBeShown = true;
		ResetLoadoutButton.Show();
	}

	//
	// If the active loadout has no valid data in it,
	// then we need to build one from the profile.
	//
	if(loadout.NoLoadout && bUseProfiles)
	{
		activeLoadout = activeProfile.GetActiveLoadout();

		// build a loadout from the player profile
		ConvertToInventoryLoadout(activeLoadout, loadout);

		if(loadout.NoLoadout)
		{
			loadout.NoLoadout = false;
			// combat role
			for(i = 0; i < inventory.roles.Length; ++i)
			{
				if(inventory.roles[i].combatRoleClass != None && inventory.roles[i].bEnabled)
				{
					loadout.role = inventory.roles[i];
					break;
				}
			}
			// pack
			for(i = 0; i < inventory.packs.Length; ++i)
			{
				if(inventory.packs[i].packClass != None && inventory.packs[i].bEnabled)
				{
					loadout.pack = inventory.packs[i];
					break;
				}
			}
			// weapons
			for(i = inventory.numFallbackWeapons; i < loadout.role.combatRoleClass.default.armorClass.default.maxCarriedWeapons; ++i)
			{
				if(inventory.weapons[i].weaponClass != None && inventory.weapons[i].bEnabled)
					loadout.weapons[w++] = inventory.weapons[i];
			}
			// grenades
			loadout.grenades = inventory.grenades;

			ConvertToCustomLoadout(loadout, activeLoadout);
		}
	}

	for(i = 0; i < inventory.roles.Length; ++i)
	{
		ArmorButtons[i].SetArmorData(playerTeam, inventory.roles[i]);
		if(! inventory.roles[i].bEnabled)
		{
			ArmorButtons[i].DisableComponent();
			if(inventory.roles[i].combatRoleClass == loadout.role.combatRoleClass)
				bCurrentArmorUnavailable = true;
		}
	}

	if(bCurrentArmorUnavailable)
	{
		for(i = 0; i < inventory.roles.Length; ++i)
		{
			if(inventory.roles[i].bEnabled)
			{
				loadout.role.combatRoleClass = inventory.roles[i].combatRoleClass;
				activeLoadout.combatRoleClass = inventory.roles[i].combatRoleClass;
			}
		}
	}

	if(inventory.bCanUseCustomLoadouts)
	{
		for(i = 0; i < LoadoutButtons.Length; ++i)
		{
			/// current loadout tab is first
			if(LoadoutButtons[i] != CurrentLoadoutTab)
			{
				if(activeProfile.GetLoadout(i - 1) != None)
				{
					LoadoutButtons[i].customLoadoutData = activeProfile.GetLoadout(i - 1);
					ConvertToInventoryLoadout(activeProfile.GetLoadout(i - 1), LoadoutButtons[i].loadoutData);
					LoadoutButtons[i].Caption = LoadoutButtons[i].customLoadoutData.loadoutName;
					LoadoutButtons[i].SetEmpty(false);
				}
				else
				{
					LoadoutButtons[i].SetEmpty(true);
				}

				armorButton = FindArmorButton(LoadoutButtons[i].loadoutData.role.combatRoleClass);
				LoadoutButtons[i].SetEnabled((armorButton != None && armorButton.MenuState != MSAT_Disabled) ||
											LoadoutButtons[i].loadoutData.role.combatRoleClass == loadout.role.combatRoleClass);

				LoadoutButtons[i].SetChecked(false);
			}
			else
				LoadoutButtons[i].SetChecked(true);
		}
	}

	for(i = 0; i < inventory.weapons.Length; ++i)
	{
		if(! inventory.weapons[i].bEnabled && i >= inventory.numFallbackWeapons)
			WeaponButtons[i - inventory.numFallbackWeapons].DisableComponent();
	}

	for(i = 0; i < inventory.packs.Length; ++i)
	{
		if(! inventory.packs[i].bEnabled)
			PackButtons[i].DisableComponent();
	}

	// initially disable the weapon slots
	SetWeaponSlotsEnabled();

	CurrentLoadoutTab.customLoadoutData = activeLoadout;
	CurrentLoadoutTab.loadoutData = loadout;
	CurrentLoadoutTab.Caption = currentLoadoutText;
	CurrentLoadoutTab.SetChecked(true);
	CurrentLoadoutTab.SetEmpty(false);

	UpdateLoadoutTabs();

	// disable Done button until key-up
	DoneButton.ClickKeyCode = -1;

	//
	// Set up for tutorial usage, which involves disabling some components
	// and posting an event message.
	//
	if(inventory.bInventoryTutorial)
	{
		for(i = 0; i < weaponSlots.Length; ++i)
			weaponSlots[i].DisableComponent();

		for(i = 0; i < armorButtons.Length; ++i)
			armorButtons[i].DisableComponent();

		armorButtons[1].EnableComponent();
		OnArmorClick(armorButtons[1]);

		NextSkinButton.bCanBeShown = false;
		NextSkinButton.Hide();

		PreviousSkinButton.bCanBeShown = false;
		PreviousSkinButton.Hide();

		DoneButton.DisableComponent();

		if(playerCharacter != None)
			playerCharacter.dispatchMessage(new class'MessageInventoryUIDisplayed');
	}

	// Don't show skin buttons in SP
	if (characterController.isSinglePlayer())
	{
		NextSkinButton.bCanBeShown = false;
		NextSkinButton.Hide();

		PreviousSkinButton.bCanBeShown = false;
		PreviousSkinButton.Hide();
	}

	OnPageWatched(self);
	OnLoadoutEditFocusLost(loadoutEditBox);

	SelectedLoadoutButton = CurrentLoadoutTab;
	SelectedLoadoutButton.SetChecked(true);

	SetCurrentLoadout(SelectedLoadoutButton.loadoutData);
	if(bUseProfiles)
		SetActiveProfileLoadout(SelectedLoadoutButton.loadoutData);

	//
	// This will update the skin and the loadout in the character view. It needs
	// to be done, because if there has been no change to the character since 
	// the last time they were in an inv station, then the view won't be changed.
	// 
	UpdateSkin();
	characterView.SetHeldWeapon(WeaponSlots[lastAppliedWeaponSlotIndex].weaponClass);
}

function bool InternalOnKeyEvent(out byte Key, out byte State, float delta)
{
	// disable Done button until key-up
	if(state == EInputAction.IST_Release)
		DoneButton.ClickKeyCode = 13;

	// allow escape key to exit inventory, but only if it's not a tutorial inventory
    if( !inventory.bInventoryTutorial && bVisible && bActiveInput && Key == EInputKey.IK_Escape && State == EInputAction.IST_Press )
	{
		OnExitInventory(DoneButton);
		return true;
	}

	// handle vehicle position switch

	// This needs to be done this way because normal exec functions will not work while the inventory station interaction is active.

	//if (state == EInputAction.IST_Release)
	//{
	//	if (Asc(characterController.vehiclePositionSwitchOneKey) == Key)
	//		characterController.inventoryStationSwitchVehiclePosition(1, selectedLoadout);
	//	else if (Asc(characterController.vehiclePositionSwitchTwoKey) == Key)
	//		characterController.inventoryStationSwitchVehiclePosition(2, selectedLoadout);
	//	else if (Asc(characterController.vehiclePositionSwitchThreeKey) == Key)
	//		characterController.inventoryStationSwitchVehiclePosition(3, selectedLoadout);
	//}

	return false;
}

//
// Saves the current loadout to the selected 
// loadout slot
//
function SaveCurrentLoadout()
{
	local CustomPlayerLoadout loadout;

	// dont bother for the 'current loadout' tab, or a 'None' SelectedLoadoutButton
	if(SelectedLoadoutButton == None || SelectedLoadoutButton.slotIndex == CURRENT_LOADOUT_SLOT)
		return;

	loadout = activeProfile.GetLoadoutAutoCreate(SelectedLoadoutButton.slotIndex);
	ConvertToCustomLoadout(selectedLoadout, loadout);

	SelectedLoadoutButton.customLoadoutData = loadout;
	SelectedLoadoutButton.loadoutData = selectedLoadout;
	SelectedLoadoutButton.SetEmpty(false);	

	activeProfile.Store();
}

function OnExitInventory(GUIComponent Sender)
{
	// force the inventory station to be non tutorial
	inventory.bInventoryTutorial = false;

	// force us back to our old behind view setting
	characterController.bBehindView = bOldBehindView;

	if (inventory == None || inventory.bDeleteMe)
		return;

	// store the current loadout
	if(bUseProfiles)
	{
		SaveCurrentLoadout();
		SetActiveProfileLoadout(selectedLoadout);
	}

	if(playerCharacter != None)
		playerCharacter.dispatchMessage(new class'MessageInventoryUIExited');

	if(bNotInGame)
	{
		playerTeam.Destroy();
		inventory.Destroy();
		bNotInGame = false;
		Controller.CloseMenu();
	}
	else
	{
		inventory.finishCharacterAccess(selectedLoadout);
	}

	if(bUseProfiles)
		activeProfile.Store();

	// dump any references to actors which may cause problems
	inventory = None;
	playerTeam = None;
	playerCharacter = None;
	characterController = None;
}

function OnHide()
{
	// force us back to our old behind view setting
	characterController.bBehindView = bOldBehindView;

	// being super sure we dont have any refs...
	inventory = None;
	playerTeam = None;
	playerCharacter = None;
	characterController = None;
}

function OnSkinNext(GUIComponent Sender)
{
	currentSkinIndex++;
	if(currentSkinIndex >= availableSkins.Length)
		currentSkinIndex = 0;

	UpdateSkin();
}

function OnSkinPrevious(GUIComponent Sender)
{
	currentSkinIndex--;
	if(currentSkinIndex < 0)
		currentSkinIndex = availableSkins.Length - 1;

	UpdateSkin();
}

function UpdateSkin()
{
	local String newSkinPref;

	if(availableSkins.Length <= 0)
		return;

	// set the player skin preference
	if(currentSkinIndex > 0)
		newSkinPref = availableSkins[currentSkinIndex].Outer.Name $"." $availableSkins[currentSkinIndex].name;
	else
		newSkinPref = "";
	class'CustomPlayerLoadout'.static.SetSkinPreference(SelectedLoadoutButton.customLoadoutData.skinPreferences, playerTeam.GetMeshForRole(SelectedLoadoutButton.loadoutData.role.combatRoleClass, bIsFemale), newSkinPref);
	selectedLoadout.userSkin = newSkinPref;

	characterView.inventoryCharacter.UpdateSkin(availableSkins[currentSkinIndex]);
	characterView.UpdateLoadout(selectedLoadout);
}

function OnAssignWeapon(TribesInventoryWeaponSlot AssignedSlot)
{
	local int ExistingSlotIndexForWeapon;
	local int AssignedWeaponSlotIndex;

	if(SelectedWeaponButton != None)
	{
		lastAppliedWeaponSlotIndex = AssignedSlot.SlotIndex;
		AssignedWeaponSlotIndex = AssignedSlot.SlotIndex;
		AssignWeaponToSlot(AssignedWeaponSlotIndex, SelectedWeaponButton.weaponData);
		if(playerCharacter != None)
			playerCharacter.dispatchMessage(new class'MessageInventoryUIWeaponSelected');

		ExistingSlotIndexForWeapon = GetSlotIndexHoldingWeapon(selectedWeaponButton.weaponData.weaponClass);
		if(ExistingSlotIndexForWeapon != -1 && ExistingSlotIndexForWeapon != AssignedWeaponSlotIndex)
		{
			if(bSwapDuplicateWeaponSlots)
				AssignWeaponToSlot(ExistingSlotIndexForWeapon, selectedLoadout.weapons[AssignedWeaponSlotIndex]);
			else
				AssignWeaponToSlot(ExistingSlotIndexForWeapon, NoWeapon);
		}

		SelectedWeaponButton = None;
	}

	SetWeaponSlotsEnabled();
	characterView.SetHeldWeapon(WeaponSlots[lastAppliedWeaponSlotIndex].weaponClass);
}

function SetWeaponSlotsEnabled()
{
	local int i;

	for(i = 0; i < WeaponSlots.Length; ++i)
		WeaponSlots[i].SetEnabled(SelectedWeaponButton != None);
}

// Inventory button callbacks
function OnWeaponClick(GUIComponent Sender)
{
	local int i;

	SelectedWeaponButton = TribesInventoryWeaponButton(Sender);

	// cycle through all the weapon buttons, checking to
	// ensure that none are selected when they shouldnt be
	for(i = 0; i < WeaponButtons.Length; ++i)
		WeaponButtons[i].SetChecked(WeaponButtons[i] == SelectedWeaponButton && WeaponButtons[i].MenuState != MSAT_Disabled);

	SetWeaponSlotsEnabled();
}

function OnWeaponWatched(GUIComponent Sender)
{
	if(inventory.bInventoryTutorial && TribesInventoryButton(Sender) != None && TribesInventoryButton(Sender).bIsFlashing)
	{
		Sender.EnableComponent();
		return;
	}

	WatchedItemNameLabel.Caption = TribesInventoryWeaponButton(Sender).weaponData.weaponClass.default.localizedName;
	WatchedItemInfoLabel.Caption = TribesInventoryWeaponButton(Sender).weaponData.weaponClass.default.infoString;
}

function OnPackClick(GUIComponent Sender)
{
	local InventoryStationAccess.InventoryStationPack NoPack;
	NoPack.packClass = None;

	if(! TribesInventoryPackButton(Sender).IsChecked())
		SelectPack(TribesInventoryPackButton(Sender).packData);
//	else
//		SelectPack(NoPack);
}

function OnPackWatched(GUIComponent Sender)
{
	WatchedItemNameLabel.Caption = TribesInventoryPackButton(Sender).packData.packClass.default.localizedName;
	WatchedItemInfoLabel.Caption = TribesInventoryPackButton(Sender).packData.packClass.default.infoString;
}

function OnArmorClick(GUIComponent Sender)
{
	if(inventory.bInventoryTutorial && TribesInventoryButton(Sender) != None && TribesInventoryButton(Sender).bIsFlashing)
	{
		Sender.EnableComponent();
		return;
	}

	SelectArmor(TribesInventoryArmorButton(Sender).roleData);
}

function OnArmorWatched(GUIComponent Sender)
{
	if(inventory.bInventoryTutorial && TribesInventoryButton(Sender) != None && TribesInventoryButton(Sender).bIsFlashing)
	{
		Sender.EnableComponent();
		return;
	}

	WatchedItemNameLabel.Caption = TribesInventoryArmorButton(Sender).roleData.combatRoleClass.default.armorClass.default.armorName;
	WatchedItemInfoLabel.Caption = TribesInventoryArmorButton(Sender).roleData.combatRoleClass.default.armorClass.default.infoString;
//	WatchedItemIcon.Image = playerTeam.GetArmorIconForRole(TribesInventoryArmorButton(Sender).roleData.combatRoleClass);
}

function OnLoadoutClick(GUIComponent Sender)
{
	local int i;
	local String nextSkinName, loadoutPrefSkin;

	if(! inventory.bCanUseCustomLoadouts)
		return;
	
	if(TribesInventoryLoadoutButton(Sender) == None || TribesInventoryLoadoutButton(Sender).bEmptySlot || ! Sender.bCanBeShown)
		return;

	// spark an edit event if this button
	// was already selected
	if(SelectedLoadoutButton == Sender)
	{
		OnLoadoutEditStart(Sender);
		return;
	}

	if(SelectedLoadoutButton != None)
	{
		SaveCurrentLoadout();
		SelectedLoadoutButton.SetChecked(false);
	}	
	SelectedLoadoutButton = TribesInventoryLoadoutButton(Sender);
	SelectedLoadoutButton.SetChecked(true);

	SetCurrentLoadout(SelectedLoadoutButton.loadoutData);
	SetActiveProfileLoadout(SelectedLoadoutButton.loadoutData);

	loadoutPrefSkin = class'CustomPlayerLoadout'.static.GetSkinPreference(SelectedLoadoutButton.customLoadoutData.skinPreferences, 
										playerTeam.GetMeshForRole(SelectedLoadoutButton.loadoutData.role.combatRoleClass, bIsFemale));

	for(i = 0; i < availableSkins.Length; ++i)
	{
		nextSkinName = availableSkins[i].Outer.Name$"."$availableSkins[i].Name;
		if(nextSkinName == loadoutPrefSkin)
		{
			currentSkinIndex = i;
			break;
		}
	}

	UpdateSkin();
}

function OnLoadoutWatched(GUIComponent Sender)
{
	local TribesInventoryLoadoutButton watchedLoadout;

	if(! inventory.bCanUseCustomLoadouts)
		return;

	watchedLoadout = TribesInventoryLoadoutButton(Sender);

	if(watchedLoadout.customLoadoutData != None)
		WatchedItemNameLabel.Caption = watchedLoadout.customLoadoutData.loadoutName;
	else
		WatchedItemNameLabel.Caption = "";
	if(watchedLoadout.loadoutData.role.combatRoleClass != None)
		WatchedLoadoutArmorIcon.Image = playerTeam.GetArmorIconForRole(watchedLoadout.loadoutData.role.combatRoleClass);
	if(watchedLoadout.loadoutData.pack.packClass != None)
		WatchedLoadoutPackIcon.Image = watchedLoadout.loadoutData.pack.packClass.default.inventoryIcon;
	if(watchedLoadout.loadoutData.weapons[0].weaponClass != None)
		WatchedLoadoutWeaponIcon1.Image = watchedLoadout.loadoutData.weapons[0].weaponClass.default.inventoryIcon;
	if(watchedLoadout.loadoutData.weapons[1].weaponClass != None)
		WatchedLoadoutWeaponIcon2.Image = watchedLoadout.loadoutData.weapons[1].weaponClass.default.inventoryIcon;
	if(watchedLoadout.loadoutData.weapons[2].weaponClass != None)
		WatchedLoadoutWeaponIcon3.Image = watchedLoadout.loadoutData.weapons[2].weaponClass.default.inventoryIcon;
}

function OnLoadoutEditCompleted(GUIComponent Sender)
{
	loadoutEditBox.Hide();

	if(editedLoadoutButton == None)
		return;

	editedLoadoutButton.customLoadoutData.loadoutName = loadoutEditBox.GetText();
	editedLoadoutButton.Caption = editedLoadoutButton.customLoadoutData.loadoutName;
	editedLoadoutButton.Show();
	editedLoadoutButton = None;
	activeProfile.Store();
}

function OnLoadoutEditFocusLost(GUIComponent Sender)
{
	editedLoadoutButton = None;
	if(loadoutEditBox != None)
		loadoutEditBox.Hide();
	if(editedLoadoutButton != None)
		editedLoadoutButton.Show();
}

function OnLoadoutEditFocusGained(GUIComponent Sender)
{
	// due to some gui system change, I have to do this 
	// here. It's annoying & slow, but I can't find the problem 
	// in the underlying code, so this is my workaround
	SelectArmor(selectedLoadout.role);
}

function OnLoadoutEditStart(GUIComponent Sender)
{
	local CustomPlayerLoadout editedLoadout;

	editedLoadoutButton = TribesInventoryLoadoutButton(Sender);

	// cant edit the current loadout tab
	if(editedLoadoutButton == CurrentLoadoutTab)
		return;

	if(editedLoadoutButton != None)
		editedLoadout = editedLoadoutButton.customLoadoutData;
	else
		return;

	// create the edit box if we need to
	if(loadoutEditBox == None)
	{
		loadoutEditBox = GUIEditBox(LoadoutButtonsContainer.AddComponent("GUI.GUIEditBox", , true));
		loadoutEditBox.OnEntryCompleted = OnLoadoutEditCompleted;
		loadoutEditBox.OnEntryCancelled = OnLoadoutEditFocusLost;
		loadoutEditBox.OnLostFocus = OnLoadoutEditFocusLost;
		loadoutEditBox.OnFocused = OnLoadoutEditFocusGained;
		loadoutEditBox.StyleName = editedLoadoutButton.StyleName;
		loadoutEditBox.bNeverFocus = false;
		loadoutEditBox.InitComponent(LoadoutButtonsContainer);
		loadoutEditBox.RenderWeight = 1.0;
		loadoutEditBox.MaxWidth = MaxLoadoutNameLength;
	}

	loadoutEditBox.SetText(editedLoadout.loadoutName);
	loadoutEditBox.WinTop = Sender.WinTop;
	loadoutEditBox.WinLeft = Sender.WinLeft;
	loadoutEditBox.WinWidth = Sender.WinWidth;
	loadoutEditBox.WinHeight = Sender.WinHeight;

//	editedLoadoutButton.Hide();
	loadoutEditBox.Show();
	loadoutEditBox.Focus();
	// Mega-Hack(TM): for some reason, focus() is failing. This forces the 
	// edit box to be the focused control.
	Controller.FocusedControl = loadoutEditBox;
}

function OnLoadoutReset(GUIComponent Sender)
{
	local PlayerProfile DefaultProfile;

	// dont let the current loadout tab be reverted
	if(CurrentLoadoutTab == SelectedLoadoutButton)
		return;

	DefaultProfile = TribesGUIController(Controller).profileManager.GetDefaultProfile();

	if(DefaultProfile == None)
		return;

	// revert the pressed buttons loadout data to the data in the default profile
	ConvertToInventoryLoadout(DefaultProfile.GetLoadout(SelectedLoadoutButton.slotIndex), SelectedLoadoutButton.loadoutData);
	ConvertToCustomLoadout(SelectedLoadoutButton.loadoutData, SelectedLoadoutButton.customLoadoutData);
	// need to set the name manually
	SelectedLoadoutButton.customLoadoutData.loadoutName = DefaultProfile.GetLoadout(SelectedLoadoutButton.slotIndex).loadoutName;

	// update the display
	SetCurrentLoadout(SelectedLoadoutButton.loadoutData);
	SetActiveProfileLoadout(SelectedLoadoutButton.loadoutData);
	SelectedLoadoutButton.Refresh();

	// store the active loadout, and hence the loadout data.
	activeProfile.Store();
}

function OnLoadoutGroupUp(GUIComponent Sender)
{
	if(currentLoadoutArrayStart > 0)
	{
		currentLoadoutArrayStart = Max(0, currentLoadoutArrayStart - NumVisibleLoadoutSlots);
		UpdateLoadoutTabs();
	}
}

function OnLoadoutGroupDown(GUIComponent Sender)
{
	if(currentLoadoutArrayStart < LoadoutButtons.Length - NumVisibleLoadoutSlots)
	{
		currentLoadoutArrayStart = Min(LoadoutButtons.Length - 1, currentLoadoutArrayStart + NumVisibleLoadoutSlots);
		UpdateLoadoutTabs();
	}
}

//
// SelectCurrentLoadout
//
function SetCurrentLoadout(InventoryStationAccess.InventoryStationLoadout loadout)
{
	local int i;

	selectedLoadout.grenades = loadout.grenades;

	SelectArmor(loadout.role);

	for(i = 0; i < WeaponSlots.Length; ++i)
		AssignWeaponToSlot(i, loadout.weapons[i]);

	SelectPack(loadout.pack);
}

//
// SelectArmor
// 
// Selects the armor for the current loadout
//
function SelectArmor(InventoryStationAccess.InventoryStationCombatRole role)
{
	local int i;
	local int weaponSlotIndex;
	local bool weaponEnabled;
	local TribesInventoryArmorButton button;

	if(role.combatRoleClass == None)
	{
		for(i = 0; i < weaponSlots.Length; ++i)
			AssignWeaponToSlot(i, NoWeapon);
		selectedLoadout.pack.packClass = None;
		return;
	}

	selectedLoadout.role = role;
	CharacterView.UpdateLoadout(selectedLoadout);

	// cycle through all the armor buttons, checking to
	// ensure that none are selected when they shouldnt be
	button = FindArmorButton(role.combatRoleClass);
	for(i = 0; i < ArmorButtons.Length; ++i)
		ArmorButtons[i].SetChecked(ArmorButtons[i] == button);

	// update number of weapon slots
	UpdateWeaponSlots(selectedLoadout.role.combatRoleClass.default.armorClass.default.maxCarriedWeapons);

	// update the weapon lists to reflect weapons which 
	// are unavailable to this armor class
	for(i = 0; i < WeaponButtons.Length; i++)
	{
		weaponSlotIndex = GetSlotIndexHoldingWeapon(WeaponButtons[i].weaponData.weaponClass);
		weaponEnabled = role.combatRoleClass.default.armorClass.static.IsWeaponAllowed(WeaponButtons[i].weaponData.weaponClass) &&
						inventory.weapons[i + inventory.numFallbackWeapons].bEnabled;

		WeaponButtons[i].SetEnabled(WeaponEnabled && weaponSlotIndex == -1);
		WeaponButtons[i].SetChecked(false);

		if(! WeaponEnabled && weaponSlotIndex != -1)
			AssignWeaponToSlot(weaponSlotIndex, NoWeapon);
	}

	SelectedWeaponButton = None;
	SetWeaponSlotsEnabled();

	UpdateAvailableSkins();
	SaveCurrentLoadout();

	characterView.SetHeldWeapon(WeaponSlots[lastAppliedWeaponSlotIndex].weaponClass);
}

//
// SelectPack
// 
// Selects the pack for the current loadout
//
function SelectPack(InventoryStationAccess.InventoryStationPack pack)
{
	local int i;
	local TribesInventoryPackButton button;

	selectedLoadout.pack = pack;
	CharacterView.UpdateLoadout(selectedLoadout);

	// cycle through all the pack buttons, checking to
	// ensure that none are selected when they shouldnt be
	button = FindPackButton(pack.packClass);
	for(i = 0; i < PackButtons.Length; ++i)
		PackButtons[i].SetChecked(PackButtons[i].packData.packClass == pack.packClass);

	SaveCurrentLoadout();
}

//
// AssignWeaponToSlot
//
// Assigns a weapon to a slot in the loadout, and updates the 
// the GUI to reflect the change
//
function AssignWeaponToSlot(int slotIndex, InventoryStationAccess.InventoryStationWeapon weapon)
{
	local int i;

	// weapon not allowed, don't select it
	if(weapon.weaponClass != None &&
	   selectedLoadout.role.combatRoleClass != None &&
	   selectedLoadout.role.combatRoleClass.default.armorClass != None &&
	   ! selectedLoadout.role.combatRoleClass.default.armorClass.static.IsWeaponAllowed(weapon.weaponClass))
			return;

	WeaponSlots[slotIndex].SetWeaponClass(weapon.weaponClass);

	// dont forget to change the loadout
	selectedLoadout.weapons[slotIndex] = weapon;
	CharacterView.UpdateLoadout(selectedLoadout);

	if(selectedLoadout.role.combatRoleClass != None &&
	   selectedLoadout.role.combatRoleClass.default.armorClass != None)
	{
		// cycle through all the weapon buttons, checking to
		// ensure that none are selected when they shouldnt be
		for(i = 0; i < WeaponButtons.Length; ++i)
		{
			WeaponButtons[i].SetEnabled(GetSlotIndexHoldingWeapon(WeaponButtons[i].weaponData.weaponClass) == -1 && 
										inventory.weapons[i + inventory.numFallbackWeapons].bEnabled == true &&
										selectedLoadout.role.combatRoleClass.default.armorClass.static.IsWeaponAllowed(WeaponButtons[i].weaponData.weaponClass));
		}
	}

	SaveCurrentLoadout();
}

//
// GetSlotIndexHoldingWeapon
//
// Returns the slot index for the requested Weapon class, if the weapon class is not
// in a slot, it returns -1.
//
function int GetSlotIndexHoldingWeapon(class<Weapon> weaponClass)
{
	local int i;

	for(i = 0; i < WeaponSlots.Length; i++)
	{
		if(selectedLoadout.weapons[i].weaponClass != None && selectedLoadout.weapons[i].weaponClass == weaponClass && i < selectedLoadout.role.combatRoleClass.default.armorClass.default.maxCarriedWeapons)
			return i;
	}

	return -1;
}

//
// FindWeaponButton
//
// Finds an Weapon button in the weapon buttons array
//
function TribesInventoryWeaponButton FindWeaponButton(class<Weapon> weaponClass, optional out int index)
{
	local int i;

	for(i = 0; i < WeaponButtons.Length; ++i)
	{
		if(weaponClass == WeaponButtons[i].weaponData.weaponClass)
		{
			index = i;
			return WeaponButtons[i];
		}
	}

	return None;
}

//
// FindArmorButton
//
// Finds an Armor button in the armor buttons array
//
function TribesInventoryArmorButton FindArmorButton(class<CombatRole> combatRoleClass, optional out int index)
{
	local int i;

	for(i = 0; i < ArmorButtons.Length; ++i)
	{
		if(combatRoleClass == ArmorButtons[i].roleData.combatRoleClass)
		{
			index = i;
			return ArmorButtons[i];
		}
	}

	return None;
}

//
// FindPackButton
//
// Finds an Pack button in the pack buttons array
//
function TribesInventoryPackButton FindPackButton(class<Pack> packClass, optional out int index)
{
	local int i;

	for(i = 0; i < PackButtons.Length; ++i)
	{
		if(packClass == PackButtons[i].packData.packClass)
		{
			index = i;
			return PackButtons[i];
		}
	}

	return None;
}

//
// UpdateAvailableSkins
//
// Searches the skins array and updates the available skins list.
//
function UpdateAvailableSkins()
{
	local class baseSkinClass;
	local class skinClass;

	if(characterController != None && characterController.IsSinglePlayer())
		return;

	// return if we dont have valid combat role & armor class
	if(selectedLoadout.role.combatRoleClass == None || 
	   selectedLoadout.role.combatRoleClass.default.armorClass == None)
			return;

	availableSkins.Remove(0, availableSkins.Length);
	availableSkins[availableSkins.Length] = class'SkinInfo';
	baseSkinClass = class'SkinInfo';
	ForEach AllClasses(baseSkinClass, skinClass)
	{
		if(class<SkinInfo>(skinClass).static.isApplicable(characterView.inventoryCharacter.Mesh))
			availableSkins[availableSkins.Length] = class<SkinInfo>(skinClass);
	}

	if(availableSkins.Length > 0)
	{
		NextSkinButton.bCanBeShown = true;
		NextSkinButton.Show();
		PreviousSkinButton.bCanBeShown = true;
		PreviousSkinButton.Show();
	}
	else
	{
		NextSkinButton.bCanBeShown = false;
		NextSkinButton.Hide();
		PreviousSkinButton.bCanBeShown = false;
		PreviousSkinButton.Hide();
	}

	// it makes no sense to continue with the old skin index, 
	// because it may not even be valid for the mesh
	currentSkinIndex = 0;
	characterView.inventoryCharacter.UpdateSkin(availableSkins[currentSkinIndex]);
}

//
// SetActiveProfileLoadout
//
// Sets the active profile loadout to be the passed loadout
//
function SetActiveProfileLoadout(InventoryStationAccess.InventoryStationLoadout loadout)
{
	local CustomPlayerLoadout newLoadout;

	if(activeProfile.GetActiveLoadout() != None)
	{
		newLoadout = activeProfile.GetActiveLoadout();
	}
	else
	{
		newLoadout = new class'CustomPlayerLoadout';
		activeProfile.SetActiveLoadout(newLoadout);
	}

	ConvertToCustomLoadout(loadout, newLoadout);
}

//
// ConvertToInventoryLoadout
//
// Utility function to convert a CustomPlayerLoadout to an InventoryStationLoadout
//
function ConvertToInventoryLoadout(CustomPlayerLoadout InLoadout,
								   out InventoryStationAccess.InventoryStationLoadout OutLoadout)
{
	local InventoryStationAccess.InventoryStationWeapon weapon;
	local int i;

	if(InLoadout == None)
	{
		OutLoadout.NoLoadout = true;
		return;
	}

	OutLoadout.NoLoadout = false;

	OutLoadout.role.combatRoleClass = InLoadout.combatRoleClass;
	OutLoadout.userSkin = InLoadout.static.GetSkinPreference(InLoadout.skinPreferences, playerTeam.GetMeshForRole(OutLoadout.role.combatRoleClass, bIsFemale));
	OutLoadout.pack.packClass = InLoadout.packClass;
	OutLoadout.grenades.grenadeClass = InLoadout.grenades.grenadeClass;

	for(i = 0; i < InLoadout.weaponList.Length && i < inventory.maxWeapons; i++)
	{
		weapon.weaponClass = InLoadout.weaponList[i].weaponClass;
		OutLoadout.weapons[i] = weapon;
	}

	if(OutLoadout.role.combatRoleClass == None)
		OutLoadout.NoLoadout = true;
}

//
// ConvertToCustomLoadout
//
// Utility function to convert an InventoryStationLoadout to a CustomPlayerLoadout 
//
function ConvertToCustomLoadout(InventoryStationAccess.InventoryStationLoadout InLoadout,
								out CustomPlayerLoadout OutLoadout)
{
	local CustomPlayerLoadout.WeaponInfo weaponInfo;
	local int i;

	if(OutLoadout == None || InLoadout.NoLoadout == true || InLoadout.role.combatRoleClass == None)
		return;

	OutLoadout.combatRoleClass = InLoadout.role.combatRoleClass;
	OutLoadout.packClass = InLoadout.pack.packClass;
	OutLoadout.grenades.grenadeClass = InLoadout.grenades.grenadeClass;
	OutLoadout.grenades.ammo = 0;

	OutLoadout.weaponList.Remove(0, OutLoadout.weaponList.Length);
	for(i = 0; i < inventory.maxWeapons; ++i)
	{
		weaponInfo.weaponClass = InLoadout.weapons[i].weaponClass;
		weaponInfo.ammo = 0;
		OutLoadout.weaponList[OutLoadout.weaponList.Length] = weaponInfo;
	}
}

defaultproperties
{
	// dont want to be persistent - the gui changes from station to station
	bPersistent					= true
	bAutoAdvanceSlotSelection	= false
	bSwapDuplicateWeaponSlots	= false
	MenuState					= MSAT_Blurry
	NumVisibleLoadoutSlots		= 8
	MaxLoadoutSlots				= 23
	NumWeaponSlots				= 3
	MaxLoadoutNameLength		= 24

	ArmorText			= "1 - SELECT ARMOR"
	PackText			= "2 - SELECT PACK"
	WeaponText			= "3 - SELECT WEAPON"
	AcceptText			= "4 - ACCEPT CHANGES & EXIT"
	currentLoadoutText	= "CURRENT LOADOUT"
	TitleText			= "INVENTORY STATION"

	ExternalViewportSurround = Texture'GUITribes.InvScreenBorder'

	ArmorParams			= (gutter=5,columns=3,rows=1,styleName="STY_InvButton")
	PackParams			= (gutter=5,columns=4,rows=1,styleName="STY_InvButton")
	WeaponParams		= (gutter=5,columns=5,rows=2,styleName="STY_InvWeaponButton")
	LoadoutParams		= (gutter=0,columns=8,rows=1,styleName="STY_InvTab")
	WeaponSlotParams	= (gutter=0,columns=3,rows=1,styleName="STY_InvButton")

	bSuppressLevelRender=true
}
