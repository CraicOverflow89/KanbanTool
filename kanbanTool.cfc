component name = "kanbanTool" output = "false"
{
	// Map Request UDF
	udf_request = new plugins.request().request;

	/**
	* @hint loads details from txt file (expecting "DOMAIN|TOKEN" format)
	* @path an absolute file path from which to load the file  
	*/
	public struct function authenticationLoad(required string path)
	{
		var content = fileRead(arguments.path);
		if(!len(content) || !findNoCase("|", content)) {throw(message = "Invalid authentication file - must contain 'DOMAIN|TOKEN'", type = "Invalid authentication");}
		content = listToArray(content, "|");
		if(!arrayLen(content) == 2 || !len(content[1]) || !len(content[2])) {throw(message = "Invalid authentication file - must contain 'DOMAIN|TOKEN'", type = "Invalid authentication");}
		return {domain:content[1], token:content[2]};
	}

	/**
	* @hint checks authentication struct
	* @auth the struct of details
	*/
	private boolean function authenticationValidate(required struct auth)
	{
		if(!structKeyExists(arguments.auth, "domain")) {throw(message = "Domain required in authentication!", type = "Invalid authentication");}
		if(!structKeyExists(arguments.auth, "token")) {throw(message = "Token required in authentication!", type = "Invalid authentication");}
		return true;
	}

	/**
	* @hint retrieves account information
	* @auth authentication details
	*/
	public struct function infoAccount(required struct auth)
	{
		authenticationValidate(arguments.auth);
		var response = udf_request("https://" & arguments.auth.domain & ".kanbantool.com/api/v1/boards.json?api_token=" & arguments.auth.token);
		if(findNoCase("Connection Failure", response)) {throw(message = "Connection Failure... check your authentication details." type = "Connection Failure");}
		return {account:deserializeJson(response)};
	}

	/**
	* @hint retrieves board information
	* @auth authentication details
	* @boardID the id of the board to lookup
	*/
	public struct function infoBoard(required struct auth, required numeric boardID)
	{
		authenticationValidate(arguments.auth);
		return deserializeJson(udf_request("https://" & arguments.auth.domain & ".kanbantool.com//api/v1/boards/" & arguments.boardID & ".json?api_token=" & arguments.auth.token)); 
	}

	/**
	* @hint retrieves board task information
	* @auth authentication details
	* @boardID the id of the board to lookup
	* @swimlaneID the optional swimlane to lookup
	* @workflowStageID the optional workflow stage to lookup
	*/
	public struct function infoBoardTask(required struct auth, required numeric boardID, numeric swimlaneID, numeric workflowStageID)
	{
		authenticationValidate(arguments.auth);
		var url = "https://" & arguments.auth.domain & ".kanbantool.com//api/v1/boards/" & arguments.boardID & "/tasks.json?api_token=" & arguments.auth.token;
		if(isDefined("arguments.swimlaneID")) {url &= "&swimlane_id=" & arguments.swimlaneID;}
		if(isDefined("arguments.workflowStageID")) {url &= "&workflow_stage_id=" & arguments.workflowStageID;}
		return {board:deserializeJson(udf_request(url))};
	}

	/**
	* @hint retrieves task information
	* @auth authentication details
	* @boardID the id of the board to lookup
	* @taskID the id of the task to lookup
	*/
	public struct function infoTask(required struct auth, required numeric boardID, required numeric taskID)
	{
		authenticationValidate(arguments.auth);
		return deserializeJson(udf_request("https://" & arguments.auth.domain & ".kanbantool.com//api/v1/boards/" & arguments.boardID & "/tasks/" & arguments.taskID & ".json?api_token=" & arguments.auth.token));
	}

	/**
	* @hint creates a task on a board
	* @auth authentication details
	* @boardID the id of the board to create on
	* @userID the id of the user to assign the task to
	* @title the title of the task to create
	* @description the optional description of the task to create
	* @link the optional external link of the task to create
	*/
	public struct function taskCreate(required struct auth, required numeric boardID, required numeric userID, required string title, string description, string link)
	{
		authenticationValidate(arguments.auth);
		var fields = [];
		arrayAppend(fields, {name:"task[assigned_user_id]", value:arguments.userID});
		arrayAppend(fields, {name:"task[name]", value:arguments.title});
		if(isDefined("arguments.description")) {arrayAppend(fields, {name:"task[description]", value:arguments.description});}
		if(isDefined("arguments.link")) {arrayAppend(fields, {name:"task[external_link]", value:arguments.link});}
		return deserializeJson(udf_request(url = "https://" & arguments.auth.domain & ".kanbantool.com//api/v1/boards/" & arguments.boardID & "/tasks.json?api_token=" & arguments.auth.token, verb = "post", fields = fields));
	}

	/**
	* @hint moves a task on a board
	* @auth authentication details
	* @boardID the id of the board to move on
	* @taskID the id of the task to move
	*/
	public struct function taskMove(required struct auth, required numeric boardID, required numeric taskID, boolean forward)
	{
		authenticationValidate(arguments.auth);
		var direction = "next_stage";
		if(isDefined("arguments.forward") && !arguments.forward) {direction = "prev_stage";}
		return deserializeJson(udf_request(url = "https://" & arguments.auth.domain & ".kanbantool.com//api/v1/boards/" & arguments.boardID & "/tasks/" & arguments.taskID & "/move.json?api_token=" & arguments.auth.token & "&direction=" & direction, verb = "put"));
	}

}
