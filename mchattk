#!/usr/bin/perl -w # -*-Perl-*-
#
# NOTE: portions shamefully borrowed/mutilated from Shendal's monkchat
#       some of the comments are Shendal's.
#       My comments are denoted with (ase)
#
# (ase) mchattk
# Adapted from:
# monkchat
# Shendal, June 2000
#
# Special thanks to zzamboni who created PerlMonksChat.pm
# Very special thanks to vroom for creating PerlMonks.org
# Oh, and Larry Wall's okay in my book for making perl
#
# (ase) And thanks to Shendal for the Win32:GUI code
#
# Notes:
#  - When I output to the chatterbox window, the script needs
#    to append the output to the end of the buffer.  Currently,
#    Win32::GUI doesn't have a nice way to do this.  Instead,
#    I have to select the end of the buffer and then do a 
#    ReplaceSel.  It's kludgy, but it works.
# (ase) Tk::Text widget doesn't have this problem fortunately :)
#
# To-do:
#  - while getting data from the website, the gui locks up
#    this is really annoying, but I can't figure out how 
#    to get around it.  I put a status bar there to help
#    let the user know what's going on, but it still locks.
# (ase) This is also a problem with this Tk version...
#
#  - chatterbox doesn't automatically scroll down when new
#    chatter is coming in.  I cannot find the method to 
#    move down on every insert.
# (ase) I've added the $Chatterbox->see('end') in &printMessage to fix this.
#
#  - hitting return doesn't send message - I'm not sure
#    how to bind this
# (ase) In Tk one just uses $widget->bind("<Return>",\&sub_name)
#
#  - userlist should probably be double-clickable to get info
#    on selected user (by launching a browser?)
# (ase) not implemented in this tk version yet either
#
# Version history:
#
# 0.9.2 6/16/00
#  - XP progress bar is more accurate: now reports % of way
#    from current level to next
# 0.9.1 6/16/00
#  - fixed private message formatting
#  - text now inserted at bottom of buffer
#  - added /checkoff, /co for checking off private messages
#  - added /msgs to re-print unchecked private messages
#  - sent private messages now appear in chatterbox buffer
#  - added color
# 0.9 6/15/00
#  - initial release
#
use strict;
use Tk 8.0;
use Tk::LabEntry;
use SDBM_File;
use PerlMonksChat;
use Fcntl;

# Version info
my $version     = '0.9.2';
my $status_idle = "mchattk version $version is idle";

# Polling itervals (in milliseconds)
# Set to zero to disable
my $interval_chat      = 15000;	# 15 secs
my $interval_xp        = 600000; # 10 mins
my $interval_userlist  = 60000;	# 1 mins

# Colors (ase) Note: I changed this to a hash for ease of tieing.
my %color;

tie(%color,'SDBM_File',"$ENV{HOME}/.mctk",O_RDWR|O_CREAT,0640);

my %default_color=(default=> 'black',
	private  => 'purple',
	username => 'blue',
	message  => 'green',
	error    => 'red',
	background => 'white', #chatwindow backround color
);

#set colors to default unless they have alreayd been set
for my $option (keys %default_color) {
    if ($color{$option} eq "") {
    	$color{$option} = $default_color{$option}
	}
}

# perlmonk levels
# the xp xml ticker doesn't return this, so we'll have to hard code it
my %perlmonk_levels = (1 => 0,
			2 => 20,
			3 => 50,
			4 => 100,
			5 => 200,
			6 => 500,
			7 => 1000,
			8 => 1600,
			9 => 2300,
			10 => 3000);

# This is the beast that drives everything
my $p;				# perlmonkschat object

# user information
my ($user,$passwd);


# GUI Objects (Tk objects)
my($Window);			# The over-all window object
my($Chatfield);			# object that displays all the chat text
my($Userlist);			# userlist listbox
my($UserlistLabel);		# displays number of users logged in
my($Inputfield);		# object that allows the user to type their own message
my($SayButton);			# send text button
my($Progress);			# progress bar intended to show xp & next level
my($XPLabel);			# displays XP information on the screen
my($Status);			# well, a status bar (ase) in this case a Tk canvas object
my($userinfo_w);		# userinformation window
my($unField,$pwField,$confField);

# Status vars
my ($prect,$ptext); #XP canvas items

# here we go!
&initWindow;
&initChat;
MainLoop();

