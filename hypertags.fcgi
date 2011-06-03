#!/usr/bin/perl

#020421

# how to use: first generate tags file using 'ctags -Rn .' in the topmost of
# source code tree. then put this FastCGI script in that directory and
# access with your browser. you must have a webserver that supports FastCGI.

use CGI::Fast ':standard';
use CGI::Carp 'fatalsToBrowser';
use Cwd;
use HTML::Entities 'encode_entities';
use URI::Escape;


$css{""}=<<_;
<style>
.linenum {color:#999999;}
a {text-decoration:none;color:#993333;}
a.url {text-decoration:underline;color:#0000ff;}
</style>
_

$css{dir}="";

$css{python} = <<_;
<style>
a {text-decoration:none;color:#993333;}
a.url {text-decoration:underline;color:#0000ff;}
.linenum {color:#999999;}
.comment {color:#339933;}
</style>
_


###

$prefix = getcwd;

die "Can't open tags in the current directory: $!\n" unless open F, "./tags";
while (<F>) {
	$line++;
	next if /^!/;
	($tagname, $tagfile, $tagaddress) = /([^\t]+)\t([^\t]+)\t(.+)/ or die "Syntax error in tags file line $line\n";
	$tagaddress =~ s/;".*//;
	push @{ $tags{$tagname}{$tagfile} }, $tagaddress;
}

while(new CGI::Fast) {
	print "Content-Type: text/html\n\n";

	$relpath = $ENV{PATH_INFO};
	$relpath =~ s#^/+##;
	$abspath = "$prefix/$relpath";
	for ($file, $abspath) { s#\\#/#g; s#\.\.?(/|$)##g; s#//+##g; }
	
	if (param('t')) {
		($tagname) = param('t') =~ /(\w+)/;
		print "<h2>tag '$tagname'</h2>\n";
		if (exists $tags{$tagname}) {
			print "<ul>\n";
			$num_links=0; $cur_link="";
			for $tagfile (keys %{ $tags{$tagname} }) {
				@linenums = @{ $tags{$tagname}{$tagfile} };
				print "<li><a href=$ENV{SCRIPT_NAME}/",uri_escape($tagfile),">",encode_entities($tagfile),"</a> (";
				print join ", ", map {"<a href=$ENV{SCRIPT_NAME}/".uri_escape($tagfile)."#$_>$_</a>"} @linenums;
				print ")\n";
				$num_links += @linenums; $cur_link = "$ENV{SCRIPT_NAME}/".uri_escape($tagfile)."#$linenums[-1]";
			}
			print "</ul>\n";
			print "<meta http-equiv=Refresh content=\"0;url=$cur_link\">" if $num_links == 1;
		}
	} elsif (!-e $abspath) {
		print "Error: file does not exist\n";
	} elsif (-d _) {
		if ($ENV{PATH_INFO} !~ m#/$#) {
			print "<meta http-equiv=Refresh content=\"0;url=$ENV{SCRIPT_NAME}$ENV{PATH_INFO}/\">";
		} else {
			print $css{dir};
			print "<h2>",encode_entities($relpath ? $relpath : "."),"</h2>\n";
			print "<table>\n";
			#print "<tr bgcolor=#c0c0c0><td>Name</td></tr>\n";
			$i=0;
			@entries = ();
			opendir DIR,$abspath or die; while ($_ = readdir DIR) { push @entries, $_ unless /^\.\.?$/ }
			@entries = sort @entries;
			unshift @entries, '..' if $relpath;
			chdir $abspath;
			for (@entries) {
				$bgcolor=++$i % 2 ? "#f0f0f0":"#ffffff";
				print "<tr bgcolor=$bgcolor><td><a href=",uri_escape($_),(-d $_ ? "/":""),">",
					encode_entities($_),(-d _ ? "/":""),"</td></tr>\n";
			}
			print "</table>\n";
		}
	} elsif (-f _) {
		if (!open F, $abspath) {
			print "Error: Cannot read file\n";
		} else {
			{ local $/; $content = <F>; }
			$relpath =~ /\.py$/i and $lang = "python" or $relpath =~ /\.pl$/i and $lang = "perl" or $lang = "";
			
			print $css{$lang};
			print "<h2>",encode_entities($relpath),"</h2>\n";

			@lines = split "\n", $content;
			$i=0;
			print "<pre>";
			for (@lines) {
				s/\r//g;
				++$i;
				$_ = xify(encode_entities($_));
				if (/\S/) {
					print "<a name=$i class=linenum>",sprintf("%4d",$i),"</a>&nbsp;",$_,"\n";
				} else {
					print "\n";
				}
			}
			print "</pre>";
		}
	} else {
		print "Error: not a regular file or directory\n";
	}
}

sub xify {
	local $_ = shift;
	
	s#(\w+)#exists $tags{$1} ? "<a href=$ENV{SCRIPT_NAME}?t=$1>$1</a>" : $1#eg;
	s#\b((?:mailto|https?|ftp|telnet|gopher|news):\S+)#<a href=$1 class=url>$1</a>#g;
	
	# python comments
	if ($lang == 'python' || $lang == 'perl') {
		s{(#.*)}{<span class=comment>$1</span>}g;
	}
	
	return $_;
}
