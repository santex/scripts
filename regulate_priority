#!/usr/bin/ruby

# 040227 - regulate win2k process priorities. some processes are naughty and setting their 
# priorities to High, some others just need to be set to lower because win2k scheduler sucks.

DELAY = 5

PSTAT_COMMAND = "pstat"

NORMAL_PRIORITY_CLASS = 32
IDLE_PRIORITY_CLASS = 64
BELOW_NORMAL_PRIORITY_CLASS = 0x4000
ABOVE_NORMAL_PRIORITY_CLASS = 0x8000

priorities = {
  /vmware-vmx\.exe/i => BELOW_NORMAL_PRIORITY_CLASS,
  /nero\.exe/i => NORMAL_PRIORITY_CLASS,
  /producer\.exe/i => IDLE_PRIORITY_CLASS,
  /flaskmpeg\.exe/i => IDLE_PRIORITY_CLASS,
}

###

require 'Win32API'

FORMAT_MESSAGE_IGNORE_INSERTS  = 0x00000200
FORMAT_MESSAGE_FROM_SYSTEM     = 0x00001000
PROCESS_SET_INFORMATION        = 0x0200
PROCESS_QUERY_INFORMATION      = 0x0400

OpenProcess = Win32API.new('kernel32', 'OpenProcess', 'LLL', 'L')
SetPriorityClass = Win32API.new('kernel32', 'SetPriorityClass', 'LL', 'L')
GetLastError = Win32API.new('kernel32', 'GetLastError', '', 'L')
FormatMessageA = Win32API.new('kernel32', 'FormatMessageA', 'LPLLPLPPPPPPPP', 'L')

def lastErrorMessage
  code = GetLastError.call
  msg = "\0" * 1024
  len = FormatMessageA.call(FORMAT_MESSAGE_IGNORE_INSERTS +
                            FORMAT_MESSAGE_FROM_SYSTEM, 0,
                            code, 0, msg, 1024, nil, nil,
                            nil, nil, nil, nil, nil, nil)
  msg[0, len].tr("\r", '').chomp
end

def getphandle(pid)
  if ((phandle = OpenProcess.call(
         PROCESS_QUERY_INFORMATION | PROCESS_SET_INFORMATION, 
         1, 
         pid)) == 0)
    raise SystemCallError, lastErrorMessage
  end
  phandle
end

def setpriority(pid, prio)
  phandle = getphandle(pid)
  if SetPriorityClass.call(phandle, prio) == 0
    raise SystemCallError, lastErrorMessage
  end
end

loop {
  IO.popen(PSTAT_COMMAND) { |f|
    f.each { |line|
      next unless line =~ /^\s+\d+:\d+:\d+/
      line =~ /.+\s+(\d+)\s+(.+)/; pid, proc = $1, $2; pid = pid.to_i
      priorities.each_pair { |re, prio|
        next unless proc =~ re
        setpriority(pid, prio)
      }
    }
  }
  sleep DELAY
}
