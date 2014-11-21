//=============================================================================
// Object: The base class all objects.
// This is a built-in Unreal class and it shouldn't be modified.
//=============================================================================
class Object
	native
	noexport;

#define IG_SHARED 1
#define IG_NATIVE_SIZE_CHECK 1
#define IG_UC_CONSTRUCTOR 1
#define IG_UC_ALLOCATOR 1
#define IG_UC_ACTOR_ALLOCATOR 1
#define IG_UC_THREADED 1
#define IG_UC_LATENT 1
#define IG_UC_LATENT_STACK_CLEANUP 1
#define IG_UC_CLASS_CONSTRUCTOR 1
#define IG_NOCOPY 1
#define IG_UC_FLAT_CATEGORIES 1
#define IG_R 1
#define IG_MOJO 1
#define WITH_KARMA 1
#define IG_SHADOWS 1
#define IG_BUMPMAP 1
#define IG_RENDERER 1
#define IG_SHADER 1
#define IG_MACROTEX 1
#define IG_FOG 1
#define IG_ACTOR_GROUPING 1
#define IG_ACTOR_LABEL 1
#define IG_EFFECTS 1
#define IG_FLUID_VOLUME 1
#define IG_SCRIPTING 1
#define IG_UDN_UTRACE_DEBUGGING 1
#define IG_GLOW 1
#define IG_DYNAMIC_SHADOW_DETAIL 1
#define IG_ZONECONSTRAINED_LIGHTS 1
#define IG_GUI_LAYOUT 1
#define IG_ACTOR_CONFIG 1
#define IG_ANIM_ADDITIVE_BLENDING 1
#define IG_EXTERNAL_CAMERAS 1
#define IG_DISABLE_UNREAL_ACTOR_SOUND_MANAGEMENT 1

// Define the following project-specific symbols to 0 so the script compiler 
// won't warn about undefined symbols. These MUST stay as 0 in the shared engine.
#define IG_TRIBES3 1
#define IG_SWAT 0

#define IG_TRIBES3_MOVEMENT 1
#define IG_TRIBES3_PHYSICS 1
#define IG_TRIBES3_STATICMESH_SOCKETS 1
#define IG_TRIBES3_ADMIN 1
#define IG_TRIBES3_TV 1
#define IG_TRIBES3_VOTING 1
#define IG_TRIBES3_CSIRO 0

#define IG_TRIBES3_E3 1

//=============================================================================
// UObject variables.

// Internal variables.
var native private const int ObjectInternal[6];


var(Object) native const editconst object Outer;
var native const int ObjectFlags;
var(Object) native const editconst name Name;
var native const editconst class Class;

//=============================================================================
// Unreal base structures.

// Object flags.
const RF_Transactional	= 0x00000001; // Supports editor undo/redo.
const RF_Public         = 0x00000004; // Can be referenced by external package files.
const RF_Transient      = 0x00004000; // Can't be saved or loaded.
const RF_NotForClient	= 0x00100000; // Don't load for game client.
const RF_NotForServer	= 0x00200000; // Don't load for game server.
const RF_NotForEdit		= 0x00400000; // Don't load for editor.
#if IG_SHARED // david: added unnamed objects - objects have no name entry in the hash
const RF_Unnamed		= 0x08000000; // object has no name or FName hash entry
#endif

#if IG_TRIBES3 // Ryan: import struct doesn't seem to work so making this global :(
struct GameSpyServerData
{
	var int gsServerId;
	var String gsIpAddress;
	var int gsPing;
	var bool gsLAN;
	var String gsMapName;
	var String gsNumPlayers;
	var String gsMaxPlayers;
	var String gsHostName;
	var String gsHostPort;
	var String gsGameType;
	var String gsGameVer;
	var String gsRequiresPassword;
	var String gsTeamOneName;
	var String gsTeamTwoName;
	var String gsTeamOneScore;
	var String gsTeamTwoScore;
	var String gsAdminName;
	var String gsAdminEmail;
	var String gsTrackingStats;
	var String gsMinVersion;
	var Array<String> gsPlayerNames;
	var Array<String> gsPlayerScores;
	var Array<String> gsPlayerPings;
	var Array<String> gsPlayerTeams;
};
#endif // IG

