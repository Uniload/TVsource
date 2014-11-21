class MessagePreDrawHUD extends Engine.Message;

var DefaultHUD	hud;
var Canvas		canvas;


// construct
overloaded function construct(DefaultHUD _hud, Canvas _Canvas)
{
	hud = _hud;
	canvas = _canvas;
}

static function string editorDisplay(Name triggeredBy, Message filter)
{
	return "";
}

defaultproperties
{
}
