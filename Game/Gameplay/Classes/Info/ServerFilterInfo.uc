// Defaults defined in Campaign.ini
// A new object with default values is saved in TribesGUIConfig when a new campaign is started.
// Reference the object in TribesGUIConfig for the current state of the campaign.
class ServerFilterInfo extends Core.Object
	PerObjectConfig
	config(ServerFilters);

struct serverFilter
{
	var config string filterName;
	var config string queryString;
};

var config array<serverFilter> filterList;

function copy(ServerFilterInfo source)
{
	local int i;

	filterList.Length = source.filterList.Length;

	for (i=0; i<filterList.Length; i++)
	{
		filterList[i].filterName = source.filterList[i].filterName;
		filterList[i].queryString = source.filterList[i].queryString;
	}
}

function removeFilter(string filterName)
{
	local int i;

	for (i=0; i<filterList.Length; i++)
	{
		if (filterList[i].filterName == filterName)
			filterList.Remove(i, 1);
	}
}

function addFilter(string filterName, string query)
{
	local int i;

	// Don't allow duplicates
	for (i=0; i<filterList.Length; i++)
	{
		if (filterList[i].filterName == filterName)
			return;
	}

	filterList.Length = filterList.Length + 1;
	filterList[filterList.Length-1].filterName = filterName;
	filterList[filterList.Length-1].queryString = query;
}

function string getQueryForName(string filterName)
{
	local int i;

	for(i=0; i<filterList.Length; i++)
	{
		if (filterList[i].filterName == filterName)
			return filterList[i].queryString;
	}

	return "";
}

defaultproperties
{
}