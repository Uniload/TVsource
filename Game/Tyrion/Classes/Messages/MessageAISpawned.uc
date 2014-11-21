class MessageAISpawned extends Engine.Message
	editinlinenew;

var Name spawnPoint;
var Name spawnedAI;

// construct
overloaded function construct(Name _spawnPoint, Name _spawnedAI)
{
	spawnPoint = _spawnPoint;
	spawnedAI = _spawnedAI;

	SLog(spawnPoint $ " spawned " $ spawnedAI);
}

// editorDisplay
static function string editorDisplay(Name triggeredBy, Message filter)
{
	return triggeredBy$" spawns an AI";
}


defaultproperties
{
	specificTo	= class'AISpawnPoint'
}