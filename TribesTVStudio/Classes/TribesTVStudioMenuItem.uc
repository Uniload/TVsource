//-----------------------------------------------------------
//
//-----------------------------------------------------------
class TribesTVStudioMenuItem extends Object;

enum ETVItemState {
	TribesTVStudio_None,
	TribesTVStudio_On,
	TribesTVStudio_Off,
};

var string Text;
var ETVItemState mstate;
var texture icon;
var TribesTVStudioMenuItem next;
var TribesTVStudioMenuItem prev;
var TribesTVStudioMenuItem child;
var TribesTVStudioMenuItem parent;
var int hid;
var int lid;				
var bool icononly;

//Adds an item last to the specified chain
function TribesTVStudioMenuItem addToChain (TribesTVStudioMenuItem chain, TribesTVStudioMenuItem c)
{
	local TribesTVStudioMenuItem last, cur;

	last = none;
	cur = chain;
	
	while (cur != none) {
		last = cur;
		cur = cur.next;		
	}	
	
	if (last == none) {
		chain = c;
		c.prev = none;
	}
	else {
		last.next = c;
		c.prev = last;
	}
	return chain;
}

function addChild (TribesTVStudioMenuItem c)
{
	child = addToChain (child, c);
	c.parent = self;
}

function addNext (TribesTVStudioMenuItem c)
{
	next = addToChain (next, c);
	c.parent = parent;
}

function addHere (TribesTVStudioMenuItem c)
{
	if (next != none) {
		c.next = next;
		next.prev = c;
	}
	c.prev = self;
	c.parent = parent;
	next = c;
}

//Adds c before this element. Needs the current list head, returns the new (can be unchanged)
function TribesTVStudioMenuItem addBefore (TribesTVStudioMenuItem head, TribesTVStudioMenuItem c)
{
	local TribesTVStudioMenuItem ret;

	if (self != head) {
		prev.next = c;
		c.prev = prev;
		ret = head;
	}
	else {
		ret = c;	
	}	

	c.next = self;	
	c.parent = parent;
	prev = c;			
	
	return ret;
}

//Deletes this item from the list. Returns new list head if needed
function TribesTVStudioMenuItem deleteHere (TribesTVStudioMenuItem head)
{
	if (next != none) {
		next.prev = prev;
	}
	if (prev != none) {
		prev.next = next;
		return head;
	}
	else {
		return next;
	}
}

//Sets this item to TribesTVStudio_On and the other items on the same level to TribesTVStudio_Off
function SetRadio ()
{
	local TribesTVStudioMenuItem cur;
	
	//Fix the ones ahead
	cur = next;
	while (cur != none) {
		cur.mstate = TribesTVStudio_Off;
		cur = cur.next;
	}

	//And the ones behind
	cur = prev;
	while (cur != none) {
		cur.mstate = TribesTVStudio_Off;
		cur = cur.prev;
	}

	mstate = TribesTVStudio_On;	
}

//Returns the next item, going through the list in a depth-first manner
function TribesTVStudioMenuItem Iterate ()
{
	if (child != none)
		return child;
	if (next != none)
		return next;
	if (parent == none)
		return none;
	return parent.next;
}

DefaultProperties
{

}
