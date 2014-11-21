//=============================================================================
// Emitter: An Unreal Spark Particle Emitter.
//=============================================================================
class SparkEmitter extends ParticleEmitter
	native;

struct ParticleSparkData
{
	var	float	TimeBeforeVisible;
	var float	TimeBetweenSegments;
	var vector	StartLocation;
	var vector	StartVelocity;
};

var (Spark)			Range						LineSegmentsRange;
var (Spark)			Range						TimeBeforeVisibleRange;
var (Spark)			Range						TimeBetweenSegmentsRange;

var transient		array<ParticleSparkData>	SparkData;
var transient		vertexbuffer				VertexBuffer;
var transient		indexbuffer					IndexBuffer;
var transient		int							NumSegments;
var transient		int							VerticesPerParticle;
var transient		int							IndicesPerParticle;
var transient		int							PrimitivesPerParticle;

defaultproperties
{
     LineSegmentsRange=(Min=5.000000,Max=5.000000)
}
