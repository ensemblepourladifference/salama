userExtension = session:getVariable("username");
base_dir = session:getVariable("base_dir");
JSON = loadfile(base_dir .. "/scripts/utils/JSON.lua")()
session:execute("curl", "http://localhost:4000/api/users/".. userExtension);
responseCode = session:getVariable("curl_response_code");
responseJSONString = session:getVariable("curl_response_data");
responseTable = JSON:decode(responseJSONString);
userID = responseTable.user.id;

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
  session:consoleLog("debug", "Lua variable resCodeDialplanCreate: ".. resCodeDialplanCreate .. "\n");
  session:consoleLog("debug", "Lua variable resJSONDialplanCreate: ".. resJSONDialplanCreate .. "\n");
  session:consoleLog("debug", "Lua variable resTableDialplanCreate.message: ".. resTableDialplanCreate.message .. "\n");
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
    session:consoleLog("debug", "Add another loop");
  end
end

function tablelength(t)
  local count = 0
  for _ in pairs(t) do count = count + 1 end
  return count
end

function playOrDelete(counter,table)
  session:sleep(250);
  session:consoleLog("debug", "Extension in table: ".. table[counter]["extensions"] .. "\n");
  session:streamFile("ivr/2-3.wav")
  session:sayPhrase("saynumber", table[counter]["extensions"], "en")
  session:sleep(500);
  deleteRequest = session:playAndGetDigits(1, 1, 3, 7000, "#", "file_string://ivr/press.wav!digits/1.wav!ivr/2-4a.wav!ivr/press.wav!digits/2.wav!ivr/2-4b.wav", "ivr/ivr-that_was_an_invalid_entry.wav", "\\d+");
  session:consoleLog("debug", "Lua variable deleteRequest: ".. deleteRequest .. "\n");
  if deleteRequest == "1" then
    session:consoleLog("debug", "should go to next thing");
    return deleteRequest
  else
    session:sleep(500);
    session:sayPhrase("saynumber", table[counter]["extensions"], "en")
    session:sleep(250);
    session:streamFile("ivr/2-5a.wav")
    deleteConfirmation = session:playAndGetDigits(1, 1, 3, 7000, "#", "file_string://ivr/press.wav!digits/1.wav!ivr/2-4a.wav!ivr/press.wav!digits/2.wav!ivr/1-8-to-confirm.wav", "ivr/ivr-that_was_an_invalid_entry.wav", "\\d+");
    if deleteConfirmation == "2" then
      --delete
      session:execute("curl", "http://localhost:4000/api/dialplan/".. table[counter]["id"] .." delete");
      responseCode = session:getVariable("curl_response_code");
      responseJSONString = session:getVariable("curl_response_data");
      session:sleep(500);
      session:sayPhrase("saynumber", table[counter]["extensions"], "en")
      session:sleep(250);
      session:streamFile("ivr/2-5a.wav")
      return true
    else
      return true
    end
  end
end

--Play a message to caller
session:execute("playback", "ivr/1-1-this-is-salama.wav");
session:sleep(250);
hearOrAddRequest = session:playAndGetDigits(1, 1, 3, 7000, "#", "file_string://ivr/press.wav!digits/1.wav!ivr/2-2a.wav!ivr/press.wav!digits/2.wav!ivr/2-2b.wav", "ivr/ivr-that_was_an_invalid_entry.wav", "\\d+");
  
extensionCounter = 1;

while (extensionCounter <= tablelength(responseTable["user"]["dialplans"])) and (hearOrAddRequest == "1") do
  editCase = playOrDelete(extensionCounter, responseTable["user"]["dialplans"]);
  extensionCounter = extensionCounter + 1;
  if extensionCounter >= tablelength(responseTable["user"]["dialplans"]) then
    session:execute("playback", "ivr/2-6.wav");
    session:sleep(250);
    session:execute("playback", "ivr/1-9.wav");
    addAnotherRequest = session:playAndGetDigits(1, 1, 3, 7000, "#", "file_string://ivr/press.wav!digits/1.wav!ivr/1-10a.wav!ivr/press.wav!digits/2.wav!ivr/1-10b.wav", "ivr/ivr-that_was_an_invalid_entry.wav", "\\d+");
    if addAnotherRequest == "1" then
      hearOrAddRequest = "2"
    else
      hangup_call();
    end
  end
end
if ((hearOrAddRequest == "2")) then
  tries = 0;
  while tries < 3 do
    --<min> <max> <tries> <timeout> <terminators> <file> <invalid_file> <var_name> <regexp> <digit_timeout> <transfer_on_failure>
    newContact = session:playAndGetDigits(11, 12, 3, 7000, "#", "ivr/1-6.wav", "ivr/ivr-that_was_an_invalid_entry.wav", "\\d+");
    session:consoleLog("debug", "Lua variable newContact: ".. newContact .. "\n");
    session:sleep(500);
    session:execute("playback", "phrase:whoami:".. newContact);
    confirmationRequest = session:playAndGetDigits(1, 1, 3, 7000, "#", "ivr/press-one-confirm-two-try-again.wav", "ivr/ivr-that_was_an_invalid_entry.wav", "\\d+");
    if confirmationRequest == "1" then
      addNewDialplan(userID, newContact)
    else
      tries = tries + 1;
    end
  end
  if (tries > 2) then
      hangup_call();
  end
end
