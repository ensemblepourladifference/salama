userExtension = session:getVariable("userExtension")
session:execute("playback", "ivr/1-1-this-is-salama.wav");
session:sleep(500);
session:execute("playback", "/var/freeswitch-audio/salama/name-${userExtension}.wav");
session:sleep(250);
session:execute("playback", "ivr/8-2.wav");
session:sleep(250)
session:streamFile("ivr/vm-goodbye.wav")
session:hangup()