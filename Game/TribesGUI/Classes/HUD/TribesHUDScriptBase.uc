//================================================================
// Class: TribesHUDScriptBase
//
// Base hud script class, which loads any user created hud elements.
//
//================================================================

class TribesHUDScriptBase extends HUDContainer
	native
	abstract;

struct native HUDExtension
{
	var() config String ElementName	"Name to load the extension from in the ini file";
	var() config String ClassName	"Fully qualified (package name included) class name of the extension";
	var() config String IniFile		"Ini file to load the extension from";
};

var() config Array<HUDExtension>	ExtensionSpecs;

overloaded function Construct()
{
	super.Construct();

	LoadExtensions();
}

function LoadExtensions()
{
	local class<HUDElement> ExtensionClass;
	local HUDElement NewElement;
	local int i;

	for(i = 0; i < ExtensionSpecs.Length; ++i)
	{
		ExtensionClass = class<HUDElement>(DynamicLoadObject(ExtensionSpecs[i].ClassName, class'Class'));
		NewElement = HUDElement(FindObject(ExtensionSpecs[i].ElementName, ExtensionClass));
		if(NewElement == None)
			NewElement = CreateHUDElement(ExtensionClass, ExtensionSpecs[i].ElementName);

		// add the element
		NewElement.iniOverride = ExtensionSpecs[i].IniFile;
		AddExistingElement(NewElement);

		// do a specific load config with the specced filename if necessary
		if(ExtensionSpecs[i].IniFile != "")
			NewElement.LoadConfig(ExtensionSpecs[i].ElementName, ExtensionClass, ExtensionSpecs[i].IniFile);
	}
}
