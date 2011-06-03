#!/usr/bin/perl

# 2005-01-13

use Getopt::Long;
use IO::Socket;
$|++;

%opt = (
  action => "listen",
  host => "0.0.0.0",
  log_level => 4,
);

sub debug($) { return unless $opt{log_level} >= 5; print "WARN: $_[0]\n" }
sub info_($) { return unless $opt{log_level} >= 4; print "INFO: $_[0]\n" }
sub warn_($) { return unless $opt{log_level} >= 3; print "WARN: $_[0]\n" }
sub error($) { return unless $opt{log_level} >= 2; print "ERROR: $_[0]\n" }
sub fatal($) { return unless $opt{log_level} >= 1; print "FATAL: $_[0]\n"; exit 1 }

GetOptions(
  "help" => sub { $opt{action} = "help" },
  "host=s" => \$opt{host},
  "port=i" => \$opt{port},
);

if ($opt{action} eq 'help') {
  print <<HELP;
interactive-daemon.pl - start a listening TCP socket and interact line
by line with remote client

USAGE
  interactive-daemon.pl --help
  interactive-daemon.pl --port PORT [--host HOST]

OPTIONS
  --port Specify port
  --host Specify host to bind to (default is 0.0.0.0)
HELP
  exit 0;
}

fatal "Please specify --port" unless $opt{port};

$server = IO::Socket::INET->new(
  LocalAddr => $opt{host},
  Listen => 5,
  LocalPort => $opt{port},
  Proto => 'tcp',
  Reuse => 1,
) or fatal "Can't bind to $opt{host}:$opt{port}: $@";

info_ "Listening on $opt{host}:$opt{port}...";

while ($client = $server->accept) {
  $client->autoflush(1);
  info_ "Connection from ".$client->peerhost.":".$client->peerport;
  while (1) {
    print "Press 1 to type response, 2 to retrieve a line from client> ";
    $cmd = <STDIN>;
    if ($cmd =~ /^1$/) {
      print "Type response, end with Ctrl-D> "; $resp = join "", <STDIN>;
      print $client $resp;
    } elsif ($cmd =~ /^2$/) {
      $resp = <$client>;
      if ($resp) {
        chomp($resp);
        print "CLIENT: $resp\n";
      } else {
	info_ "Client ".$client->peerhost.":".$client->peerport." disconnected";
	close $client;
	last;
      }
    } else {
      error "Invalid command";
    }
  }
}

info_ "Program ended";
