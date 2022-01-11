#!/usr/bin/env ruby
#
require 'logger'
if ARGV[1]
    fd = IO.sysopen("/proc/1/fd/1","w")
    io = IO.new(fd,"w")
    io.sync = true
    MY_APPLICATION_LOG_OUTPUT = io
else
    MY_APPLICATION_LOG_OUTPUT = $stdout
end
$logger = Logger.new MY_APPLICATION_LOG_OUTPUT

require_relative 'extract_deps'
def get_content p
  rns = ""
  File.open(p, 'r') do |f|
    f.each_line do |l|
        rns += l
    end
  end
  rns
end
def main src_root, ninja_root
    Dir.chdir(ninja_root) 
    rns = get_content Dir::pwd + '/obj/webrtc.ninja'
    e = Extract.new rns
     e.gen_cmake
end

main '','/Users/mac/google/macos-ios/src/out/default'
