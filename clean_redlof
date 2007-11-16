#!/usr/bin/ruby

# 040212

VER = "0.011 [2004-02-12]".freeze

require 'find'

puts <<EOF
clean_redlof - Attempt to clean Redlof-infected HTML/ASP/PHP files.

Version #{VER}, Copyright (c) 2003-2004 PT Master Web Network

Permission to use, copy, modify, and distribute this software and its
documentation for any purpose, without fee, and without a written agreement
is hereby granted, provided that the above copyright notice and this
paragraph and the following two paragraphs appear in all copies.

IN NO EVENT SHALL PT MASTER WEB NETWORK BE LIABLE TO ANY PARTY FOR DIRECT,
INDIRECT, SPECIAL, INCIDENTAL, OR CONSEQUENTIAL DAMAGES, INCLUDING LOST
PROFITS, ARISING OUT OF THE USE OF THIS SOFTWARE AND ITS DOCUMENTATION, EVEN
IF PT MASTER WEB NETWORK HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

EOF

raise ArgumentError, "Usage: clean_redlof <directory>\n" unless ARGV.length == 1
dir = ARGV[0]
raise RuntimeError, "Directory `#{dir}' doesn't exist" unless File.exists?(dir)

Find.find(dir) { |path|
  next unless File.file? path
  print "#{path}: "
  unless path =~ /\.(s?html?|stm|php[34]?|phtml|asp|htt|asa)$/i
    puts "skipped."
    next
  end
  content = File.open(path).read
  origcontent = content.dup
  if content.gsub!(/\s*onload="?vbscript:KJ_start\(\)"?/mi, '')
    content.gsub!(%r{<script language=vbscript>.+?</script>}mi) { |m|
      if m =~ /ExeString|APPLET NAME=KJ/
        ""
      else
        m
      end
    }
  end

  if content != origcontent
    print "INFECTED, cleaning... "
    fp = File.open(path, "w")
    fp.print content
    fp.close
    puts "cleaned."
  else
    puts "clean."
  end
}
