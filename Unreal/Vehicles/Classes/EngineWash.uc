class EngineWash extends Engine.Emitter;

function SetStrength(float washdist)
{
	if ( WashDist > 800 )
	{
		Emitters[0].LifeTimeRange.Min = Max(0.2, Emitters[0].Default.LifeTimeRange.Min * (WashDist-800)/1200);
		Emitters[0].LifeTimeRange.Max = Max(0.2, Emitters[0].Default.LifeTimeRange.Max * (WashDist-800)/1200);
	}
	else
	{
		Emitters[0].LifeTimeRange.Min = Emitters[0].Default.LifeTimeRange.Min;
		Emitters[0].LifeTimeRange.Max = Emitters[0].Default.LifeTimeRange.Max;
	}
}

defaultproperties
{
 	Physics=PHYS_None
	bNoDelete=false
    Begin Object Class=SpriteEmitter Name=SpriteEmitter3
		SecondsBeforeInactive=0
        Acceleration=(Z=50.000000)
        UseColorScale=True
        ColorScale(0)=(Color=(B=153,G=193,R=213,A=255))
        ColorScale(1)=(RelativeTime=1.000000,Color=(B=153,G=193,R=213,A=255))
        FadeOutStartTime=1.200000
        FadeOut=True
        FadeInEndTime=0.300000
        FadeIn=True
        MaxParticles=200
        ResetAfterChange=True
        StartLocationShape=PTLS_Polar
        StartLocationPolarRange=(X=(Min=-5.000000,Max=5.000000),Y=(Max=360.000000),Z=(Min=-20.000000,Max=-20.000000))
        AlphaRef=5
        UseRotationFrom=PTRS_Offset
        SpinParticles=True
        RotationOffset=(Roll=-16384)
        SpinsPerSecondRange=(X=(Min=-0.250000,Max=0.250000),Y=(Min=-0.250000,Max=0.250000))
        StartSpinRange=(X=(Min=-0.500000,Max=0.500000),Y=(Min=-0.500000,Max=0.500000),Z=(Min=-0.500000,Max=0.500000))
        UseSizeScale=True
        UseRegularSizeScale=False
        SizeScale(1)=(RelativeTime=0.250000,RelativeSize=1.000000)
        SizeScale(2)=(RelativeTime=1.000000,RelativeSize=3.000000)
        StartSizeRange=(X=(Min=50.000000,Max=50.000000),Y=(Min=50.000000,Max=50.000000),Z=(Min=50.000000,Max=50.000000))
        UniformSize=True
        DrawStyle=PTDS_AlphaBlend
        Texture=Texture'jm-particl2.Particles.jm-explo5'
        TextureUSubdivisions=3
        TextureVSubdivisions=3
        BlendBetweenSubdivisions=True
        LifetimeRange=(Min=2.000000,Max=2.000000)
        StartVelocityRadialRange=(Min=-250.000000,Max=-250.000000)
        VelocityLossRange=(X=(Max=1.000000),Y=(Max=1.000000))
        GetVelocityDirectionFrom=PTVD_AddRadial
        Name="SpriteEmitter3"
    End Object
    Emitters(0)=SpriteEmitter'SpriteEmitter3'
}

 