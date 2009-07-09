#!/usr/bin/php
<?php

#$page = file_get_contents("http://www.bi.go.id/web/id/Moneter/Kurs+Bank+Indonesia/Kurs+Uang+Kertas+Asing/");
$page = file_get_contents("kurs-bi.cache");

preg_match('/Update Terakhir\s+(\d\d? \w+ \d\d\d\d)/s', $page, $m);
$tgl = $m[1];
echo $tgl, "\n";

preg_match_all('/>([A-Z]{3})<.+?>([0-9,.]+)<.+?>([0-9,.]+)<.+?>([0-9,.]+)</', $page, $kurs, PREG_SET_ORDER);
print_r($kurs);
