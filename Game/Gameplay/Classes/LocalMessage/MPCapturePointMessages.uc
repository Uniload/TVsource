class MPCapturePointMessages extends TribesLocalMessage;

var localized string cantCaptureWhenNotHome;

static function string GetString(
	optional int Switch,
	optional Core.Object Related1, 
	optional Core.Object Related2,
	optional Object OptionalObject,
	optional String OptionalString
	)
{
	switch (Switch)
	{
		case 1:	return default.cantCaptureWhenNotHome;
			break;
	}
}

defaultproperties
{
	announcements(0)=(effectEvent=CapturableCaptured,speechTag=FLGCAPTURED,debugString="%1 captured a flag.")

	cantCaptureWhenNotHome = "You can't capture when your flag isn't home."
}