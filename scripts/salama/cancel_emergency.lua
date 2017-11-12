--get the value set by dialplan into channel
userExtension = session:getVariable("username")
base_dir = session:getVariable("base_dir")
JSON = loadfile(base_dir .. "/share/freeswitch/scripts/utils/JSON.lua")()
deleteScript = base_dir .. "/share/freeswitch/scripts/utils/deleteScript.sh"
cancelEmergencyDialerScript = base_dir .. "/share/freeswitch/scripts/salama/cancel_emergency_dialer.py"

function hangup_call ()
  session:sleep(250)
  session:streamFile("ivr/vm-goodbye.wav")
  session:hangup()
end

--duplicate recording for audit trail
executeCommand = "sh "..deleteScript.." emergency-".. userExtension ..".wav "
session:consoleLog("debug", "executeCommand is: "..executeCommand)
deleteCmd = os.execute(executeCommand)
session:consoleLog("debug", deleteCmd)


function cancelEmergency(userExtension)

  -- get user and contacts
  session:execute("curl", "http://localhost:4000/api/users/"..userExtension.." get ")
  resCodeUserGet = session:getVariable("curl_response_code")
  resJSONUserGet = session:getVariable("curl_response_data")
  resTableUserGet = JSON:decode(resJSONUserGet)
  session:consoleLog("debug", "Lua variable resCodeUserGet: ".. resCodeUserGet .. "\n")
  session:consoleLog("debug", "Lua variable resJSONUserGet: ".. resJSONUserGet .. "\n")
  session:consoleLog("debug", "Lua variable resTableUserGet.message: ".. resTableUserGet.message .. "\n")
  session:consoleLog("debug", "New user! ID is: "..resTableUserGet.user.id);
  -- loop through contacts and prepare emergency dialplan
  toBeContacted = ""
  contactCount = 0
  for i, val in ipairs(resTableUserGet["user"]["dialplans"]) do
    contactCount = contactCount + 1
    session:consoleLog("debug", "i: "..i);
    toBeContacted = toBeContacted ..val["extensions"]..","
  end
  if (contactCount == 0) then
    session:sleep(250)
    session:streamFile("ivr/3-1c.wav")
    toBeContacted = "1030"
    session:consoleLog("debug", "toBeContacted set to administrator numnber: " ..toBeContacted);
  else
    toBeContacted = toBeContacted:sub(1, -2)
    session:consoleLog("debug", "toBeContacted is: " ..toBeContacted);
  end
  -- get emergency
  userID = resTableUserGet.user.id
  session:execute("curl", "http://localhost:4000/api/emergencies/"..userID);
  resCodeEmergGet = session:getVariable("curl_response_code");
  resJSONEmergGet = session:getVariable("curl_response_data");
  resTableEmergGet = JSON:decode(resJSONEmergGet);
  emergencyID = resTableEmergGet.emergency.id

  -- update emergency

  session:execute("curl", "http://localhost:4000/api/emergencies/"..emergencyID.." content-type 'application/x-www-form-urlencoded' put &cancelled=true&");
  resCodeEmergPost = session:getVariable("curl_response_code");
  resJSONEmergPost = session:getVariable("curl_response_data");
  resTableEmergPost = JSON:decode(resJSONEmergPost);
  session:consoleLog("debug", "Lua variable resCodeEmergPost: ".. resCodeEmergPost .. "\n");
  session:consoleLog("debug", "Lua variable resJSONEmergPost: ".. resJSONEmergPost .. "\n");
  session:consoleLog("debug", "Lua variable resTableEmergPost.message: ".. resTableEmergPost.message .. "\n");

  executeEmergencyCommand = "python "..cancelEmergencyDialerScript.." ".. userID .." "..toBeContacted.." "..userExtension
  session:consoleLog("debug", "executeEmergencyCommand is: "..executeEmergencyCommand)
  emergCmd = os.execute(executeEmergencyCommand)

  session:sleep(250)
  session:streamFile("ivr/5-2.wav")
  session:sleep(500);

  hangup_call()
end

cancelEmergency(userExtension)