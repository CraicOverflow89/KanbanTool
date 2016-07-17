<cfscript>

	/*
		to get this working you need to get your domain and token info into auth{}
		then try getting data from infoAccount and going from there

		there aren't functions here for everything you can do, so feel free to add some!
		see http://kanbantool.com/about/api#introduction for more information

		the kanbanTool component does a little error handling but parsing or connection issues will be thrown
		obviously, adapt everything to how you best see fit, for your own needs
	*/

	// Map Component
	tool = new kanbanTool();

	// Authentication (hardcoded)
	auth = {domain:"YOUR DOMAIN", token:"YOUR TOKEN"};
	// see http://kanbantool.com/about/api#getting-started for info on getting your token

	// Authentication (protected)
	//auth = tool.authenticationLoad("YOUR PATH TO FILE"); // this is my preferred method
	// feel free to construct your own struct via db query or simply hardcoding it as above

	// Account Info
	writeDump(tool.infoAccount(auth));

	// Board Info
	//writeDump(tool.infoBoard(auth, 1)); // where 1 is boardID (get from infoAccount)

	// Board Task Array
	//writeDump(tool.infoBoardTask(auth, 1)); // where 1 is boardID (get from infoAccount)

	// Task Info
	//writeDump(tool.infoTask(auth, 1, 2)); // where 1 is boardID and 2 is taskID (get from infoBoardTask) 

	// Task Create
	//writeDump(tool.taskCreate(auth, 1, 2, "New Task 1", "API Test"));
	//writeDump(tool.taskCreate(auth, 1, 2, "New Task 2", "API Test", "API Test for additional values", "http://www.google.ie/", 297));

	// Task Move
	//writeDump(tool.taskMove(auth, 1, 2, false)); 

</cfscript>