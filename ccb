#! /usr/bin/perl -w
####################################################################
# ccb.pl - a Chatterbox client written in Perl Curses              #
####################################################################
# Abstract: ccb is a simple curses interface to the chatterbox     #
#         : feature of the PerlMonks.org website.                  #
#         : Some functionality is missing, but it is designed to   #
#         : to meet some very specific goals - and should be easy  #
#         : to enhance.                                            #
#                                                                  #
# Thanks  : Go to Shendal for his Perk/Tk client,                  #
#         : Zzamboni for the PerlMonks modules and the sample code #
#         : Vroom for creating PerlMonks.org                       #
#         : ybiC for saying "A curses CB client would be mondo++!" #
#         : and merlyn, for not turning me into a frog             #
#         : Lots of other people that deserve mention              #
#                                                                  #
# History : 20011004 - mbl - Initial version.                      #
#         : 20011006 - mbl - Some primitive functionality is here. #
#         : 20011007 - mbl - Created the chat buffer object.       #
#         :                - I guess I pretty much made the whole  #
#         :                - thing work - all options and stuff.   #
#         : 20011008 - mbl - Fixed a little big in the log buffer  #
#         :                - and some other screen bugs.           #
#         : 20011015 - mbl - Removed some of the lag by correcting #
#         :                - the timing and help in a window.      #
#         : 20011016 - mbl - Forking code added.                   #
#         : 20011018 - mbl - More things to make the behavior      #
#         :                - match the CB spec.                    #
#         : 20011021 - mbl - Added support for ignore/unignore     #
#         : 20011022 - mbl - Adjusted IPC timing to reduce errors. #
#         : 20011024 - mbl - Added support for timestamps.         #
#         : 20011025 - mbl - Added confirm odd message dialog.     #
#         : 20011026 - mbl - Added support to save message buffer. #
#         : 20011027 - mbl - Fixed a bug when the child lags.      #
#         :                - Some private message handling.        #
#         : 20011104 - mbl - Some more tweaks to IPC.              #
#                                                                  #
# To-do   : More fun stuff, like colors.                           #
#         : Get personal messages checkoff to work.                #
#         : Improvements to the IPC performance might be possible. #
#         : I *still* like the idea of a PM minibrowser...         #
####################################################################
# Boring, pointless crap:                                          #
# This is free software that may be distributed under the same     #
# license as Perl itself.  This software comes with no warranty.   #
#                                                                  #
# I suppose that it's Copyright (C) 2001 M. Litherland             #
#                                                                  #
# Get the latest version from http://www.nule.org/ which is also   #
# where the author can be reached.                                 #
####################################################################
my $VERSION = "1.0pre2a"; 

# change your @INC if you have weird module locations.
use lib "/home/litherm/lib/perl5/site_perl/5.6.1/PerlMonksChat2";

use strict;
use Curses;
use Curses::Widgets;
use IO::Handle qw(autoflush);
use Socket;
use Text::Wrap;

# PM Modules
use PerlMonks::Chat;
use PerlMonks::Users;

# Record separator for IPC
use constant RSEPARATOR => "MiKeIsDaUbErCoDeR"; #:)

#############
# Variables #
#############

# Widgets
my ($main, $input, $display, $dialog);

# Variables for dealing with curses widgets
my ($text, $test);

# Handles for our PM objects
my ($chat, $monks, $buffer, $pid);

# More variables
my ($username, $password);

###########################
# Initialize chat package #
###########################