// A globally unique identifier.
struct Guid
{
	var int A, B, C, D;
};

// A point or direction vector in 3d space.
struct Vector
{
	var() config float X, Y, Z;
};

// A plane definition in 3d space.
struct Plane extends Vector
{
	var() config float W;
};

// An orthogonal rotation in 3d space.
struct Rotator
{
	var() config int Pitch, Yaw, Roll;
};

// An arbitrary coordinate system in 3d space.
struct Coords
{
	var() config vector Origin, XAxis, YAxis, ZAxis;
};

// Quaternion
struct Quat
{
	var() config float X, Y, Z, W;
};

// Used to generate random values between Min and Max
struct Range
{
	var() config float Min;
	var() config float Max;
};

#if IG_SHARED
// Used to generate random values between Min and Max
struct IntegerRange
{
	var() config int Min;
	var() config int Max;
};
#endif

// Vector of Ranges
struct RangeVector
{
	var() config range X;
	var() config range Y;
	var() config range Z;
};

// A scale and sheering.
struct Scale
{
	var() config vector Scale;
	var() config float SheerRate;
	var() config enum ESheerAxis
	{
		SHEER_None,
		SHEER_XY,
		SHEER_XZ,
		SHEER_YX,
		SHEER_YZ,
		SHEER_ZX,
		SHEER_ZY,
	} SheerAxis;
};

// Camera orientations for Matinee
enum ECamOrientation
{
	CAMORIENT_None,
	CAMORIENT_LookAtActor,
	CAMORIENT_FacePath,
	CAMORIENT_Interpolate,
	CAMORIENT_Dolly,
};

// Generic axis enum.
enum EAxis
{
	AXIS_X,
	AXIS_Y,
	AXIS_Z
};

// A color.
struct Color
{
	var() config byte B, G, R, A;
};

// A bounding box.
struct Box
{
	var vector Min, Max;
	var byte IsValid;
};

// A bounding box sphere together.
struct BoundingVolume extends Box
{
	var plane Sphere;
};

// a 4x4 matrix
struct Matrix
{
	var() Plane XPlane;
	var() Plane YPlane;
	var() Plane ZPlane;
	var() Plane WPlane;
};

// A interpolated function
struct InterpCurvePoint
{
	var() float InVal;
	var() float OutVal;
};

struct InterpCurve
{
	var() array<InterpCurvePoint>	Points;
};

struct CompressedPosition
{
	var vector Location;
	var rotator Rotation;
	var vector Velocity;
};

#if IG_TRIBES3 // Paul: Material Coordinates structure
struct native MatCoords
{
	var() config float U;
	var() config float V;
	var() config float UL;
	var() config float VL;
};
#endif

//=============================================================================
// Constants.

const MaxInt = 0x7fffffff;
const Pi     = 3.1415926535897932;

//=============================================================================
// Basic native operators and functions.

// Bool operators.
native(129) static final preoperator  bool  !  ( bool A );
native(242) static final operator(24) bool  == ( bool A, bool B );
native(243) static final operator(26) bool  != ( bool A, bool B );
native(130) static final operator(30) bool  && ( bool A, skip bool B );
native(131) static final operator(30) bool  ^^ ( bool A, bool B );
native(132) static final operator(32) bool  || ( bool A, skip bool B );

// Byte operators.
native(133) static final operator(34) byte *= ( out byte A, byte B );
native(134) static final operator(34) byte /= ( out byte A, byte B );
native(135) static final operator(34) byte += ( out byte A, byte B );
native(136) static final operator(34) byte -= ( out byte A, byte B );
native(137) static final preoperator  byte ++ ( out byte A );
native(138) static final preoperator  byte -- ( out byte A );
native(139) static final postoperator byte ++ ( out byte A );
native(140) static final postoperator byte -- ( out byte A );

