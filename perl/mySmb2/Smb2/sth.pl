require"./lmNtlm.pl";
my ($user, $pass, $target, $challenge, $nonce) = ("mee", "pass1234", "WIN7", pack("H*","70c6a3229c48dc56"), pack("H*","0102030405060708"));
printf"NTLM2 session response: %s\n", unpack("H*", ntlm2_session_response($pass, $challenge, $nonce));