################################################################################
#
# initWindow
#
# Initialize the GUI window
#
sub initWindow {

  $Window = MainWindow->new(
			    -title  => "Perlmonks Chat",
			    -width  => 600,
			    -height => 400,
				  );
  my $menubar = $Window->Menu;
  $Window->configure(-menu => $menubar);

  my $file_mb = $menubar->cascade(-label => '~File',-tearoff => 0);
  my $update_mb = $menubar->cascade(-label => '~Update',-tearoff => 0);
  my $options_mb = $menubar->cascade(-label => '~Options',-tearoff => 0);

  $file_mb->command(-label         => 'Exit',
		    -underline => 1,
		    -command   => sub {exit(0)} );

  $update_mb->command(-label => 'Chatterbox',
		      -underline => 0,
		      -command => \&updChatterbox_Click);

  $update_mb->command(-label => 'XP',
		      -underline => 0,
		      -command => \&updXP_Click);

  $update_mb->command(-label => 'Userlist',
		      -underline => 0,
		      -command => \&updUserlist_Click);

  $update_mb->separator();

  $update_mb->command(-label => 'Username/passwd',
		      -underline => 9,
		      -command => \&updUsername_Click);

  $options_mb->command(-label=> 'Chat Background',
                       -underline => 0,
                       -command=> 
        sub { $Chatfield->configure(-bg=>$Window->
                chooseColor(-initialcolor=> $Chatfield->cget(-bg),
                            -title => "Background Color"))
            }
                      );

  $options_mb->command(-label=> 'Default text',
                       -underline => 0,
                       -command=> 
	    sub { $Chatfield->tagConfigure('default',-foreground=>$Window->
                chooseColor(-initialcolor=> $Chatfield->tagCget('default',-foreground),
                            -title => "Default Text Color"));
            }
                      );

  $options_mb->command(-label=> 'Private text',
                       -underline => 0,
                       -command=> 
	    sub { $Chatfield->tagConfigure('private',-foreground=>$Window->
                chooseColor(-initialcolor=> $Chatfield->tagCget('private',-foreground),
                            -title => "Received Private /msg Text Color"));
            }
                      );

  $options_mb->command(-label=> 'Username text',
                       -underline => 0,
                       -command=> 
	    sub { $Chatfield->tagConfigure('username',-foreground=>$Window->
                chooseColor(-initialcolor=> $Chatfield->tagCget('username',-foreground),
                            -title => "Username Text Color"));
            }
                      );

  $options_mb->command(-label=> 'Message text',
                       -underline => 0,
                       -command=> 
	    sub { $Chatfield->tagConfigure('message',-foreground=>$Window->
                chooseColor(-initialcolor=> $Chatfield->tagCget('message',-foreground),
                            -title => "Sent Private /msg Text Color"));
            }
                      );

  $options_mb->command(-label=> 'Error text',
                       -underline => 0,
                       -command=> 
	    sub { $Chatfield->tagConfigure('error',-foreground=>$Window->
                chooseColor(-initialcolor=> $Chatfield->tagCget('error',-foreground),
                            -title => "Error Text Color"));
            }
                      );

  $options_mb->separator();

  $options_mb->command(-label=> 'Save Settings',
                       -underline=> 0,
                       -command=>\&save_settings);

  $options_mb->command(-label=> 'Reset to defaults',
                       -underline=> 0,
                       -command=>\&reset_settings);

  my $uframe=$Window->Frame()->pack(-side=>'top');
  my $lframe=$uframe->Frame()->pack(-side=>'left');
  my $rframe=$uframe->Frame()->pack(-side=>'left',-anchor=>'n');
  my $dframe=$Window->Frame()->pack(-side=>'top');
  my $d2frame=$Window->Frame()->pack(-side=>'bottom');

  $Chatfield = $lframe->Scrolled("Text",
				    -width    => 50,
				    -height   => 20,
				    -bg => $color{'background'},
				 -wrap => 'word',
				    -state => 'disabled',
				 -scrollbars => 'osoe',
				   )->pack(-side=>'top');

  my $itfont = $Chatfield->fontCreate('fontitalic',
                                     -family => 'courier',
                                     -size=>'9',
                                     -slant=>'italic');
  #(ase) configure color tags
  foreach(keys %color) {
	$Chatfield->tagConfigure($_,-foreground=>$color{$_});
	}

  $Chatfield->tagConfigure('italic',-font=>'fontitalic');

  $UserlistLabel = $rframe->Label(
				     -text     => "Getting userlist...",
				     -relief   => "sunken",
				    )->pack(-side=>'top',-fill=>'x');

  $Userlist = $rframe->Scrolled("Listbox",
				  -width    => 10,
				  -height   => 12,
                  -scrollbars => 'osoe',
				  -selectmode => 'single',
				 )->pack(-side=>'top',-fill=>'x');

  $Inputfield = $dframe->Entry(
				      -width    => 50,
				     )->pack(-side=>'left',-fill=>'x',-pady=>4);

  $Inputfield->bind("<Return>", \&Say_Click);

  $SayButton = $dframe->Button(
				  -text     => "Say",
			      -command => \&Say_Click
				 )->pack(-side=>'left');

  $XPLabel = "Getting XP info...";

  $Status = $d2frame->Label(
			      -text  => $status_idle,
			      -relief   => 'sunken',
			     )->pack(-side=>'left',-fill=>'x');

  $Progress = $d2frame->Canvas(-height=>21,
                              -width=>251,
                              -relief=>'sunken',
                              -borderwidth=>2)->pack(-side=>'left');
  $prect = $Progress->createRectangle(0,0,250,20,-fill=> 'red',-outline=>'red');
  $ptext = $Progress->createText(125,10,-text=>$XPLabel);
}

