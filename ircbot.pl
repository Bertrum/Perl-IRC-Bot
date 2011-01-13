#!/usr/bin/env perl
use strict;
use warnings;
use IO::Socket;
my ($sock, $buffer);

#NETWORK INFORMATION
my $server = "insomnia.paradoxirc.net";
my $port = "6668";

#BOT SETTINGS
my $mynick = "PerlCorinth";
my $ident = "Perlt";
my $realname = "Bertrums Perl Bot";
my $umode = "+B";
my $channel = "#Corinth";

$sock = IO::Socket::INET->new(    
  PeerAddr => $server,   
  PeerPort => $port,                  
  Proto => 'tcp',                     # as stated above, IRC is a TCP socket
  Timeout => 30                       # give it 30 secons before we give up
) || die "Could not connect to server: $!\n";

sub quote {
  my ($msg) = @_;
  print $sock "$msg\r\n"; # this method makes life easy. instead of doing print $sock "DATA\r\n";, we can do quote('DATA') for the same effect
  print "S: $msg\n";
}

my %_commands = (
  PING => sub {   
    my ($cmd, $source) = @_; 
    quote("PONG $source");
 },
);


# Ignore this until the comments bring you here! Sroll 
my %commands = (     
  JOIN => sub {   
    my ($source, $cmd, $target) = @_; 
    my $nick = (split '!', $source)[0];
    $nick = substr $nick, 1;
    $target = substr $target, 1;
    quote("PRIVMSG $target :Hello, $nick!");
  },
  '001' => sub {  
    my ($server, $cmd, $target, @msg) = @_; 
    quote("JOIN $channel");
  },
  PRIVMSG => sub {
    my ($src, $cmd, $target, @msg) = @_;
  },
);


quote("NICK $mynick");                # this is registration to the server. we're introducing our self as
quote("USER $mynick 8 $ident :$realname"); # Perl!perl, and our real name is LOL PERL!

while ($buffer = <$sock>) # < > resembles the output of the socket file. we store it as $buffer
{
  print "R: $buffer"; # we don't need "\n" here, see next line
  chomp $buffer; # $sock adds the "\r\n" suffixes to print new lines to us. we'll remove these before parsing, but after printing.

  parse($buffer); # parse points to sub parse {} below
}

close $sock; # this means that $sock has stopped talking to us, so we'll close our end too

sub parse {
  my ($buffer) = @_; 
  my @bits = split ' ', $buffer; 
  my $source = $bits[0];
  my $command = $bits[1];
  my $target = $bits[2];
  if (exists $commands{uc($command)}) 
  {
    $commands{$command}->(@bits); 
  } 
my $_command = $bits[0];
  if (exists $_commands{uc($_command)})
  {
    $_commands{$_command}->(@bits); 
  } 
}
