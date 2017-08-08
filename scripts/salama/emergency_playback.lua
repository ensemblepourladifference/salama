contact = session:getVariable("contact")
userExtension = session:getVariable("userExtension")
userID = session:getVariable("userID")
JSON = loadfile(base_dir .. "/scripts/utils/JSON.lua")()

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
newString = resTable.emergency.contacted..","..contact
session:execute("curl", "http://localhost:4000/api/emergencies/"..userID.." contacted="..newString);
resCodeEmergencyUpdate = session:getVariable("curl_response_code")
resJSONEmergencyUpdate = session:getVariable("curl_response_data")
resTableEmergencyUpdate = JSON:decode(resJSONEmergencyUpdate)
session:consoleLog("info", "Lua variable resCodeEmergencyUpdate: ".. resCodeEmergencyUpdate .. "\n")
session:consoleLog("info", "Lua variable resJSONEmergencyUpdate: ".. resJSONEmergencyUpdate .. "\n")
session:consoleLog("info", "Lua variable resTableEmergencyUpdate.message: ".. resTableEmergencyUpdate.message .. "\n")
playAgainRequest = session:playAndGetDigits(1, 1, 3, 7000, "#", "file_string://ivr/press.wav!digits/1.wav!ivr/6-5.wav!ivr/press.wav!digits/2.wav!ivr/1-10b.wav", "ivr/ivr-that_was_an_invalid_entry.wav", "\\d+");
if playAgainRequest == "1" then
  session:sleep(500);
  session:execute("playback", "/var/freeswitch-audio/salama/emergency-${userExtension}.wav");
  hangup_call()
else
  hangup_call()
end