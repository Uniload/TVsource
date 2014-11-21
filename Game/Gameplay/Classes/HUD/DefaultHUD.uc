class DefaultHUD extends Engine.HUD;

var Pathfinding.PFTestHarness pathfindTestHarness;
var NavigationTestHarness navigationTestHarness;
var string NavigationTestHarnessClass;

// AI Debug stuff
var SquadInfo debugSquadInfo;	// Squad for whom Formation debug info is being displayed

// Weapon debug stuff
var bool playerWeaponDebug;	// Show debug for the current weapon

simulated event PostBeginPlay()
{
	local class<NavigationTestHarness> navigationTestClassInstance;

	Super.PostBeginPlay();

	Label = 'HUD';
	
	// spawn and initialise pathfinding system test harness
	pathfindTestHarness = spawn(class'PFTestHarness', self);
	pathfindTestHarness.initialise(self);

	// spawn and initialise navigation system test harness
	navigationTestClassInstance = class<NavigationTestHarness>(DynamicLoadObject(NavigationTestHarnessClass, class'Class'));
	navigationTestHarness = spawn(navigationTestClassInstance, self);
	navigationTestHarness.initialise(self);
}

simulated function DrawHUD(canvas Canvas)
{
	clientDispatchMessage(new class'MessagePreDrawHUD'(self, Canvas));

	Super.DrawHUD( canvas );

//	if ( debugAIChar != None )
//		debugAIChar.controller.drawDebug( canvas, self );
}

exec function debugPlayerWeapon()
{
	playerWeaponDebug = true;
}

// Temporary function to quickly display shadowed text
simulated function drawShadowedText(canvas Canvas, String text, int x, int y)
{
	Canvas.Font = SmallFont;
	Canvas.SetPos(x+1, y+1);
	Canvas.SetDrawColor(80, 80, 80);
	Canvas.DrawText(text);
	Canvas.SetPos(x, y);
	Canvas.SetDrawColor(255, 255, 255);
	Canvas.DrawText(text);
}

// Temporary function to quickly display shadowed text
simulated function drawJustifiedShadowedText(canvas Canvas, String text, int x, int y, int x1, int y1, int justify)
{
	local Color color;

	color = Canvas.DrawColor;

	Canvas.Font = SmallFont;
	Canvas.SetDrawColor(80, 80, 80);
	Canvas.DrawTextJustified(text, justify, x+1, y+1, x1, y1);
	Canvas.SetDrawColor(color.r, color.g, color.b, color.a);
	Canvas.DrawTextJustified(text, justify, x, y, x1, y1);
}

