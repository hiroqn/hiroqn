# frozen_string_literal: true

# EPEA-CO2-NDIR-07 を USB シリアルから読む。
# プロトコル: 115200 baud, 1 行 JSON {"CO2":570}
# 参考: https://druby.hatenablog.com/entry/2022/10/11/184907
#       https://gist.github.com/seki/964ff441e41a4bef95ec1a532b0e2411

require "fcntl"
require "json"
require "optparse"

options = {
  count: 1,
  warmup: 5,
  device: nil,
}

OptionParser.new do |o|
  o.banner = "Usage: epea-co2 [options]"
  o.on("-d", "--device PATH", "USB serial device") { |v| options[:device] = v }
  o.on("-n", "--count N", Integer, "valid readings to print (0 = until interrupted)") { |v| options[:count] = v }
  o.on("--warmup SEC", Integer, "seconds to wait after opening the port") { |v| options[:warmup] = v }
end.parse!

def detect_device
  found = Dir.glob("/dev/cu.usbserial-*").sort
  abort "No USB serial device found under /dev/cu.usbserial-*" if found.empty?
  warn "multiple devices: #{found.join(", ")}; using #{found.first}" if found.size > 1
  found.first
end

def configure_serial(dev)
  unless system("/bin/stty", "-f", dev, "115200", "raw", "clocal", "cread", "cs8",
                "-parenb", "-cstopb", "-hupcl", "-echo", "-ixon", "-ixoff")
    abort "stty failed for #{dev}"
  end
end

def drain(io)
  loop do
    ready = IO.select([io], nil, nil, 0.2)
    break unless ready
    io.readpartial(4096)
  end
end

dev = options[:device] || detect_device
warn "device=#{dev}"

fd = IO.sysopen(dev, Fcntl::O_RDWR | Fcntl::O_NOCTTY)
io = IO.new(fd)
io.binmode
io.sync = true

begin
  configure_serial(dev)
  sleep options[:warmup]
  drain(io)

  printed = 0
  loop do
    break if options[:count] > 0 && printed >= options[:count]
    ready = IO.select([io], nil, nil, 1)
    next unless ready
    line = io.gets
    break unless line
    line = line.gsub("\r", "").chomp
    next if line.empty?
    begin
      ppm = JSON.parse(line)["CO2"]
    rescue JSON::ParserError
      next
    end
    next unless ppm.is_a?(Numeric)
    puts ppm
    $stdout.flush
    printed += 1
  end
ensure
  io.close
end
