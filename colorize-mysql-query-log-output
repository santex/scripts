#!/usr/bin/perl

# 2004-10-16

# usage: tail -f /var/log/mysql/query.log | this-script

$opt_colorize_different_conn = 1;
$opt_colorize_sql = 1;
$opt_count_query = 1; # show query counter per connection

###

use Tie::Cache;

$|++;

%COLOR_CODES = (
  normal       => "\x1b[0m",

  black        => "\x1b[0;30m",
  red          => "\x1b[0;31m",
  green        => "\x1b[0;32m",
  brown        => "\x1b[0;33m",
  blue         => "\x1b[0;34m",
  magenta      => "\x1b[0;35m",
  cyan         => "\x1b[0;36m",
  white        => "\x1b[0;37m",

  bold_black   => "\x1b[1;30m",
  bold_red     => "\x1b[1;31m",
  bold_green   => "\x1b[1;32m",
  bold_brown   => "\x1b[1;33m",
  bold_blue    => "\x1b[1;34m",
  bold_magenta => "\x1b[1;35m",
  bold_cyan    => "\x1b[1;36m",
  bold_white   => "\x1b[1;37m",

  rev_black        => "\x1b[7;30m",
  rev_red          => "\x1b[7;31m",
  rev_green        => "\x1b[7;32m",
  rev_brown        => "\x1b[7;33m",
  rev_blue         => "\x1b[7;34m",
  rev_magenta      => "\x1b[7;35m",
  rev_cyan         => "\x1b[7;36m",
  rev_white        => "\x1b[7;37m",

  rev_bold_black   => "\x1b[7;1;30m",
  rev_bold_red     => "\x1b[7;1;31m",
  rev_bold_green   => "\x1b[7;1;32m",
  rev_bold_brown   => "\x1b[7;1;33m",
  rev_bold_blue    => "\x1b[7;1;34m",
  rev_bold_magenta => "\x1b[7;1;35m",
  rev_bold_cyan    => "\x1b[7;1;36m",
  rev_bold_white   => "\x1b[7;1;37m",
);

@CONN_COLORS = qw(
  cyan
  brown
  green
  bold_red
  bold_cyan
  bold_blue
  bold_green
);

$CONNECT_COLOR     = "rev_bold_magenta";
$DISCONNECT_COLOR  = "rev_red";
$QUERY_COLOR       = "bold_brown";


tie %counters, 'Tie::Cache', 100;
$in_query = 0;

# konversi nama warna jadi escape codes
sub c { ($_[0] eq 'normal' ? '' : $COLOR_CODES{normal}) . $COLOR_CODES{$_[0]} }

# print escape code untuk warna connection id
sub connc { c($opt_colorize_different_conn ? $CONN_COLORS[ $_[0] % @CONN_COLORS ] : "normal") }

sub normc { c("normal") }

$conn = 0;
while (<>) {
  chomp;
  if (($timestamp, $_conn, $cmd, $arg) = /^(\d{6} \d\d:\d\d:\d\d\t|\t\t) ([0-9 ]{5}[0-9]) ([\w ]{11})(.*)/) {
    $conn = $_conn;
    $in_query = $cmd =~ /^Query/ ? 1 : 0;
    $cmd_color = $cmd =~ /^Connect/ ? $CONNECT_COLOR : ($cmd =~ /^Query/ ? $QUERY_COLOR : ($cmd =~ /^Quit/ ? $DISCONNECT_COLOR : "normal"));
    print $timestamp, " ", connc($conn), $conn, " ", c($cmd_color), $cmd;
    if ($in_query) {
      # $arg =~ s/^\s+//; $arg = "\n$arg";
      if ($opt_count_query) {
	$counters{$conn}++;
	print normc(), " (#$counters{$conn}) ";
      }
      print +($opt_colorize_sql ? connc($conn) : c($QUERY_COLOR)), $arg;
    } else {
      print $arg;
    }
  } else {
    if ($in_query) {
      print +($opt_colorize_sql ? connc($conn) : c($QUERY_COLOR)), $_;
    } else {
      print;
    }
  }
  #041016 14:34:05     102 Connect
  #041016 14:34:05 xxxxxx x Connect

  print normc(),"\n";
}
