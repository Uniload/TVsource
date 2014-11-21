class SpeechCategoryManager extends Core.Object
	native
	config(SpeechCategories);

var config Array<String>	categoryNames;
var Array<SpeechCategory>	categories;

///
/// Initialises the array of speech categories based on the categoryNames
/// loaded from config.
///
event LoadCategories()
{
	local int i;

	for(i = 0; i < categoryNames.Length; ++i)
		categories[i] = new(None, categoryNames[i]) class'SpeechCategory';
}