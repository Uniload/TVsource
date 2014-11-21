// ====================================================================
//  Class:  TribesGui.TribesSaveGamesBase
//
//  Common functions for save/load guis
// ====================================================================

class TribesSaveGameBase extends TribesGUIPage
	native;

native function Array<string> GetSaves();
native function bool DeleteSave(string Filename);

function LoadSaveGameList(GUIMultiColumnListBox list, optional bool bKeepList)
{
	local Array<string> Saves;
	local int i;

	Saves = GetSaves();

	if (!bKeepList)
		list.Clear();

	for (i = 0; i < Saves.Length; i++)
	{
        list.AddNewRowElement( "Name",, DecodeFromURL(Saves[i]) );
		list.PopulateRow( "Name" );
	}
    list.SetActiveColumn( "Name" );

	if (Saves.Length != 0)
		list.SetIndex(0);
	else
		list.SetIndex(-1);
}

