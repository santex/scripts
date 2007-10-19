#!/usr/bin/perl

# 2004-05-27 - backup important (personal) data; things like software,
#              docs/manual, etc. are not copied because they can be retrieved
#              from the Internet.
#
# 2005-09-10 - fix problem with --exclude/--exclude-from. harus disebutkan SEBELUM daftar yang ingin di-tar.
# 2005-09-09 - kayaknya bakal gede nih, dah banyak foto2 dan camcorder. sementara taro hasilnya di harddisk lain dulu (malcolm)
# 2004-07-31 - update list of excludes
# 2004-02-03 - update list of includes & excludes, debianization

use File::Temp qw(tempfile);

use POSIX;
$YYMMDD = POSIX::strftime "%Y%m%d", localtime;

$BACKUP_DEST_DIR  = "/media/marie/data/backup";

# we create a big tarball, then we split per 699M (or per 4-some GB, when we
# have used DVD) using 'split' and put each into a bestcrypt volume, then
# burn each volume on a disc.
#
# or we could just pgp the whole .tar and split it.

$BACKUP_DEST_NAME = "sh-s-$YYMMDD.tar.gz.UNENCRYPTED";

#$VOLUME_SIZE       = 714; # 714*1000 KB


@DIRS = grep {not /^#/m and /\S/} split /\n/, <<_;
# don't use wildcard here, but use whole directories.

/etc

# masih pake sistem manual, so gak disimpan di /u/USER/sysetc/zone=*
#/var/named

/var/spool/cron
/var/lib/mysql
/var/lib/postgres
/home/sloki/cpanel

# user's home + sites + etc dir
/home/sloki/user
/encrypted/home/sloki/user

# we don't use MDB anymore, anyway
#/home/sloki/mdb

# manipurlation-builder
/encrypted/usr/bin

# we don't use redhat anymore
#/usr/src/redhat/SOURCES
#/usr/src/redhat/SPECS
#/usr/src/redhat/RPMS
#/usr/src/redhat/SRPMS

_


@EXCLUDES = grep {not /^#/m and /\S/} split /\n/, <<_;

# ada di elektrik dan di archive.masterwebnet.com anyway
/home/sloki/user/mwn/sites/archive.mwn.builder.localdomain/www/archive/*

# huge stuff that we already mirror to elektrik, archive.or.id anyway
/home/sloki/user/steven/public/*

# we don't need access logs
/home/sloki/user/*/sites/*/syslog/*

# sekarang rata2 cache browser udah ditaruh di /u/USER/tmp, but still...
#/home/sloki/user/*/home/.opera/cache4/*
#/home/sloki/user/*/home/.mozilla/user/*/Cache/*
#/home/sloki/user/*/home/.galeon/mozilla/Cache/*
#/encrypted/home/sloki/user/*/home/.opera/cache4/*
#/encrypted/home/sloki/user/*/home/.mozilla/user/*/Cache/*
#/encrypted/home/sloki/user/*/home/.galeon/mozilla/Cache/*
/home/sloki/user/*/var/*
/home/sloki/user/*/tmp/*
/encrypted/home/sloki/user/*/var/*
/encrypted/home/sloki/user/*/tmp/*

# movies, guede
/encrypted/home/sloki/user/v/home/t/*

# kadang2 gede juga?
/home/sloki/user/*/home/.mc/tmp/*
/encrypted/home/sloki/user/*/home/.mc/tmp/*

# backup files
*~

# mozilla mail indexes
*.msf

# gnome? xnview? thumbnail files
.thumbnails/*

# gnome trash
.Trash/*
.Trash-*/*

/var/lib/mysql/log.*
/var/lib/mysql/*.log

_


# ---

$> and die "$0: FATAL: Please run me as root, because I need to backup system files like /etc, etc.\n";

chdir $BACKUP_DEST_DIR or die "$0: FATAL: Can't chdir to `$BACKUP_DEST_DIR': $!\n";

($excludes_fh, $excludes_filename) = tempfile(DIR => '/tmp');
for (@EXCLUDES) { print $excludes_fh $_, "\n" }

$cmd = "time nice -n 19 ".
  "tar cvfz '$BACKUP_DEST_NAME' ".
  "--exclude-from=$excludes_filename ".
  join(" ", map {"'$_'"} @DIRS)
  ;

print "$cmd\n";
system $cmd;
