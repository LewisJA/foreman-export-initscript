require "erb"
require "foreman/export"
require "pry"

class Foreman::Export::Cphep < Foreman::Export::Base

  def export

    super
    error("Must specify a location") unless location
    create_directory("#{location}") rescue error("Could not create: #{location}")
    
    # FileUtils.mkdir_p(location) rescue error("Could not create: #{location}")
    
    # name = "cphep/master.erb"
    # name_without_first = name.split("/")[1..-1].join("/")
    # matchers = []
    # matchers << File.join(options[:template], name_without_first) if options[:template]
    # matchers << File.expand_path("~/.foreman/templates/#{name}")
    # matchers << File.expand_path("../../../../data/export/#{name}", __FILE__)
    # path = File.read(matchers.detect { |m| File.exists?(m) })
    # compiled = ERB.new(path).result(binding)
    # write_file "#{app}", compiled

    
    create_directory("#{app}")

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
      # matchers << File.expand_path("~/Documents/Projects/foreman-export-initscript/data/export/#{name}")
      # matchers << File.expand_path("~/Documents/Projects/foreman-export-initscript/data/export/#{name}", __FILE__)
      File.read(matchers.detect { |m| File.exists?(m) })
    end
  end

    
           
  def log
    options[:log] || "/var/www/apps/#{app}/shared/log/"
  end

end

