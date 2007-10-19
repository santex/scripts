#!/usr/bin/perl

use strict;
use warnings;
use Getopt::Long;
use Log::Log4perl qw(:easy);

# --- globals

my $My_Ip;
my %Default_Config = (
                      ip_checker_url => "http://people.masterwebnet.com/steven/env.cgi",
                      log_level => 'warn',
                      log_file => undef,
                      user_agent => 'Opera/9.00 (X11; Linux i686; U; en)',
                     );
my %Config;
my $Ua = LWP::UserAgent->new;

# --- subs

sub get_my_ip {
  my $ip;
  DEBUG "Executing /sbin/ifconfig...";
  my @ips = `/sbin/ifconfig` =~ /^\s+inet addr:(\d+\.\d+\.\d+\.\d+)/mg;
  DEBUG "Found these IP addresses from /sbin/ifconfig: ".join(", ", @ips);
  do { ERROR "Failed to get the list of this computer's IP address: $!" } unless @ips;
  for (@ips) {
    do { $ip = $_; last } unless /^(10|127|192\.168|)\./;
  }
  if ($Config{ip_checker_url}) {
    get($Config{ip_checker_url}) =~ /REMOTE_ADDR.+?(\d+\.\d+\.\d+\.\d+)/ and $My_Ip = $1;
  }
}

die "$0: Failed to get my public IP address\n" unless $My_Ip;

die "$0: Usage: $0 <nama-account>\n" if @ARGV != 1;
$id = $ARGV[0];
die "$0: Account tidak dikenal\n" if !exists $accounts{$id};
%acc = %{$accounts{$id}};
die "$0: acc $id: norek tidak ada/salah\n" if $acc{no} !~ /^\d{10}$/;
die "$0: acc $id: username tidak ada/salah\n" if $acc{username} !~ /^\w{8}\d{4}$/;
die "$0: acc $id: PIN tidak ada/salah\n" if $acc{pin} !~ /^\d{6}$/;
die "$0: acc $id: PAN tidak ada/salah\n" if $acc{pan} !~ /^\d{4}$/;
die "$0: acc $id: Period salah\n" if $acc{period} !~ /^(bulan|hari|2?minggu)$/;

# --- get command-line options



# get our public IP address

$now = time;
$n = $acc{period} eq 'hari' ? 0 : 
       ($acc{period} eq 'minggu' ? 7*24*3600 : 
        ($acc{period} eq '2minggu' ? 2*7*24*3600 :
         31*24*3600
        )
       );
@d1 = localtime($now - $n);
$d1 = sprintf("%02d", $d1[3]); $m1 = sprintf("%02d", $d1[4]+1); $y1 = $d1[5]+1900;
@d2 = localtime $now;
$d2 = sprintf("%02d", $d2[3]); $m2 = sprintf("%02d", $d2[4]+1); $y2 = $d2[5]+1900;

# sudah ada session? coba pakai langsung
$csession = "";
#if (-f "$id.csession") {
#    die "$0: acc $id: $id.cession: $!\n" if !($csession=readfile("$id.csession"));
#    chomp($csession);
#}

# kalau tidak ada, login
$logindata = "value%28actions%29=login&value%28user_id%29=$acc{username}&".
  "value%28user_ip%29=$My_Ip&value%28pswd%29=$acc{pin}&value%28Submit%29=LOGIN";
if (!$csession) {
    die "$0: acc $id: Anda pernah gagal login: hapus dulu file $id.fail\n"
        if readfile("$id.fail");

    $_ = curl("/authentication.do","/",$logindata);
    writefile("$id.debug-login-$now", $_) if $debug;
    die "$0: acc $id: Gagal login: No response\n" unless $_;
    ($csession) = /(JSESSIONID=[^;]+)/;

    # gagal login? jika ya, cari tahu kenapa
    if (/value\(actions\)=logout&value\(strError\)=(.+?)(?:&|\r|\n)/) {
        my $reason = $1;
        writefile("$id.debug-fail-$now", $_) if $debug;
        die "$0: acc $id: Gagal login: $reason\n";
    }

    # setelah berhasil login, save csession
    # die "$0: acc $id: Gagal save session: $!\n" if !writefile("$id.csession", $csession);
}

# ambil mutasi
$_ = curl("/accountstmt.do?value(actions)=acctstmtview",
          "accountstmt.do?value(actions)=acct_stmt",
          $csession,
          "value%28D1%29=$acc{no}&".
          "value%28startDt%29=$d1&value%28D2%29=$m1&value%28startYr%29=$y1&".
          "value%28endDt%29=$d2&value%28D3%29=$m2&value%28endYr%29=$y2&".
          "value%28submit1%29=Lihat+Mutasi+Rekening");
writefile("$id.mutasi-$y1$m1$d1-$y2$m2$d2.html", removescript($_));

# bonus, sekalian ambil saldo :)
$_ = curl("/balanceinquiry.do",
          "/nav_bar_indo/account_information_menu.html", $csession, "");
writefile("$id.saldo-$y2$m2$d2.html", $_);# if $debug;

# gagal?
die "$0: acc $id: Gagal ambil mutasi\n" if m#^HTTP/1.\d 30\d#m;
