// ====================================================================
//  Class:  XAdmin.SortedStringArray
//  Parent: XAdmin.StringArray
//
//  <Enter a description here>
// ====================================================================

class SortedStringArray extends StringArray;

function int Add(string item, string tag, optional bool bUnique)
{
local int pos;

	pos = FindTagId(tag);
	if (pos < 0)
		return InsertAt(-pos-1, item, tag);
	else if (bUnique)
		return pos;
	else
		return InsertAt(pos, item, tag);
}

function int FindTagId(string Tag)
{
local int sz, min, max, pos;

	sz = AllItems.Length;
	if (sz == 0 || tag < AllItems[0].tag)
		return -1;
		
	if (tag > AllItems[sz-1].tag)
		return -sz-1;

	if (tag == AllItems[0].tag)
		return 0;
	
	if (tag == AllItems[sz-1].tag)
		return sz-1;
		
	// Find the position of insertion
	min = 0;
	max = sz - 1;
	pos = (min + max)/2;
	while ((max-min) >  1)
	{
		if (tag == AllItems[pos].tag)
			return pos;
			
		if (tag < AllItems[pos].tag)
			max = pos;
		else
			min = pos;
					
		pos = (min + max)/2;
	}
	return -pos-2;	
} 

defaultproperties
{
}
