#!/usr/bin/env ruby

require './permissions_generator'
require 'json'
require 'fileutils'

class PermissionsGenerator

  def initialize(permissions_file_path, generators_file_path, modules_file_path, build_root)

    @permissions_file = File.read(permissions_file_path)
    @generators_file = File.read(generators_file_path)
    @modules_file = File.read(modules_file_path)

    @pJson = JSON.parse(@permissions_file)
    @gJson = JSON.parse(@generators_file)
    @mJson = JSON.parse(@modules_file)

    @build_root = build_root
  end

  def camel_to_pascal(camel)
    return camel[0].chr.upcase + camel[1..-1]
  end
  def camel_to_snake(camel)
    camel.gsub(/([^A-Z])([A-Z]{1})/, '\1_\2')
  end
  def spaced_to_pascal(spaced)
    result = ''
    spaced.split(' ').each { |term|
      term = term[0].chr.upcase + term[1..-1]
      result = result + term;
    }
    return result
  end

  def generate_permissions

    built_files = []

    permissions = @pJson['permissions']
    generators = @gJson['generators']

    generators.each{ |generator|

      class_shell = generator['class_shell']

      procs = generator['permission_procs']
      procs.keys.each {|proc_key|
        code = ''
        ruby_proc = eval "proc{#{procs[proc_key]}}"
        permissions.keys.each &ruby_proc
        class_shell = class_shell.sub! proc_key, code
      }

      post_proc = generator['post_proc']
      unless post_proc == nil
        ruby_proc = eval "proc{#{post_proc}}"
        ruby_proc.call()
      end

      target_path = @build_root + generator['target_path'][1..-1]
      built_files.push(target_path)
      dirname = File.dirname(target_path)
      unless File.directory?(dirname)
        FileUtils.mkdir_p(dirname)
      end
      target_file = File.open(target_path, 'w')
      target_file.write(class_shell)
    }

    built_files
  end

  def build_modules
    template = "/* tslint:disable: jsdoc-format */\n/**\n * ======================\n * DO NOT EDIT THIS FILE!\n * ======================\n *\n * This code was generated by the permissions_generator.rb script.\n * Should you wish to add a new IMQS V8 module, follow the instructions\n * to regenerate this class at:\n *\n * https://imqssoftware.atlassian.net/wiki/display/ASC/Generating+Permissions\n */\nmodule iq {\n\texport module auth {\n\t\texport enum AuthModule {MODULES\n\t\t}\n\t}\n}"
    code = ""
    modules = @mJson['modules']
    modules.each {|name|
      code = code + "\n\t\t\t#{camel_to_snake(spaced_to_pascal(name['name'])).upcase} = <any>\"#{name['name']}\","
    }
    template = template.sub('MODULES', code).sub(",\n\t\t}", "\n\t\t}")
    target_file = File.open(@build_root+"/www/js/auth/modules.ts", 'w')
    target_file.write(template)
  end
end

def get_infrastructurebuild_root
  currentDir = File.dirname(__FILE__)
  currentDir[0..(currentDir.index('InfrastructureBuild')+19)]
end

jpm = PermissionsGenerator.new('permissons.json', 'generators.json', 'modules.json', get_infrastructurebuild_root)
jpm.build_modules()
generated = jpm.generate_permissions()
puts "The following files were generated:\n\n"
generated.each { |path|
    puts "\t#{path}"
}
puts "\nThese files will need to be manually committed and pushed to their respective project repos."
puts "NB: The permisisons.json file must only ever be pushed to master, so as to avoid conflicts between teams."
exit