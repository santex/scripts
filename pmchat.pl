#!/usr/bin/perl -w 

 
##  
## pmchat by Nicholas J. Leon ala mr.nick (nicholas@binary9.net) 
##                                    http://www.mrnick.binary9.net 

## A text mode client for the Chatter Box of Perl Monks 
## this is not an attempt to be complete, but small and useful 
## Use it or not. No guaranteee, no warranty, blah blah 

## Now supports Win32 installations with a different ReadLine
## call.

## Autoupdate now actually autoupdates

## Oh, and it has no error checking :) 


my $ID='$Id: pmchat,v 1.42 2001/06/03 17:49:22 nicholas Exp $'; #'
 
use strict; 
use XML::Simple; 
use LWP::Simple; 
use LWP::UserAgent; 
use HTTP::Cookies; 
use HTTP::Request::Common; 
use Data::Dumper; 
use Text::Wrap qw($columns wrap); 
use Term::ReadLine; 
use Term::ReadKey qw(GetTerminalSize); 
use HTML::Parser;
use File::Copy;
 
$|++; 

my $pm='http://www.perlmonks.org/index.pl'; 
my $cookie="$ENV{HOME}/.pmcookie"; 
my $cffile="$ENV{HOME}/.pmconfig"; 
my %config=( 
            timestamp => 0, 
            colorize => 1, 
            browser => '/usr/bin/lynx %s',
            newnodes => 25,
            updateonlaunch => 0,
            timeout => 15,
           ); 
 
my %seenmsg; 
my %seenprv; 
my %xp;
my $ua;
 
## some color stuff (if you want) 
my %colormap= 
  (  
   node => [ "\e[33m", "\e[0m" ], 
   user => [ "\e[1m", "\e[0m" ], 
   code => [ "\e[32m", "\e[0m" ], 
   me => [ "\e[36m", "\e[0m" ], 
   private => [ "\e[35m","\e[0m" ],
   important => [ "\e[1;34m","\e[0m" ],
  ); 

## <readmore>
##############################################################################
##############################################################################

sub writeconfig { 
  unless (open(OUT,">$cffile")) { 
    warn "Couldn't open '$cffile' for writing: $!\n"; 
    return; 
  } 

  print OUT "$_ $config{$_}\n" for keys %config; 

  close OUT; 
} 
sub readconfig { 
  unless (open(IN,$cffile)) { 
    warn "Couldn't open '$cffile' for reading: $!\n"; 
    return; 
  } 
  
  %config=(%config,(map /^([^\s]+)\s+(.+)$/,<IN>));
  
  close IN; 
} 

## testing ... autoupdate
sub autoupdate {
  my $quiet=shift;
  my $r=$ua->request(GET "http://www.mrnick.binary9.net/pmchat/version");
  my($ver)=$r->content=~/^([\d\.]+)$/;
  my($this)=$ID=~/,v\s+([\d\.]+)/;
  
  print "This version is $this, the current version is $ver.\n" unless $quiet;

  if ($this >= $ver) {
    print "There is no need to update.\n" unless $quiet;
    return;
  }

  print "A new version is available, $ver.\n";

  $r=$ua->request(GET "http://www.mrnick.binary9.net/pmchat/pmchat");

  my $tmp=$ENV{TMP} || $ENV{TEMP} || "/tmp";
  my $fn="$tmp/pmchat-$ver";

  unless (open (OUT,">$fn")) {
    print "Unable to save newest version to $fn\n";
    return;
  }

  print OUT $r->content;
  close OUT;

  ## okay, a couple checks here: we can autoupdate IF the following
  ## are true
  if ($^O=~/win32/i) {
    print "Sorry, autoupdate not available for Windows installations.\n";
    print "The newest version has been saved in $tmp/pmchat.$ver.\n";
    return;
  }

  ## moving the old version someplace else 
  if (!move($0,"$0.bak")) {
    print "Couldn't move $0 to $0.bak, aborting.\n";
    print "The newest version has been saved in $fn.\n";
    return;
  }
  ## moving the new version to the old's location
  if (!move($fn,$0)) {
    print "Couldn't move $fn to $0, aborting $!.\n";
    move("$0.bak",$0);
    print "The newest version has been saved in $fn.\n";
    return;
  }
  ## okay! Reload!
  chmod 0755,$0;
  writeconfig;
  exec $0;
}
  

##############################################################################
##############################################################################

sub colorize {
  my $txt=shift;
  my $type=shift;

  return $txt unless $config{colorize};
  return $txt if $^O=~/win32/i;

  "$colormap{$type}[0]$txt$colormap{$type}[1]";
}

sub user {
  colorize(shift,"user");
}
sub imp {
  colorize(shift,"important");
}  
sub content {
  my $txt=shift;

  return $txt unless $config{colorize};
  return $txt if $^O=~/win32/i;

  unless ($txt=~s/\<code\>(.*)\<\/code\>/$colormap{code}[0]$1$colormap{code}[1]/mig) {
    $txt=~s/\[([^\]]+)\]/$colormap{node}[0]$1$colormap{node}[1]/g;
  }

  $txt;
}
##############################################################################
##############################################################################

