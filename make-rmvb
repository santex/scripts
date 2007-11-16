#!/usr/bin/ruby

# 040703 - ganti dirs. sekarang bikin under vmware karena host gue sekarang
# linux...

# 040422 - sebenernya udah bikin kemaren/2 hari lalu (pake perl), tapi
# partisi FAT32 kayaknya suka lose files? ngeri deh...

# 040421 - make rmvb files from mpg using producer

# --- config

#default_mpeg_dir       = "s:/root/backup/media/tmp/rmvbwork"
#default_temp_dir       = "s:/root/backup/media/tmp/rmvbwork"
default_mpeg_dir       = "s:/root/media2/tmp/rmvbwork"
default_temp_dir       = "s:/root/media2/tmp/rmvbwork"

default_producer_path  = "c:/producer/producer.exe"

default_bitrate        = "450"

# ---

require 'getoptlong'

options = [
  ["-h", "--help", GetoptLong::NO_ARGUMENT],
  ["-t", "--temp-dir", GetoptLong::REQUIRED_ARGUMENT],
  ["-d", "--mpeg-dir", GetoptLong::REQUIRED_ARGUMENT],
  ["-b", "--bitrate", GetoptLong::REQUIRED_ARGUMENT],
  ["-p", "--producer-path", GetoptLong::REQUIRED_ARGUMENT],
]

parser = GetoptLong.new
parser.set_options(*options)

mpeg_dir = temp_dir = producer_path = bitrate = nil

loop {
  opt, arg = parser.get
  break if not opt
  case opt
  when "-h"
    puts "make-rmvb.rb - Make .rmvb files from .mpg files"
    p options
    exit 0
  when "-t"
    temp_dir = arg
  when "-d"
    mpeg_dir = arg
  when "-p"
    producer_path = arg
  when "-b"
    arg =~ /^(350|450)$/ or
      raise ArgumentError, "bitrate must be 350 or 450"
    bitrate = arg
  end
}

if !mpeg_dir
  mpeg_dir = default_mpeg_dir
end
if !FileTest.exists? mpeg_dir
  raise RuntimeError, "mpeg_dir `#{mpeg_dir}' doesn't exist"
end
if !FileTest.directory? mpeg_dir
  raise RuntimeError, "mpeg_dir `#{mpeg_dir}' is not a dir"
end

if !temp_dir
  drive = (mpeg_dir =~ /^([A-Za-z])/) ? $1 : "c"
  #temp_dir = "#{drive}:/tmp"
  temp_dir = default_temp_dir
end
if !FileTest.exists? temp_dir
  raise RuntimeError, "temp_dir `#{temp_dir}' doesn't exist"
end
if !FileTest.directory? temp_dir
  raise RuntimeError, "temp_dir `#{temp_dir}' is not a dir"
end

if !producer_path
  producer_path = default_producer_path
end

if !bitrate
  bitrate = default_bitrate
end

Dir.chdir mpeg_dir
ENV['TMP'] = ENV['TEMP'] = temp_dir
mpegs = Dir.glob("*.mpg") + Dir.glob("*.mpeg") + Dir.glob("*.m1v")
i = 0
mpegs.sort_by { |x| x.downcase }.each { |mpeg|
  i += 1
  mpeg =~ /(.+)\.(m1v|mpe?g)/i; rmvb = "#{$1}.rmvb"
  cmd = %Q(#{producer_path} -am voice -ad "#{bitrate}k VBR Download" -i "#{mpeg}" -o "#{rmvb}")
  
  puts "INFO: #{i}/#{mpegs.length}: #{cmd}"
  
  if (FileTest.exists? rmvb)
    puts "WARN: #{rmvb} already exists, skipping..."
    next
  end

  # nama file yang mengandung '&' mau diconvert, tapi terakhir gagal
  # direname oleh si tolol producer - 2004-10-12
  if (mpeg =~ /&/)
    puts "WARN: #{mpeg} name contains '&', skipping..."
    next
  end
  
  system cmd
}
