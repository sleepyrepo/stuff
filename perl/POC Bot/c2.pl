#!/usr/bin/perl -w
use strict;
use IO::Socket::INET;
use IO::Select;

my $pid = 0;
my $cmdPipe;
my @kids;
my $port = 4444;
my $sock = IO::Socket::INET->new(Listen=>5, LocalPort=>$port, ReuseAddr=>1);

if($pid = open($cmdPipe, "-|")){                #fork child to loop read from child stdin
                                                #$cmdPipe is connected to child stdout
  push @kids, $pid;                             #save child pid for later wait
}else{
  ($_ eq "q\n")? print($_) && exit : print $_ while(<>);        #exit child loop if user quit q\n
}

if($pid = fork){                                #fork second child to loop R from $cmdPipe,loop accept and  R/W to client socket
  push @kids, $pid;                             #save child pid for later wait
  wait for @kids;                               #wait for child
}else{
  my @clients;                                  #array to store client_socket
  my $client;
  while(1){
    my $select = IO::Select->new($sock);        #io/select to check for new connection without block
    if($select->can_read(0.25)){                #if socket ready
      $client = $sock->accept;
      push @clients, $client;                   #save new client
      printf"\n%s:%s conected...\n", $client->peerhost, $client->peerport;
    }
    for my $idx (0..$#clients){                 #loop remove client_socket that self terninate session
      $select = IO::Select->new($clients[$idx]);
      if($select->can_read(0.25)){              #if io/select say socket is ready, but sysread return 0
                                                #then client initiated close socket(buffer has EOF from FIN/ACK) 
        splice(@clients, $idx, 1) unless sysread($clients[$idx], my $buf, 0xffff);
      }
    }
    $select = IO::Select->new($cmdPipe);        #io/select to check if $cmdPipe is ready without block
    if($select->can_read(0.25)){
      my $cmd = <$cmdPipe>;                     #get cmd from $cmdPipe
      if($cmd eq "q\n"){                        #if detect quit q\n
        shutdown($_, 2) for @clients;           #close all socket and ALL copies
        exit;                                   #exit child
      }
      syswrite($_, $cmd) for @clients;          #send it out to all client_socket
      for(@clients){                            #get response from all client_socket
        sysread($_, my $buf, 0xffff);
        printf"\n%s:%s says...\n%s\n%s\n%s\n", $_->peerhost, $_->peerport, "="x80, $buf, "-"x80;
      }
    }
  }
}
