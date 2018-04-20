require 'pry'
class Generator
  attr_accessor :pdir, :executable, :environment, :project, :requirements

  GREEN='\033[0;32m'
  RED='\033[0;31m'
  NC='\033[0m'
  CREATED = "#{GREEN}created#{NC}"
  ADDLINE = "#{GREEN}added#{NC}"
  ERROR = "#{RED}Error#{NC}: "
  
  def run(array)
    if array[0] == "new"
      # binding.pry
      array.length < 3 ? new(array[1]) : new(array[1], array[2..(array.length-1)])
    elsif array[0] == "--help"
      help
    else
      error("unknown command")
    end
  end

  def error(error_text)
    system("printf '#{ERROR} #{GREEN}#{error_text}#{NC}\n'")
    system("printf 'type #{GREEN}ruby-generator --help#{NC} for more options\n'")
  end

  def new(project, dependencies=nil)
    # print "What would you like to call your project? "
    # project = gets.strip
    @project = project
    @pdir = "./#{project}"
    @executable = "#{pdir}/bin/#{project}"
    @environment = "#{project}/config/environment.py"
    @requirements = "#{pdir}/requirements.txt"
    create_project_dir
    add_bin
    add_config
    add_lib
    !dependencies ? add_requirements : add_requirements(dependencies)
  end

  def create_project_dir
    add_folder(pdir)
  end

  def add_bin
    add_folder("#{pdir}/bin")
    add_file("#{pdir}/bin/#{project}")
    add_line("#!usr/bin/env python", executable)
    add_line("\nimport os", executable)
    add_line("import sys", executable)
    add_line("\ncwd = os.getcwd()", executable)
    add_line('sys.path.append(cwd + "/config")', executable)
    add_line("\nfrom config import *", executable)
  end

  def add_requirements(dependencies=nil)
    add_file("#{pdir}/requirements.txt")
    if dependencies
      dependencies.each do |d|
        add_line(d, requirements)
      end
    end
  end

  def add_lib
    add_folder("#{pdir}/lib")
  end

  def add_config
    add_folder("#{pdir}/config")
    add_file(environment)
    add_line("import os", environment)
    add_line("import sys", environment)
    add_line("\ncwd = os.getcwd()", environment)
    add_line('sys.path.append(cwd + "/lib")', environment)
    add_line("\nfrom lib import *", environment)
  end

  def add_file(path)
    system("touch #{path}")
    system("printf '#{CREATED} #{path}\n'")
  end

  def add_folder(path)
    system("mkdir #{path}")
    system("printf '#{CREATED} #{path}\n'")
  end

  def add_line(text, path)
    system("echo '#{text}' >> #{path}")
    system("printf '#{ADDLINE} #{text} >> #{path}\n'")
  end


  def help
    system("printf '\n#{GREEN}Python Generator Commands#{NC}\n'")
    system("printf -- '-----------------------\n'")
    system("printf '#{RED}new <project name>  <dependencies(optional)>#{NC}   -   Creates a new python project.\n\n'")
  end

end