// Integer operators.
native(141) static final preoperator  int  ~  ( int A );
native(143) static final preoperator  int  -  ( int A );
native(144) static final operator(16) int  *  ( int A, int B );
native(145) static final operator(16) int  /  ( int A, int B );
native(146) static final operator(20) int  +  ( int A, int B );
native(147) static final operator(20) int  -  ( int A, int B );
native(148) static final operator(22) int  << ( int A, int B );
native(149) static final operator(22) int  >> ( int A, int B );
native(196) static final operator(22) int  >>>( int A, int B );
native(150) static final operator(24) bool <  ( int A, int B );
native(151) static final operator(24) bool >  ( int A, int B );
native(152) static final operator(24) bool <= ( int A, int B );
native(153) static final operator(24) bool >= ( int A, int B );
native(154) static final operator(24) bool == ( int A, int B );
native(155) static final operator(26) bool != ( int A, int B );
native(156) static final operator(28) int  &  ( int A, int B );
native(157) static final operator(28) int  ^  ( int A, int B );
native(158) static final operator(28) int  |  ( int A, int B );
native(159) static final operator(34) int  *= ( out int A, float B );
native(160) static final operator(34) int  /= ( out int A, float B );
native(161) static final operator(34) int  += ( out int A, int B );
native(162) static final operator(34) int  -= ( out int A, int B );
native(163) static final preoperator  int  ++ ( out int A );
native(164) static final preoperator  int  -- ( out int A );
native(165) static final postoperator int  ++ ( out int A );
native(166) static final postoperator int  -- ( out int A );

// Integer functions.
native(167) static final Function     int  Rand  ( int Max );
native(249) static final function     int  Min   ( int A, int B );
native(250) static final function     int  Max   ( int A, int B );
native(251) static final function     int  Clamp ( int V, int A, int B );

// Float operators.
native(169) static final preoperator  float -  ( float A );
native(170) static final operator(12) float ** ( float A, float B );
native(171) static final operator(16) float *  ( float A, float B );
native(172) static final operator(16) float /  ( float A, float B );
native(173) static final operator(18) float %  ( float A, float B );
native(174) static final operator(20) float +  ( float A, float B );
native(175) static final operator(20) float -  ( float A, float B );
native(176) static final operator(24) bool  <  ( float A, float B );
native(177) static final operator(24) bool  >  ( float A, float B );
native(178) static final operator(24) bool  <= ( float A, float B );
native(179) static final operator(24) bool  >= ( float A, float B );
native(180) static final operator(24) bool  == ( float A, float B );
native(210) static final operator(24) bool  ~= ( float A, float B );
native(181) static final operator(26) bool  != ( float A, float B );
native(182) static final operator(34) float *= ( out float A, float B );
native(183) static final operator(34) float /= ( out float A, float B );
native(184) static final operator(34) float += ( out float A, float B );
native(185) static final operator(34) float -= ( out float A, float B );

// Float functions.
native(186) static final function     float Abs   ( float A );
native(187) static final function     float Sin   ( float A );
native      static final function	  float Asin  ( float A );
native(188) static final function     float Cos   ( float A );
native      static final function     float Acos  ( float A );
native(189) static final function     float Tan   ( float A );
native(190) static final function     float Atan  ( float A, float B ); 
native(191) static final function     float Exp   ( float A );
native(192) static final function     float Loge  ( float A );
native(193) static final function     float Sqrt  ( float A );
native(194) static final function     float Square( float A );
native(195) static final function     float FRand ();
native(244) static final function     float FMin  ( float A, float B );
native(245) static final function     float FMax  ( float A, float B );
native(246) static final function     float FClamp( float V, float A, float B );
native(247) static final function     float Lerp  ( float Alpha, float A, float B );
native(248) static final function     float Smerp ( float Alpha, float A, float B );

