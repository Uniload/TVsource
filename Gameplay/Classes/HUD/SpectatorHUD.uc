class SpectatorHUD extends DefaultHUD;

simulated function DrawHUD( canvas C )
{
	local PlayerCharacterController PC;
	local float textWidth, textHeight;

	PC = PlayerCharacterController(PlayerOwner);
	if (PC == None)
		return;

	C.SetDrawColor(255, 255, 255);

	// print spectator help
	C.Font = SmallFont;
	C.TextSize("W", textWidth, textHeight);
	drawJustifiedShadowedText(C, "Press fire to start, press jetpack to view other players", 0, C.ClipY * 0.01, C.ClipX, C.ClipY * 0.01 + textHeight, 1);

	// print the name of the player we are viewing
	if (Pawn(PC.ViewTarget) != None)
	{
		C.Font = MedFont;
		
		if (Pawn(PC.ViewTarget).PlayerReplicationInfo != None)
			drawJustifiedShadowedText(C, "Viewing " $ Pawn(PC.ViewTarget).PlayerReplicationInfo.PlayerName, 0, C.ClipY * 0.95, C.ClipX, C.ClipY, 1);
	}
	else
	{
		drawJustifiedShadowedText(C, "Spectator", 0, C.ClipY * 0.95, C.ClipX, C.ClipY, 1);
	}
}
