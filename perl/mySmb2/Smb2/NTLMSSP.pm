
package NTLMSSP{

use Crypt::DES;
use Digest::MD4;
use Digest::MD5;

sub _keyExtend{
  my $bits = sprintf"%08b"x7, unpack("C*", shift);
  pack"(B8)*", map{
    my $bits7 = substr $bits, 0, 7, "";
    my $count = 0;                                    
    $count += $_ for split(//, $bits7);
    $bits7 .= $count % 2? "0" : "1";                    #append parity bit 0 if sum of bits == odd, else 1
  }(1..8);                                              #loop 8 times
}

sub _ntlm_hash{
  my $pass = shift;
  return Digest::MD4::md4 pack("v*", unpack("C*", $pass));
}

sub _ntlm2_session_response{                             #"Negotiate NTLM2 Key" flag, replaces both the LM and NTLM response fields 
  my ($pass, $challenge, $nonce) = @_;
  my $lm_response = $nonce . "\x00"x16;
  my $session_nonce = $challenge . $nonce;
  my $ntlmv2_session_hash =  substr Digest::MD5::md5($session_nonce), 0, 8;
  my @bits7 = unpack"(a7)3", _ntlm_hash($pass) . "\x00"x5;
  my @bits8 = map{_keyExtend $_} @bits7;
  my $ntlm_response = join"", map{Crypt::DES->new($_)->encrypt($ntlmv2_session_hash)} @bits8;
  return ($lm_response, $ntlm_response);
}

my $NTLMSSP_FLAGS = {
  Nego_56		=> 0x80000000,	#56 bit enc (DES??)
  Nego_key_exchange	=> 0x40000000,	#include session key in msg3
  Nego_128		=> 0x20000000,	#128 bit enc
  Nego_version		=> 0x02000000,
  Nego_targetinfo	=> 0x00800000,	#include targetinfo block(type2)
  Req_non_nt_session	=> 0x00400000,
  Nego_identify		=> 0x00100000,
  Nego_ntlm2_key	=> 0x00080000,	#use NTLM2 Session Response (not ntlmv2) wireshark-> extended security
  Target_type_share	=> 0x00040000,	#realm is a share(type2)
  Target_type_server	=> 0x00020000,	#realm is a server(type2)
  Target_type_domain	=> 0x00010000,	#realm is a domain(type2)
  Nego_always_sign	=> 0x00008000,	#authenticated comm should be sifn with dummy sig
  Nego_oem_workstation	=> 0x00002000,	#include workstation in type1
  Nego_oem_domain	=> 0x00001000,	#include domain in type1
  Nego_anonymous	=> 0x00000800,	#anon auth(type3)
  Nego_nt_only		=> 0x00000400,
  Nego_ntlm_key		=> 0x00000200,	#use ntlm auth
  Nego_lm_key		=> 0x00000080,	#use lm for sign/seal
  Nego_datagram		=> 0x00000040,	
  Nego_seal		=> 0x00000020,	#encrypted
  Nego_sign		=> 0x00000010,	#digital sign
  Req_target		=> 0x00000004,	#show me server realm in type2
  Nego_oem		=> 0x00000002,	#will use oem in secbuffer
  Nego_unicode		=> 0x00000001,	#unicode in sec buffer
};

my $NTLMSIG = "NTLMSSP\x00";

my $flags = 0;
$flags |= $NTLMSSP_FLAGS->{$_} for (
  "Nego_ntlm2_key", 			#only do ntlm2_session_response 
  "Nego_oem",				#use OEM char encode in sec buff when send
  #"Nego_oem_workstation",		#say type1 include workstation in oem
  #"Nego_unicode",
);

sub msg1{
  #my $workstation = shift;		#both domain/workstation can be "" when NOT set Nego_oem_workstation/domain
  my $msg1_packer = [
    "str", $NTLMSIG,			#sig
    "32le", 1,				#type1
    "32le", $flags,
    "16le", 0,				#domain
    "16le", 0,
    "32le", 32,
    "16le", 0,#length $workstation,	#workstation
    "16le", 0,#length $workstation,
    "32le", 32,
    #"str", $workstation,
  ];
  return Struct->packer($msg1_packer);
}

sub msg3{
  shift;
  my ($user, $pass, $workstation, $target, $challenge) = @_;
  my $nonce = pack"H*", "0102030405060708";		#do MD5 later
  my ($lm_res, $ntlm_res) = _ntlm2_session_response($pass, $challenge, $nonce);
  my ($lm_res_len, $ntlm_res_len, $target_len, $user_len, $workstation_len) = (length $lm_res, length $ntlm_res, length $target,  length $user, length $workstation);
  my $end = 52;
  my $msg3_packer = [
    "str" => $NTLMSIG,			#sig
    "32le" => 3,                        #type3
    "16le" => $lm_res_len,				#lm/lmv2 response sec buff
    "16le" => $lm_res_len,
    "32le" => $end,					#32 works??
    "16le" => $ntlm_res_len,				#nt/ntlmv2 response sec buff
    "16le" => $ntlm_res_len,
    "32le" => $end + $lm_res_len,
    "16le" => $target_len,				#target secbuff, can be "" for local login
    "16le" => $target_len,
    "32le" => $end + $lm_res_len + $ntlm_res_len, 
    "16le" => $user_len,				#username secbuff
    "16le" => $user_len,
    "32le" => $end + $lm_res_len + $ntlm_res_len + $target_len,   
    "16le" => $workstation_len,				#workstation secbuf, can be "" for local login
    "16le" => $workstation_len,
    "32le" => $end + $lm_res_len + $ntlm_res_len + $target_len + $user_len,
    "str" => $lm_res . $ntlm_res . $target . $user . $workstation,
  ];
  return Struct->packer($msg3_packer);
}
}
1;

