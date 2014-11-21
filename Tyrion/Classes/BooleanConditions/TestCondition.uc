//=====================================================================
// TestCondition
//=====================================================================

class TestCondition extends Core.Object implements IBooleanActionCondition;

//=====================================================================
// Functions

static function bool actionTest( ActionBase parent, NS_Action child )
{
	return true;
}

