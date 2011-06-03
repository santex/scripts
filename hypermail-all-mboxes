#!/usr/bin/perl
use Getopt::Long;
$|++;

# 20040204, adds --nobak option; --nocontrive now defaults to 1; fix typo ($nohcc, should've been $nohhc).
# 20021223, now accepts arguments, if no arguments then will still process all mboxes in current directory.
# 200211xx, now accepts some options
# 200208xx, first write

$verbose = 1;
$nohide = 0;
$progress = 0;
$nohhc = 1;
$showtocc = 0;
$preserve_delivery = 0;
$help = 0;
$backup = 1;
$nocontrive = 1;
$checknum = 0;
GetOptions(
  'nobak' => sub { $backup=0 },
  'nohide' => \$nohide,
  'nocontrive' => \$nocontrive,
  'showtocc' => \$showtocc,
  'preserve-delivery' => \$preserve_delivery,
  'nohhc' => \$nohhc,
  'verbose' => \$verbose,
  'progress' => \$progress,
  'checknum' => \$checknum,
  'help|?' => \$help,
);

if ($help) {
  print <<_;
Usage: $0 [options] [mbox ...]

Create hypertext archive from monthly mbox files, using Hypermail. This
script is a convenient wrapper for Hypermail. The The mbox files are
preprocessed first (e.g. unnecessary headers are removed), and the hypertext
pages are preprocessed (e.g. email addresses are trimmed to avoid
harvesting, etc.) The mbox files need to be named like 200212.mbo?x or
200201-200212.mbo?x to be accepted by this script. If no mbox files is
specified, will process all *.mbx and *.mbox in the current directory.

Options:

--nobak = don't create .mbox.bz2 files
--nohide = do not trim email addresses
--nocontrive = do not contrive subject headers
--showtocc = show to/cc headers in the message pages
--preserve-delivery = do not strip Delivered-To/Path/etc. from mbox files
--nohhc = do not strip long strings that might crash the HTML Help Compiler
--verbose = be verbose
--progress = show Hypermail progress
--checknum = check the number of messages
_
 
  exit 0;
}

@ARGV = (<*.mbx>,<*.mbox>) if not @ARGV;

for (@ARGV) {
  $files{$_}++ and next; -f or next;
  /^((?:20|19)?)(\d\d)-?(\d\d)(\.mbo?x)?$/ and $dir=($1 ? $1:"20")."$2$3" or
  /^(\d\d\d\d\d\d)-(\d\d\d\d\d\d)\.mbo?x$/ and $dir="$1-$2" or
  do {warn "\n=====cant recognize mailbox name: $_, skipped=====\n\n";next};
  
  print "+ $_ -> $dir\n";
  print "  + making sure line ending is unix-style...\n";
  system "'from-dos!' $_";
  die "    failed ($?)\n" if $?;

  unless ($preserve_delivery) {
    print "  + removing delivery headers from $_...\n";
    system "'strip-delivery-headers!' $_";
    die "    failed ($?)\n" if $?;
  }

  $bak="$dir.mbox.bz2";
  unless ((-f $bak) || !$backup) {
    print "  + backing up $_ -> $bak...\n";
    system "bzip2 -c $_ > $bak" unless -f $bak;
    die "    failed ($?)\n" if $?;
  }

  print "  + disabling X-No-Archive headers...\n";
  system "'disable-no-archive!' $_";
  die "    failed ($?)\n" if $?;

  print "  + inserting random Message-ID header to messages that lack one...\n";
  system "'insert-random-message-ids!' $_";
  die "    failed ($?)\n" if $?;
  unless (-d $dir) {mkdir $dir,0755 or do{warn "\n=====cant mkdir $dir, skipped=====\n\n";next}}

  print "  + running hypermail...\n";
  system "${\($showtocc ? 'HM_SHOWHEADERS=1 HM_SHOW_HEADERS=Message-ID,To,Cc ':'')} hypermail ${\($progress ? '-p':'')} -d $dir -m $_";
  die "    failed ($?)\n" if $?;

  chdir $dir;
  @b=glob"[0-9]*.html";
  if ($checknum) {
    print "  + checking number of messages... ";
    {
      local $/;
      open F,"../$_" or die "cant open $_ for reading, aborting\n";
      @a=<F>=~/^From /mg;
      print scalar(@a)," (mbox) vs ",scalar(@b)," (hypermail)\n";
    }
  }
  
  unless ($nocontrive) {
    print "  + contriving <title>s...\n";
    system "find -maxdepth 1 -name \x27[0-9]*.html\x27 | xargs -n 1000 'contrive-hypermail-message-subject!'";
    die "    failed ($?)\n" if $?;
  }
  
  unless ($nohhc) {
    print "  + removing things that might crash html help compiler...\n";
    system "find -maxdepth 1 -name \x27[0-9]*.html\x27 | xargs -n 1000 'remove-hhc-crasher!'";
    die "    failed ($?)\n" if $?;
  }
  
  unless ($nohide) {
    print "  + hiding email addresses...\n";
    system "find -maxdepth 1 -name \x27*.html\x27 | xargs -n 1000 'hide-email-domains!'";
    die "    failed ($?)\n" if $?;
  }

  chdir "..";
}
