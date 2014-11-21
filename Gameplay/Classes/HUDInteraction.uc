class HUDInteraction extends Engine.Interaction;

var TribesHUDBase hudOwner;

//-----------------------------------------------------------------------------
// Check for the console key.

State Enabled
{
	function bool KeyEvent( EInputKey Key, EInputAction Action, FLOAT Delta )
	{
		if(hudOwner != None)
			return hudOwner.KeyEvent(Key, Action, Delta);

		return false;
	}

	function bool KeyType( EInputKey Key, optional string Unicode )
	{
		if(hudOwner != None)
			return hudOwner.KeyType(Key, Unicode);

		return false;
	}
}

defaultproperties
{
     bRequiresTick=True
}
