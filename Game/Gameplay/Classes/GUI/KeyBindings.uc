class KeyBindings extends Core.Object
	config(user);

//////////////////////////////////////////////////////////////////////////////////////
// Key Config Settings
//////////////////////////////////////////////////////////////////////////////////////
var() config Array<string> CommandCategory;
var() config Array<string> CommandString;
var() localized config Array<string> LocalizedCommandString;
var() localized config Array<string> LocalizedCommandCategories;
var() config Array<string> PrimaryBinds;
var() config Array<string> SecondaryBinds;

static function string GetKeyFromBinding(string CommandStringSearch, optional bool bLocalized)
{
	local int i;

	CommandStringSearch = Caps(CommandStringSearch);

	for (i = 0; i < default.CommandString.Length; i++)
	{
		if (InStr(Caps(default.CommandString[i]), CommandStringSearch) != -1)
		{
			if (i < default.PrimaryBinds.Length)
				return default.PrimaryBinds[i];
			else
				return "";
		}
	}
}