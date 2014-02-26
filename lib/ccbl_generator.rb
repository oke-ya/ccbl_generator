require "ccbl_generator/version"
require 'erubis'
require 'plist'

class CcblGenerator
  def initialize(project_name: ,path: )
    raise "No such plist file #{path}" unless File.exists?(path)

    plist = Plist::parse_xml(path)
    class_name = plist["nodeGraph"]["customClass"]
    if class_name.length < 1
      class_name = File.basename(path, ".ccb")
    end
    @binding = {project_name: project_name,
                class_name:   class_name,
                plist:        plist}

  end

  def generate
    generate_loader
    generate_header
  end

  def generate_loader
    template = File.expand_path("../../template/loader.h.erb", __FILE__)
    @loader = Erubis::Eruby.new(File.read(template)).result(@binding)
  end

  def generate_header
    template = File.expand_path("../../template/header.h.erb", __FILE__)
    @loader = Erubis::Eruby.new(File.read(template)).result(@binding)
  end
end
