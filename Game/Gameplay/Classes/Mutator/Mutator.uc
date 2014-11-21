// Tribes 3 Mutator class
class Mutator extends Engine.Mutator;

// changes the loadout that is given to the player when he spawns
function string MutateSpawnLoadoutClass(Character c)
{
	if ( Mutator(NextMutator) != None )
		return Mutator(NextMutator).MutateSpawnLoadoutClass(c);
	else
		return "";
}

// changes the combat role that is set for the player when he spawns
function string MutateSpawnCombatRoleClass(Character c)
{
	if ( Mutator(NextMutator) != None )
		return Mutator(NextMutator).MutateSpawnCombatRoleClass(c);
	else
		return "";
}

// changes the player's meshes
// setting any of the parameters to 'None' uses the default mesh
function MutatePlayerMeshes(out Mesh characterMesh, out class<Jetpack> jetpackClass, out Mesh armsMesh)
{
	if ( Mutator(NextMutator) != None )
		Mutator(NextMutator).MutatePlayerMeshes(characterMesh, jetpackClass, armsMesh);
	else
	{
		characterMesh = None;
		jetpackClass = None;
		armsMesh = None;
	}
}

// allow or disallow manual respawns
function bool MutateManualRespawn()
{
	if ( Mutator(NextMutator) != None )
		return Mutator(NextMutator).MutateManualRespawn();
	else
		return true;
}