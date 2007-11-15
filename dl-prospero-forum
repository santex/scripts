#!/usr/bin/perl

my $HOST = "forums.prosperotechnologies.com";
my $PORT = 80;
my $PREFIX = "delphiforums.";
my %months = qw(Jan 1 Feb 2 Mar 3 Apr 4 May 5 Jun 6 Jul 7 AUg 8 Sep 9 Oct 10 Nov 11 Dec 12);

# 030616

$|++;
use strict;
use LWP::UserAgent;
use Getopt::Long;
use HTTP::Cookies;
use HTTP::Request::Common qw(GET POST);

sub _log($$);
sub _logdie($$);

my $verbosity=1;
my $user="";
my $pass="";

GetOptions(
    'verbosity|v=i' => \$verbosity,
    'user=s' => \$user,
    'pass=s' => \$pass,
);

if (@ARGV != 1 && @ARGV != 2) {
    die <<_;
Usage: $0 [options] <forumname> <dir>
Options:
  --cookie C     Supply C as the cookie. can be supplied more than once.
  --verbosity N  Set verbosity between 0 to 9. Default is 1.
_
}

my ($forumname, $dir) = @ARGV;
$dir ||= "$PREFIX$forumname";
$forumname =~ /^[A-Za-z0-9_-]+$/ or _logdie(1, "FATAL: Bad forum name `$forumname'");

my $thisyear = (localtime)[5]+1900;

my $ua = new LWP::UserAgent;
my $cj = new HTTP::Cookies;
$ua->cookie_jar($cj);
my ($req, $resp);

_log(1, "checking forumname `$forumname'...");
$req = GET "http://$HOST/$forumname";
_log(9, reqinfo($req));
$resp = $ua->request($req);
do { $resp = $ua->request($req) } if $resp->is_redirect; # site will redirect to login page and back to so $ua->request will return

unless ($resp->is_success) {
    if ($resp->is_redirect) {
        my $rurl = GetRedirectUrl($resp);
        if ($rurl =~ /notfound/) {
            _logdie(1, "FATAL: forum `$forumname' not found");
        } elsif ($rurl =~ /clientLogin/) {
            _logdie(1, "FATAL: forum needs login, please supply user & pass");
        } else {
            _logdie(1, "FATAL: got redirected to `$rurl', can't handle this");
        }
    } else {
        _logdie(1, "FATAL: got response code: ".$resp->code);
    }
}

if (!(-d $dir)) {
    _log(5, "$dir doesn't exist, creating dir...");
    mkdir $dir, 0755 or _logdie(1, "FATAL: Can't mkdir `$dir': $!");
}

# collect thread information
#do {
#    my $threadspage = $resp->content;
#};

sub _log($$) {
    my ($level, $msg) = @_;
    return if $verbosity < $level;
    print "[$level] $msg\n";
}

sub _logdie($$) {
    _log($_[0], $_[1]);
    exit 1;
}

# return the URL we're redirected to
sub GetRedirectUrl($) {
    my $response = $_[0];

    my $url = $response->header('Location') || return undef;

    # the Location URL is sometimes non-absolute which is not allowed, fix it
    local $URI::ABS_ALLOW_RELATIVE_SCHEME = 1;
    my $base = $response->base;
    $url = $HTTP::URI_CLASS->new($url, $base)->abs($base);

    return $url;
}

sub reqinfo($) {
    my $req = $_[0];
    $req->method . " " . $req->uri;
}

sub strip($) {
}
