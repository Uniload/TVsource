class HUDContainer extends HUDElement
	native;

var() array<HUDElement>		children;

cpptext
{

	// Internal Render function
	virtual void Render(UCanvas *canvas);

	// Internal horizontal packing function
	virtual void ResizeForWidth(UCanvas *canvas, INT pixelWidth);

	// Internal Layout function
	virtual void Layout(UCanvas *canvas);
}

function InitElementHeirachy(TribesHUDScript Base, HUDContainer Parent)
{
	local int i;

	super.InitElementHeirachy(Base, Parent);

	for(i = 0; i < children.Length; ++i)
		children[i].InitElementHeirachy(BaseScript, self);
}

event SetAlpha(float newAlpha)
{
	local int i;

	super.SetAlpha(newAlpha);

	for(i = 0; i < children.Length; ++i)
		children[i].SetAlpha(newAlpha);
}

//
// Returns whether this container has a specified element
//
function bool HasElement(HUDElement element)
{
	local int i;

	for(i = 0; i < children.Length; ++i)
	{
		if(children[i] == element)
			return true;
	}

	return false;
}

//
// Adds an element object to the container 
//
function AddExistingElement(HUDElement NewElement, optional bool bNoInit)
{
	if(HasElement(NewElement))
		return;

	NewElement.ParentElement = self;
	if(iniOverride != "")
	{
		NewElement.iniOverride = iniOverride;
		NewElement.LoadConfig(String(NewElement.name), NewElement.class, iniOverride);
	}
	if(! bNoInit)
		NewElement.InitElement();
	if(children.Length > 0)
	{
		NewElement.previousSibling = children[children.Length - 1];
		children[children.Length - 1].nextSibling = NewElement;
	}
	children[children.Length] = NewElement;

	NewElement.BaseScript = BaseScript;
	ElementAdded(NewElement, children.Length);
}

//
// Adds (creating first) a component object to the container 
//
function HUDElement AddElement(string className, optional string objectName, optional bool bNoInit)
{
	local HUDElement NewElement;
	local class<HUDElement> NewElementClass;
	
	NewElementClass = class<HUDElement>(DynamicLoadObject(className, class'class'));

	// Create and add the new Component, initialising
	// its parent to self and calling InitElement
	NewElement = CreateHUDElement(NewElementClass, objectName);
	AddExistingElement(NewElement, bNoInit);

	return NewElement;
}

//
// Adds a component object to the container, but uses the passed name to
// initialise the component from a config file. This is like cloning an
// element without having to create it
//
function HUDElement AddClonedElement(string className, string objectName, optional string newObjectName)
{
	local HUDElement newElement;

	newElement = CreateClonedElement(className, objectName, newObjectName);

	AddExistingElement(newElement);

	return newElement;
}

//
// Called when a new element is added or removed in this Container
//
function ElementAdded(HUDElement newChild, int index);
function ElementRemoved(HUDElement oldChild, int index);

//
// Removes the element at the specified index
//
function RemoveElementAt(int index)
{
	local HUDElement oldElement;

	oldElement = children[index];
	children.Remove(index, 1);

	if(oldElement.previousSibling != None)
		oldElement.previousSibling.nextSibling = oldElement.nextSibling;
	if(oldElement.nextSibling != None)
		oldElement.nextSibling.previousSibling = oldElement.previousSibling;

	oldElement.NextSibling = None;
	oldElement.PreviousSibling = None;

	ElementRemoved(oldElement, index);
}

//
// Removes all the elements from the container
//
function RemoveAll()
{
	children.Remove(0, children.Length);
}

//
// Forces the whole element tree to need a layout
//
event ForceNeedsLayout()
{
	local int i;

	bNeedsLayout = true;

	for(i = 0; i < children.Length; ++i)
		children[i].ForceNeedsLayout();
}

defaultproperties
{

}