################################################################################
#
# initChat
#
# Initialize the chat interface
#
sub initChat {
  $p = PerlMonksChat->new();
  $p->add_cookies;
  $p->login($user,$passwd) if $user;
  $Window->repeat($interval_chat,\&updChatterbox_Click)   if ($interval_chat);
  $Window->repeat($interval_xp,\&updXP_Click)             if ($interval_xp);
  $Window->repeat($interval_userlist,\&updUserlist_Click) if ($interval_chat);
  &updChatterbox_Click;		# seed the chatterbox
  &updXP_Click;			# seed the XP info
  &updUserlist_Click;		# seed the Userlist area
}

################################################################################
#
# Say_Click
#
# What to do when the user clicks the say button
#
sub Say_Click {
  $Status->configure(-text=>"Sending data...");
  my($text) = $Inputfield->get();
  $Inputfield->delete(0,'end');
  if ($text =~ /^\s*\/msg\s+(\S+)\s*(.+)$/i) {
    $p->send($text);
    printMessage("Sent private msg to $1: $2");
  } elsif ($text =~ /^\/?(checkoff|co)\s+/ && (my @ids=($text=~/(\d+)/g))) {
    my(%msgs) = $p->personal_messages;
    $p->checkoff(map { (sort keys %msgs)[$_-1] } @ids);
    printMessage("* Checked off private msgs");
  } elsif ($text =~ /^\s*\/msgs\s*$/) {
    if (my %msgs=$p->personal_messages) {
      my($msg_num) = 1;
      foreach (sort keys %msgs) {
	printMessage("($msg_num) $msgs{$_}",'private');
	$msg_num++;
      }
    } else {
      printMessage("* No personal messages");
    }
  } else {
    $p->send($text);
    &updChatterbox_Click;
  }
  $Status->configure(-text=>$status_idle);
}

################################################################################
#
# Exit_Click
#
# What to do when the user clicks the exit menu option
#
sub Exit_Click { exit(0); }


################################################################################
#
# updChatterbox_Click;
#
# Checks for new chat messages
#
sub updChatterbox_Click {
  $Status->configure(-text=>"Checking for new chat messages...");
  my($msg_num) = 1;
  foreach ($p->getnewlines(1)) {
    if (s/^\(\d+\)/\($msg_num\)/) { 
      $msg_num++;
      printMessage("$_",'private');
    } elsif (s/^<(\S+)>//) {
      printuser($1);
      printMessage("$_",'default');
    } else {
      printMessage("$_",'italic');
    }
  }
  $Status->configure(-text=>$status_idle);
}

  sub printuser {
    my($user) = shift;
    printMessage('<','default',1);
    printMessage("$user",'username',1);
    printMessage('>','default',1);
  }

################################################################################
#
# updXP_Click
#
# Find user's current XP level and what the next level will be
#
sub updXP_Click {
  $Status->configure(-text=>"Checking for new XP information...");
  my(%xp)=$p->xp;
  if (%xp) {
    my($position) = int(( ($xp{xp}-$perlmonk_levels{$xp{level}}) /
			  ($xp{xp} - $perlmonk_levels{$xp{level}} + $xp{xp2nextlevel}) ) * 100);
     $Progress->delete($prect);
     $prect=$Progress->createRectangle(0,0,$position*2.5-1,20,-fill=>'green',
         -outline=>'green');
    my($XPLabelStr) = "Level: $xp{level}, XP: $xp{xp}, "
      . "To next: $xp{xp2nextlevel} ($position%), Votes left: $xp{votesleft}";
      $Progress->delete($ptext);
      $ptext=$Progress->createText(125,10,-text=>$XPLabelStr);
  } else {
      $Progress->delete($ptext);
      $ptext=$Progress->createText(125,10,-text=>"Could not get your XP info");
  }
  $Status->configure(-text=>$status_idle);
}