// draws the current team and player scores
simulated function drawScores(Canvas C, optional int y)
{
	local PlayerCharacterController PC;
	local float textSizeX, textSizeY;
	local int i, j, x;
	local Array<int> scoreVals;
	local Array<string> scoreNames;
	local Array<TribesReplicationInfo> sortedTRIList;
	local PlayerReplicationInfo P;
	local Character char;
	local TeamInfo team;

	PC = PlayerCharacterController(PlayerOwner);
	if (PC == None)
		return;

	char = Character(PlayerOwner.Pawn);
	if (char == None)
		return;

	C.Font = SmallFont;
	C.TextSize("W", textSizeX, textSizeY);

	// Team Scores
	scoreNames.Length = 0;
	scoreVals.Length = 0;
	C.SetDrawColor(255, 255, 255);
	ForEach DynamicActors(class'TeamInfo', team)
	{
		// sort by score
		i = 0;
		if ( scoreVals.length > 0 )
			while ( i < scoreVals.length && scoreVals[i] > team.Score )
				i++;

		scoreVals.Insert(i, 1);
		scoreVals[i] = team.Score;
		scoreNames.Insert(i, 1);
		scoreNames[i] = string(team.Label);
	}

	if (y == 0)
	{
		y = 0.1 * C.ClipY;
	}
	
	x = 0.1 * C.ClipX;

	C.SetPos(x + (0.8 * C.ClipX * 0.0), y - textSizeY - 3);
	C.DrawText("Team");

	C.SetPos(x + (0.8 * C.ClipX * 0.22), y - textSizeY - 3);
	C.DrawText("Score");

	C.SetPos(x, y);
	C.DrawRect(C.WhiteTex, 0.8 * C.ClipX, 1);

	C.SetPos(x + (0.8 * C.ClipX * 0.22) - 5, y - textSizeY);
	C.DrawRect(C.WhiteTex, 1, (scoreVals.Length + 1) * textSizeY);

	y += 2;

	for (i = 0; i < scoreVals.Length; i++)
	{
		if (scoreNames[i] == string(char.team().Label))
			C.SetDrawColor(255, 0, 0);
		else
			C.SetDrawColor(255, 255, 255);

		drawJustifiedShadowedText(C, scoreNames[i], x + (0.8 * C.ClipX * 0.0), y, x + (0.8 * C.ClipX * 0.7), y + 0.03 * C.ClipY, 0);
		drawJustifiedShadowedText(C, string(scoreVals[i]), x + (0.8 * C.ClipX * 0.22), y, x + (0.8 * C.ClipX * 1.0), y + 0.03 * C.ClipY, 0);

		y += 0.03 * C.ClipY;
	}

	y += 40;

	// Player Scores
	scoreNames.Length = 0;
	scoreVals.Length = 0;
	C.SetDrawColor(255, 255, 255);

	for (j = 0; j < PlayerOwner.GameReplicationInfo.PRIArray.Length; j++)
	{
		P = tribesReplicationInfo(PlayerOwner.GameReplicationInfo.PRIArray[j]);

		// sort by score
		i = 0;
		if ( scoreVals.length > 0 )
			while ( i < scoreVals.length && scoreVals[i] > P.Score )
				i++;

		sortedTRIList.Insert(i, 1);
		sortedTRIList[i] = tribesReplicationInfo(P);
		scoreVals.Insert(i, 1);
		scoreVals[i] = P.Score;
		scoreNames.Insert(i, 1);
		scoreNames[i] = P.PlayerName;
	}

	x = 0.1 * C.ClipX;

	C.SetPos(x + (0.8 * C.ClipX * 0.0), y - textSizeY - 3);
	C.DrawText("Player");

	C.SetPos(x + (0.8 * C.ClipX * 0.22), y - textSizeY - 3);
	C.DrawText("Score");

	
	C.SetPos(x + (0.8 * C.ClipX * 0.22 + 60), y - textSizeY - 3);
	C.DrawText("O");

	C.SetPos(x + (0.8 * C.ClipX * 0.22 + 90), y - textSizeY - 3);
	C.DrawText("D");

	C.SetPos(x + (0.8 * C.ClipX * 0.22 + 120), y - textSizeY - 3);
	C.DrawText("S");

	for (j=0; j < sortedTRIList[0].statDataList.Length; j++)
	{
		C.SetPos(x + (0.8 * C.ClipX * 0.22 + 180 + j*50), y - textSizeY - 3);
		C.DrawText(char.tribesReplicationInfo.statDataList[j].statClass.default.acronym);
	}

	C.SetPos(x, y);
	C.DrawRect(C.WhiteTex, 0.8 * C.ClipX, 1);

	C.SetPos(x + (0.8 * C.ClipX * 0.22) - 5, y - textSizeY);
	C.DrawRect(C.WhiteTex, 1, (scoreVals.Length + 1) * textSizeY);

	y += 2;

	P = char.tribesReplicationInfo;

	for (i = 0; i < sortedTRIList.Length; i++)
	{
		if (sortedTRIList[i].PlayerName == P.PlayerName)
			C.SetDrawColor(255, 0, 0);
		else
			C.SetDrawColor(255, 255, 255);

		drawJustifiedShadowedText(C, sortedTRIList[i].PlayerName, x + (0.8 * C.ClipX * 0.0), y, x + (0.8 * C.ClipX * 0.7), y + 0.03 * C.ClipY, 0);
		drawJustifiedShadowedText(C, string(int(sortedTRIList[i].Score)), x + (0.8 * C.ClipX * 0.22), y, x + (0.8 * C.ClipX * 1.0), y + 0.03 * C.ClipY, 0);
		drawJustifiedShadowedText(C, string(sortedTRIList[i].offenseScore), x + (0.8 * C.ClipX * 0.22+60), y, x + (0.8 * C.ClipX * 1.0), y + 0.03 * C.ClipY, 0);
		drawJustifiedShadowedText(C, string(sortedTRIList[i].defenseScore), x + (0.8 * C.ClipX * 0.22+90), y, x + (0.8 * C.ClipX * 1.0), y + 0.03 * C.ClipY, 0);
		drawJustifiedShadowedText(C, string(sortedTRIList[i].styleScore), x + (0.8 * C.ClipX * 0.22+120), y, x + (0.8 * C.ClipX * 1.0), y + 0.03 * C.ClipY, 0);
		for (j=0; j < sortedTRIList[i].statDataList.Length; j++)
		{
			drawJustifiedShadowedText(C, string(sortedTRIList[i].statDataList[j].amount), x + (0.8 * C.ClipX * 0.22 + 180 + j*50), y, x + (0.8 * C.ClipX * 1.0), y + 0.03 * C.ClipY, 0);
		}
		y += 0.03 * C.ClipY;
	}
}

// drawBox
function drawBox(canvas C, int x, int y, int w, int h, optional int size)
{
	if (size == 0)
		size = 1;

	C.SetPos(X, Y);
	C.DrawRect(C.WhiteTex, size, h);
	C.DrawRect(C.WhiteTex, w, size);
	C.SetPos(X + w, Y);
	C.DrawRect(C.WhiteTex, size, h);
	C.SetPos(X, Y + h);
	C.DrawRect(C.WhiteTex, w+size, size);
	C.SetPos(X, Y);
}

// LocalizedMessage
simulated function LocalizedMessage( class<LocalMessage> Message, optional int Switch, optional Core.Object Related1, optional Core.Object Related2, optional Core.Object OptionalObject, optional string CriticalString, optional string OptionalString )
{
	PlayerOwner.ClientMessage( Message.static.GetString(Switch, Related1, Related2, OptionalObject, OptionalString) );
}


//=============================================================================

defaultProperties
{
	NavigationTestHarnessClass = "Tyrion.ConcreteNavigationTest"

	ConsoleMessagePosY = 0.6
    ConsoleMessageCount=8
}
