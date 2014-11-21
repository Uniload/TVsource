// ====================================================================
//  Class:  TribesGui.TribesSlideshowMenu
//
// ====================================================================

class TribesSlideshowMenu extends TribesGUIPage
     ;

var(TribesGui) EditInline Config GUIImage slideshowImage "A component of this page which has its behavior defined in the code for this page's class.";
var() bool bDontQuitOnClick;
var(TribesGui) config array<Material> imageList "A component of this page which has its behavior defined in the code for this page's class.";
var(TribesGui) config  int imageDelay			"The number of seconds to wait before auto-advancing the slideshow.  0 to disable auto-advancement";
var(TribesGui) config bool bAllowClickToAdvance "If true, clicking the mouse button on the screen will advance it";

var int currentImageIndex;
var bool bActivated;
var int numTicks;

function InitComponent(GUIComponent MyOwner)
{
	Super.InitComponent(MyOwner);
	OnShow=InternalOnShow;
    OnKeyEvent=InternalOnKeyEvent;
	slideshowImage.OnClick=OnSlideshowClick;
	slideshowImage.OnKeyEvent=InternalOnKeyEvent;
}

function InternalOnShow()
{
	// Prevent queued mouse clicks from being processed
	SetTimer(0.2, false);
}

function StartSlideshow()
{
	//Log("Starting slideshow");
	currentImageIndex = 0;
	if (imageList.Length == 0)
	{
		Log("Slideshow warning:  there are no images to show in the slideshow");
		return;
	}

	slideshowImage.Image = imageList[0];
	if (imageDelay > 0)
		SetTimer(imageDelay, false);
}

function EndSlideshow()
{
	//Log("Ending slideshow");
	SetTimer(0, false);

	if (!bDontQuitOnClick)
		Controller.CloseMenu();

	OnSlideshowEnd();
}

function OnSlideShowEnd()
{
	// Overridden
}

function AdvanceSlideshow()
{
	//Log("Advancing slideshow");
	if (!advanceImage())
	{
		EndSlideshow();
	}

	// Set timer again if applicable
	if (imageDelay > 0)
		SetTimer(imageDelay, false);
}

event Timer()
{
	numTicks++;

	if (numTicks < 2)
	{
		setTimer(0.2);
		return;
	}

	if (!bActivated)
	{
		bActivated = true;
		bAcceptsInput = true;
		slideshowImage.bAcceptsInput=true;
		slideshowImage.bCaptureMouse=true;
		StartSlideshow();
	}
	else
		AdvanceSlideshow();
}

function bool InternalOnKeyEvent(out byte Key, out byte State, float delta)
{
	if (!bActivated || numTicks < 2)
		return true;

	if (bDontQuitOnClick)
		return false;

    if( bVisible && bActiveInput && State == EInputAction.IST_Press && (Key == EInputKey.IK_Escape))
    {
		AdvanceSlideshow();
        return true;
    }
    return false;
}

function OnSlideshowClick(GUIComponent Sender)
{
	if (!bActivated || numTicks < 2)
		return;

	if (bAllowClickToAdvance)
		AdvanceSlideshow();
}

function bool advanceImage()
{
	currentImageIndex++;
	//Log("CurrentImageIndex set to "$currentImageIndex$" with imageList.Length set to "$imageList.Length);
	if (currentImageIndex >= imageList.Length)
		return false;

	slideshowImage.Image = imageList[currentImageIndex];
	return true;
}

function bool isLastSlide()
{
	return currentImageIndex == imageList.Length - 1;
}


defaultproperties
{
	imageDelay=6
	bHideMouseCursor=true
	bAcceptsInput=false
}