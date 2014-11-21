// Actor class that can be used to enable a TsAction to receive events
class MessageRouter extends Engine.Info;

var transient TsAction			target;


function Set(TsAction _target, class<Message> msgClass, string triggeredByFilter)
{
	target = _target;

	registerMessage(msgClass, triggeredByFilter);
}

function onMessage(Message msg)
{
	target.Message(msg);
}