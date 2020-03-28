
#!/usr/bin/perl -w
use strict;
use threads;

my @thrs;
my $count = 3;                  #number of threads to create

sub dosth{
  my $sth;
  $sth .= $_ for(1..0xffffff);
}

push @thrs, threads->new(\&dosth) for(1..$count);
$_->join for @thrs;


#run with
#time perl ./perlVsPyThread.pl
#output
#real -> tome start to finish
#user -> CPU time in user mode
#sys -> CPU time in kernel mode

#num threads: perl vs py real time      ***python thread slower due to GIL(global interpreter lock)
#1: 0m0.763s vs 0m0.010s 
#2: 0m0.743s vs 0m4.833s
#3: 0m1.154s vs 0m19.184s
#...
