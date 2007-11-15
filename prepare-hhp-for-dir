#!/usr/bin/perl -0

# 031121
# - add verbose option
# - fix regex to caused .htm files to be skipped

#020909, v0.0.1
# todo:
#  - option to include/exclude specific file extensions [perlu untuk mwmag, exclude issue/N/pdf/, otherwise the chm would bloat; lalu harus include issue/N/content/TITLE/file/*.*, kecuali .htaccess :-)]
#  - option to include/exclude specific directories
#  - option to sort TOC entries by modified date? by size? or by a list file (say, order.txt) [would be nice for mwmag]
#  - option to contrive subjects according to supplied rules/patterns
#  - what to do if there's no index.html? use another html? create a dummy one? [would be nice for mwmag, karena mwmag menggunakan]
#  - by default, the indexer only index .html files. check options in HHP/HHC to also index .shtml, .txt, .phtml, etc.
#  - option to include/exclude dot files
#  - option to follow symlink or not
#  - option to give some default/other title when no <title> is found
#  - option to remove empty directories [would be nice for mwmag]

$|++;
use Getopt::Long;
use File::Find;

$progname = $0; $progname =~ s#.+/##;
$chmizer = $progname;
$list_txt = 1;
$list_images = 0;
$list_other = 0;
$dir_first = 1;
$sort = 'title';
$verbose = 0;

@FILES = ();

GetOptions(
    "chmizer|c=s" => \$chmizer,
    "list-txt" => \$list_txt,
    "list-images" => \$list_images,
    "list-other" => \$list_other,
    "dir-first" => \$dir_first,
    "sort|s=s" => \$sort,
    "verbose" => sub {$verbose = 1},
);
    
die "Usage: $progname [options] dir\n" unless @ARGV == 1;
$dir = $ARGV[0]; $dir =~ s#.+/(.+)#$1#; $dir =~ s#/$##;
die "$dir doesn't exist, stopped\n" unless -e $dir;
die "$dir is not a dir, stopped\n" unless -d $dir;
die "sort must be 'title' or 'filename', stopped\n" unless $sort eq 'title' or $sort eq 'filename';

open HHC, ">$dir.hhc" or die "Can't create $dir.hhc: $!, stopped\n";
open HHP, ">$dir.hhp" or die "Can't create $dir.hhp: $!, stopped\n";
open BAT, ">$dir.bat" or die "Can't create $dir.bat: $!, stopped\n";


chdir $dir or die "Can't chdir to $dir: $!, stopped\n";
($indexfile, $indextitle, $items) = process_dir($dir);

print HHC "<ul>\n";
print HHC spaces("").'<li><object type="text/sitemap"><param name="Local" value="'.forward2backslash("$dir/$indexfile").'"><param name="Name" value="'.$indextitle.'"></object>'."\n";
print HHC $items;
print HHC "\n</ul>\n";

print HHP <<_;
[OPTIONS]
Compatibility=1.1
Compiled file=$dir.chm
Contents file=$dir.hhc
Default Window=$dir
Default topic=$dir\\$indexfile
Display compile progress=Yes
Full-text search=Yes
Language=0x409
Title=$archivename
[WINDOWS]
$dir="$dir","$dir.hhc","","$dir\\$indexfile","$dir\\$indexfile",,,,,0x2520,220,0x384e,[84,16,784,504],,,,0,,,0
[FILES]
_
print HHP map {"$_\n"} @FILES;

print BAT qq("C:\\Program Files\\HTML Help Workshop\\hhc.exe" "$dir.hhp");

close HHC or die "Can't write $dir.hhc: $!, stopped\n";
close HHP or die "Can't write $dir.hhp: $!, stopped\n";
close BAT or die "Can't write $dir.bat: $!, stopped\n";

sub vprint($) {
    print $_[0] if $verbose;
}

sub process_dir($) {
    my $prefix = shift;
    my $indent = spaces($prefix);
    my $space = spaces("./dir");
    my $indexfile = "";
    my $indextitle = $prefix; $indextitle =~ s#.+/(.+)#$1#; $indextitle = proper_title($indextitle);
    
    local *F;
    my @items = ();
    for my $entry (<*>) {  # so dot files aren't included?
        vprint "$prefix/$entry";
        if (-f $entry) {
            vprint " ";
            my $title = "($entry)";
            if ($entry =~ /\.(s?html?|asp|php3?|phtml)$/i) {
                open F, $entry or do {warn "Can't open $prefix/$entry: $!, skipped\n"; next};
                $title = $1 if <F> =~ m#<title[^>]*>(.+?)</title>#si;
                close F;
            }
            $title = proper_title($title);
            if ($entry =~ /\.s?html?$/i or 
                ($entry =~ /\.(te?xt)$/i and $list_txt) or
                ($entry =~ /\.(gif|jpeg?|jpg|png)$/i and $list_images) or
                $list_other) {
                if (!$indexfile and $entry =~ /^(index|default)\.(s?html?|asp)$/i) {
                    $indexfile = $entry;
                    $indextitle = $title;
                } else {
                    push @items, [$title, '<li><object type="text/sitemap"><param name="Local" value="'.forward2backslash("$prefix/$entry").'"><param name="Name" value="'.$title.'"></object>', $entry, 0];
                }
                vprint "[added]\n";
                push @FILES, forward2backslash("$prefix/$entry");
            } else {
                vprint "[skipped]\n";
            }
        } elsif (-d $entry) {
            vprint "/";
            chdir $entry or die "Can't chdir to $prefix/$entry: $!, stopped\n";
            my ($idxf, $idxt, $items) = process_dir("$prefix/$entry");
            chdir ".." or die "Can't chdir back to $prefix: $!, stopped\n";
            my $title = $idxt || proper_title($title);
            push @items, [$title, '<li><object type="text/sitemap"><param name="Local" value="'.forward2backslash("$prefix/$entry/$idxf").'"><param name="Name" value="'.$title.'"></object>'."\n".$items, "$entry/$idxf", 1];
        }
    }
    my $i = $sort eq 'title' ? 0 : 2;
    if ($dir_first) {
        @items = sort { ($b->[3] <=> $a->[3]) || (lc($a->[$i]) cmp lc($b->[$i])) } @items;
    } else {
        @items = sort { lc($a->[$i]) cmp lc($b->[$i]) } @items;
    }
    
    return (
        $indexfile,
        $indextitle,
        "$indent<ul>\n" . (join "", map {"$indent$space$_->[1]\n"} @items) . "$indent</ul>"
    );
}

sub proper_title {
    local $_ = shift;
    s#<[^>]+>##sg;
    s#"#&quot;#g;
    s#^\s+##s; s#\s+$##s; s#[\012\015]+# #g; s# {2,}# #g;
    s#[\x00-\x1f\x80-\xff]#?#g;
    $_;
}

sub forward2backslash {
    local $_ = shift;
    tr#/#\\#;
    $_;
}

sub spaces {
    my $prefix = shift;
    my $i = 1; $i++ while $prefix =~ m#/#g;
    " " x $i;
}
