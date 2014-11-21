//=====================================================================
// IFollowFunction
//
// Defines a function called 'offset' that can be "passed in" to
// script functions by passing in a class that implements this interface
//=====================================================================

interface IFollowFunction;

//=====================================================================
// Functions

// should offset be updated?
function bool updateOffset( Pawn follower, Pawn leader, int positionIndex );

// offset from leader pawn to actual location follower wants to go to
function Vector offset( Pawn leader, int positionIndex );

// is a given location a valid place to follow to?
function bool validDestination( Vector point );

// how close do you want to get to the target?
function float proximityFunction();
