class SkeletalPawn extends Pawn
	placeable;

function PostBeginPlay()
{
	Super.PostBeginPlay();
	LoopAnim('stand_turn');
}

defaultproperties
{
}
