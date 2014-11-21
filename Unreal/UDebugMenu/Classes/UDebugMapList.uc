class UDebugMapList extends UWindow.UWindowListBoxItem;

var string MapName;
var string DisplayName;

function int Compare(UWindow.UWindowList T, UWindow.UWindowList B)
{
	if(Caps(UDebugMapList(T).MapName) < Caps(UDebugMapList(B).MapName))
		return -1;

	return 1;
}

// Call only on sentinel
function UDebugMapList FindMap(string FindMapName)
{
	local UDebugMapList I;

	for(I = UDebugMapList(Next); I != None; I = UDebugMapList(I.Next))
		if(I.MapName ~= FindMapName)
			return I;

	return None;
}