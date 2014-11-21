class MessageContainerDeposit extends Engine.Message
	editinlinenew;

var Name container;
var() Name depositer;
var() Name team;
var() int amount;


// construct
overloaded function construct(Name _container, Name _depositer, Name _team, int _amount)
{
	container = _container;
	depositer = _depositer;
	team = _team;
	amount = _amount;

	SLog(depositer $ " deposited " $ amount $ " carryables into " $ container);
}

// editorDisplay
static function string editorDisplay(Name triggeredBy, Message filter)
{
	return triggeredBy$" container gets carryables deposited";
}


defaultproperties
{
	specificTo	= class'MPCarryableContainer'
}