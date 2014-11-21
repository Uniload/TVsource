class MessageContainerWithdrawal extends Engine.Message
	editinlinenew;

var Name container;
var() Name withdrawer;
var() Name team;
var() int amount;


// construct
overloaded function construct(Name _container, Name _withdrawer, Name _team, int _amount)
{
	container = _container;
	withdrawer = _withdrawer;
	team = _team;
	amount = _amount;

	SLog(withdrawer $ " withdrew " $ amount $ " carryables from " $ container);
}

// editorDisplay
static function string editorDisplay(Name triggeredBy, Message filter)
{
	return triggeredBy$" container gets carryables withdrawn";
}


defaultproperties
{
	specificTo	= class'MPCarryableContainer'
}