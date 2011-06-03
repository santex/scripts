#!/usr/bin/php -q
<?php
$content = join("", file("http://satunet.com/headlines-ekonomi.txt"));
mail(
	"steven@ruby-lang.or.id",
	"Satunet Ekonomi (".date("Y-m-d H:i:s").")",
	$content,
	"From: headlines-satunet-ekonomi@ruby-lang.or.id\n");
?>
