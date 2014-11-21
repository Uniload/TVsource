class ActionGoalAction extends TyrionScriptAction
	abstract;

var() editcombotype(enumTyrionTargets) Name target;

function AI_Goal postGoal(Actor a, AI_Goal goal)
{
	local Rook r;
	local SquadInfo si;
	local AI_Goal newGoal;

	r = Rook(a);
	si = SquadInfo(a);

	newGoal = AI_Goal( class'Engine.Tyrion_Setup'.static.shallowCopyGoal( goal ));

	if ( r != None )
	{
		newGoal.init( AI_Resource( newGoal.findResource( r, newGoal )));	// init called here because init is never called on "goal"
		newGoal.postGoal( None ).myAddRef();	// designer created goals should never get deleted
	}
	else if ( si != None )
	{
		newGoal.init( AI_Resource( si.squadAI ));
		newGoal.postGoal( None ).myAddRef();	// designer created goals should never get deleted
	}

	return newGoal;
}

function unpostGoal(Actor a, String goalName)
{
	local AI_Goal goal;

	goal = class'AI_Goal'.static.findGoalByName( a, goalName );
	if ( goal != None )
	{
		//if ( Pawn(a).logTyrion )
		//	log( "UNPOSTING" @ goal.name @ "from" @ a.name );

		if ( goal.resource == None )
		{
			// goal not yet initialized: resource.init will remove it
			goal.priority = -1;
		}
		else
			goal.unPostGoal( None );
	}
}