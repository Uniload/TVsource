class MessageGoalScored extends Engine.Message
	editinlinenew;

var Name goal;
var() Name scorer;
var() Name team;
var() Name ball;


// construct
overloaded function construct(Name _goal, Name _scorer, Name _team, Name _ball)
{
	goal = _goal;
	scorer = _scorer;
	team = _team;
	ball = _ball;

	SLog(scorer $ " scored a goal in " $ goal $ " with " $ ball);
}

// editorDisplay
static function string editorDisplay(Name triggeredBy, Message filter)
{
	return triggeredBy$" has ball thrown into it to score a goal";
}


defaultproperties
{
	specificTo	= class'MPGoal'
}