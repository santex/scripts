#!/usr/bin/ruby

# 040118. telkom lines SUCK!!!

def time_delta_as_phrase(delta)
  delta = delta.floor
  is_neg = delta <= 0 ? true : false
  delta = delta.abs

  years = (delta / (365*86400)).floor; delta -= years * 365*86400
  months = (delta / (30*86400)).floor; delta -= months * 30*86400
  days = (delta / 86400).floor; delta -= days * 86400
  hours = (delta / 3600).floor; delta -= hours * 3600
  minutes = (delta / 60).floor; delta -= minutes * 60
  secs = delta
  
  [
    (years > 0  ? "#{years} tahun" : ""),
    (months > 0 ? "#{months} bulan" : ""),
    (days > 0 ? "#{days} hari" : ""),
    (hours > 0 ? "#{hours} jam" : ""),
    (minutes > 0 ? "#{minutes} menit" : ""),
    "#{secs} detik",
    (is_neg ? "lalu" : "lagi")
  ].select {|x| x.length > 0}.join " "
end

def time_delta_as_hms(delta)
  is_neg = delta < 0 ? true : false
  delta = delta.floor.abs

  hours = (delta / 3600).floor; delta -= hours * 3600
  minutes = (delta / 60).floor; delta -= minutes * 60
  secs = delta
  
  sprintf "%02d:%02d:%02d", hours, minutes, secs
end

def speed_as_kbps(bytes, secs)
  if secs == 0
    "-"
  else
    s = bytes*8/1024.0/secs
    if s >= 1000
      "***"
    elsif s < 10
      sprintf "%.1f", s
    else
      sprintf "%3d", s
    end
  end
end

last_on_time = last_off_time = nil
rx = tx = 0
deltarx = deltatx = 0
deltarx_15sec = deltatx_15sec = 0
deltarx_1min = deltatx_1min = 0
deltarx_5min = deltatx_5min = 0
deltarx_15min = deltatx_15min = 0

loop do
  ifconfig = `/sbin/ifconfig ppp0 2>&1`
  now = Time.now.to_i
  
  if ifconfig =~ /RX bytes:\s*(\d+)/

    if !last_on_time
      last_on_time = now
      last_off_time = nil
      lastrx = rx = $1.to_i; ifconfig =~ /TX bytes:\s*(\d+)/; lasttx = tx = $1.to_i
      deltarx, deltatx = 0, 0
      lastdeltarx = lastdeltatx = 0, 0
      deltarx_15sec = deltatx_15sec = 0
      deltarx_1min = deltatx_1min = 0
      deltarx_5min = deltatx_5min = 0
      deltarx_15min = deltatx_15min = 0
    else
      lastrx, lasttx = rx, tx
      lastdeltarx, lastdeltatx = deltarx, deltatx
      rx = $1.to_i; ifconfig =~ /TX bytes:\s*(\d+)/; tx = $1.to_i
      deltarx, deltatx = (rx-lastrx), (tx-lasttx)
      deltarx_15sec += deltarx; deltatx_15sec += deltatx
      deltarx_1min += deltarx; deltatx_1min += deltatx
      deltarx_5min += deltarx; deltatx_5min += deltatx
      deltarx_15min += deltarx; deltatx_15min += deltatx
    end
    
    on_time = now - last_on_time
    
    #puts "lastrx=#{lastrx}, deltarx=#{deltarx}, lastdeltarx=#{lastdeltarx}, deltarx_15sec=#{deltarx_15sec}"
    
    #doh, gak becus nih rumusnya
    #printf "%s RX=[%8d %3s %3s %3s %3s %3s]  TX=[%8d %3s %3s %3s %3s %3s]\n",
    #  time_delta_as_hms(on_time),
    #  rx,
    #  speed_as_kbps(deltarx, 1),
    #  speed_as_kbps(deltarx_15sec, (on_time > 15 ? 15 : 0)),
    #  speed_as_kbps(deltarx_1min, (on_time > 60 ? 60 : 0)),
    #  speed_as_kbps(deltarx_5min, (on_time > 300 ? 300 : 0)),
    #  speed_as_kbps(deltarx_15min, (on_time > 900 ? 900 : 0)),
    #  tx,
    #  speed_as_kbps(deltatx, 1),
    #  speed_as_kbps(deltatx_15sec, (on_time > 15 ? 15 : 0)),
    #  speed_as_kbps(deltatx_1min, (on_time > 60 ? 60 : 0)),
    #  speed_as_kbps(deltatx_5min, (on_time > 300 ? 300 : 0)),
    #  speed_as_kbps(deltatx_15min, (on_time > 900 ? 900 : 0))

    printf "%s RX=[%8d %3s]  TX=[%8d %3s]\n",
      time_delta_as_hms(on_time),
      rx,
      speed_as_kbps(deltarx, 1),
      #speed_as_kbps(deltarx_15sec, (on_time > 15 ? 15 : 0)),
      #speed_as_kbps(deltarx_1min, (on_time > 60 ? 60 : 0)),
      #speed_as_kbps(deltarx_5min, (on_time > 300 ? 300 : 0)),
      #speed_as_kbps(deltarx_15min, (on_time > 900 ? 900 : 0)),
      tx,
      speed_as_kbps(deltatx, 1),
      #speed_as_kbps(deltatx_15sec, (on_time > 15 ? 15 : 0)),
      #speed_as_kbps(deltatx_1min, (on_time > 60 ? 60 : 0)),
      #speed_as_kbps(deltatx_5min, (on_time > 300 ? 300 : 0)),
      #speed_as_kbps(deltatx_15min, (on_time > 900 ? 900 : 0))
      
      nil

    if on_time > 15; deltarx_15sec -= lastdeltarx; deltatx_15sec -= lastdeltatx; end
    if on_time > 60; deltarx_1min -= lastdeltarx; deltatx_1min -= lastdeltatx; end
    if on_time > 300; deltarx_5min -= lastdeltarx; deltatx_5min -= lastdeltatx; end
    if on_time > 900; deltarx_15min -= lastdeltarx; deltatx_15min -= lastdeltatx; end
    
  elsif ifconfig =~ /Device not found/
    if !last_off_time
      last_off_time = now
      last_on_time = nil
    end
    puts "Down (setidaknya sejak #{time_delta_as_phrase(last_off_time - now)})"

  else
    raise RuntimeError, "Error, unexpected ifconfig output: #{ifconfig}"
  end

  sleep 1
end
