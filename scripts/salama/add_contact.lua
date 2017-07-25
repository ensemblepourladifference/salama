--Wait half seconds
session:sleep(500);
--Play a message to caller
session:execute("playback", "ivr/1-5.wav");
tries = 0;
--Wait half seconds
session:sleep(500);
--get the value set by dialplan into channel
userExtension = session:getVariable("username");
--print that value on FreeSWITCH console and logfile
session:consoleLog("info", "Lua variable userExtension: ".. userExtension .. "\n");
while tries < 3 do
  --<min> <max> <tries> <timeout> <terminators> <file> <invalid_file> <var_name> <regexp> <digit_timeout> <transfer_on_failure>
  newContact = session:playAndGetDigits(4, 4, 3, 7000, "#", "ivr/1-6.wav", "ivr/ivr-that_was_an_invalid_entry.wav", "\\d+");
  session:consoleLog("info", "Lua variable newContact: ".. newContact .. "\n");
  --Wait half seconds
  session:sleep(500);
  session:execute("playback", "phrase:whoami:".. newContact);
  --Wait half seconds
  confirmationRequest = session:playAndGetDigits(1, 1, 3, 7000, "#", "ivr/press-one-confirm-two-try-again.wav", "ivr/ivr-that_was_an_invalid_entry.wav", "\\d+");

  if confirmationRequest == "1" then
    session:execute("curl", "http://localhost:4000/".. userExtension);
    curl_response_code = session:getVariable("curl_response_code");
    curl_response      = session:getVariable("curl_response_data");
    -- if curl_response_code == 404 no user exists, create new one else edit existing
    session:consoleLog("info", "Lua variable curl_response_code: ".. curl_response_code .. "\n");
    session:consoleLog("info", "Lua variable curl_response: ".. curl_response .. "\n");
    hangup_call();
    break
  else
    tries = tries + 1;
  end
end
if (tries > 2) then
    hangup_call();
end