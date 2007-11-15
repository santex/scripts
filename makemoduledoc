#!/usr/bin/perl

#010409, waktu mo baca modul Template

use File::Path;
use Cwd;
use File::Find;

$target_dir=getcwd()."/htmldocs";

find sub {
	return unless -f && /\.(pod|pm)$/;
	
	$dir = "$target_dir/$File::Find::dir";

	if (!-d $dir) {
		mkpath [$dir] or die;
	}

	system qq(pod2html "$_" >"$dir/$_.html");
}, "./";
