#!/usr/bin/env ruby

require 'json'
require 'fileutils'
require_relative 'generators_static_data'

def infrastructurebuild_root
  root = File.dirname(File.dirname(File.dirname(__FILE__)))
  if root === '.'
    root = File.dirname(File.dirname(__dir__))
  end
  return root
end

def generate_permissions
  built_files = []

  permissions = JSON.parse(File.read('permissions.json'))['permissions']
  outputs = JSON.parse(File.read('outputs.json'))['outputs']

  outputs.each{ |output|
    type = Generators[output["type"]]
    template = type[:template]
    procs = type[:procs]
    procs.each {|pname, pfunc|
      code = ''
      permissions.each_with_index { |pair, i|
        enum, perm = pair[0], pair[1]
        code += pfunc.call(enum.to_i, perm, i == permissions.length - 1) + "\n"
      }
      template = template.sub!(pname, code)
    }

    target_path = File.join(infrastructurebuild_root, output['target_path'])
    built_files.push(target_path)
    dirname = File.dirname(target_path)
    FileUtils.mkdir_p(dirname) if !File.directory?(dirname)
    File.open(target_path, 'w') { |f|
      f.write(template)
    }
  }

  return built_files
end

def build_modules
  template = "/* tslint:disable: jsdoc-format */\n/**\n * ======================\n * DO NOT EDIT THIS FILE!\n * ======================\n *\n * This code was generated by the permissions_generator.rb script.\n * Should you wish to add a new IMQS V8 module, follow the instructions\n * to regenerate this class at:\n *\n * https://imqssoftware.atlassian.net/wiki/display/ASC/Generating+Permissions\n */\nnamespace iq {\n\texport namespace auth {\n\t\texport enum AuthModule {MODULES\n\t\t}\n\t}\n}"
  code = ""
  modules = JSON.parse(File.read('modules.json'))['modules']
  modules.each {|name|
    code = code + "\n\t\t\t#{camel_to_snake(spaced_to_pascal(name['name'])).upcase} = <any>\"#{name['name']}\","
  }
  template = template.sub('MODULES', code).sub(",\n\t\t}", "\n\t\t}")
  File.open(File.join(infrastructurebuild_root, "www/js/auth/modules.ts"), 'w') { |f|
    f.write(template)
  }
end

build_modules()
generated = generate_permissions()
puts "The following files were generated:\n\n"
generated.each { |path|
    puts "\t#{path}"
}
puts "\nThese files will need to be manually committed and pushed to their respective project repos."
puts "NB: The permisisons.json file must only ever be pushed to master, so as to avoid conflicts between teams."
