require "ccbl_generator/version"
require "ccbl_generator/template_helper"
require 'erubis'
require 'plist'
require 'pp'

class TemplateRenderer < Erubis::Eruby
  include CcblGenerator::TemplateHelper
end

class CcblGenerator
  attr_accessor :custom_classes

  def extract_custom_classes(nodes)
    return unless nodes
    extracted = nodes.select{|n| n['baseClass'] != "CCBFile" && n['customClass'].length > 0 }.map{|n|
      {base_class: n['baseClass'],
        custom_class: n['customClass'],
        custom_properties: n["customProperties"]}
    }
    extracted += nodes.map{|n| extract_custom_classes(n['children']) }.flatten
  end

  def extract_member_variables(nodes)
    return unless nodes
    selected = nodes.select{|n| n['memberVarAssignmentName'].length > 0 } 
    selected += nodes.map{|n| extract_member_variables(n['children']) }.flatten
  end

  def initialize(project_name: ,path: )
    raise "No such plist file #{path}" unless File.exists?(path)

    plist = Plist::parse_xml(path)
    class_name = plist["nodeGraph"]["customClass"]
    if class_name.length < 1
      class_name = File.basename(path, ".ccb")
    end

    @custom_classes = extract_custom_classes(plist["nodeGraph"]["children"])
    @custom_classes.uniq!

    
    member_variables = extract_member_variables(plist["nodeGraph"]['children'])
    controls = plist['nodeGraph']['children'].select{|node| node["baseClass"] == 'CCControlButton' }.map{|node|
      n = node["properties"].find{|n| n['name'] == 'ccControl'}["value"]
      n && n.first 
    }
    custom_properties = plist["nodeGraph"]["customProperties"]
    parent_class = (i = custom_properties.index{|v| v['name'] == "parentClass" }) && custom_properties.slice!(i)["value"] if custom_properties

    @binding = {parent_class:      parent_class,
                project_name:      project_name,
                controls:          controls,
                class_name:        class_name,
                base_class:        "Layer",
                plist:             plist,
                member_variables:  member_variables,
                custom_properties: custom_properties,
                custom_classes:    custom_classes,
                property_type: {0 => 'int', 1 => 'float', 2 => 'bool', 3 => 'string' },
                symbol_type:   {0 => '%d',  1 => '%f',    2 => '%d',   3 => '%s'}
    }

  end

  def generate
    {loader: generate_loader(@binding),
     header: generate_header(@binding),
     body:   generate_body(@binding)}
  end

  def generate_loader(binding)
    template = File.expand_path("../../template/loader.h.erb", __FILE__)
    TemplateRenderer.new(File.read(template)).result(binding)
  end

  def generate_header(binding)
    name = case binding[:base_class]
           when "Sprite"
             "sprite_header"
           else
             "header"
           end

    template = File.expand_path("../../template/#{name}.h.erb", __FILE__)
    TemplateRenderer.new(File.read(template)).result(binding)
  end

  def generate_body(binding)
    name = case binding[:base_class]
           when "Sprite"
             "sprite_body"
           else
             "body"
           end
    template = File.expand_path("../../template/#{name}.cpp.erb", __FILE__)

    TemplateRenderer.new(File.read(template)).result(binding)
  end

  def generate_custom_class(classes)
    binding = {project_name:      @binding[:project_name],
               class_name:        classes[:custom_class],
               member_variables:  [],
               custom_properties: classes[:custom_properties],
               controls:          [],
               base_class: classes[:base_class].gsub(/^CC/, ""),
               property_type: @binding[:property_type],
               symbol_type:   @binding[:symbol_type]}
    %w|header body loader|.map{|type|
      [type, send("generate_#{type}", binding)]
    }.to_h
  end
end
