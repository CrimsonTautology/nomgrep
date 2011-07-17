/**
 * vim: set ts=4 :
 * =============================================================================
 * SourceMod Nomination Grep Plugin
 * Nominate a map from a menu generated by a given search key //or regular expression//dream on
 *
 *
 * This is my first plugin so if you see me doing anything increadilby stupid please
 * find me and yell at me loudly.
 * =============================================================================
 *
 *
 */

#include <sourcemod>
#include <mapchooser>

#pragma semicolon 1

public Plugin:myinfo =
{
	name = "Nomination Grep",
	author = "Billehs",
	description = "Provides Map Nominations based on a given search key",
	url = "https://bitbucket.org/CrimsonTautology/nomgrep"
};


#define MAPSEARCH_FOUND (1<<0)
#define MAPSEARCH_FOUND_ONE (1<<1)
#define MAPSEARCH_FOUND_NONE (1<<2)

new Handle:g_MapList = INVALID_HANDLE;
new g_mapFileSerial = -1;

public OnPluginStart()
{
	LoadTranslations("common.phrases");
	LoadTranslations("nominations.phrases");

	new arraySize = ByteCountToCells(33);	
	g_MapList = CreateArray(arraySize);

	RegConsoleCmd("sm_nomsearch", Command_Nomgrep);
	RegConsoleCmd("sm_nomgrep", Command_Nomgrep);
}

/** OnConfigsExecuted
 * Here until I figure out how to use nominations's g_maplist/menu
 * Read from maplist.cfg to build a map list
 */
public OnConfigsExecuted()
{
	if (ReadMapList(g_MapList,
					g_mapFileSerial,
					"nominations",
					MAPLIST_FLAG_CLEARARRAY|MAPLIST_FLAG_MAPSFOLDER)
		== INVALID_HANDLE)
	{
		if (g_mapFileSerial == -1) {
			SetFailState("Unable to create a valid map list.");
		}
	}
}


public Action:Command_Nomgrep(client, args){
	if (!client) {
		return Plugin_Handled;
	}
	
	if (args == 0) {
		ReplyToCommand(client, "[SM] Incorrect Syntax:  !nomsearch <searchstring>");
		return Plugin_Handled;
	}
	
	decl String:searchKey[64];
	GetCmdArg(1, searchKey, sizeof(searchKey));
	
	
	new result = mapSearch(client, searchKey, g_MapList);
	
	//If no matches were found
	if (result == MAPSEARCH_FOUND_NONE) {
		ReplyToCommand(client, "[SM] No maps were found matching '%s'", searchKey);
		return Plugin_Handled;	
	}
	
	return Plugin_Continue;	
}

/** 
 * Call Nomination's Handler_MapSelectMenu and get it's return value
 */
public nominationSelectMenuHandle(Handle:menu, MenuAction:action, param1, param2) {
	new Handle:nominations = FindPluginByFile("nominations.smx");
	new Function:Handler_MapSelectMenu = GetFunctionByName(nominations, "Handler_MapSelectMenu");

	decl result;

	// Start function call
	Call_StartFunction(nominations, Handler_MapSelectMenu);

	// Push parameters one at a time
	Call_PushCell(menu);
	Call_PushCell(action);
	Call_PushCell(param1);
	Call_PushCell(param2);

	// Finish the call, get the result
	Call_Finish(result);

	return result;
}

/** mapSearch
 * Perform a search for maps that contain a string searchKey in a given mapList
 */
public mapSearch(client, String:searchKey[64], Handle:mapList){
	new String:map[64];

	//Create a handle to nominations's menu creation function
	new Handle:mapSearchedMenu =CreateMenu(nominationSelectMenuHandle, MENU_ACTIONS_DEFAULT|MenuAction_DrawItem|MenuAction_DisplayItem);
	
	//Compile a regular expression from our searchKey
	//new Handle:searchRegex = CompileRegex(searchKey);
	

	//Loop through each item in the map list
	for (new i = 0; i < GetArraySize(g_MapList); i++) {
		GetArrayString(mapList, i, map, sizeof(map));

		//If this map matches the search key, add it to the menu
		if(StrContains(map, searchKey, true) >= 0){
			AddMenuItem(mapSearchedMenu, map, map);
		}
	}


	//If no maps were found don't even bother displaying a menu
	if(GetMenuItemCount(mapSearchedMenu) <=0){
		return MAPSEARCH_FOUND_NONE;
	}

	//TODO what if only one map was found?  Display only one result?
	
	//Try and display this new menu
	SetMenuTitle(mapSearchedMenu, "%t", "Nominate Title", client);
	DisplayMenu(mapSearchedMenu, client, MENU_TIME_FOREVER);

	return MAPSEARCH_FOUND;
}