// Vector operators.
native(211) static final preoperator  vector -     ( vector A );
native(212) static final operator(16) vector *     ( vector A, float B );
native(213) static final operator(16) vector *     ( float A, vector B );
native(296) static final operator(16) vector *     ( vector A, vector B );
native(214) static final operator(16) vector /     ( vector A, float B );
native(215) static final operator(20) vector +     ( vector A, vector B );
native(216) static final operator(20) vector -     ( vector A, vector B );
native(275) static final operator(22) vector <<    ( vector A, rotator B );
native(276) static final operator(22) vector >>    ( vector A, rotator B );
native(217) static final operator(24) bool   ==    ( vector A, vector B );
native(218) static final operator(26) bool   !=    ( vector A, vector B );
native(219) static final operator(16) float  Dot   ( vector A, vector B );
native(220) static final operator(16) vector Cross ( vector A, vector B );
native(221) static final operator(34) vector *=    ( out vector A, float B );
native(297) static final operator(34) vector *=    ( out vector A, vector B );
native(222) static final operator(34) vector /=    ( out vector A, float B );
native(223) static final operator(34) vector +=    ( out vector A, vector B );
native(224) static final operator(34) vector -=    ( out vector A, vector B );

// Vector functions.
native(225) static final function float  VSize  ( vector A );
native(226) static final function vector Normal ( vector A );
native(227) static final function        Invert ( out vector X, out vector Y, out vector Z );
native(252) static final function vector VRand  ( );
native(300) static final function vector MirrorVectorByNormal( vector Vect, vector Normal );
#if IG_SHARED
// marc: additional vector convenience functions
native(228) static final function float	 VSize2D( vector A );
native		static final function float  VSizeSquared( vector A );
native		static final function float  VSizeSquared2D( vector A );
native		static final function bool	 IsZero( vector A );
native		static final function bool	 IsNearlyZero( vector A );
// darren: distance and distance squared functions
native      static final function float  VDist( vector A, vector B );
native      static final function float  VDistSquared( vector A, vector B );
#endif

// Rotator operators and functions.
native(142) static final operator(24) bool ==     ( rotator A, rotator B );
native(203) static final operator(26) bool !=     ( rotator A, rotator B );
native(287) static final operator(16) rotator *   ( rotator A, float    B );
native(288) static final operator(16) rotator *   ( float    A, rotator B );
native(289) static final operator(16) rotator /   ( rotator A, float    B );
native(290) static final operator(34) rotator *=  ( out rotator A, float B  );
native(291) static final operator(34) rotator /=  ( out rotator A, float B  );
native(316) static final operator(20) rotator +   ( rotator A, rotator B );
native(317) static final operator(20) rotator -   ( rotator A, rotator B );
native(318) static final operator(34) rotator +=  ( out rotator A, rotator B );
native(319) static final operator(34) rotator -=  ( out rotator A, rotator B );
native(229) static final function GetAxes         ( rotator A, out vector X, out vector Y, out vector Z );
native(230) static final function GetUnAxes       ( rotator A, out vector X, out vector Y, out vector Z );
native(320) static final function rotator RotRand ( optional bool bRoll );
native      static final function rotator OrthoRotation( vector X, vector Y, vector Z );
native      static final function rotator Normalize( rotator Rot );
native		static final operator(24) bool ClockwiseFrom( int A, int B );

#if IG_SHARED // rotator inverse function [crombie]
native		static final function rotator Inverse  ( rotator A );
#endif

// String operators.
//  Convert-to-string operators
native(112) static final operator(40) string $  ( coerce string A, coerce string B );
native(168) static final operator(40) string @  ( coerce string A, coerce string B );
//  Case-sensitive string comparisons (equivalent to appStrcmp operations)
native(115) static final operator(24) bool   <  ( string A, string B );
native(116) static final operator(24) bool   >  ( string A, string B );
native(120) static final operator(24) bool   <= ( string A, string B );
native(121) static final operator(24) bool   >= ( string A, string B );
native(122) static final operator(24) bool   == ( string A, string B );
native(123) static final operator(26) bool   != ( string A, string B );
//  Case-INSENSITIVE string comparison '~=' (equivalent to appStricmp)
native(124) static final operator(24) bool   ~= ( string A, string B );

#if IG_TRIBES3	// michaelj:  Additional string operators from UT2004
native(322) static final operator(44) string $= ( out string A, coerce string B );
native(323) static final operator(44) string @= ( out string A, coerce string B );
native(324) static final operator(45) string -= ( out string A, coerce string B );
#endif

