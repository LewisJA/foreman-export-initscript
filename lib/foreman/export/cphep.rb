require "erb"
require "foreman/export"

class Foreman::Export::Cphep < Foreman::Export::Base

  def export
    create_directory("#{app}") rescue error("Can not create:  #{location}/#{app}")
    FileUtils.chown(user, nil, "#{location}") rescue error("Could not chown #{location} to #{user}")
    FileUtils.chown(user, nil, "#{location}/#{app}") rescue error("Could not chown #{location}/#{app} to #{user}")

    Dir["#{app}*"].each do |file|
      clean file
    end
    
    engine.each_process do |name, process|
      next if engine.formation[name] < 1
      1.upto(engine.formation[name]) do |num|
        port = engine.port_for(process, num)
        write_template "cphep/process.erb", "#{app}/#{name}", binding
      end
    end
  end


  
  def export_template(name, file=nil, template_root=nil)
    if file && template_root
      old_export_template name, file, template_root
    else
      name_without_first = name.split("/")[1..-1].join("/")
      matchers = []
      matchers << File.join(options[:template], name_without_first) if options[:template]
      matchers << File.expand_path("../foreman-export-initscript/data/export/#{name}")
      File.read(matchers.detect { |m| File.exists?(m) })
    end
  end


  
  def location
    options[:location] || "/etc/init.d"
  end


  
  def log
    options[:log] || "#{engine.root}/log"
  end

end
