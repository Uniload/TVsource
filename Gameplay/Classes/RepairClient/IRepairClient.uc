interface IRepairClient;

function onTendrilCreate(RepairTendril t);

function bool canRepair(Rook r);

function float getRepairRadius();

function Pawn getFXOriginActor();

function Vector getFXTendrilOrigin(Vector targetPos);

function Vector getFXTendrilTarget(Actor target);

function beginRepair(Rook r);

function endRepair(Rook r);