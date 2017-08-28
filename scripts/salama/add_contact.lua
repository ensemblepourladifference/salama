--get the value set by dialplan into channel
userExtension = session:getVariable("username");
base_dir = session:getVariable("base_dir");
JSON = loadfile(base_dir .. "/scripts/utils/JSON.lua")()

function hangup_call ()
  session:streamFile("ivr/thank-you.wav")
  session:sleep(250)
  session:streamFile("ivr/vm-goodbye.wav")
  session:hangup()
end

function addNewDialplan(userID, newContact)
  session:execute("curl", "http://localhost:4000/api/dialplan post user_id="..userID .."&extensions="..newContact);
  resCodeDialplanCreate = session:getVariable("curl_response_code");
  resJSONDialplanCreate = session:getVariable("curl_response_data");
  resTableDialplanCreate = JSON:decode(resJSONDialplanCreate);
  session:consoleLog("info", "Lua variable resCodeDialplanCreate: ".. resCodeDialplanCreate .. "\n");
  session:consoleLog("info", "Lua variable resJSONDialplanCreate: ".. resJSONDialplanCreate .. "\n");
  session:consoleLog("info", "Lua variable resTableDialplanCreate.message: ".. resTableDialplanCreate.message .. "\n");
  session:sleep(500);
  --Would you like to add another?
  session:execute("playback", "ivr/1-9.wav");
  --Wait half seconds
  addAnotherRequest = session:playAndGetDigits(1, 1, 3, 7000, "#", "file_string://ivr/press.wav!digits/1.wav!ivr/1-10a.wav!ivr/press.wav!digits/2.wav!ivr/1-10b.wav", "ivr/ivr-that_was_an_invalid_entry.wav", "\\d+");
  if addAnotherRequest == "2" then
    session:sleep(500);
    --Thanks you have signed up
    session:execute("playback", "ivr/1-11.wav");
    session:sleep(500);
    --Next time you are in danger
    session:execute("playback", "ivr/1-12.wav");
    session:sleep(250);
    session:execute("playback", "ivr/phone.wav");
    session:sleep(250);
    session:execute("playback", "digits/1.wav");
    session:sleep(250);
    session:execute("playback", "digits/1.wav");
    session:sleep(250);
    session:execute("playback", "digits/1.wav");
    session:sleep(500);
    --and we wil tell your contacts
    session:execute("playback", "ivr/1-12b.wav");
    session:sleep(500);
    hangup_call();
  else
    session:consoleLog("info", "Add another loop");
  end
end

--Wait half seconds
session:sleep(500);
--Play a message to caller
session:execute("playback", "ivr/1-5.wav");
tries = 0;
--Wait half seconds
session:sleep(500);
--print that value on FreeSWITCH console and logfile
session:consoleLog("info", "Lua variable userExtension: ".. userExtension .. "\n");
while tries < 3 do
  --<min> <max> <tries> <timeout> <terminators> <file> <invalid_file> <var_name> <regexp> <digit_timeout> <transfer_on_failure>
  newContact = session:playAndGetDigits(11, 12, 3, 7000, "#", "ivr/1-6.wav", "ivr/ivr-that_was_an_invalid_entry.wav", "\\d+");
  session:consoleLog("info", "Lua variable newContact: ".. newContact .. "\n");
  --Wait half seconds
  session:sleep(500);
  session:execute("playback", "phrase:whoami:".. newContact);
  --Wait half seconds
  confirmationRequest = session:playAndGetDigits(1, 1, 3, 7000, "#", "ivr/press-one-confirm-two-try-again.wav", "ivr/ivr-that_was_an_invalid_entry.wav", "\\d+");

  if confirmationRequest == "1" then
    session:execute("curl", "http://localhost:4000/api/users/".. userExtension);
    responseCode = session:getVariable("curl_response_code");
    responseJSONString = session:getVariable("curl_response_data");
    responseTable = JSON:decode(responseJSONString);
    -- if curl_response_code == 404 no user exists, create new one else edit existing
    session:consoleLog("info", "Lua variable curl_response_code: ".. responseCode .. "\n");
    session:consoleLog("info", "Lua variable curl_response: ".. responseJSONString .. "\n");
    session:consoleLog("info", "Lua variable responseTable.message: ".. responseTable.message .. "\n");
    if responseCode == "400" then
      session:execute("curl", "http://localhost:4000/api/users post extension="..userExtension);
      resCodeUserCreate = session:getVariable("curl_response_code");
      resJSONUserCreate = session:getVariable("curl_response_data");
      resTableUserCreate = JSON:decode(resJSONUserCreate);
      session:consoleLog("info", "Lua variable resCodeUserCreate: ".. resCodeUserCreate .. "\n");
      session:consoleLog("info", "Lua variable resJSONUserCreate: ".. resJSONUserCreate .. "\n");
      session:consoleLog("info", "Lua variable resTableUserCreate.message: ".. resTableUserCreate.message .. "\n");
      session:consoleLog("info", "New user! ID is: "..resTableUserCreate.user.id);
      addNewDialplan(resTableUserCreate.user.id, newContact)
    else
      session:consoleLog("info", "User exists! ID is: "..responseTable.user.id);
      addNewDialplan(responseTable.user.id, newContact)
    end
  else
    tries = tries + 1;
  end
end
if (tries > 2) then
    hangup_call();
end