# I'm a newbie when it comes to OO Perl too - be gentle...
{ package Chat;

# Object constructor
sub new
{
	my $self = {};
	shift; # Package name

	# Counter for updating the buffer
	$self->{COUNTER}   = time();
	$self->{MCOUNTER}  = 20; # Max time

	# Flag for time stamps
	$self->{TIMESTAMP} = 1;  # 0 is off

	# Variables for working with the buffer
	$self->{POSITION}  = 0;
	$self->{LENGTH}    = 500;
	$self->{BUFFER}    = []; # Message buffer

	bless($self);
	return $self;
}

# Provide a method for changing the buffer size
sub length 
{
	my $self = shift;
	
	if (@_)
	{
		$self->{LENGTH} = shift;
	}

	return $self->{LENGTH};
}

# Provide a method for toggling the time stamp
sub show_time
{
	my $self = shift;
	
	if (@_)
	{
		$self->{TIMESTAMP} = shift;
	}

	return $self->{TIMESTAMP};
}

# A simple counter to set the chat request interval.
# Passing a value instead sets the Max Counter interval,
# returns the time remaining (0 if done);
sub counter
{
	my $self = shift;
	my $delta;
	
	if (@_)
	{
		$self->{MCOUNTER} = shift;
	}

	$delta = ($self->{COUNTER} + $self->{MCOUNTER}) - time();

	if ($delta <= 0)
	{
		$self->{COUNTER} = time();

		return 0;
	}
	else
	{
		return $delta;
	}
}

# Add lines into the scrollback buffer
sub addlines
{
	my $self = shift;
	my $line;

	if (@_)
	{
		foreach $line (@_)
		{
			# Attempt to remove empty lines.
			next if ($line =~ /^\s*$/);

			# Add the line in the next available position
			# in the buffer
			$self->{BUFFER}[$self->{POSITION}] = $line;

			# If we are at the last available position in
			# the buffer, reset and start over.
			if ($self->{POSITION} >= $self->{LENGTH})
			{
				$self->{POSITION} = 0;
			}
			else
			{
				$self->{POSITION}++;
			}
		}
	}
}

# Return an array with the number of lines requested.
sub getlines
{
	my $self = shift;
	my ($rows, $i, $position);
	my (@return);

	if (@_)
	{
		$rows = shift;
		# POSITION is one past the current line (ahem, bug? :-)
		$position = $self->{POSITION} - $rows - 1;
		$position += $self->{LENGTH} if ($position < 0);

		for ($i = 0; $i < $rows; $i++)
		{
			# Set the position ahead, but rewind if hit the
			# end.
			$position++;
			$position = 0 if ($position >= $self->{LENGTH});

			# When first initialized Much of the buffer may
			# be empty.
			if (defined($self->{BUFFER}[$position]))
			{
				push @return, $self->{BUFFER}[$position];
			}
			else
			{
				push @return, "";
			}
		}
	}

	return @return;
}

} # Back to the main package

################
# Main Routine #
################

# Create a new main window
$main = new Curses;

# Configure some options
noecho();         # Disable echoing from the console.
$main->keypad(1); # Map special keys.
halfdelay(10);    # This works like Poll when a function is passed
                  # to a widget. Redraws the chat window every 2
		  # seconds, and gets new messages per /freq
$main->erase();
select_colour($main, 'black');
$main->attrset(0);

&header();

# Prompt for username and pass
($text, $test) = input_box(
	'title' => "Logon",
	'prompt' => "Enter your PM username",
	'border' => "white",
	'cursor_disable' => 1,
	'function' => \&header
);

if (($test == 1) && ($text ne ""))
{
	$username = $text;
}
else
{
	&handle_error("Username required and not provided");
}

($text, $test) = input_box(
	'title' => "Logon",
	'prompt' => "Enter your PM password",
	'border' => "white",
	'cursor_disable' => 1,
	'password' => 1,
	'function' => \&header
);

if (($test == 1) && ($text ne ""))
{
	$password = $text;
}
else
{
	&handle_error("Password required and not provided");
}

# Get rid of the login boxes while we wait
$main->erase();
$main->addstr(0, 1, "Attempting to log in, please wait...");
$main->refresh();

# Log in (all your password are belong to us)
$chat = PerlMonks::Chat->new();
$chat->add_cookies;

$chat->login($username, $password)
	or &handle_error("Could not login: $!");

$monks = PerlMonks::Users->new();
$monks->add_cookies;

# Produce a child to handle the transactions.
$main->addstr(1, 1, "Starting child process...");
$main->refresh();

# Create a socketpair
socketpair(CHILD, PARENT, AF_UNIX, SOCK_STREAM, PF_UNSPEC)
	or &handle_error("Socket could not be created.");
CHILD->autoflush(1);
PARENT->autoflush(1);

# Fork here
if ($pid = fork())
{
	close PARENT;

	# Create a chat buffer
	$buffer = new Chat;
	print CHILD $buffer->counter . "\n";
}
else
{
	close CHILD;

	&child();

	exit 0;
}

