class CustomLogger < ActiveSupport::Logger::Formatter
  SEVERITY_COLOR_MAP   = {'DEBUG'=>'0;37', 'INFO'=>'32', 'WARN'=>'33', 'ERROR'=>'31', 'FATAL'=>'31', 'UNKNOWN'=>'37'}

  def call(severity, time, progname, msg)
    formatted_severity = sprintf("%-5s",severity.to_s)
    formatted_time = time.strftime("%Y-%m-%d %H:%M:%S")
    color = SEVERITY_COLOR_MAP[severity]
    "\033[0;37m#{formatted_time} (pid:#{$$})\033[0m [\033[#{color}m#{formatted_severity}\033[0m] #{msg.strip}\n"
  end
end
