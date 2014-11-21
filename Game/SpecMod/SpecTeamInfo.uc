class SpecTeamInfo extends Engine.ReplicationInfo;

var string localizedName;
var float GeneratorHealthTotal;
var float GeneratorHealthMaxTotal;

replication
{
    reliable if (Role == ROLE_Authority)
	localizedName,
	GeneratorHealthTotal,
	GeneratorHealthMaxTotal;
}

defaultproperties
{
	bAlwaysRelevant=true;
}