class ActionCalcDistance extends Action;

var() editcombotype(enumScriptLabels) Name actorOne;
var() editcombotype(enumScriptLabels) Name actorTwo;

var actionnoresolve Actor a;
var actionnoresolve Actor b;

latent function Variable execute()
{
	local Variable result;

	Super.execute();

	if (a == None)
		a = findByLabel(None, actorOne);

	if (b == None)
		b = findByLabel(None, actorTwo);

	if (a != None && b != None)
		result = newTemporaryVariable(class'VariableFloat', String(VSize(a.Location - b.Location)));

	return result;
}

// editorDisplayString
function editorDisplayString(out string s)
{
	s = "Distance between " $ propertyDisplayString('actorOne') $ " and " $ propertyDisplayString('actorTwo');
}

defaultproperties
{
	returnType			= class'Variable'
	actionDisplayName	= "Calculate Distance"
	actionHelp			= "Calculate the distance between two actors"
	category			= "Actor"
}