// String functions.
native(125) static final function int    Len    ( coerce string S );
native(126) static final function int    InStr  ( coerce string S, coerce string t );
native(127) static final function string Mid    ( coerce string S, int i, optional int j );
native(128) static final function string Left   ( coerce string S, int i );
native(234) static final function string Right  ( coerce string S, int i );
native(235) static final function string Caps   ( coerce string S );
native(236) static final function string Chr    ( int i );
native(237) static final function int    Asc    ( string S );
#if IG_TRIBES3	// michaelj:  Additional string functions from UT2004
native(201)  static final function int    StrCmp ( coerce string S, coerce string T, optional int Count, optional bool bCaseSensitive );
native(202)  static final function string Repl	( coerce string Src, coerce string Match, coerce string With, optional bool bCaseSensitive );
native(204)  static final function string Eval   ( bool Condition, coerce string ResultIfTrue, coerce string ResultIfFalse );
native(238) static final function string Locs	( coerce string S);
native(239) static final function bool   Div ( coerce string Src, string Divider, out string LeftPart, out string RightPart);
#endif
#if IG_TRIBES3 // dbeswick: more useful string functions
static final function bool IsValidForURL(coerce string S)
{
	local int i;
	local string c;

	for (i = 0; i < Len(S); i++)
	{
		c = Mid(S, i, 1);
		if (c == "%" ||
			c == "$" ||
			c == "&" ||
			c == "'" ||
			c == "*" ||
			c == "+" ||
			c == "," ||
			c == "." ||
			c == "/" ||
			c == ":" ||
			c == ";" ||
			c == "=" ||
			c == "?" ||
			c == "@" ||
			c == " " ||
			c == "\"" ||
			c == "<" ||
			c == ">" ||
			c == "#" ||
			c == "{" ||
			c == "}" ||
			c == "|" ||
			c == "\\" ||
			c == "^" ||
			c == "~" ||
			c == "[" ||
			c == "]" ||
			c == "`")
		return false;
	}

	return true;
}

static final function string EncodeForURL(coerce string S)
{
	// must handle '%' first
	S = Repl(S, "%", "%25");
	S = Repl(S, "$", "%24");
	S = Repl(S, "&", "%26");
	S = Repl(S, "'", "%27");
	S = Repl(S, "*", "%2A");
	S = Repl(S, "+", "%2B");
	S = Repl(S, ",", "%2C");
	S = Repl(S, ".", "%2E");
	S = Repl(S, "/", "%2F");
	S = Repl(S, ":", "%3A");
	S = Repl(S, ";", "%3B");
	S = Repl(S, "=", "%3D");
	S = Repl(S, "?", "%3F");
	S = Repl(S, "@", "%40");
	S = Repl(S, " ", "%20");
	S = Repl(S, "\"", "%22");
	S = Repl(S, "<", "%3C");
	S = Repl(S, ">", "%3E");
	S = Repl(S, "#", "%23");
	S = Repl(S, "{", "%7B");
	S = Repl(S, "}", "%7D");
	S = Repl(S, "|", "%7C");
	S = Repl(S, "\\", "%5C");
	S = Repl(S, "^", "%5E");
	S = Repl(S, "~", "%7F");
	S = Repl(S, "[", "%5B");
	S = Repl(S, "]", "%5D");
	S = Repl(S, "`", "%60");

	return S;
}

static final function string DecodeFromURL(coerce string S)
{
	S = Repl(S, "%24", "$");
	S = Repl(S, "%26", "&");
	S = Repl(S, "%27", "'");
	S = Repl(S, "%2A", "*");
	S = Repl(S, "%2B", "+");
	S = Repl(S, "%2C", ",");
	S = Repl(S, "%2E", ".");
	S = Repl(S, "%2F", "/");
	S = Repl(S, "%3A", ":");
	S = Repl(S, "%3B", ";");
	S = Repl(S, "%3D", "=");
	S = Repl(S, "%3F", "?");
	S = Repl(S, "%40", "@");
	S = Repl(S, "%20", " ");
	S = Repl(S, "%22", "\"");
	S = Repl(S, "%3C", "<");
	S = Repl(S, "%3E", ">");
	S = Repl(S, "%23", "#");
	S = Repl(S, "%7B", "{");
	S = Repl(S, "%7D", "}");
	S = Repl(S, "%7C", "|");
	S = Repl(S, "%5C", "\\");
	S = Repl(S, "%5E", "^");
	S = Repl(S, "%7F", "~");
	S = Repl(S, "%5B", "[");
	S = Repl(S, "%5D", "]");
	S = Repl(S, "%60", "`");
	// must handle '%' last
	S = Repl(S, "%25", "%");

	return S;
}