################################################################################
#
# updUserlist_Click
#
# Updates the userlist listbox
#
sub updUserlist_Click {
  $Status->configure(-text=>"Checking userlist...");
  $Userlist->delete(0,'end');
  my(%users)=$p->users;
  if (%users) {
    my $num_users = 0;
    foreach (sort keys(%users)) {
      $Userlist->insert('end',"$_"); $num_users++;
    }
    $UserlistLabel->configure(-text=>"# Users: $num_users");
  } else {
    printError("Ack!  Noone's logged in!");
    $UserlistLabel->configure(-text=>"# Users: zero!");
  }
  $Status->configure(-text=>$status_idle);
}

################################################################################
#
# updUsername_Click
#
# Updates the username/password cookie
#
sub updUsername_Click {
  $Status->configure(-text=>"Updating user information...");

   if (!$userinfo_w) {
     $userinfo_w = $Window->Toplevel(-takefocus=>1,
            					     -title  => "Update user info");
     $userinfo_w->withdraw();
     $userinfo_w->transient($Window);

     $unField = $userinfo_w->LabEntry(
 					 -label => "Username:",
 					 -width  => 25,
 					 -labelPack => [-side => 'left' ]
 					)->pack;

     $pwField = $userinfo_w->LabEntry(
 					 -label   => "Password:",
 					 -width    => 25,
 					 -show => '*',
 					 -labelPack => [-side => 'left' ]
 					)->pack;

     $confField = $userinfo_w->LabEntry(
 					   -label   => "Confirm:",
 					   -width    => 25,
 					   -show => '*',
 					   -labelPack => [-side => 'left' ]
 					  )->pack;

     $userinfo_w->Button(
 						-text     => "Cancel",
 						-command=>
 			sub { $userinfo_w->grabRelease;
 			      $userinfo_w->withdraw;
 			    }
 					       )->pack(-side =>'right',-padx=>5,-pady=>2);

     $userinfo_w->Button (
 					    -text     => "Ok",
 						-command=> \&Ok_Click
 					   )->pack(-side => 'left',-padx=>5,-pady=>2);
   }

  $userinfo_w->Popup;
  $unField->focusForce;
  $userinfo_w->protocol('WM_DELETE_WINDOW',sub {;}); #handle window 'x' button
  $userinfo_w->grabGlobal;

  $Status->configure(-text=>$status_idle);
}

  sub Ok_Click { 
  	my ($un,$pw,$co) = ($unField->Text,$pwField->Text,$confField->Text);
     unless ($un && $pw && $co) {
       printError("All fields required. Nothing changed.");
	   $userinfo_w->grabRelease;
 	   $userinfo_w->withdraw;
       return;
     }
     if ($pw ne $co) {
       printError("Password and confirmation did not match. Nothing changed.");
	   $userinfo_w->grabRelease;
 	   $userinfo_w->withdraw;
     } else {
       $p->login($un,$pw);
	   $userinfo_w->grabRelease;
 	   $userinfo_w->withdraw;
     }
   }

################################################################################
#
# printMessage and printError
#
# Prints an error or message to the chatterbox
#
sub printMessage {
  my($msg) = shift;
  my($color) = shift || 'message';
  my($omit_return) = shift;
  $msg .= "\n" unless $omit_return;
  $Chatfield->configure(-state=>'normal');
  $Chatfield->insert('end',$msg,$color);
  $Chatfield->see('end');
  $Chatfield->configure(-state=>'disabled');
}
sub printError {
  my($error) = shift;
  printMessage("ERROR: $error",'error')
}

# save color settings
sub save_settings {
    for my $option (keys %color) {
      $color{$option}=$Chatfield->tagCget($option,-foreground) unless $option eq 'background';
    }
    $color{'background'}=$Chatfield->cget(-bg);
}

# reset color settings to default values
sub reset_settings {
  foreach(keys %default_color) {
	$Chatfield->tagConfigure($_,-foreground=>$color{$_}) unless $_ eq 'background';
	}
  $Chatfield->configure(-bg => $default_color{'background'});
  save_settings;
}
