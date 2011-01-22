use File::Spec;
use Proc::PID::File;

sub mysystem {
  my $cmd = shift;

  my $filtered_cmd = $cmd;

  if (1) { # verbose
    syswrite STDOUT, "system(): $filtered_cmd\n";
    system $cmd;
    syswrite STDERR, "system() exits non-zero: $?\n" if $?;
  } else {
    system $cmd;
    syswrite STDERR, "system(): $filtered_cmd (exit=$?)\n" if $?;
  }
}

sub check_self_instance {
  die "Already running!\n" if Proc::PID::File->running(dir=>"/tmp");
}

sub prepare_tmp_dir {
  mysystem qq(mkdir -p "$TO");
  mysystem qq(cp -la "$TO" "$TO.tmp") unless (-e "$TO.tmp");
}

sub move_tmp_dir_to_final_dir {
  mysystem qq(chmod -R u+w "$TO") if (-e $TO);
  mysystem qq(chmod -R u+w "$TO.tmp")  if (-e "$TO.tmp");
  mysystem qq(chmod -R u+w "$TO.tmp2") if (-e "$TO.tmp2");
  mysystem qq(rm -rf "$TO.tmp2" && mv "$TO" "$TO.tmp2" && mv "$TO.tmp" "$TO" && rm -rf "$TO.tmp2");
}

sub mirror_with_command {
  my @cmd = @_;

  check_self_instance();
  prepare_tmp_dir();
  for my $cmd (@cmd) {
    mysystem $cmd;
    die "mirroring failed! (status=$?): $!\n" if $?;
  }
  move_tmp_dir_to_final_dir();
}

# sintaks excludes (basically sama dg rsync):
# - "foo" = relatif, matches filename foo di semua dir
# - "/foo/bar" = absolute terhadap _titik awal_ download, mis download dari /baz maka match /baz/foo/bar

sub mirror_with_ftpmirror_command {
  my @args = @_;
  my @cmds = ();
  
  for my $args (@args) {

    my @x = ();
    if ($args->{excludes} && @{$args->{excludes}}) {
      for (@{$args->{excludes}}) {
	if (m|^/|) {
	  push @x, "$args->{remote_path}$_";
	} elsif (m|^\*/|) {
	  push @x, $_;
	} else {
	  push @x, "*/$_";
	}
      }
    }

  push @cmds,
    "ftpcopy ".
    "--bps ".
    ($args->{rate_limit} ? "--rate-limit ".$args->{rate_limit}*1024 : "" )." ".
    (@x ? join(" ", map { "--exclude ".esc($_) } @x) : "" )." ".
    # src
    "-s $args->{remote_host} \"$args->{remote_path}\" ".
    # dest
    "\"$args->{local_path}.tmp".($args->{local_subdir} || "")."\""
    ;

  }

  mirror_with_command(@cmds);
}

sub mirror_with_rsync_command {
  my @args = @_;
  my @cmds = ();

  for my $args (@args) {

    my @x = ();
    if ($args->{excludes} && @{$args->{excludes}}) {
      for (@{$args->{excludes}}) {
	push @x, $_;
      }
    }

    push @cmds,
      "rsync ".
      ($args->{proto} eq 'ssh' ? '-e ssh ':'').
      "-avz --del --delete-excluded --force ".
      ($args->{rate_limit} ? "--bwlimit $args->{rate_limit} " : "" ).
      (@x ? join(" ", map { "--exclude ".esc($_) } @x) : "" )." ".
       # src
      ($args->{proto} eq 'rsync' ? 
       ($args->{remote_user} ? "$args->{remote_user}\@":"")."$args->{remote_host}::\"$args->{remote_path}/\" " :
       ($args->{remote_user} ? "$args->{remote_user}\@":"")."$args->{remote_host}:\"$args->{remote_path}/\" "
      ).
       # dest
      "\"$args->{local_path}.tmp".($args->{local_subdir} || "")."\""
      ;
  }

  mirror_with_command(@cmds);

}

sub esc {
  local $_ = shift;
  s/'/'"'"'/g;
  "'$_'";
}

