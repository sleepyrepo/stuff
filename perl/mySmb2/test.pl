#!/usr/bin/perl -w
use strict;
use lib (".", "../lib/lib/perl5");		#point ot lib dirs
use Smb2::Client;
use Data::Dumper;

my $client = Smb2::Client->new(
  user => "user",
  pass => "pass12345678",
  ip => "10.0.0.254",
  host => "hostname",
  domain => "somedom",
  port => 445,
);

$client->negotiate;
$client->session_setup;
$client->tree_connect("test");
$client->create;

my ($smb, $res) = $client->query_directory("*");
#print $res->{data};
#go figure how to parse FileDirectoryInformation
#https://docs.microsoft.com/en-us/openspecs/windows_protocols/ms-fscc/b38bf518-9057-4c88-9ddd-5e2d3976a64b

do{
  substr $res->{data}, 0, 4+4+8+8+8+8+8+8, "";
  my ($fileAttr, $len) = unpack"VV", substr($res->{data}, 0, 4+4, "");
  my $name = substr $res->{data}, 0, $len, ""; 
  printf"%s\n", $name;
} while length $res->{data};

$client->close;
$client->tree_disconnect;
$client->logoff;