static final function bool HasUnicode(coerce string S);
#endif


#if IG_TRIBES3_ADMIN    // glenn: admin support - split
native(400) static final function int    Split  ( coerce string Src, string Divider, out array<string> Parts );
#endif

// Object operators.
native(114) static final operator(24) bool == ( Object A, Object B );
native(119) static final operator(26) bool != ( Object A, Object B );

// Name operators.
native(254) static final operator(24) bool == ( name A, name B );
native(255) static final operator(26) bool != ( name A, name B );

// InterpCurve operator
native		static final function float InterpCurveEval( InterpCurve curve, float input );
native		static final function InterpCurveGetOutputRange( InterpCurve curve, out float min, out float max );
native		static final function InterpCurveGetInputDomain( InterpCurve curve, out float min, out float max );

// Quaternion functions
native		static final function Quat QuatProduct( Quat A, Quat B );
native		static final function Quat QuatInvert( Quat A );
native		static final function vector QuatRotateVector( Quat A, vector B );
native		static final function Quat QuatFindBetween( Vector A, Vector B );
native		static final function Quat QuatFromAxisAndAngle( Vector Axis, Float Angle );
native		static final function Quat QuatFromRotator( rotator A );
native		static final function rotator QuatToRotator( Quat A );

//=============================================================================
// General functions.

#if IG_UC_ALLOCATOR // karl: Added Allocator
// Called by new operator (on the default object of a particular class).  
// Allocates and returns an object of that class.
native static function Object Allocate( Object Context,				// auto parameter, calling object
										optional Object Outer,		// override outer object
										optional string n,			// override name of new object
										optional INT flags,			// flags for new object
										optional Object Template	// copy from this object
										 );
#endif

// Logging.
native(231) final static function Log( coerce string S, optional name Tag );
#if IG_SHARED
// Writes the stack of guard/unguard blocks to the log file.
// IG_LOG_GUARD_STACK must be enabled in IrrationalBuild.h [darren]
native final static function LogGuardStack();
#endif
native(232) final static function Warn( coerce string S );
native static function string Localize( string SectionName, string KeyName, string PackageName );
#if IG_SCRIPTING // Ryan: Separate log for scripting logs
native static function bool CanSLog();
native static function SLog(coerce string msg);
#endif // IG

#if IG_UDN_UTRACE_DEBUGGING // ckline: UDN UTrace code
native static final function SetUTracing( bool bNewUTracing );
native static final function bool IsUTracing();
#endif 

// Goto state and label.
native(113) final function GotoState( optional name NewState, optional name Label );
native(281) final function bool IsInState( name TestState );
native(284) final function name GetStateName();

#if IG_UC_THREADED // karl: Moved sleep to Object
native(256) final latent function Sleep( float Seconds );
#endif

// Objects.
native(258) static final function bool ClassIsChildOf( class TestClass, class ParentClass );
native(303) final function bool IsA( name ClassName );
#if IG_SHARED
native static final function class CommonBase(Array<class> classes);
#endif // IG

// Probe messages.
native(117) final function Enable( name ProbeFunc );
native(118) final function Disable( name ProbeFunc );