sub cookie {
  $ua->cookie_jar(HTTP::Cookies->new());
  $ua->cookie_jar->load($cookie);
}

sub login {
  my $user; 
  my $pass; 
  
  ## fixed <> to <STDIN> via merlyn
  print "Enter your username: "; chomp($user=<STDIN>); 
  print "Enter your password: "; chomp($pass=<STDIN>); 
  
  $ua->cookie_jar(HTTP::Cookies->new(file => $cookie, 
                                     ignore_discard => 1, 
                                     autosave => 1, 
                                    ) 
                 ); 
  
  my $r=$ua->request( POST ($pm,[  
                                 op=> 'login',  
                                 user=> $user,  
                                 passwd => $pass, 
                                 expires => '+1y',  
                                 node_id => '16046'  
                                ])); 
}

sub xp { 
    my $r=$ua->request(GET("$pm?node_id=16046")); 
    my $xml=XMLin($r->content); 
    
    $config{xp}=$xml->{XP}->{xp} unless defined $config{xp};
    $config{level}=$xml->{XP}->{level} unless defined $config{level};


    print "\nYou are logged in as ".user($xml->{INFO}->{foruser}).".\n"; 
    print "You are level $xml->{XP}->{level} ($xml->{XP}->{xp} XP).\n"; 
    if ($xml->{XP}->{level} > $config{level}) {
      print imp "You have gained a level!\n";
    }
    print "You have $xml->{XP}->{xp2nextlevel} XP left until the next level.\n"; 

    if ($xml->{XP}->{xp} > $config{xp}) {
      print imp "You have gained ".($xml->{XP}->{xp} - $config{xp})." experience!\n";
    }
    elsif ($xml->{XP}->{xp} < $config{xp}) { 
      print imp "You have lost ".($xml->{XP}->{xp} - $config{xp})." experience!\n"; 
    }                               

    ($config{xp},$config{level})=($xml->{XP}->{xp},$xml->{XP}->{level});

    print "\n"; 
  } 
 
sub who { 
  my $req=GET("$pm?node_id=15851"); 
  my $res=$ua->request($req); 
  my $ref=XMLin($res->content,forcearray=>1); 
 
  print "\nUsers current online (";
  print $#{$ref->{user}} + 1;
  print "):\n";

  print wrap "\t","\t",map { user($_->{username})." " } @{$ref->{user}};

  print "\n";
} 
 
sub newnodes { 
  my $req=GET("$pm?node_id=30175"); 
  my $res=$ua->request($req); 
  my $ref=XMLin($res->content,forcearray=>1); 
  my $cnt=1; 
  my %users=map { ($_->{node_id},$_->{content}) } @{$ref->{AUTHOR}}; 
  
  print "\nNew Nodes:\n";
  
  if ($ref->{NODE}) {
    for my $x (sort { $b->{createtime} <=> $a->{createtime} } @{$ref->{NODE}}) { 
      print wrap "\t","\t\t", 
      sprintf("%d. [%d] %s by %s (%s)\n",$cnt,
              $x->{node_id},$x->{content},
              user(defined $users{$x->{author_user}} ? $users{$x->{author_user}}:"Anonymous Monk"),
              $x->{nodetype});
      last if $cnt++==$config{newnodes}; 
    } 
  }
  print "\n";
  
} 

##############################################################################
##############################################################################

sub showmessage {
  my $msg=shift;
  my $type=shift || '';
  
  for my $k (keys %$msg) {
    $msg->{$k}=~s/^\s+|\s+$//g
  }

  print "\r";
  
  if ($type eq 'private') {
    print wrap('',"\t",
               ($config{timestamp}?sprintf "%02d:%02d:%02d/",(unpack("A8A2A2A2",$msg->{time}))[1..3]:'').
               colorize("$msg->{author} says $msg->{content}","private").
               "\n");
  }
  else {
    if ($msg->{content}=~s/^\/me\s+//) {
      print wrap('',"\t",
                 ($config{timestamp}?sprintf "%02d:%02d:%02d/",(unpack("A8A2A2A2",$msg->{time}))[1..3]:'').
                 colorize("$msg->{author} $msg->{content}","me"),
                 "\n");
    }
    else {
      print wrap('',"\t",
                 ($config{timestamp}?sprintf "%02d:%02d:%02d/",(unpack("A8A2A2A2",$msg->{time}))[1..3]:'').
                 colorize($msg->{author},"user").
                 ": ".
                 content($msg->{content}).
                 "\n");
    }
  }
}
             

sub getmessages { 
  my $req=GET("$pm?node_id=15834"); 
  my $res=$ua->request($req); 
  my $ref=XMLin($res->content, forcearray=>1 ); 
  
  if (defined $ref->{message}) { 
    for my $mess (@{$ref->{message}}) { 
      ## ignore this message if we've already printed it out 
      next if $seenmsg{"$mess->{user_id}:$mess->{time}"}++; 

      showmessage $mess; 
    } 
  } 
  else { 
    ## if there is nothing in the list, reset ours 
    undef %seenmsg; 
  } 
} 

