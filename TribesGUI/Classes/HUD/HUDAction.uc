//=================================================================
// Class: HUDAction
//
// Base action object for HUDScripts to respond to user input & other
// UI based events. Any actions which should be acecssable from any HUD
// should be defined here as Delegate functions with no body, and
// assigned with a function within the TribesHUD class.
//
//=================================================================

class HUDAction extends Core.Object;

//
// Cancels chat message window
Delegate CancelChat();

//
// Sends a chat message, and cancels the chat message window
Delegate SendChatMessage(String msg);

//
// Sends a quick chat message, and cancels the quick chat message window
Delegate SendQuickChatMessage(QuickChatMenu menuItem);

//
// Selects a loadout slot
Delegate SelectLoadout(int slot);
