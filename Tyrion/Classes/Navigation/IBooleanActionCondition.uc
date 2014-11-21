//=====================================================================
// IBooleanActionCondition
//
// Defines a function called 'actionTest' that can be "passed in" to
// script functions by passing in a class that implements this interface
//=====================================================================

interface IBooleanActionCondition;

//=====================================================================
// Functions

static function bool actionTest( ActionBase parent, NS_Action child );