sub getprivatemessages { 
  my $req=GET("$pm?node_id=15848"); 
  my $res=$ua->request($req); 
  my $ref=XMLin($res->content,forcearray=>1); 
  
  if (defined $ref->{message}) { 
    for my $mess (@{$ref->{message}}) { 
      ## ignore this message if we've already printed it out 
      next if $seenprv{"$mess->{user_id}:$mess->{time}"}++; 
 
      showmessage $mess,"private"; 
    } 
  } 
  else { 
    undef %seenprv; 
  } 
} 

sub postmessage { 
  my $msg=shift; 
  my $req=POST ($pm,[ 
                     op=>'message', 
                     message=>$msg, 
                     node_id=>'16046', 
                    ]); 
  
  $ua->request($req); 
} 

sub node {
  my $id=shift;

  system(sprintf($config{browser},"$pm?node_id=$id"));
}

sub help {
  print <<EOT
The following commands are available:
    /help         :: Shows this message
    /newnodes     :: Displays a list of the newest nodes (of all types)
                     posted. The number of nodes displayed is limited by
                     the "newnodes" user configurable variable.
    /node ID      :: Retrieves the passed node and launches your user
                     configurable browser ("browser") to view that node.
    /reload       :: UNIX ONLY. Restarts pmchat.
    /set          :: Displays a list of all the user configurable
                     variables and their values.
    /set X Y      :: Sets the user configurable variable X to
                     value Y.
    /update       :: Checks for a new version of pmchat, and if it
                     exists, download it into a temporary location.
                     This WILL NOT overwrite your current version.
    /quit         :: Exits pmchat
    /who          :: Shows a list of all users currently online
    /xp           :: Shows your current experience and level.
EOT
  ;
}

##############################################################################
##############################################################################
my $old;
my $term=new Term::ReadLine 'pmchat';

sub getlineUnix {
  my $message;

  eval {
    local $SIG{ALRM}=sub { 
      $old=$readline::line; 
      die 
    };
    
    ## I don't use the version of readline from ReadKey (that includes a timeout)
    ## because this version stores the interrupted (what was already typed when the
    ## alarm() went off) text in a variable. I need that so I can restuff it 
    ## back in.

    alarm($config{timeout}) unless $^O=~/win32/i;
    $message=$term->readline("Talk: ",$old);
    $old=$readline::line='';
    alarm(0) unless $^O=~/win32/i;
  };    

  $message;
}

sub getlineWin32 {
  my $message=ReadLine($config{timeout});

  ## unfortunately, there is no way to preserve what was already typed
  ## when the timeout occured. If you are typing when it happens,
  ## you lose your text.

  $message;
}

## initialize our user agent
$ua=LWP::UserAgent->new;
$ua->agent("pmchat-mrnick"); 

## trap ^C's
## for clean exit
$SIG{INT}=sub { 
  writeconfig;
  exit 
};

## load up our config defaults
readconfig;

## for text wrapping
$columns=(Term::ReadKey::GetTerminalSize)[0] || $ENV{COLS} || $ENV{COLUMNS} || 80;

if (-e $cookie) {
  cookie;
}
else {
  login;
}

my($this)=$ID=~/,v\s+([\d\.]+)/;

print "This is pmchat version $this.\n";

autoupdate(1) if $config{updateonlaunch};
xp();
print "Type /help for help.\n";
who();
newnodes();
getprivatemessages;
getmessages();


while (1) {
  my $message;

  getprivatemessages;
  getmessages;
  
  if ($^O=~/win32/i) {
    $message=getlineWin32;
  }
  else {
    $message=getlineUnix;
  }

  if (defined $message) {
    ## we understand a couple of commands
    if ($message=~/^\/who/i) {
      who;
    }
    elsif ($message=~/^\/quit/i) {
      writeconfig;
      exit;
    }
    elsif ($message=~/^\/set\s+([^\s]+)\s+(.+)$/) {
      $config{$1}=$2;
      print "$1 is now $2\n";
    }
    elsif ($message=~/^\/set$/) {
      for my $k (sort keys %config) {
        printf "\t%-10s %s\n",$k,$config{$k};
      }
    }
    elsif ($message=~/^\/new\s*nodes/) {
      newnodes;
    }
    elsif ($message=~/^\/xp/) {
      xp;
    }
    elsif ($message=~/^\/node\s+(\d+)/) {
      node($1);
    }
    elsif ($message=~/^\/help/) {
      help;
    }
    elsif ($message=~/^\/reload/) {
      print "Reloading $0!\n";
      writeconfig;
      exec $0;
    }
    elsif ($message=~/^\/update/) {
      autoupdate;
    }
    elsif ($message=~/^\/me/ || $message=~/^\/msg/) {
      postmessage($message);
    }
    elsif ($message=~/^\//) {
      print "Unknown command '$message'.\n";
    }
    else {
      postmessage($message);
    }
  }
}