sub Mirror {
  if ($PROTO eq 'ftp') {
    mirror_with_ftpmirror_command(
                                    {
                                     remote_host => $HOST,
                                     remote_path => $DIR,
                                     local_path => $TO,
                                     rate_limit => $RATE_LIMIT,
                                     excludes=>$EXCLUDES,
                                    }
                                 );
  } elsif ($PROTO eq 'rsync') {
    mirror_with_rsync_command(
                                {
                                 remote_host => $HOST,
                                 remote_user => $USER,
                                 remote_path => $DIR,
                                 local_path => $TO,
                                 proto => 'rsync',
                                 rate_limit => $RATE_LIMIT,
                                 excludes=>$EXCLUDES,
                                }
                             );
  } elsif ($PROTO eq 'rsync+ssh') {
    mirror_with_rsync_command(
                                {
                                 remote_host => $HOST,
                                 remote_user => $USER,
                                 remote_path => $DIR,
                                 local_path => $TO,
                                 proto => 'ssh',
                                 rate_limit => $RATE_LIMIT,
                                 excludes=>$EXCLUDES,
                                }
                             );
  } else {
    die "FATAL: Unknown PROTO, pick ftp or rsync or rsync+ssh!\n";
  }
}

# safer debian mirroring (according to anonftpsync script): mirror
# /pool first and then the rest (/dists, etc)

sub MirrorDebian {
  if ($PROTO eq 'ftp') {
    mirror_with_ftpmirror_command(
                                    {
                                     remote_host => $HOST,
                                     remote_path => "$DIR/pool",
                                     local_path => $TO,
				     local_subdir => "/pool",
                                     rate_limit => $RATE_LIMIT,
                                     excludes=>$EXCLUDES,
                                    },
                                    {
                                     remote_host => $HOST,
                                     remote_path => $DIR,
                                     local_path => $TO,
                                     rate_limit => $RATE_LIMIT,
                                     excludes=>$EXCLUDES,
                                    }
                                 );
  } elsif ($PROTO eq 'rsync') {
    mirror_with_rsync_command(
                                {
                                 remote_host => $HOST,
                                 remote_user => $USER,
                                 remote_path => "$DIR/pool",
                                 local_path => $TO,
				 local_subdir => "/pool",
                                 proto => 'rsync',
                                 rate_limit => $RATE_LIMIT,
                                 excludes=>$EXCLUDES,
                                },
                                {
                                 remote_host => $HOST,
                                 remote_user => $USER,
                                 remote_path => $DIR,
                                 local_path => $TO,
                                 proto => 'rsync',
                                 rate_limit => $RATE_LIMIT,
                                 excludes=>$EXCLUDES,
                                }
                             );
  } elsif ($PROTO eq 'rsync+ssh') {
    mirror_with_rsync_command(
                                {
                                 remote_host => $HOST,
                                 remote_user => $USER,
                                 remote_path => "$DIR/pool",
                                 local_path => $TO,
				 local_subdir => "/pool",
                                 proto => 'ssh',
                                 rate_limit => $RATE_LIMIT,
                                 excludes=>$EXCLUDES,
                                },
                                {
                                 remote_host => $HOST,
                                 remote_user => $USER,
                                 remote_path => $DIR,
                                 local_path => $TO,
                                 proto => 'ssh',
                                 rate_limit => $RATE_LIMIT,
                                 excludes=>$EXCLUDES,
                                }
                             );
  } else {
    die "FATAL: Unknown PROTO, pick ftp or rsync or rsync+ssh!\n";
  }
}

sub excludes_debian_arch_not_i386() {
  my @unwanted_archs = qw(
    alpha amd64 arm hppa hurd-i386 ia64 m68k mips mipsel powerpc s390 sh sparc
  );
  # i386
  # sh udah gak ada?
  # amd64 belon official

  (map {"*-$_"} @unwanted_archs),        # a.l. {binary,installer,disks,Contents}-ARCH
  (map {"*-$_.diff"} @unwanted_archs),   # a.l. Contents-ARCH.diff
  (map {"*_$_.deb"} @unwanted_archs)     # binary packages
  ;
}

1;
