#! /usr/bin/perl
# USAGE: yapc-vlc ROOM
# where ROOM is L, V, 313, or 325

# from: https://gist.github.com/2926115
# by: madsen

use strict;
use warnings;

use IPC::Cmd qw[can_run];
use List::Util qw(first);
use HTML::TreeBuilder 5 -weak;

my $player = first { can_run($_) } qw(vlc vlc.exe mplayer mplayer.exe wmplayer.exe);

my %room = (
  l   => '1de9c319-010c-4585-8617-210873935dfa',
  325 => '90b5b79a-ceb6-4084-8cca-8977ff1aa729',
  313 => '1c56eaf7-1178-4cb9-bf47-53e717ea74c2',
  v   => '5b80d7ae-5fc7-46c4-98ba-5f770a8be940',
);

my $catalog =
  'http://ics.webcast.uwex.edu/mediasite/Catalog/pages/catalog.aspx?catalogId='
  . ($room{lc shift} || die "Room must be l v 313 325");

my $tree = HTML::TreeBuilder->new_from_url($catalog);

my $url =
  $tree->look_down(qw(_tag span class PresentationCard_OnAir))
       ->look_up(qw(_tag tr))
       ->look_down(qw(_tag a  href) =>
                   qr!^http://ics\.webcast\.uwex\.edu/mediasite/Viewer!)
       ->attr('href');

my @parts = ($url =~ /peid=(\w{8})(\w{4})(\w{4})(\w{4})(\w+)\w\w\z/)
    or die;

my $new = "http://video.ics.uwex.edu/" . join('-', @parts);

#use 5.010; say $new; exit;

if ($^O =~ /Win32/) {
  system start => $player, $new;
} else {
  system "$player $new &";
}
