//-----------------------------------------------------------
//
//-----------------------------------------------------------
class TribesTVStudioActionVS extends TribesTVStudioViewSelector;

struct PlayerRating{
	var float rating;
	var PlayerReplicationInfo pri;
	var Vector lastPos;
};

var PlayerRating ratings[32];
var int numPlayers;
var int nextUpdate;
var int lastBestId;
var float maxScore;

function PostBeginPlay()
{
	local TribesTVStudioActionVS_GR G;

	Super.PostBeginPlay();
	G = spawn(class'TribesTVStudioActionVS_GR');
	if ( Level.Game.GameRulesModifiers == None )
		Level.Game.GameRulesModifiers = G;
	else
		Level.Game.GameRulesModifiers.AddGameRules(G);

	G.reportTo=self;

	SetTimer (1, true);
}

function Timer ()
{
	local int a;
	local PlayerRating oldRatings[32];
	local int num;
	local PlayerReplicationInfo pri;
	local float bestRating;
	local int bestPlayer;

	//Check to make sure all players are still valid
	for (a = 0; a < numplayers; ++a) {
		if (ratings[a].pri == none) {
			nextupdate = 0;
			break;
		}
		if (ratings[a].pri.owner == none) {
			nextupdate = 0;
			break;
		}
	}

	nextUpdate--;
	if(nextUpdate<0){
		nextUpdate=10;
		maxScore=0;
		for(a=0;a<numPlayers;++a){
			oldRatings[a].pri=ratings[a].pri;
			oldRatings[a].rating=ratings[a].rating;
			oldRatings[a].lastPos=ratings[a].lastPos;
		}
		foreach Allactors (class'PlayerReplicationInfo', pri) {
			if (!pri.bOnlySpectator){
				if(pri!=ratings[num].pri){

					//Make sure we don't keep an old priority on a dropped player
					if (ratings[num].pri != none)
						SetCamTarget (ratings[num].pri.playername, 0);

					ratings[num].pri = pri;
					ratings[num].rating = 0;
					for(a=0;a<numPlayers;++a){
						if(oldRatings[a].pri==ratings[num].pri){
							ratings[num].rating=oldRatings[a].rating;
							ratings[num].lastPos=oldRatings[a].lastPos;
							break;
						}
					}
				}
				if(pri.Score>maxScore)
					maxScore=pri.score;
				num++;
			}
		}
		numPlayers=num;
		if(maxScore==0)
			maxScore=1;
		maxScore/=8;//how much to weight score
	}
	for(a=0;a<numPlayers;++a){
		ratings[a].rating*=0.85; //reward old actions less
		ratings[a].rating+=min(VSize(ratings[a].lastPos-ratings[a].pri.owner.location),200)/30; //reward movement
		ratings[a].lastPos=ratings[a].pri.owner.location;
	}

	bestRating=0;
	bestPlayer=-1;

	for(a=0;a<numPlayers;++a){
		if(ratings[a].rating + ratings[a].pri.score/maxScore > bestRating){	//weight in score separatly in order to not track old scores
			bestRating=ratings[a].rating + ratings[a].pri.score/maxScore;
			bestPlayer=a;
		}
	}

	if(bestPlayer!=-1){
		if(lastBestId!=ratings[bestPlayer].pri.playerId){
			ratings[bestPlayer].rating*=2;  //prevent too frequent target switches by increasing new targets value;
			bestrating *= 2;
			lastBestId=ratings[bestPlayer].pri.playerId;
		}
	}

	//Update what we think of each target
	if (bestrating > 0) {
		for (a = 0; a < numplayers; ++a) {
			SetCamtarget (ratings[a].pri.playername, FMax (0, 0.3 * ((ratings[a].rating + ratings[a].pri.score/maxScore) / bestrating)));
		}
		UpdateCamTarget ();
	}
}

function AddRating(int id,float rating)
{
	local int a;

	for(a=0;a<numPlayers;++a){
		if(ratings[a].pri.playerId==id){
			ratings[a].rating+=rating;
			break;
		}
	}
}

DefaultProperties
{
	description="Search for action"
	icon=texture'tviVCSearch'
}
