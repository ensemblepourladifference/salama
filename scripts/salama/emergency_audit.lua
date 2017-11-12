--get the value set by dialplan into channel
userExtension = session:getVariable("username")
base_dir = session:getVariable("base_dir")
JSON = loadfile(base_dir .. "/share/freeswitch/scripts/utils/JSON.lua")()
copyScript = base_dir .. "/share/freeswitch/scripts/utils/copyScript.sh"
emergencyDialerScript = base_dir .. "/share/freeswitch/scripts/salama/emergency_dialer.py"
luaDate = string.gsub(os.date("!%c"), ":", "-")
luaDateWithoutSpaces = string.gsub(luaDate, "%s+", "-")
auditFile = "emergency-".. userExtension .."-" .. luaDateWithoutSpaces ..".wav"

function hangup_call ()
  session:sleep(250)
  session:streamFile("ivr/vm-goodbye.wav")
  session:hangup()
end

session:consoleLog("debug", "auditFile is: "..auditFile)
--duplicate recording for audit trail
executeCommand = "sh "..copyScript.." emergency-".. userExtension ..".wav ".. auditFile
session:consoleLog("debug", "executeCommand is: "..executeCommand)
copyCmd = os.execute(executeCommand)
session:consoleLog("debug", copyCmd)
function addNewEmergency(userExtension, auditFile)

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
  -- post to emergency database
  userID = resTableUserGet.user.id
  session:execute("curl", "http://localhost:4000/api/emergencies post user_id="..userID.."&toBeContacted="..toBeContacted.."&auditPath="..auditFile);
  resCodeEmergPost = session:getVariable("curl_response_code");
  resJSONEmergPost = session:getVariable("curl_response_data");
  resTableEmergPost = JSON:decode(resJSONEmergPost);
  session:consoleLog("debug", "Lua variable resCodeEmergPost: ".. resCodeEmergPost .. "\n");
  session:consoleLog("debug", "Lua variable resJSONEmergPost: ".. resJSONEmergPost .. "\n");
  session:consoleLog("debug", "Lua variable resTableEmergPost.message: ".. resTableEmergPost.message .. "\n");
  executeEmergencyCommand = "python "..emergencyDialerScript.." ".. userID .." "..toBeContacted.." "..userExtension
  session:consoleLog("debug", "executeEmergencyCommand is: "..executeEmergencyCommand)
  emergCmd = os.execute(executeEmergencyCommand)

  session:sleep(250)
  session:streamFile("ivr/3-2.wav")
  session:sleep(500);
  session:execute("playback", "ivr/phone.wav");
  session:sleep(250);
  session:execute("playback", "digits/2.wav");
  session:sleep(250);
  session:execute("playback", "digits/2.wav");
  session:sleep(250);
  session:execute("playback", "digits/2.wav");
  session:sleep(500);
  session:execute("playback", "ivr/3-3.wav");
  -- repeat
  session:sleep(1000)
  session:streamFile("ivr/3-2.wav")
  session:sleep(500);
  session:execute("playback", "ivr/phone.wav");
  session:sleep(250);
  session:execute("playback", "digits/2.wav");
  session:sleep(250);
  session:execute("playback", "digits/2.wav");
  session:sleep(250);
  session:execute("playback", "digits/2.wav");
  session:sleep(500);
  session:execute("playback", "ivr/3-3.wav");


  hangup_call()
end

addNewEmergency(userExtension, auditFile)