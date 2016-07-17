component name = "Request" output = "false"
{

    /**
    * @hint performs a http request and processes the response 
    * @url the url of the request
    * @verb the http verb (GET, POST)
    * @fields an array of structs used in a post (NAME, VALUE, TYPE (FORMFIELD))
	* @content the request content used in a put request
    */
	public any function request(required string url, string verb = "GET", array fields = [], string content = "")
	{
		if(!arguments.verb == "GET" && !arguments.verb == "POST" && !arguments.verb == "PUT") {throw(message = "Request only supports GET, POST and PUT verbs!", type = "Unsupported verb");}
		var myHttp = new Http();
		myHttp.setMethod(arguments.verb);
		myHttp.setUrl(arguments.url);
        if(arguments.verb == "POST")
        {
            if(!arrayLen(arguments.fields)) {throw(message = "You cannot make a POST request without fields!", type = "Missing fields");}
            for(var f = 1; f <= arraylen(arguments.fields); f ++)
            {
                if(!structKeyExists(arguments.fields[f], "TYPE")) {arguments.fields[f].type = "FORMFIELD";}
                if(!structKeyExists(arguments.fields[f], "NAME")) {throw(message = "You must supply a name for all fields!", type = "Missing field name");}
                if(!structKeyExists(arguments.fields[f], "VALUE")) {throw(message = "You must supply a value for all fields!", type = "Missing field value");}
                myHttp.addParam(type = arguments.fields[f].type, name = arguments.fields[f].name, value = arguments.fields[f].value);
            }
        }
		if(arguments.verb == "PUT") {myHttp.addParam(type = "BODY", value = arguments.content);}
        return myHttp.send().getPrefix().fileContent;
	}

}