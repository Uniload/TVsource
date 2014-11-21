class StatData extends Core.Object;

var class<Stat> statClass;
var int amount;
var float lastAwardTimestamp;

function increment()
{
	amount++;
}

function decrement()
{
	amount--;
}

defaultproperties
{
}
