//-----------------------------------------------------------
//
//-----------------------------------------------------------
class posSaver extends Engine.Pawn;

var vector pos_container[500];
var rotator rot_container[500];
var int pos_container_count;

// zum speichern/laden fuer UT04 Version notwendig
function get_pos_container(int i, out vector v1)
{
v1=pos_container[i];
}
function set_pos_container(vector v1, int i)
{
pos_container[i]=v1;
}

function get_rot_container(int i, out rotator r1)
{
r1=rot_container[i];
}
function set_rot_container(rotator r1, int i)
{
rot_container[i]=r1;
}

defaultproperties
{
     bAlwaysTick=True
}
