contact = session:getVariable("contact")
userExtension = session:getVariable("userExtension")
userID = session:getVariable("userID")
JSON = loadfile("/usr/scripts/utils/JSON.lua")()

function hangup_call ()
  session:sleep(250)
  session:streamFile("ivr/6-7.wav")
  session:sleep(250);
  session:execute("playback", "digits/1.wav");
  session:sleep(250);
  session:execute("playback", "digits/1.wav");
  session:sleep(250);
  session:execute("playback", "digits/4.wav");
  session:sleep(500);
  session:streamFile("ivr/vm-goodbye.wav")
  session:hangup()
end

session:execute("playback", "ivr/1-1-this-is-salama.wav");
session:sleep(500);
session:execute("playback", "/var/freeswitch-audio/salama/name-${userExtension}.wav");
session:sleep(250);
session:execute("playback", "ivr/6-2.wav");
session:sleep(500);
session:execute("playback", "/var/freeswitch-audio/salama/emergency-${userExtension}.wav");
session:execute("curl", "http://localhost:4000/api/emergencies/".. userID);
resCode = session:getVariable("curl_response_code");
resJSONString = session:getVariable("curl_response_data");
resTable = JSON:decode(resJSONString);
if resTable.emergency.contacted then 
  session:consoleLog("debug", "Lua variable resTable: ".. resTable.emergency.contacted .. "\n")
  newString = resTable.emergency.contacted ..",".. contact
else
  newString = contact
end
session:execute("curl", "http://localhost:4000/api/emergencies/"..userID.." content-type 'application/x-www-form-urlencoded' put &contacted=" ..newString .. "&");
resCodeEmergencyUpdate = session:getVariable("curl_response_code")
resJSONEmergencyUpdate = session:getVariable("curl_response_data")
resTableEmergencyUpdate = JSON:decode(resJSONEmergencyUpdate)
session:consoleLog("debug", "Lua variable resCodeEmergencyUpdate: ".. resCodeEmergencyUpdate .. "\n")
session:consoleLog("debug", "Lua variable resJSONEmergencyUpdate: ".. resJSONEmergencyUpdate .. "\n")
session:consoleLog("debug", "Lua variable resTableEmergencyUpdate.message: ".. resTableEmergencyUpdate.message .. "\n")
hangup_call()