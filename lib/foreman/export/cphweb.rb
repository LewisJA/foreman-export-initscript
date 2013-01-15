require "erb"
require "foreman/export"

class Foreman::Export::Cphweb < Foreman::Export::Base

  def export

        #super
        error("Must specify a location") unless location
        FileUtils.mkdir_p(location) rescue error("Could not create: #{location}")

        name = "cphweb/master.erb"
        name_without_first = name.split("/")[1..-1].join("/")
        matchers = []
        matchers << File.join(options[:template], name_without_first) if options[:template]
        matchers << File.expand_path("~/.foreman/templates/#{name}")
        matchers << File.expand_path("../../../../data/export/#{name}", __FILE__)
        path = File.read(matchers.detect { |m| File.exists?(m) })
        compiled = ERB.new(path).result(binding)
        write_file "#{app}", compiled
       end
       
  def log
    options[:log] || "/var/www/apps/#{app}/shared/log/"
  end

end

