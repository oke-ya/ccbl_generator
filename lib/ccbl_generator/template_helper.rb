module CcblGenerator::TemplateHelper
  def typeof(var)
    if var["baseClass"] == "CCBFile"
      File.basename(var["properties"].find{|prop| prop["name"] == "ccbFile"}["value"], ".ccb")
    else
      var["baseClass"].gsub(/^CC/, '')
    end
  end

  def header_includes(member_variables)
    member_variables.select{|v| v["baseClass"] == "CCBFile" }
      .map{|v| v["properties"].find{|_v| _v["name"] == "ccbFile"}["value"] }
      .map{|v| '#include "' + File.basename(v, ".ccb") + 'Loader.h"'  }.join("\n")
  end
end
