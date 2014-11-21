ucsearch is a simple utility to search for text within Tribes: Vengeance .uc source code files. 

------------------------------------------------------------------------------ 


Extract ucsearchHome.exe and Utility.dll to the Tribes Vengeance Source directory 

Run ucsearchHome.exe 

Select Exercises - Grep from the menu 

Change the path to point to your T:V source directory. It will crash if this is incorrect. 
Note - default path on each load is E:\Program Files\VUGames\Tribes Vengeance\source\ 

Enter your search criteria and press Go 

Results are displayed listing the full path with name of uc file, location of line of code(@"line number" ==>) and the line of text it found 


an example result for "carrier" 


E:\Program Files\VUGames\Tribes Vengeance\source\Game\Gameplay\Classes\MPActor\MPCarryable.uc@380 ==> if (carrierKillStat != None && 

ModeInfo(Level.Game) != None && carrierController != Killer 


This tells us the path where to find the .uc file, in this case MPCarryable.uc and location is @380, line 380. You can then open this .uc in 

your editor and view the surrounding code/functions etc