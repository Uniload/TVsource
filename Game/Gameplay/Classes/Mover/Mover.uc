// Mover class with modifications for new event system
class Mover extends Engine.Mover
	hidecategories(MoverEvents)
	hidecategories(AI);

var() class<MessageTrigger> triggerMessageType			"The type of Message that the mover responds to (can be 'None')";


// PostBeginPlay
function PostBeginPlay()
{
	Super.PostBeginPlay();

	if (triggerMessageType != None)
		registerMessage(triggerMessageType, triggeredBy);
}

// Overridden functions to utilize the new event system
function DoPlayerBumpEvent( actor Other )
{
	Super.DoPlayerBumpEvent( Other );

	dispatchMessage(new class'MessageMoverPlayerBump'(label, Other.label));
}

function DoBumpEvent( actor Other )
{
	Super.DoBumpEvent( Other );

	dispatchMessage(new class'MessageMoverBump'(label, Other.label));
}

function FinishedOpening()
{
	Super.FinishedOpening();

	dispatchMessage(new class'MessageMoverOpened'(label));
}

function DoOpen()
{
	Super.DoOpen();

	dispatchMessage(new class'MessageMoverOpening'(label));
}

function FinishedClosing()
{
	Super.FinishedClosing();

	dispatchMessage(new class'MessageMoverClosed'(label));
}

function DoClose()
{
	Super.DoClose();

	dispatchMessage(new class'MessageMoverClosing'(label));
}

// onMessage
function onMessage(Message msg)
{
	local MessageTrigger t;

	if (triggerMessageType == None)
		return;

	t = MessageTrigger(msg);

	if (t != None)
	{
		Trigger(findByLabel(class'Pawn', t.trigger), Pawn(findByLabel(class'Actor', t.instigator)));
	}
}


defaultproperties
{
	TriggerMessageType = class'MessageTrigger'
	bBlockKarma = true
}