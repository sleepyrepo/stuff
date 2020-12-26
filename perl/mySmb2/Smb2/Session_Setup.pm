
package Session_Setup{

use Smb2::NTLMSSP;
use Smb2::Spnego;

sub _session_setup_packer{
  my $blob = shift;
  return [
    "16le" => 25, 	#0x19 StructSize
    "8le" => 0,		#flags 
    "8le" => 0,		#secMode 
    "32le" => 0, 	#Capabilities
    "32le" => 0,	#Channel
    "16le" => 0x58,	#bufOffset 
    "16le" => length $blob, 	#72 bufLen
    "64le" => 0,	#PreviousSessionId 
    "str" => $blob,	#blob $negTokenInit,
  ];
}

sub _session_setup_parser{
  return [
    structSize => "16le",
    flags => "16le",
    buffOffset => "16le",
    buffLen => "16le",
    data => ["*"],
  ];
}

sub request1{
  my $msg1 = NTLMSSP->msg1();
  my $negTokenInit = Spnego->negTokenInit($msg1);
  return Struct->packer(_session_setup_packer($negTokenInit));
}

sub response1{
  my ($class, $data) = @_;
  my $setup_res = Struct->parser(_session_setup_parser(), $data);
  $setup_res->{msg2} = $& if $setup_res->{data} =~ /NTLMSSP\x00.+/;
  $setup_res->{challenge} = substr $setup_res->{msg2}, 24, 8;
  return $setup_res;
}

sub request2{
  shift;
  my $msg3 = NTLMSSP->msg3(@_);
  my $negTokenTarg = Spnego->negTokenTarg($msg3);
  return Struct->packer(_session_setup_packer($negTokenTarg));
}

sub response2{
  my ($class, $data) = @_;
  my $setup_res = Struct->parser(_session_setup_parser(), $data);
  return $setup_res;
}
}
1;
