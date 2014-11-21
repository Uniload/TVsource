// ====================================================================
//  Class:  TribesGui.TribesExitMenu
//
// ====================================================================

class TribesExitMenu extends TribesSlideshowMenu
     ;

var(TribesGui) EditInline Config GUIButton ecommerceButton "A component of this page which has its behavior defined in the code for this page's class.";
var(TribesGui) EditInline Config GUIButton productButton "A component of this page which has its behavior defined in the code for this page's class.";
var(TribesGui) EditInline Config GUIButton signupButton "A component of this page which has its behavior defined in the code for this page's class.";
var(TribesGui) EditInline Config GUIButton nextButton "A component of this page which has its behavior defined in the code for this page's class.";
var(TribesGui) EditInline Config GUIButton exitButton "A component of this page which has its behavior defined in the code for this page's class.";

var(TribesGui) config string ecommerceURL;
var(TribesGui) config string productURL;
var(TribesGui) config string signupURL;

function InitComponent(GUIComponent MyOwner)
{
	Super.InitComponent(MyOwner);

	ecommerceButton.OnClick=OnEcommerceClick;
	productButton.OnClick=OnProductClick;
	signupButton.OnClick=OnSignupClick;
	nextButton.OnClick=OnNextClick;
	exitButton.OnClick=OnNextClick;

	// Hide these buttons until the last slide is shown
	ecommerceButton.Hide();
	ecommerceButton.bCanBeShown = false;
	productButton.Hide();
	productButton.bCanBeShown = false;
	signupButton.Hide();
	signupButton.bCanBeShown = false;
	exitButton.Hide();
	exitButton.bCanBeShown = false;
	ecommerceButton.SetEnabled(false);
	productButton.SetEnabled(false);
	signupButton.SetEnabled(false);
	exitButton.SetEnabled(false);
}

function OnEcommerceClick(GUIComponent Sender)
{
	PlayerOwner().ConsoleCommand("start "$ecommerceURL);
}

function OnProductClick(GUIComponent Sender)
{
	PlayerOwner().ConsoleCommand("start "$productURL);
}

function OnSignupClick(GUIComponent Sender)
{
	PlayerOwner().ConsoleCommand("start "$signupURL);
}

function onSlideshowEnd()
{
    Controller.CloseAll();
	PlayerOwner().ConsoleCommand("quit");
}

function OnNextClick(GUIComponent Sender)
{
	AdvanceSlideshow();
	if (isLastSlide())
	{
		ecommerceButton.bCanBeShown = true;
		productButton.bCanBeShown = true;
		signupButton.bCanBeShown = true;
		exitButton.bCanBeShown = true;
		ecommerceButton.Show();
		productButton.Show();
		signupButton.Show();
		exitButton.Show();
		ecommerceButton.SetEnabled(true);
		productButton.SetEnabled(true);
		signupButton.SetEnabled(true);
		nextButton.Hide();
		nextButton.SetEnabled(false);
		nextButton.bCanBeShown = false;
	}
}


defaultproperties
{
	imageDelay = 0
	bHideMouseCursor=false
}