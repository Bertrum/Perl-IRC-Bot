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

my %commands = (     # we've already declared %commands above as "my" (local)
  JOIN => sub {   # command is the key, instructions on how to parse that command are in the value as an anonymous subroutine
    my ($source, $cmd, $target) = @_; # this is what a JOIN line looks like: :miniCruzer!eyeless@255.255.255.255 JOIN :#Corinth"
    # we want to say hello to $source in $target

    my $nick = (split '!', $source)[0]; # split() turns each element into an array. we can shortcut this array by adding "[0]" (first element that gets split)
    # if source is :miniCruzer!eyeless@255.255.255.255, then $nick is now ":miniCruzer"
    $nick = substr $nick, 1; # remove the ':'
    $target = substr $target, 1; # same for the channel

    quote("PRIVMSG $target :Hello, $nick!");
  }, # separate with a ','
  '001' => sub {  # numeric 001 is the first numeric recieved, it means "welcome", and looks a bit like this: 
    my ($server, $cmd, $target, @msg) = @_;  # :doom.ca.us.paradoxirc.net 001 Perl :Welcome to the ParadoxIRC IRC Network Perl!perl@188.165.74.48
    quote("JOIN $channel"); # this tells the server I WONNA JOIN #PERL
  },
  PRIVMSG => sub {
    my ($src, $cmd, $target, @msg) = @_;
  }
);

quote("NICK $mynick");                # this is registration to the server. we're introducing our self as
quote("USER $mynick 8 $ident :realname"); # Perl!perl, and our real name is LOL PERL!



while ($buffer = <$sock>) # < > resembles the output of the socket file. we store it as $buffer
{
  print "R: $buffer"; # we don't need "\n" here, see next line
  chomp $buffer; # $sock adds the "\r\n" suffixes to print new lines to us. we'll remove these before parsing, but after printing.

  parse($buffer); # parse points to sub parse {} below
}

close $sock; # this means that $sock has stopped talking to us, so we'll close our end too

sub parse {
  my ($buffer) = @_; # @_ is the array of variables that are passed to the subroutine. you MUST put ()s around the variable!

  my @bits = split ' ', $buffer; # irc proto is consistent. :<source> <command> <target> [<other-arguments>]

  my $source = $bits[0]; # all arrays start counting at 0. math teachers start counting at 1;
  my $command = $bits[1];
  my $target = $bits[2];

  # now we can begin parsing. life is easier when you parse without regex.
 
  # to do this, we shall use a sub routine for EACH command. these are stored
  # anonymously (without a name) in the hash %commands. this may become foggy...

  if (exists $commands{uc($command)}) # check to see if we can parse this command
  {
    # I guess we can!
    $commands{$command}->(@bits); # this sends the anonymous subroutine defined at "$command" the whole line split into spaces.
  } 
}
