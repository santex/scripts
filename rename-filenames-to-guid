#!/usr/bin/perl

# 2005-04-07 - tambahin skip jika sudah guid
# 031214

for (@ARGV) {
  do { warn "# $_ is already a GUID, skipped\n"; next} if /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;
  chomp($guid = `uuidgen`);
  die "FATAL: Can't get a GUID: $!\n" unless $guid;
  print "$guid\t",escapeshellarg($_),"\t",(-s $_),"\n";
  rename $_, $guid or warn "WARN: Can't rename `$_' to $guid: $!\n";
}

sub escapeshellarg {
  local $_ = shift;
  s/'/'"'"'/g;
  "'$_'";
}
