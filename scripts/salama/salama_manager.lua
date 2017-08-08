userExtension = session:getVariable("username");
base_dir = session:getVariable("base_dir");
JSON = loadfile(base_dir .. "/scripts/utils/JSON.lua")()
session:execute("curl", "http://localhost:4000/api/users/".. userExtension);
responseCode = session:getVariable("curl_response_code");
responseJSONString = session:getVariable("curl_response_data");
responseTable = JSON:decode(responseJSONString);
-- if curl_response_code == 404 no user exists, create new one else edit existing
session:consoleLog("info", "Lua variable curl_response_code: ".. responseCode .. "\n");
session:consoleLog("info", "Lua variable curl_response: ".. responseJSONString .. "\n");
session:consoleLog("info", "Lua variable responseTable.message: ".. responseTable.message .. "\n");
if responseCode == "400" then
  session:transfer("337")
else
  session:transfer("338")
end