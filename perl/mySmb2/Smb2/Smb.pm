#!/usr/bin/perl -w
use strict;


package Smb{

my $ntStatus = {
  STATUS_SUCCESS => 0x00000000,
  STATUS_MORE_PROCESSING_REQUIRED => 0xC0000016,
};

sub request{
  shift;
  my($cmd, $flags, $msgId, $sessionId, $treeId, $cmd_data) = @_;
  my $header_packer = [
    "str" => "\xFESMB",		#id
    "16le" => 64,		#struct size
    "16le" => 0,		#credit charge
    "32le" => 0,		#status
    "16le" => $cmd,		#command
    "16le" => 1,		#credit req
    "32le" => $flags,		#flags
    "32le" => 0,		#next cmd
    "64le" => $msgId,		#msg id
    "32le" => 0,		#reserved
    "32le" => $treeId,		#treeid
    "64le" => $sessionId,	#session id
    "str" => "\x00"x16,   	#signature
  ];
  my $header = Struct->packer($header_packer);
  my $trans_packer = [
    "32be" => length $header . $cmd_data,
    "str" => $header . $cmd_data,
  ];
  return Struct->packer($trans_packer);
}


sub response{
shift;
  my $stream = shift;
  my $trans_parse = [
    len => "32be",
    data => ["*"],
  ];
  my $header_parser = [
    id => [4],
    structSize => "16le",
    creditCharge => "16le",
    status => "32le",
    cmd => "16le",
    credit_res => "16le",
    flags => "32le",
    next_cmd => "32le",
    msgId => "64le",
    reserved => "32le",
    treeId => "32le",
    sessionId => "64le",
    sig => [16],
    data => ["*"],
  ];
  my $trans_header = Struct->parser($trans_parse, $stream);
  my $smb_header = Struct->parser($header_parser, $trans_header->{data});
  my $status = $smb_header->{status};
  die sprintf("\n[+] unexpected NT Status response: 0x%08x from SMB_CMD: %d", $status, $smb_header->{cmd}) unless grep{$status == $ntStatus->{$_}} keys %$ntStatus;
  return $smb_header;
}
}
1;

