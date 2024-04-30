class SusMonitor < Formula
  desc "Monitors system resources and cursor movements to detect suspicious activity"
  homepage "https://github.com/jasonnathan/sus-monitor"  # Update with your actual URL
  url "file:///Users/jasonnathan/Repos/sus-monitor/sus-monitor.py"
  version "1.0"
  sha256 "12b59e3b09dbf92fe9042e6d5256496ff705ed3e71bc5403978cad64d5265627"  # Generate this with `shasum -a 256 /usr/local/bin/sus-monitor.py`

  depends_on "python@3.9"

  def install
    bin.install "sus-monitor.py" => "sus-monitor"
  end

  def plist
    <<~EOS
      <?xml version="1.0" encoding="UTF-8"?>
      <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
      <plist version="1.0">
      <dict>
        <key>Label</key>
        <string>#{plist_name}</string>
        <key>ProgramArguments</key>
        <array>
          <string>#{opt_bin}/sus-monitor</string>
        </array>
        <key>KeepAlive</key>
        <true/>
        <key>RunAtLoad</key>
        <true/>
      </dict>
      </plist>
    EOS
  end

  test do
    system "#{bin}/sus-monitor", "--version"
  end
end
