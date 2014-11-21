class TribesWebQueryHandler extends Engine.TribesAdminBase;

var TribesServerAdmin Owner;

var string DefaultPage;
var string Title;
var string NeededPrivs;

function bool Init(TribesServerAdmin owner) 
{ 
    self.Owner = owner;
    return true;
}

function bool Query(WebRequest Request, WebResponse Response) 
{ 
    return false; 
}
