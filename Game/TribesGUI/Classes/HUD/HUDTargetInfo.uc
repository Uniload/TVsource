class HUDTargetInfo extends HUDContainer;

var() config Color	enemyColor;
var() config Color	allyColor;
var() config Color	healthColor;
var() config Color	shieldColor;
var() config float	pixelHealthRatio;
var() config float	pixelShieldRatio;

var LabelElement infoLabel;
var LabelElement healthLabel;

var float health;
var float maxHealth;
var float shield;
var float maxShield;
var bool  bCanBeDamaged;

function InitElement()
{
	super.InitElement();

	infoLabel = LabelElement(AddElement("TribesGUI.LabelElement", "default_targetInfoLabel"));
	healthLabel = LabelElement(AddElement("TribesGUI.LabelElement", "default_targetHealthLabel"));
}

function UpdateData(ClientSideCharacter c)
{
	local string healthString;
	local int IntHealth;

	bVisible = c.targetType != None;
	if(bVisible)
	{
		//infoLabel.SetText(c.targetLabel $"\\" $(c.targetDistance / 80) $" Meters");
		infoLabel.SetText(c.targetLabel);
		infoLabel.textColor = LocalData.GetTeamColor(LocalData.targetTeamAlignment, false, LocalData.TargetTeam);
		healthLabel.textColor = LocalData.GetTeamColor(LocalData.targetTeamAlignment, false, LocalData.TargetTeam);

		health = c.targetHealth;
		maxHealth = c.targetHealthMax;
		shield = c.targetShield;
		maxShield = c.targetShieldMax;

		bCanBeDamaged = c.targetCanBeDamaged;

		if (bCanBeDamaged)
		{
			IntHealth = int(health);
			if(IntHealth < health)
				IntHealth += 1;
			healthString $= IntHealth;
			if (Len(healthString) == 1)
				healthString = "000" $ healthString;
			else if (Len(healthString) == 2)
				healthString = "00" $ healthString;
			else if (Len(healthString) == 3)
				healthString = "0" $ healthString;

			healthLabel.SetText(healthString);
		}
		else
			healthLabel.SetText("");
	}
}

function RenderElement(Canvas C)
{
	local Color oldColor;
	local int healthBarHeight, shieldBarHeight;
	local float healthPerc;

	super.RenderElement(C);
	oldColor = C.DrawColor;

	healthBarHeight = 3;
	shieldBarHeight = 2;

	// draw a box to wrap the health
	if (bCanBeDamaged)
	{
		// render the status meter
		if(health > 0)
		{
			healthPerc = health / maxHealth;

			SetColor(C, LocalData.GetTeamColor(LocalData.targetTeamAlignment, true, LocalData.TargetTeam));

			// base functional range
			C.CurX = healthLabel.width + 2;
			C.CurY = height - 6;
			C.DrawRect(C.WhiteTex, (70 * healthPerc) - 1, healthBarHeight + 2);

			SetColor(C, LocalData.GetTeamColor(LocalData.targetTeamAlignment, false, LocalData.TargetTeam));

			// base non functional range
			C.CurX = healthLabel.width + 2;
			C.CurY = height - 6;
			C.DrawRect(C.WhiteTex, (70 * FMin(healthPerc, LocalData.TargetFunctionalHealthThreshold)), healthBarHeight + 2);
		}

		C.CurX = healthLabel.width + 1;
		C.CurY = height - 6;
		SetColor(C, LocalData.GetTeamColor(LocalData.targetTeamAlignment, false, LocalData.TargetTeam));
		C.DrawBox(C, 70, healthBarHeight + 1);

		C.CurX = healthLabel.width + 1;
		if(shield > 0)
		{
			SetColor(C, shieldColor);
			C.CurY = height + healthBarHeight - 4;
			C.DrawRect(C.WhiteTex, (70 * shield / maxShield) + 1, shieldBarHeight);
		}

		SetColor(C, oldColor);
	}
}

defaultproperties
{
	enemyColor = (R=255,G=0,B=0,A=255)
	allyColor = (R=0,G=255,B=0,A=255)
	
	healthColor = (R=255,G=0,B=0,A=255)
	shieldColor = (R=255,G=255,B=255,A=255)


	pixelHealthRatio = 1;
	pixelShieldRatio = 1;
}