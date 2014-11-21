class xUtil extends Core.Object
    native;

struct native MutatorRecord
{
    var() string            ClassName;
    var() class<Mutator>    MutClass; //not filled in by GetMutatorList()
    var() string            GroupName;
    var() localized string  FriendlyName;
    var() localized string  Description;
    var() byte              bActivated;
};

var() private const transient CacheMutators     CachedMutatorList;

native(573) final simulated static function GetMutatorList(out array<MutatorRecord> MutatorRecords);
