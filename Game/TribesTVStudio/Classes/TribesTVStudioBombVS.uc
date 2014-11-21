//-----------------------------------------------------------
// ViewSelector that tries to watch the bomb
// Adds priority to the bomb if it is in play
// otherwise don't do anything..
//-----------------------------------------------------------
class TribesTVStudioBombVS extends TribesTVStudioViewSelector;

enum BombState
{
    BSHome,
    BSPlayed
};

var xBombFlag bomb;
var BombState curstate;

function bool runnable ()
{
	return (level.game.isa ('xBombingRun'));
}

function FindBomb ()
{
    local xBombFlag f;

    foreach AllActors (class'xBombFlag', f) {
    	bomb = f;
    	break;
    }
}

function Tick (float deltatime)
{
	local BombState ns;

    if (bomb == none) {
        FindBomb ();
    }

	if (bomb.bhome)
		ns = BSHome;
	else
		ns = BSPlayed;

	//changed state?
	if (ns != curstate) {
		switch (ns) {
			case BSHome:
				SetCamTarget ("The Bomb", 0);
				break;
			case BSPlayed:
				SetCamTarget ("The Bomb", 0.8);
				break;
		}

		curstate = ns;
		UpdateCamTarget ();
	}
}

defaultproperties
{
    description="Follow the bomb"
    icon=texture'tviVCBomb'
}
