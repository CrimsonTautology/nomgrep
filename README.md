SM_NOMGREP
===============
[![Build Status](https://travis-ci.org/CrimsonTautology/nomgrep.png?branch=master)](https://travis-ci.org/CrimsonTautology/nomgrep)
Sourcemod Plugin that provides a quick way to search through a map nomination list.

INSTALLATION:
-------------
Simply compile with the command 

> spcomp nomgrep.sp

and put the compiled .smx file in your `"<modname>/addons/sourcemod/plugins"`
directory.

Also make sure you have the mapchooser, nominations and rockthevote plugins enabled on your server otherwise this plugin won't be of much use


USAGE:
------
When on a server with nomgrep enabled simply type into chat:

> `!nomgrep <searchkey>`

And a list of maps that have "searchkey" in their name will be displayed.


For example: You want to nominate "pl_badwater", but the server you are on has a bunch of maps in it's map list and you're forced to press "9" 50 times just to get to the payload maps.

Simply type:

> `!nomgrep badwater`

And every map with "badwater" in it's name will be displayed.