// Properties.
#if IG_SHARED // david: Get field names from a class
// Includes properties for super classes up to but not including "TerminatingSuperClass"
// 'None' returns all properties including those in class "Object"
native final iterator function AllProperties ( class FromClass, class TerminatingSuperClass, out Name PropName, optional out string PropType );
native final iterator function AllEditableProperties ( class FromClass, class TerminatingSuperClass, out Name PropName, optional out string PropType );
#endif
#if IG_SHARED // david: Get all classes of a given type 
// Gets all classes of a given type 
// Specify 'None' to return all registered classes
native final iterator function AllClasses ( class BaseClass, out class OutClass );
#endif
native final function string GetPropertyText( string PropName );
native final function SetPropertyText( string PropName, string PropValue );
native static final function name GetEnum( object E, int i );
native static final function object DynamicLoadObject( string ObjectName, class ObjectClass, optional bool MayFail );
#if IG_SHARED // david: Optional outer to find object in
native static final function object FindObject( string ObjectName, class ObjectClass, optional Object Outer );
#else
native static final function object FindObject( string ObjectName, class ObjectClass);
#endif

// Configuration.
native(536) final function SaveConfig(
#if IG_ACTOR_CONFIG || IG_GUI_LAYOUT //dkaplan - Update to allow config file and config section to be explicitly set 
			optional string OverrideSectionName, optional string FileName
#endif
#if IG_SHARED // ckline
			, optional bool FlushToDisk // ckline: default = 1; if set to 0 .ini will not be written to disk (needed to speed up GUI Editor)
			, optional bool bDoNotSaveDefaults // dkaplan: default = 0; if set to 1 .ini will not write out properties which differ from the defaults
#endif
			);

native static final function StaticSaveConfig();

native static final function ResetConfig( 
#if IG_ACTOR_CONFIG //no section header override if this is not defined
			optional string OverrideName, optional string FileName
#endif
			);

#if IG_SHARED // ckline: FlushConfig will force all .ini files in memory to be written to disk. Useful to call after making many calls to SaveConfig(..., FlushToDisk=0)
native final function FlushConfig();
#endif

// Return a random number within the given range.
native final function float RandRange( float Min, float Max );

#if IG_UC_CONSTRUCTOR // karl: Added constructors
overloaded function Construct();
#endif

#if IG_SHARED	// rowan: so we can call app seconds in script
native final function float AppSeconds();
#endif

#if IG_SHARED	// marc/ryan: for save games: NULL out all actor references
native final function NullReferences();
#endif

//=============================================================================
// Engine notification functions.

//
// Called immediately when entering a state, while within
// the GotoState call that caused the state change.
//
event BeginState();

//
// Called immediately before going out of the current state,
// while within the GotoState call that caused the state change.
// 
event EndState();

#if IG_UC_CLASS_CONSTRUCTOR // karl: Added class constructor
// This function is reponsible for initializing the properties of classes at compile time.
// this function is called at compile time, after compilation of the package
// and after legacy default properties are processed.
// Note: Do not call super.ClassConstruct(), this is done automatically due to
//	legacy considerations
function ClassConstruct()
{
}
#endif

#if IG_SHARED
native static final function AssertWithDescription(bool expression, string description);
native static final function object DynamicFindObject( string ObjectName, class ObjectClass );
native static final function Class GetSuperClass(Class derived);
native static final function int Hash(string Key, optional int Mod);
#endif

#if IG_TRIBES3 // david: replaceStr: simple token substitution
// 'replaceStr' will replace the tokens %1, %2, %3, %4, %5 in the input string with the
// values of the respective parameters
static function string replaceStr(coerce string input, optional coerce string p1, optional coerce string p2, optional coerce string p3, optional coerce string p4, optional coerce string p5)
{
	local int i, found;
	local string replacement;

	for (i = 1; i <= 5; i++)
	{
		switch (i)
		{
		case 1:	replacement = p1; break;
		case 2:	replacement = p2; break;
		case 3:	replacement = p3; break;
		case 4:	replacement = p4; break;
		case 5:	replacement = p5; break;
		}

		found = InStr(input, "%" $ i);
		if (found != -1)
		{
			input = Left(input, found) $ replacement $ Mid(input, found + 2);
		}
	}

	return input;
}
#endif

#if IG_TRIBES3 // Ryan: Get the build number
native static final function String GetBuildNumber();
native static final function String GetMinCompatibleBuildNumber();
#endif

defaultproperties
{
}
