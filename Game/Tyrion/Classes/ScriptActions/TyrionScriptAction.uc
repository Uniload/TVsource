class TyrionScriptAction extends Scripting.Action
	abstract;

event enumTyrionTargets(Engine.LevelInfo level, out Array<Name> s)
{
	local Actor a;
	
	ForEach level.AllActors(class'Actor', a)
		if ((Rook(a) != None || SquadInfo(a) != None) && a.label != '')
			s[s.Length] = a.label;
}