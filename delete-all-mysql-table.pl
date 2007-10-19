#!/usr/bin/perl

# 040617

use Getopt::Long;
use DBI;

# ---

$db = "";
$user = "";
$pass = "";
$host = "localhost";
$port = 3306;

GetOptions(
  '--db=s' => \$db,
  '--user=s' => \$user,
  '--pass=s' => \$pass,
  '--host=s' => \$host,
  '--port=i' => \$port
);

die "Please specify --db\n" if !$db;
die "Please specify --user\n" if !$user;
die "Please specify --pass\n" if !$pass;
die "Please specify --host\n" if !$host;
die "Please specify --port\n" if !$port;

$dbh = DBI->connect("DBI:mysql:database=$db;host=$host;port=$port", $user, $pass, {RaiseError => 0}) or 
  die "Failed to connect to db: $DBI::errstr\n";

#@tables = map { s/.*\.//; $_ } $dbh->tables;
@tables = $dbh->tables;

$n = 0;
for (sort @tables) {
  #print "$_\n";
  $dbh->do("DROP TABLE $_") or do {
    warn "Warning: failed deleting table $_: ".$dbh->errstr."\n";
    next;
  };
  $n++;
}

print "$n table(s) deleted\n";
