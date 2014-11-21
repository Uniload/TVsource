class HUDList extends HUDContainer
	native;

var() config bool bAutoHeight;
var() config int RowSpacing;

var Array<HUDList> columns;

cppText
{
	virtual void Layout(UCanvas *canvas);
}


//
// check in the element added event for new columns
//
function ElementAdded(HUDElement newChild, int index)
{
	local HUDList NewList;

	NewList = HUDList(newChild);

	if(NewList != None)
		columns[columns.Length] = NewList;

	newChild.SetNeedsLayout();
}

//
// check in the element added event for new columns
//
function ElementRemoved(HUDElement removedChild, int index)
{
	local HUDList NewList;

	NewList = HUDList(removedChild);

	if(NewList != None)
		columns.Remove(index, 1);

	SetNeedsLayout();
}

function bool HasMultipleColumns()
{
	return columns.Length > 1;
}

function bool IsListEmpty()
{
	if(HasMultipleColumns())
		return columns[0].children.Length <= 0;
	else
		return children.Length <= 0;
}

defaultproperties
{
	bAutoHeight = false
}