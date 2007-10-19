#!/usr/bin/perl

use strict;
use Getopt::Long;
use IO::Socket::UNIX;
$|++;

my %opt = (
  action => "listen",
  log_level => 4,
);

sub debug($) { return unless $opt{log_level} >= 5; print "WARN: $_[0]\n" }
sub info_($) { return unless $opt{log_level} >= 4; print "INFO: $_[0]\n" }
sub warn_($) { return unless $opt{log_level} >= 3; print "WARN: $_[0]\n" }
sub error($) { return unless $opt{log_level} >= 2; print "ERROR: $_[0]\n" }
sub fatal($) { return unless $opt{log_level} >= 1; print "FATAL: $_[0]\n"; exit 1 }

GetOptions(
  "help" => sub { $opt{action} = "help" },
  "sock=s" => \$opt{sock},
);

if ($opt{action} eq 'help') {
  print <<HELP;
interactive-daemon.pl - start a listening TCP socket and interact line
by line with remote client

USAGE
  interactive-daemon.pl --help
  interactive-daemon.pl --sock PATH

OPTIONS
  --port Specify path of UNIX socket
HELP
  exit 0;
}

fatal "Please specify --sock" unless $opt{sock};
my $sock_path = $opt{sock};

my $sock = IO::Socket::UNIX->new(Type=>SOCK_STREAM, Peer=>$sock_path);
my $err = $@ unless $sock;
if ($sock) {
  fatal("Some process is already listening on $sock_path, aborting");
} elsif ($err =~ /^connect: permission denied/i) {
  fatal("Cannot access $sock_path, aborting");
} elsif ($err =~ /^connect: connection refused/i) {
  unlink $sock_path;
} elsif ($err !~ /^connect: no such file/i) {
  fatal("Cannot bind to $sock_path: $err");
}

my $server = IO::Socket::UNIX->new(
  Listen => 5,
  Local => $opt{sock},
) or fatal "Can't bind to $opt{sock}: $@";

info_ "Listening on $opt{sock}:...";

while (my $client = $server->accept) {
  $client->autoflush(1);
  info_ "Connection";
  while (1) {
    print "Press 1 to type response, 2 to retrieve a line from client> ";
    my $cmd = <STDIN>;
    if ($cmd =~ /^1$/) {
      print "Type response, end with Ctrl-D> "; my $resp = join "", <STDIN>;
      print $client $resp;
    } elsif ($cmd =~ /^2$/) {
      my $resp = <$client>;
      if ($resp) {
        chomp($resp);
        print "CLIENT: $resp\n";
      } else {
	info_ "Client disconnected";
	close $client;
	last;
      }
    } else {
      error "Invalid command";
    }
  }
}

info_ "Program ended";
