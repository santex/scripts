#!/usr/bin/perl -0 -pi

# 040505

s#<script.+?</script>##sig;
s#<link[^>]+>##sig;
s#<div id="navi".+?</div>##si;
