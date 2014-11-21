class SimpleCommandlet extends Commandlet;

var int intparm;

function int TestFunction()
{
	return 666;
}

function int Main( string Parms )
{
	local int temp;
	local float floattemp;
	local string textstring;
	local string otherstring;

	Log("Simple commandlet says hi.");
	Log("Testing function calling.");
	temp = TestFunction();
	Log("Function call returned" @ temp);
	Log("Testing cast to int.");
	floattemp = 3.0;
	temp = int(floattemp);
	Log("Temp is cast from "$floattemp$" to "$temp);
	Log("Testing min()");
	temp = Min(32, TestFunction());
	Log("Temp is min(32, 666): "$temp);
	textstring = "wookie";
	Log("3 is a "$Left(textstring, 3));
	otherstring = "skywalker";
	otherstring = Mid( otherstring, InStr( otherstring, "a" ) );
	Log("otherstring:" @ otherstring);
	return 0;
}

defaultproperties
{
     HelpCmd="Simple"
     HelpOneLiner="Simple test commandlet"
     HelpUsage="Simple (no parameters)"
}
