//==============================================================================
//  Created on: 01/02/2004
//  Stub class for VotingReplicationInfo
//
//  Written by Ron Prestenback
//  © 2003, Epic Games, Inc. All Rights Reserved
//==============================================================================

class VotingReplicationInfoBase extends ReplicationInfo
	abstract
	notplaceable;

replication
{
	reliable if ( Role == ROLE_Authority )
		SendResponse;

	reliable if ( Role < ROLE_Authority )
		SendCommand;
		
	// functions the client calls on the server
	reliable if( Role < ROLE_Authority )
		SubmitMapVote,
		SubmitKickVote,
		SubmitAdminVote,
		SubmitTeamDamageVote,
		SubmitTournamentVote;
}

function SubmitMapVote(string map, string gametype);
function SubmitKickVote(string name);
function SubmitAdminVote(string name);
function SubmitTeamDamageVote(bool vote);
function SubmitTournamentVote(bool vote);

delegate ProcessCommand( string Command );
delegate ProcessResponse( string Response );

function SendCommand( string Cmd )
{
	ProcessCommand(Cmd);
}

simulated function SendResponse( string Response )
{
	ProcessResponse(Response);
}

simulated function bool MatchSetupLocked() { return false; }

simulated function bool MapVoteEnabled() { return false; }
simulated function bool KickVoteEnabled() { return false; }
simulated function bool AdminVoteEnabled() { return false; }
simulated function bool TeamDamageVoteEnabled() { return false; }
simulated function bool TournamentVoteEnabled() { return false; }

simulated function bool MatchSetupEnabled() { return false; }
