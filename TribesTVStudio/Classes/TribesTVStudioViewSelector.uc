//-----------------------------------------------------------
//
//-----------------------------------------------------------
class TribesTVStudioViewSelector extends Actor;

var string description;
var texture icon;
var int id;                     //Assigned runtime

var array<TribesTVStudioTestController> controllerlist;

var int curMode;

struct TargetPriority
{
    var string name;
    var float priority;
};

var array<TargetPriority> targets;

//Called by our creator when our id is known
function AssignID (int nr)
{
    id = nr;
}

function PostBeginPlay()
{
	curMode = -1;
}

//Return false if this VS is inappropiate for current game
function bool runnable ()
{
	return true;
}

function DeleteController (int index)
{
	local int j;

	for (j=index+1; j < controllerlist.length; j++) {
        controllerlist[j-1] = controllerlist[j];
    }

    controllerlist.length = controllerlist.length - 1;
}

function RemoveController (TribesTVStudioTestController c)
{
    local int i;

    //Start with resetting priorities for us on that controller
    for (i = 0; i < targets.length; ++i) {
        c.SetTargetPriority (targets[i].name, 0, id);
    }

    //find position
    for (i = 0; i < controllerlist.length; ++i) {
        if (controllerlist[i] == c)
            break;
    }

    //not found?
    if (i == controllerlist.length)
        return;

	DeleteController (i);
}

//Adds a controller that we should instruct what to view
function AddController (TribesTVStudioTestController c)
{
    local int i;

    //make sure it isn't already in the list
    for (i = 0; i < controllerlist.length; ++i) {
        if (controllerlist[i] == c)
            return;
    }

    controllerlist.length = controllerlist.length + 1;
    controllerlist[controllerlist.length - 1] = c;

    //Make sure this controller views what we currently want
    if (curmode != -1) {
	    c.SetCamMode (curMode);
	}

    for (i = 0; i < targets.length; ++i) {
        c.SetTargetPriority(targets[i].name, targets[i].priority, id);
    }
}

//Calls setcamtarget on all listening controllers
//also updates our internal list
//after doing changes, call updatecamtarget
function SetCamTarget (string target, float priority)
{
    local int i;

    //Find target in prio list
    for (i=0; i < Targets.length; ++i) {
        if (targets[i].name == target)
            break;
    }

    //Not found?
    if (i == Targets.length) {
        Targets.length = Targets.length + 1;
        Targets[i].name = target;
    }

    //Update it
    Targets[i].priority = priority;

    for (i = 0; i < controllerlist.length; ++i) {

    	//Since a controller could have gone missing we need to check
    	if (controllerlist[i] == none) {
    		DeleteController (i);
    		i--;
    	}
    	else {
	        controllerlist[i].settargetpriority (target, priority, id);
	    }
    }
}

//Calls updateCamtarget on all listenings controllers
function UpdateCamTarget ()
{
    local int i;

    for (i = 0; i < controllerlist.length; ++i) {

    	//Since a controller could have gone missing we need to check
    	if (controllerlist[i] == none) {
    		DeleteController (i);
    		i--;
    	}
    	else {
	        controllerlist[i].updatecamtarget ();
	    }
    }
}

//Calls setcammode on all listening controllers
function SetCamMode (int mode)
{
    local int i;

    curMode = mode;
    for (i = 0; i < controllerlist.length; ++i) {

    	//Since a controller could have gone missing we need to check
    	if (controllerlist[i] == none) {
    		DeleteController (i);
    		i--;
    	}
    	else {
	        controllerlist[i].setcammode (mode);
	    }
    }
}

DefaultProperties
{
    bHidden=true
    description="superclass"
    icon=texture'tviIcon'
}
