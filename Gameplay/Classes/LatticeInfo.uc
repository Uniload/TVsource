// LatticeInfo
// Provides a means of linking together MPActors.  Linked MPActors can mark neighbors as available or
// unavailable as objectives change.  It is assumed that there is at most one LatticeInfo per active ModeInfo

class LatticeInfo extends Engine.Info
	editinlinenew
	placeable;

struct TeamLink
{
	var()	editdisplay(displayActorLabel)
			editcombotype(enumTeamInfo)
			TeamInfo team;
};

struct MPActorLink
{
	var()	editdisplay(displayActorLabel)
			editcombotype(enumMPActor)
			MPActor	A;
	var()	editdisplay(displayActorLabel)
			editcombotype(enumMPActor)
			MPActor	B;
	var()	array<TeamLink> 
			accessList	"A list of TeamLinks that can currently access this link.";
};

var(Lattice) array<MPActorLink> lattice					"An array of links that results in a network of MPActors.  Some MPActors can mark neighbour MPActors as available or unavailable as objectives change.";
var(Lattice) bool				 bInitializeByOwnership		"When true, the lattice's network is automatically intialized according to its MPActors' team ownership.";

simulated function PostBeginPlay()
{
	Super.PostBeginPlay();

	if (bInitializeByOwnership)
		initializeByOwnership();
}

// Setup the initial configuration of the lattice based on MPActor ownership with the following rules
// - If node A is owned by team T then connected node B is accessible to team T
// - Otherwise, node B is inaccessible to team T
// - If node B is owned by team U then connected node A is accessible to team U
// - Otherwise, node A is inaccessible to team U
simulated function initializeByOwnership()
{
	local int i;

	for (i=0; i<lattice.Length; i++)
	{
		if (lattice[i].A.team() != None)
			grantAccess(lattice[i], lattice[i].A.team());
		if (lattice[i].B.team() != None)
			grantAccess(lattice[i], lattice[i].B.team());
	}
}

// Checks to see if a is accessible to team t
simulated function bool isAccessible(MPActor a, TeamInfo t)
{
	local int i,j;
	local MPActorLink link;

	for (i=0; i<lattice.Length; i++)
	{
		link = lattice[i];
		if (link.A == a || link.B == a)
		{
			for (j=0; j<link.accessList.Length; j++)
			{
				if (link.accessList[j].team == t)
					return true;
			}
		}
	}

	return false;
}

simulated function grantAccess(MPActorLink link, TeamInfo t)
{
	local int i;
	local TeamLink tl;

	// Don't allow duplicate teams
	for (i=0; i<link.accessList.Length; i++)
	{
		if (link.accessList[i].team == t)
			return;
	}

	// Add the team
	tl.team = t;
	link.accessList[link.accessList.Length] = tl;

	Log(self$" granted access to "$link.accessList[link.accessList.Length - 1].team);
}

simulated function revokeAccess(MPActorLink link, TeamInfo t)
{
	local int i;

	for (i=0; i<link.accessList.Length; i++)
	{
		if (link.accessList[i].team == t)
			link.accessList.Remove(i, 1);
	}
}

// Sends callback messages to neighbor nodes
simulated function makeNeighboursAvailable(MPActor a, TeamInfo t)
{
	local int i;

	for (i=0; i<lattice.Length; i++)
	{
		if (lattice[i].A == a)
		{
			grantAccess(lattice[i], t);
			lattice[i].B.onAvailableToLattice();
		}
		else if (lattice[i].B == a)
		{
			grantAccess(lattice[i], t);
			lattice[i].A.onAvailableToLattice();
		}
	}
}


// Sends callback messages to neighbor nodes
simulated function makeNeighboursUnavailable(MPActor a, TeamInfo t)
{
	local int i;

	for (i=0; i<lattice.Length; i++)
	{
		if (lattice[i].A == a)
		{
			revokeAccess(lattice[i], t);
			lattice[i].B.onUnavailableToLattice();
		}
		else if (lattice[i].B == a)
		{
			revokeAccess(lattice[i], t);
			lattice[i].A.onUnavailableToLattice();
		}
	}
}

// enumTeamInfo
// List all team info objects in the editor
function enumTeamInfo(Engine.LevelInfo l, out Array<TeamInfo> s)
{
	local TeamInfo t;

	ForEach l.AllActors(class'TeamInfo', t)
	{
		s[s.Length] = t;
	}
}

function enumMPActor(Engine.LevelInfo l, out Array<MPActor> s)
{
	local MPActor a;

	ForEach l.AllActors(class'MPActor', a)
	{
		s[s.Length] = a;
	}
}

// Display an actor reference's label in the editor
function string displayActorLabel(Actor t)
{
	return string(t.label);
}

defaultproperties
{
     bAlwaysRelevant=True
     RemoteRole=ROLE_DumbProxy
     NetUpdateFrequency=1.000000
}
