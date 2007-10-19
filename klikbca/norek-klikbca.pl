#!/usr/bin/perl -w

require "config.pl";
require "func.pl";

$id = $norek_id;

die "$0: Usage: $0 <norek> ...\n" if !@ARGV;
die "$0: Account tidak dikenal\n" if !exists $accounts{$norek_id};
%acc = %{$accounts{$id}};
die "$0: acc $id: norek tidak ada/salah\n" if $acc{no} !~ /^\d{10}$/;
die "$0: acc $id: username tidak ada/salah\n" if $acc{username} !~ /^\w{8}\d{4}$/;
die "$0: acc $id: PIN tidak ada/salah\n" if $acc{pin} !~ /^\d{6}$/;
die "$0: acc $id: PAN tidak ada/salah\n" if $acc{pan} !~ /^\d{4}$/;

$now = time;

# sudah ada session? coba pakai langsung
$csession = "";
if (-f "$id.csession") {
    die "$0: acc $id: $id.cession: $!\n" if !($csession=readfile("$id.csession"));
    chomp($csession);
}

# kalau tidak ada, login
$logindata = "txtUserId=$acc{username}&txtPIN=$acc{pin}&txtPAN=$acc{pan}";
if (!$csession) {
    die "$0: acc $id: Anda pernah gagal login: hapus dulu file $id.fail\n"
        if readfile("$id.fail");
    
    $_ = curl("/login.asp","/main.asp","",$logindata);
    writefile("$id.debug-login-$now.html", $_) if $debug;
    die "$0: acc $id: Gagal login: No response\n" unless $_;
    ($csession) = /(CSESSION=[^;]+)/;

    # gagal login? jika ya, cari tahu kenapa
    if (/main.asp/) {
        unlink "$id.csession";
        $_ = curl("/main.asp", "/login.asp", $csession, $logindata);
        $reason = "";
        m#<script language=javascript>alert\('([^']+)#i and $reason=$1;
        writefile("$id.debug-fail-$now.html", $_) if $debug;
        writefile("$id.fail", "1");
        die "$0: acc $id: Gagal login: $reason\n";
    }

    # tidak jelas hasilnya?
    die "$0: acc $id: Gagal login: ?\n" unless /index2.asp/;

    # setelah berhasil login, save csession
    die "$0: acc $id: Gagal save session: $!\n" if !writefile("$id.csession", $csession);
}

unlink "$id.fail";

# sebelum melakukan transfer, perlu ambil halaman formnya dulu
$_ = curl("/fund_transfer/fundtransfer_1.asp",
          "/nav_bar_indo/menu_bar.html", $csession, "") or die;
writefile("$id.debug-fundtransfer_1-$now.html", $_) if $debug;

# session mungkin expired, suruh user relogin
die "$0: acc $id: Session kemungkinan expired. Hapus dulu file $id.csession.\n"
    if (m#^HTTP/1.\d 30\d#m and /logoff/);

# lakukan transfer (don't worry, sampai tahap konfirmasi saja, untuk mengintip nama pemilik norek)
for $norek (@ARGV) {
    $_ = curl("/fund_transfer/fundtransfer_2.asp",
              "/fund_transfer/fundtransfer_1.asp",
              $csession,
              "D1=Rp.&T1=10000&D2=1-$acc{no}&D4=1-$acc{no}&R1=V1&T2=$norek&FlagTokenLast=Y&submit.x=0&submit.y=0&PIN=284407");
    writefile("$id.debug-fundtransfer_2-$norek-$now.html", $_) if $debug;
    # gagal?
    die "$0: acc $id: norek $norek: Gagal\n" if m#^HTTP/1.\d 30\d#m and /logoff?/;
    ($nama) = m#NAMA PENERIMA.*? : .*?<font.*?>([^<]+)#i;
    $message = ""; $message = $1 if /(TRANSAKSI ANDA GAGAL)/;
    if ($nama) {
    	$nama =~ s/^\s+//s; $nama =~ s/\s+$//s;
    	print "$norek = $nama\n";
    } else {
    	warn "$0: acc $id: norek $norek: Tidak ditemukan? $message\n" unless $nama;
    }
}
