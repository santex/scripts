sub clean_env {
  $ENV{PATH} = "/usr/sbin:/sbin:/usr/bin:/bin";
  delete @ENV{qw/IFS CDPATH ENV BASH_ENV/};
  $<=$>; $(=$);
}

sub mysystem {
  print STDERR $_[0],"\n";
  system $_[0];
}

# $1=target host/net, $2=gateway, $3=netmask, $4=flags, $5=metric, $6=ref, $7=use, $8=iface
$route4_line = qr/^(\d+\.\d+\.\d+\.\d+) \s+ # $1=dest 
                   (\d+\.\d+\.\d+\.\d+) \s+ # $2=gateway
                   (\d+\.\d+\.\d+\.\d+) \s+ # $3=netmask
                   ([A-Z]+) \s+ # $4=flags
                   (\d+) \s+ # $5=metric
                   (\d+) \s+ # $6=ref
                   (\d+) \s+ # $7=use
                   (\w+) # $8=iface
                   $/x;

sub delete_all_nonlocal_routes {
  print "+ Deleting all default gw and non-local routes...\n";
  while (1) {
    $found = 0;
    for (`route -n`) {
      $_ =~ $route4_line or do {
        next;
      };
      if ($1 eq '0.0.0.0') { # default gw
        mysystem "route del default gw $2 dev $8";
        $found++;
      } elsif ($2 ne '0.0.0.0') { # gateway is not local
        if ($3 eq '255.255.255.255') { # single host route
          mysystem "route del -host $1 dev $8 2>/dev/null";
        } else { # network block route
          mysystem "route del -net $1 netmask $3 dev $8";
        }
        $found++;
      }
    }
    last if !$found;
    sleep 1;
  }
}

sub turn_on_eth0 {
  if (`ifconfig` !~ /^eth0\s/m) {
    print "+ Turning on eth0...\n";
    mysystem "ifup eth0";
  }
  if (`ifconfig` !~ /^eth0\s/m) {
    die "FATAL: Can't turn on eth0, exiting...\n";
  }
  # 2006-05-17
  print "+ Adding routing for extra public IPs on eth0...\n";
  # disabled 2006-10-04 - mysystem "route add -host 202.43.165.14 dev eth0"; # prima, 2006-05-17
  # disabled 2006-10-04 - mysystem "route add -host 202.43.165.12 dev eth0"; # ini udah lama nih, maybe since 2003-2004, tapi gak dipake. dulu rencananya buat quark. maybe nanti utk mirror/public sites.
}

sub turn_off_tundevs27 {
  if (`ifconfig` =~ /^tuns27\s/m) {
    print "+ Turning off tunnelling device for s27...\n";
    mysystem "$Bin/init.d/tunnelling-s27-elektrik.elektrik_side stop";
  }
  if (`ifconfig` =~ /^tuns27\s/m) {
    die "FATAL: Can't turn off tunnelling device for s27, exiting...\n";
  }
}

sub turn_off_tundevs23 {
  if (`ifconfig` =~ /^tuns23\s/m) {
    print "+ Turning off tunnelling device for s23...\n";
    mysystem "$Bin/init.d/tunnelling-s23-elektrik.elektrik_side stop";
  }
  if (`ifconfig` =~ /^tuns23\s/m) {
    die "FATAL: Can't turn off tunnelling device for s23, exiting...\n";
  }
}

sub turn_off_all_tundevs {
  turn_off_tundevs23();
  turn_off_tundevs27();
}

sub turn_on_tundevs27 {
  turn_on_eth0();
  if (`ifconfig` !~ /^tuns27\s/m) {
    print "+ Turning on tunnelling device for s27...\n";
    mysystem "$Bin/init.d/tunnelling-s27-elektrik.elektrik_side start";
  }
  if (`ifconfig` !~ /^tuns27\s/m) {
    die "FATAL: Can't turn on tunnelling device for s27, exiting...\n";
  }
}

sub turn_on_tundevs23 {
  turn_on_eth0();
  if (`ifconfig` !~ /^tuns23\s/m) {
    print "+ Turning on tunnelling device for s23...\n";
    mysystem "$Bin/init.d/tunnelling-s23-elektrik.elektrik_side start";
  }
  if (`ifconfig` !~ /^tuns23\s/m) {
    die "FATAL: Can't turn on tunnelling device for s23, exiting...\n";
  }
}

1;
