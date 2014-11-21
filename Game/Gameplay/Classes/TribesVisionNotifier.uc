///////////////////////////////////////////////////////////////////////////////
// VisionNotifier.uc - VisionNotifier class
// The VisionNotifier notifies all registered clients when the Viewer sees or no longer sees another Pawn
// Clients of the VisionNotifier are stored in the NotificationList, and should be registered through the Pawn

class TribesVisionNotifier extends AICommon.VisionNotifier
	native;

//=====================================================================
// Constants

//=====================================================================
// Variables

//=====================================================================
// Functions

// returns true if the specified pawn can currently be seen by anyone on his squad
native function bool isVisible(Pawn TestPawn);

// returns true if the specified pawn has LOS from *this* viewer
native function bool isLocallyVisible(Pawn TestPawn);

protected native function RemoveAnyReferencesToPawn(Pawn PawnBeingRemoved);

// returns seenList
native function array<Rook> getSeenList();

// returns a list of currently seen enemies
native function array<Rook> getEnemyList();
