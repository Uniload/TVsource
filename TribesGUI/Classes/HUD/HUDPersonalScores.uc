class HUDPersonalScores extends HUDContainer;


var localized String OffenseText;
var localized String DefenseText;
var localized String StyleText;

var HUDContainer LabelList;
var LabelElement OffenseLabel;
var LabelElement DefenseLabel;
var LabelElement StyleLabel;

var HUDContainer ScoreList;
var LabelElement OffenseScore;
var LabelElement DefenseScore;
var LabelElement StyleScore;

var bool bInitialised;

function InitElement()
{
	Super.InitElement();

	if(bInitialised)
		return;

	LabelList = HUDContainer(AddElement("TribesGUI.HUDContainer", "default_ScoreLabelList"));
	OffenseLabel = LabelElement(LabelList.AddClonedElement("TribesGUI.LabelElement", "default_ScoreLabel", "OffenseLabel"));
	OffenseLabel.SetText(OffenseText);
	DefenseLabel = LabelElement(LabelList.AddClonedElement("TribesGUI.LabelElement", "default_ScoreLabel", "DefenseLabel"));
	DefenseLabel.SetText(DefenseText);
	StyleLabel = LabelElement(LabelList.AddClonedElement("TribesGUI.LabelElement", "default_ScoreLabel", "StyleLabel"));
	StyleLabel.SetText(StyleText);

	ScoreList = HUDContainer(AddElement("TribesGUI.HUDContainer", "default_ScoreDataList"));
	OffenseScore = LabelElement(ScoreList.AddClonedElement("TribesGUI.LabelElement", "default_ScoreData", "OffenseScore"));
	OffenseScore.SetText("0");
	DefenseScore = LabelElement(ScoreList.AddClonedElement("TribesGUI.LabelElement", "default_ScoreData", "DefenseScore"));
	DefenseScore.SetText("0");
	StyleScore = LabelElement(ScoreList.AddClonedElement("TribesGUI.LabelElement", "default_ScoreData", "StyleScore"));
	StyleScore.SetText("0");
}

function UpdateData(ClientSideCharacter c)
{
	super.UpdateData(c);

	if (ClassIsChildOf(c.gameClass, class'MultiplayerGameInfo'))
	{
		OffenseScore.SetText(""$c.OffenseScore);
		DefenseScore.SetText(""$c.DefenseScore);
		StyleScore.SetText(""$c.StyleScore);
	}
	else
	{
		LabelList.bVisible = false;
		ScoreList.bVisible = false;
	}
}

defaultproperties
{
	OffenseText="Offense:"
	DefenseText="Defense:"
	StyleText="Style:"
}