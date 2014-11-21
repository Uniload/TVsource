//******************************************************************************
//* AnnouncerHandler 0.2 by Cactusbone
//* 13 november 2004
//*
//* This allows classes to register to myAnnouncer to get messages, and while
//* registering to say if they should still display.
//******************************************************************************
interface AnnouncerHandler
          dependsOn(myAnnouncer);

import enum EStatus from myAnnouncer;
import enum EType from myAnnouncer;
import enum ESide from myAnnouncer;

function getMessage(EType type, ESide side, EStatus status, ClientSideCharacter c);
function TeamChanged(ClientSideCharacter c);

defaultproperties
{
}
