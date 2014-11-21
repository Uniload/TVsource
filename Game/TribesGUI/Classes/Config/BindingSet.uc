///
///
///
class BindingSet extends Engine.Actor
	PerObjectConfig
	Config(CustomControllerConfigs);

struct KeyBinding
{
	var 			bool 			bIsSectionLabel;		// set to true to makethis a section label
    var localized	string 			KeyLabel;				// label
	var				string 			Alias;					// The command alias for this binding
	var 			array<int>		Binds;					// 
	var				array<string>	BindKeyNames;			// 
	var				array<string>	BindLocalizedKeyNames;	// 
};

var localized config Array<KeyBinding>	Bindings;	// Holds the array of key bindings
var config String SetName;							// Name for this binding Set ** Must be unique **

//
// Resets the Bindings array with an associated control mapping
//
function ResetBindings()
{
	local ControlMapping mapping;
	local KeyBinding binding;
	local int i;

	if(SetName == "")
	{
		log("ERROR: SetName is empty: control mapping cannot be loaded");
		return;
	}

	mapping = new(None, SetName) class'ControlMapping';

	bindings.Remove(0, Bindings.Length);

	for(i = 0; i < mapping.NumMappings; ++i)
	{
		binding.bIsSectionLabel = mapping.GetMapping(i).bIsSectionLabel;
		binding.KeyLabel = mapping.GetMapping(i).Action;
		binding.Alias = mapping.GetMapping(i).Command;

		bindings[bindings.Length] = binding;
	}
}

//
// Returns a "Weight" for given key. This to ascertain whether
// a key binding should go into the primary or secondary list of
// bindings for a particular function. (or ternary, for that matter)
//
function int Weight(int i)
{
	if ( (i==0x01) || (i==0x02) )
		return 100;
		
	if ( (i>=0x30) && (i<=0x5A) )
		return 50;

	if (i==0x20)
		return 45;
		
	if (i==0x04)
		return 40;

	if (i==0xEC || i==0xED)
		return 35;		
		
	if (i>=0x21 && i<=0x28)
		return 30;
		
	if (i>=0x60 && i<=0x6F)
		return 30;
			
	return 25;
}

//
// Swaps two bindings for a single action
//
function Swap(int index, int a, int b)
{
	local int TempInt;
	local string TempStrA, TempStrB;
	
	TempInt  = Bindings[Index].Binds[a];
	TempStrA = Bindings[Index].BindKeyNames[a];
	TempStrB = Bindings[Index].BindLocalizedKeyNames[a];
	
	Bindings[Index].Binds[a] = Bindings[Index].Binds[B];
	Bindings[Index].BindKeyNames[a] = Bindings[Index].BindKeyNames[b];
	Bindings[Index].BindLocalizedKeyNames[a] = Bindings[Index].BindLocalizedKeyNames[b];
	
	Bindings[Index].Binds[b] = TempInt;
	Bindings[Index].BindKeyNames[b] = TempStrA;
	Bindings[Index].BindLocalizedKeyNames[b] = TempStrB;
}

//
// Loads the config from the existing bindings.
//
function ReadCurrent()
{
	local int i, j, k, index;
	local string KeyName, Alias, LocalizedKeyName;

	ResetBindings();

	for(i = 0; i < 255; ++i)
	{
		KeyName = Level.GetLocalPlayerController().ConsoleCommand("KEYNAME"@i);
		LocalizedKeyName = Level.GetLocalPlayerController().ConsoleCommand("LOCALIZEDKEYNAME"@i);
		if(KeyName != "")
		{
			Alias = Level.GetLocalPlayerController().ConsoleCommand("KEYBINDING"@KeyName);
			if(Alias != "")
			{
				for(j = 0; j < Bindings.Length; j++)
				{
					if(Bindings[j].Alias ~= Alias)
					{
						index = Bindings[j].Binds.Length;						
					
						Bindings[j].Binds[index] = i;
//						Bindings[j].KeyLabel = Labels[Clamp(j, 0, Bindings.Length - 1)];
						Bindings[j].BindKeyNames[Index] = KeyName;
						Bindings[j].BindLocalizedKeyNames[Index] = LocalizedKeyName;

						for(k = 0; k < index; k++)
						{
							if(Weight(Bindings[j].Binds[k]) < Weight(Bindings[j].Binds[Index]) )
							{
								Swap(j,k,Index);
								break;
							}
						}
					}
				}
			}
		}
	}
}

//
// Stores the config to a file
//
function Store()
{
	SaveConfig();
}

//
// Applies the current key bindings to the settings to be used
// by the player.
//
function Apply()
{
	local int i, j;

	for(i = 0; i < Bindings.Length; ++i)
	{
		for(j = 0; j < Bindings[i].BindKeyNames.Length; ++j)
			Level.GetLocalPlayerController().ConsoleCommand("SET Input"@Bindings[i].BindKeyNames[j]@Bindings[i].Alias);
	}
}

//
// Sets a keybinding
//
function SetBinding(int index, int subIndex, byte key)
{
	if(index >= Bindings.Length)
		return;

	if((SubIndex < Bindings[Index].Binds.Length) && (Bindings[Index].Binds[SubIndex] == key))
		return;

	RemoveAllOccurances(key);

	if(subIndex >= Bindings[Index].Binds.Length)
	{
		Bindings[Index].Binds.Length = Bindings[Index].Binds.Length + 1;
		Bindings[Index].BindKeyNames.Length = Bindings[Index].BindKeyNames.Length + 1;
		Bindings[Index].BindLocalizedKeyNames.Length = Bindings[Index].BindLocalizedKeyNames.Length + 1;
		subIndex = Bindings[Index].Binds.Length - 1;
	}
	Bindings[Index].Binds[SubIndex] = key;
	Bindings[Index].BindKeyNames[SubIndex] = ConsoleCommand("KeyName"@key);
	Bindings[Index].BindLocalizedKeyNames[SubIndex] = ConsoleCommand("LOCALIZEDKEYNAME"@key);

//	ConsoleCommand("SET Input"@Bindings[Index].BindKeyNames[SubIndex]@Bindings[Index].Alias);
}

//	
// Removes all occurances of a Key within the keybindings array.
//
private function RemoveAllOccurances(byte key)
{
	local int i, j;
	
	for(i = 0; i < Bindings.Length; i++)
	{
		for(j = Bindings[i].Binds.Length - 1; j >= 0; j--)
		{
			if(Bindings[i].Binds[j] == key)
			{
				RemoveExistingKey(i, j);
			}
		}
	}
}

//
// Gets the current localized keybinding for an index & subindex
//
function string GetCurrentKeyBinding(int index, int subIndex)
{

	if(index >= Bindings.Length)
		return "";

	if(Bindings[index].bIsSectionLabel)
		return "";

	if(subindex >= Bindings[index].Binds.Length)
		return "";
		
	return Bindings[index].BindLocalizedKeyNames[subIndex];
}

//
// Removes an existing key from a keybinding
//
function RemoveExistingKey(int index, int subIndex)
{
	if((Index >= Bindings.Length) || (SubIndex >= Bindings[Index].Binds.Length) || (Bindings[Index].Binds[SubIndex] < 0))
		return;

	// Clear the bind
//	ConsoleCommand("SET Input"@Bindings[Index].BindKeyNames[SubIndex]);

	// Clear the entry
	Bindings[Index].Binds.Remove(subIndex, 1);
	Bindings[Index].BindKeyNames.Remove(subIndex, 1);
	Bindings[Index].BindLocalizedKeyNames.Remove(subIndex, 1);
}