# Clear the screen
$main->erase();
$main->refresh();

# From now on the &message subroutine and the chat $buffer handle
# all screen draws.
$buffer->addlines("{CCB} - Curses Chatterbox client, Type '/help' for available commands.");

# Main loop
while (1)
{
	($test, $text) = txt_field(
		'window' => $main,
		'regex' => "\n",
		'xpos' => 0,
		'ypos' => $LINES - 3,
		'lines' => 1,
		'cols' => $COLS - 2,
		'border' => "white",
		'cursor_disable' => 1,
		'function' => \&messages
	);

	chomp $text;
	
	# Begin processing the message entered
	if ($text =~ /^\/help/i)
	{
		&help_popup($buffer);
	}
	elsif ($text =~ /^\/who/i)
	{
		&list_users($buffer);
	}
	elsif ($text =~ /^\/xp/i)
	{
		&show_xp($buffer);
	}
	elsif ($text =~ /^\/log/i)
	{
		&show_log($buffer, "SHOW");
	}
	elsif ($text =~ /^\/save/i)
	{
		&show_log($buffer, "SAVE");
	}
	elsif ($text =~ /^\/msgs/i)
	{
		&show_msgs($buffer);
	}
	#elsif ($text =~ /^\/(?:checkoff|co)\s+/i)
	#{
		# Don't quite have this figured out...
	#}
	elsif ($text =~ /^\/freq\s*(\d*)/i)
	{
		# This is used to set an alarm and shouldn't be
		# too small.
		my $min = 5;
		if ($1 > $min)
		{
			$buffer->counter($1);
			$buffer->addlines("{CCB} - Interval set to $1");
		}
		else
		{
			$buffer->addlines("{CCB} - Interval must be greater than $min");
		}
	}
	elsif ($text =~ /^\/time/i)
	{
		if ($buffer->show_time)
		{
			$buffer->show_time(0);
			$buffer->addlines("{CCB} - Time stamps disabled");
		}
		else
		{
			$buffer->show_time(1);
			$buffer->addlines("{CCB} - Time stamps enabled");
		}
	}
	elsif ($text =~ /^\/(?:msg|tell)\s+(\S+)\s+(.+)$/i)
	{
		# A private message is being sent
		$chat->send($text);

		$buffer->addlines(split "\n", wrap("", "\t", "{CCB} - private message sent to $1: $2"));
	}
	elsif ($text =~ /^\/(ignore|unignore)\s+(\S+)/i)
	{
		my $action = lc($1);
		my $user = $2;

		$action =~ s/.$/ing/;

		# A private message is being sent
		$chat->send($text);

		$buffer->addlines(split "\n", wrap("", "\t", "{CCB} - $action user $user"));
	}
	elsif ($text =~ /^\/me\s*/i)
	{
		# /me emotes.
		$chat->send($text);
	}
	elsif ($text =~ /^\/quit/i)
	{
		# Ask the child to exit then quit.
		$main->erase();
		$main->addstr(0, 1, "Ending child process...");
		$main->refresh();

		# Code to exit.
		print CHILD "-1\n";

		waitpid($pid, 0);
		exit 0;
	}
	elsif (($text =~ /^\s{0,1}\//) || ($text =~ /^.{0,2]msg/i))
	{
		# All valid forms of commands are accounted for,
		# here we can handle near misses.
		
		($text, $test) = input_box(
			'title' => "Vague response",
			'prompt' => "Please confirm, cancel or change your message:",
			'border' => "white",
			'content' => "$text",
			'cursor_disable' => 1
		);

		if (($test == 1) && ($text ne ""))
		{
			# Text was confirmed to send.
			$chat->send($text);
		}
		else
		{
			$buffer->addlines("{CCB} - message not sent");
		}
	}
	else
	{
		# Try to send whatever message was entered.
		if ($text ne "")
		{
			$chat->send($text);
		}
	}
}

END
{
	# Ask Curses to exit cleanly.
	endwin();
}

exit 0;

###############
# Subroutines #
###############

sub header
{
	# Display a nice header whilst we perform various tasks
	$main->standout();
	$main->addstr(0, 1, "{CCB} - Curses ChatterBox Client by {NULE} v. $VERSION");
	$main->standend();
	$main->refresh();
}

sub child
{
	my ($request, $text);

	# Listen for a timing value from the parent.
	# Request the resource from
	while (1)
	{
		chomp($request = <PARENT>);

		if ($request == -1)
		{
			# We have been asked to exit
			return 1;
		}
		else
		{
			# The parent is expecting a response
			# in this many seconds or we will
			# send a lag error message
			eval
			{
				local $SIG{ALRM} = sub { die "ALARM\n" };
				alarm ($request - 1);
				$text = join "\n", $chat->getnewlines(1);
				alarm 0;
			};

			if ($@)
			{
				# Timeouts are different from other problems
				print PARENT "{CCB} - ERROR with child: $@" unless $@ eq "ALARM\n";
				# Request timed out
				print PARENT "{CCB} - Lag problem, try setting /freq higher..."
					. RSEPARATOR;
			}
			else
			{
				print PARENT "$text" . RSEPARATOR;
			}
		}
	}
}

sub messages
{
	# Note that our handles are global here because Curses::Widgets 
	# doesn't seem amenable to passing arguments ($buffer, $main)
	my ($chat, @chat, @prechat, $line, $length);
	my $i = 0;

	if ($buffer->counter == 0)
	{
		local $/ = RSEPARATOR;

		eval
		{
			local $SIG{ALRM} = sub { die "ALARM\n" };
			alarm 2;
			chomp ($chat = <CHILD>);
			alarm 0;
		};

		if ($@)
		{
			$buffer->addlines("{CCB} - ERROR with parent: $@") unless $@ eq "ALARM\n";
			$buffer->addlines("{CCB} - May have lost sync with child. (1)");
		}

		eval
		{
			local $SIG{ALRM} = sub { die "ALARM\n" };
			alarm 2;
			print CHILD $buffer->counter . "\n";
			alarm 0;
		};

		if ($@)
		{
			$buffer->addlines("{CCB} - ERROR with parent: $@") unless $@ eq "ALARM\n";
			$buffer->addlines("{CCB} - May have lost sync with child. (2)");
		}

		@chat = map { "$_\n" } split "\n", $chat;

		$Text::Wrap::columns = $COLS - 2;

		foreach $line (@chat)
		{
			if ($buffer->show_time)
			{
				$line = &time_stamp . " $line";
			}

			$buffer->addlines(split "\n", wrap("", "\t", $line));
		}
	}

	@chat = $buffer->getlines($LINES - 3);

	# Start drawing from the bottom of the screen
	$i = $LINES - 4;
	foreach $line (reverse @chat)
	{
		# Not the best way to do this, but length()
		# doesn't handle tabs correctly. # TODO? #
		$line =~ s/^\t/        /;
		$length = $COLS - length($line) - 2;

		$line = " ".$line." "x$length;
		$main->addstr($i, 0, "$line");

		$i--;

		last if $i < 0;
	}
	
	$main->refresh();

	return 1;
}

sub help_popup
{
	# Display a window with help information in it.
	my $buffer = shift;
	my ($line, $help);

	my @help = (
		"Curses ChatterBox Client v. $VERSION",
		" ",
		"Commands available:",
		"- /help     - displays this message",
		"- /who      - shows the monks logged on",
		"- /xp       - shows some quick information about you",
		"- /log      - show the chat log",
		"- /freq <#> - sets the refresh interval to # seconds",
		"- /time     - toggles time stamps on messages",
		"- /save     - dump buffer to a save file",
		"- /quit     - exits the Chatterbox client",
		"Supported Chatterbox Commands",
		"- /me ...          - emote a message.",
		"- /msg <user> ...  - send a message to <user>.",
		"- /tell <user> ... - same thing.",
		"- /msgs            - show all private messages.",
		#"- /co ###<,###...> - check off private messages.",
		#"- /checkoff ###    - same thing.",
		"- /ignore <user>   - Ignore <user>.",
		"- /unignore <user> - Unignore <user>.",
		"To-do:",
		"- Colors",
		"- I keep having imaginings of building a mini-browser in...",
		"  if winamp can do it, so can I!",
		"- Tell me what features you would like!"
	);

	foreach $line (@help)
	{
		chomp $line;

		if ($line ne "")
		{
			$help .= "$line\n";
		}
	}

	txt_field(
		'window' => $main,
		'title' => "{CCB} Help - PGUP and PGDOWN to scroll, ENTER to exit.",
		'regex' => "\n",
		'xpos' => 0,
		'ypos' => 0,
		'lines' => $LINES - 2,
		'cols' => $COLS - 2,
		'border' => "white",
		'edit' => 0,
		'cursor_disable' => 1,
		'content' => $help
	);

	# Clear the screen before returning.
	$main->erase();
	$main->refresh();
}

sub list_users
{
	my $buffer = shift;
	my (%users, $users);

	%users = $monks->users;

	if (%users)
	{
		$Text::Wrap::columns = $COLS - 2;

		$users  = "{CCB} - " . (scalar(keys(%users)) + 1);
		$users .= " users logged in: " . join " ",sort keys(%users);
		$buffer->addlines(split "\n", wrap("", "\t", $users));
	}
	else
	{
		$buffer->addlines("No users logged in (oddly enough)");
	}
}

sub show_msgs
{
	# Retrieve and display all personal messages
	my $buffer = shift;
	my (%msgs, $msg);

	%msgs = $chat->personal_messages;

	if (%msgs)
	{
		$Text::Wrap::columns = $COLS - 2;

		foreach $msg (sort keys(%msgs))
		{
			$buffer->addlines(split "\n", wrap("", "\t", "($msg) $msgs{$msg}"));
		}
	}
	else
	{
		$buffer->addlines("Could not get personal messages");
	}
}

sub show_xp
{
	# Print a display of current XP information
	my $buffer = shift;
	my (%xp, $xp);

	%xp = $monks->xp;

	if (%xp)
	{
		$Text::Wrap::columns = $COLS - 2;

		$xp  = "{CCB} - User: $xp{user}, Level: $xp{level}, XP: $xp{xp}, ";
		$xp .= "Votes: $xp{votesleft}, Next level in: $xp{xp2nextlevel} XP";
		$buffer->addlines(split "\n", wrap("", "\t", $xp));
	}
	else
	{
		$buffer->addlines("Could not get XP information");
	}
}

sub show_log
{
	my ($buffer, $mode) = @_;
	my (@chat, $line, $chat, $length, $filename);

	# If mode is SAVE then prompt for a file name
	if ($mode eq "SAVE")
	{
		my ($text, $test) = input_box(
			'title' => "Save log",
			'prompt' => "Please enter a path and filename to save your message:",
			'border' => "white",
			'edit' => 0,
			'cursor_disable' => 1
		);

		if (($test == 1) && ($text ne ""))
		{
			$filename = $text;
		}
		else
		{
			$buffer->addlines("{CCB} - log not saved.");
			return 0;
		}
	}

	$length = $buffer->length;

	# Retrieve all the lines.
	@chat = $buffer->getlines($length);
	$chat = "";
	foreach $line (@chat)
	{
		chomp $line;

		if ($line ne "")
		{
			$chat .= "$line\n";
		}
	}

	if ($mode eq "SAVE")
	{
		open (FILEHANDLE, ">$filename");
		print FILEHANDLE $chat;
		close FILEHANDLE;
		$buffer->addlines("{CCB} - log saved as $filename");
	}
	else
	{
		txt_field(
			'window' => $main,
			'title' => "{CCB} Chat log - PGUP and PGDOWN to scroll, ENTER to exit (max $length lines).",
			'regex' => "\n",
			'xpos' => 0,
			'ypos' => 0,
			'lines' => $LINES - 2,
			'cols' => $COLS - 2,
			'border' => "white",
			'cursor_disable' => 1,
			'content' => $chat
		);
	}

	# Clear the screen before returning.
	$main->erase();
	$main->refresh();
}

sub time_stamp
{
	# Produce a time stamp
	my ($sec, $min, $hour) = localtime;

	$sec  = "0".$sec if $sec < 10;
	$min  = "0".$min if $min < 10;
	$hour = "0".$hour if $hour < 10;
	return ("$hour:$min:$sec")
}

sub handle_error
{
	my $message = shift;

	msg_box(
		'message' => "$message",
		'title' => "Error"
	);

	die "$message\n";
}
