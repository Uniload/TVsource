class EffectsSubsystem extends Engine.Actor
    native
    abstract;

var EffectsSystem EffectsSystem;                                //note: assigned after Spawn() returns, so not available in *BeginPlay()

var private config array<Name> EventResponse;            		//named in the singular for clarity of configuration file

var class EffectSpecificationSubClass;

var private bool debugSlow;                                     //if true, does some error checking that takes extra time

//native noexport variables (must come last)

var private native noexport const int EventResponses[5];        //Declared as a TMultiMap<FName, UEventResponse*> in AEffectsSystem.h
var private native noexport const int EffectSpecifications[5];  //Declared as a TMap<FName, UEffectSpecification*> in AEffectsSystem.h

simulated function PreBeginPlay()
{
    local EventResponse newEventResponse;
    local int i;

    Super.PreBeginPlay();

    for (i=0; i<EventResponse.length; ++i)
    {
        //instantiate event responses
        newEventResponse = new(self, string(EventResponse[i]), 0) class'EventResponse';

        //the special EventReseponse SourceClassName 'Level' means that all
        //  specifications referenced by the Response should automatically
        //  be instantiated for the Level specified by Event.
        if (newEventResponse.SourceClassName == 'Level')
        {
            if (Level.Label == newEventResponse.Event)
                InitializeResponseSpecifications(newEventResponse);
            
            //note that newEventResponse is not added to the EventResponses hash, since
            //  the EventResponse is not meant to ever match an EffectEvent.
        }
        else
        {
        //hook-up source & target classes.
        //
        //they're specified by names in the config files so that they will not be loaded
        //  just because they're the subject of events.  Thus we do a DynamicFindObject()
        //  and hook-up the classes only if they're already loaded for another purpose.

        newEventResponse.SourceClass =
            class<Actor>(
                    DynamicFindObject(
                        String(newEventResponse.SourceClassName),
                        class'Class'));

        //if the SourceClass is in this map, then this event could happen,
        //  so add it to the collection of EventResponses.
        if (newEventResponse.SourceClass != None)
        {
            //the hash key for EventResponses is ClassName+EventName, since these are the mandatory data members
            AddEventResponse(
                name(String(newEventResponse.SourceClassName)$String(newEventResponse.Event)), newEventResponse);

                newEventResponse.Init();
                InitializeResponseSpecifications(newEventResponse);
            }
        }
    }

	if (debugSlow)
	{
		log(name$" Initialized.  Statistics:");
//		log(name$" EventResponses -"); EventResponses.Profile();
//		log(name$" EffectSpecifications -"); EffectSpecifications.Profile();
	}
}

native function AddEventResponse(name EventResponseName, EventResponse EventResponse);

function InitializeResponseSpecifications(EventResponse EventResponse)
{
    local EffectSpecification newEffectSpecification;
    local int i;

    //instantiate the specifications referenced by this response,
    //  and add them to the collection of specifications.
    //(if the specification has already been instantiated, then just
    //  reference that instance.)
    for (i=0; i<EventResponse.Specification.length; ++i)
    {
        //a 'None' specification is valid, ie. there's a chance of doing nothing in response to the event
        if (EventResponse.Specification[i].SpecificationType != 'None')
        {
            //lookup to see if the specification has already been instantiated
            newEffectSpecification = FindEffectSpecification(EventResponse.Specification[i].SpecificationType);

            if (newEffectSpecification == None)     //not yet instantiated, so instantiate it
            {
#if IG_TRIBES3  //tcohen: Tribes prefers error messages in the log.
                // validate the class... warfare crashes out big time if its not valid
                if (class<EffectSpecification>(EventResponse.Specification[i].SpecificationClass) == None)
                {
                    Log("ERROR! EventResponse ["$EventResponse.Event$"] hooked up to invalid specification ["$EventResponse.Specification[i].SpecificationType$"]");
                    continue;
                }
#else     // TMC I prefer AssertWithDescription()s.
                AssertWithDescription(class<EffectSpecification>(EventResponse.Specification[i].SpecificationClass) != None,
                    "[tcohen] EffectsSubsystem::InitializeResponseSpecifications() The EventResponse "$EventResponse.name
                    $" lists specification #"$i
                    $" (base zero) as "$EventResponse.Specification[i].SpecificationType
                    $", but that's not a valid class of EffectSpecification.");
#endif

                newEffectSpecification = EffectSpecification(
                        new(self, string(EventResponse.Specification[i].SpecificationType), 0) EventResponse.Specification[i].SpecificationClass); 
                assert(newEffectSpecification!=None);
                newEffectSpecification.Init(self);

                //the hash key for EffectSpecifications is the EffectSpecification's name
                AddEffectSpecification(newEffectSpecification.name, newEffectSpecification);
            }

            EventResponse.SpecificationReference[i] = newEffectSpecification;
        }
    }
}

native function EffectSpecification FindEffectSpecification(name EffectSpecificationName);

native function AddEffectSpecification(name EffectSpecificationName, EffectSpecification EffectSpecification);

// See parameter documentation in Actor.uc TriggerEffectEvent()
native function bool EffectEventTriggered(
        Actor Source,
        name EffectEvent,
        optional Actor Target,
        optional Material TargetMaterial,
        optional vector overrideWorldLocation,
        optional rotator overrideWorldRotation,
        optional bool unTriggered, //only one EffectSpecification should be specified for EffectEvents that may be UnTriggered
        optional bool PlayOnTarget,
        optional bool QueryOnly,
        optional IEffectObserver Observer,
        optional name Tag);

simulated function EffectSpecification GetSpecificationByString(string Specification)
{
    return FindEffectSpecification(name(Specification));
}

// Should print the current state of the subsystem to the log (via Log()) in a
// human-readable form that is suitable for debugging.
simulated function LogState() 
{
    Log("LogState not implemented for subsystem: "$self);
}

simulated event Actor PlayEffectSpecification(
        EffectSpecification EffectSpec,
        Actor Source,
        optional Actor Target,
        optional Material TargetMaterial,
        optional vector overrideWorldLocation,
        optional rotator overrideWorldRotation,
        optional IEffectObserver Observer)
{ assert(false); return None; }  // must implement in subclass!!!

simulated event StopEffectSpecification(
        EffectSpecification EffectSpec,
        Actor Source);

simulated event OnEffectSpawned(Actor SpawnedEffect);

defaultproperties
{
    debugSlow=true
        bHidden=true
}
