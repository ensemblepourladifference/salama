
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

newContact = session:playAndGetDigits(5, 6, 3, 7000, "#", "ivr/10-2.wav", "ivr/ivr-that_was_an_invalid_entry.wav", "\\d+");
session:consoleLog("info", "Lua variable newContact: ".. newContact .. "\n");
session:sayPhrase("saynumber", newContact, "en")
confirmationRequest = session:playAndGetDigits(1, 1, 3, 7000, "#", "ivr/press-one-confirm-two-try-again.wav", "ivr/ivr-that_was_an_invalid_entry.wav", "\\d+");
tries = 0;
if confirmationRequest == "1" then
  session:sleep(500);
  session:execute("playback", "/var/freeswitch-audio/salama/emergency-" .. newContact .. "}.wav");
  hangup_call()
else
  tries = tries + 1;
end
if (tries > 2) then
    hangup_call();
end


    