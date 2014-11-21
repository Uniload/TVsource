class ObjectSpawnUseableObject extends BaseDeviceAccess;

var() localized String AlreadyHaveDeployablePrompt;

function bool CanBeUsedBy(Pawn user)
{
	local Character CharacterUser;

	CharacterUser = Character(user);

	return CharacterUser != None &&
		   ObjectSpawnPoint(Owner).IsFriendly(CharacterUser) &&
		   CharacterUser.NextEquipment(None, class'Deployable') == None &&
		   ObjectSpawnPoint(Owner).UseablePointsValid[0] != UP_NotValid;
}

function UsedBy(Pawn user)
{
	if (CanBeUsedBy(user))
		ObjectSpawnPoint(Owner).OnPlayerUsed(user);

	super.UsedBy(user);
}

function byte GetPromptIndex(Character PotentialUser)
{
	local byte promptIndex;
	promptIndex = super.GetPromptIndex(PotentialUser);

	if(ObjectSpawnPoint(Owner).bHoldingObject)
	{
		if(promptIndex == 255 && PotentialUser.NextEquipment(None, class'Deployable') != None)
			promptIndex = 3;
	}

	return promptIndex;
}

// returns a prompt string based on the prompt index
static function string GetPrompt(byte PromptIndex, class<Actor> dataClass)
{
	switch(promptIndex)
	{
	case 0:
		return default.prompt;
	case 1:
		return default.PowerDownPrompt;
	case 2:
		return default.IsDisabledPrompt;
	case 3:
		return default.AlreadyHaveDeployablePrompt;
	}

	return "";
}

defaultproperties
{
	prompt = "Press '%1' to get the deployable at this station."
	AlreadyHaveDeployablePrompt = "You already have a deployable."
	markerOffset = (X=0,Y=0,Z=20)
}