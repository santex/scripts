#!/usr/bin/perl

$|++;
# 021230 - buat motong2 audio book "the gunslinger", stephen king (6,5 jam bo! dan compo gue gak bisa fast forward within a track, so we need to cut the track into 5-min pieces)
# format .tml (pymp3cut): text file which may contain empty lines or comments which begin with #. Any non-empty and non-comment line represents a segment, and is expected to be in the following format: "name [[hh:]mm:]ss"; name=filename, hh::mm::ss=ending time

$bigfile = "c:/gunslinger.mp3";
$start = "00:00:00";
$end = "00:399:21";
$segment_length = "00:05:00";
$segmentfile_template = "gs[[SEGMENTSEQ]]-[[SEGMENTSTART]]-[[SEGMENTEND]].mp3"; # [[SEGMENTSEQ]] = will be placed by sequence number ("001","002",...), [[SEGMENTEND]] = time end ("hh.mm.ss")

###

$startsec = hms2sec($start);
$endsec = hms2sec($end);
$segment_length_sec = hms2sec($segment_length);
$time = $startsec;
$i = 1;
while ($time < $endsec) {
    $filename = $segmentfile_template;
    $time2 = $time+$segment_length_sec > $endsec ? $endsec : $time+$segment_length_sec;
    for ($filename) {
        s/\[\[SEGMENTSEQ\]\]/sprintf "%03d",$i/eg;
        s/\[\[SEGMENTSTART\]\]/sec2hms($time+1)/eg;
        s/\[\[SEGMENTEND\]\]/sec2hms($time2)/eg;
        s/:/./g;
    }
    printf "%s %s\n", $filename, sec2hms($time2);
    $time = $time2; $i++;
}

sub hms2sec {
    my ($h,$m,$s) = $_[0] =~ /(\d+):(\d+):(\d+)/;
    $h*3600+$m*60+$s;
}

sub sec2hms {
    my $sec = shift;
    my $s = $sec % 60;
    my $m = int($sec/60) % 60;
    my $h = int($sec/3600) % 60;
    sprintf "%02d:%02d:%02d", $h, $m, $s;
}

#test
#print map {"$_ secs = ".sec2hms($_)."\n"} 1,2,59,60,61,1200,1201,3599,3600,3601,10000;
#print map {"$_ = ".hms2sec($_)." secs\n"} "2:46:40","00:399:21";
