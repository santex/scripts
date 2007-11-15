#!/usr/bin/perl

# 2004-08-13

use strict;
use DBI;

my $DBNAME = "slksmtpd";
my $DBUSER = "steven";
my $DBPASS = "";
my $DBHOST = "localhost";
my $DBPORT = "5433";

my $COMMIT_EVERY = 1000;

# ---

my $dbh;

# ---

sub table_exists {
  my $tablename = shift;
  $dbh->tables('', '', $tablename) ? 1:0;
}

# ---

$dbh = DBI->connect("DBI:Pg:dbname=$DBNAME;host=$DBHOST;port=$DBPORT", $DBUSER, $DBPASS);

if (!table_exists('accesslog')) {
  $dbh->do("
  CREATE TABLE accesslog (
    id SERIAL PRIMARY KEY,
    authuser TEXT NOT NULL,
    cc CHAR(2) NOT NULL,
    ip INET NOT NULL,
    time TIMESTAMP NOT NULL,
    dur FLOAT NOT NULL,
    numtx SMALLINT NOT NULL CHECK (numtx >= 0),
    subj TEXT NOT NULL,
    statusstr TEXT NOT NULL,
    statusnum SMALLINT NOT NULL CHECK (statusnum >= 100 AND statusnum <= 999),
    bytes INT NOT NULL CHECK (bytes >= 0),
    sender TEXT NOT NULL
  ) WITHOUT OIDS");
  $dbh->do("CREATE INDEX idx1 ON accesslog(cc)");
  $dbh->do("CREATE INDEX idx2 ON accesslog(ip)");
  $dbh->do("CREATE INDEX idx3 ON accesslog(statusstr)");
  $dbh->do("CREATE INDEX idx4 ON accesslog(statusnum)");
}

if (!table_exists('recipient')) {
  $dbh->do("
  CREATE TABLE recipient (
    accesslog_id INT NOT NULL REFERENCES accesslog(id),
    recipient TEXT NOT NULL
  ) WITHOUT OIDS");
  $dbh->do("CREATE INDEX idx5 ON recipient(recipient)");
}

# all or nothing

$dbh->{AutoCommit} = 0;

my $stha = $dbh->prepare("INSERT INTO accesslog (authuser,cc,ip,time,dur,numtx,subj,statusstr,statusnum,bytes,sender) 
                          VALUES (?,?,?,?,?,?,?,?,?,?,?)");
my $sthr = $dbh->prepare("INSERT INTO recipient (accesslog_id,recipient) VALUES (CURRVAL('accesslog_id_seq'),?)");

my $i = 0;
while (<>) {
  ++$i;
  
  chomp;
  m!^([^.]+)\. # authuser
     ([a-z][a-z]|-)\. # cc
     (\d+\.\d+\.\d+\.\d+) \s # ip
     \[(\d+/\w+/\d\d\d\d:\d\d:\d\d:\d\d \s [+-]\d\d\d\d)\] \s # time
     (\d+\.\d+)s \s # dur
     (\d+)tx \s # numtx
     "([^"]*)" \s # subj
     (\w+)\((\d\d\d)\) \s # statusstr & statusnum
     (\d+)b \s # bytes
     "([^"]*)" \s # sender
     \d+r \s # (numrcpt)
     "([^"]*)" # rcpts    "<-- just to fool the stupid joe 3.0 syntax highlighter
   !x or 
  die "FATAL: Line $.: Syntax error\n";
  
  my ($authuser, $cc, $ip, $time, $dur, $numtx, $subj, $statusstr, $statusnum, $bytes, $sender, $rcpts) = 
  ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12);
  
  $authuser =~ tr/=/./;
  my @rcpts = split /, /, $rcpts;
  
  $stha->execute($authuser, $cc, $ip, $time, $dur, $numtx, $subj, $statusstr, $statusnum, $bytes, $sender)
    or die "FATAL: Line $.: Transaction failed [a]\n";
  for (@rcpts) { $sthr->execute($_) or die "FATAL: Line $.: Transaction failed [r]\n"; }
  
  do { print STDERR "$i...\n"; $dbh->commit } if $i % $COMMIT_EVERY == 0;
}

do { print "$i\n"; $dbh->commit } if $i % $COMMIT_EVERY;
