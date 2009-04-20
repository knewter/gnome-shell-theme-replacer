# --
# Copyright 2009, Josh Adams
# This should have the GPL applied to it, but I can't be bothered to insert a copy just yet
# ++
# We want to loop through all .js files in a given directory and, given a particular
# yml file that defines constants, we want to replace all instances of CONST.from_pixel(something)
# to CONST.from_pixel(config_value_for_const)
#
# The yml should look like:
# ITEM_DISPLAY_NAME_COLOR: 0xffaabbff # where the value is a hexadecimal color + alpha channel
# CONST_TWO: 0xaaaaaaff
# ...etc.

require 'yaml'

theme_file = ARGV[0]
theme_file ||= '/home/jadams/ruby/gnome-shell-theme-replacer/gnome-shell-theme-replacer.yml' # FIXME: obv. this needs to be an arg for the script :)

config = YAML::load( File.open( theme_file )) 
gnome_shell_dir = '/home/jadams/gnome-shell' # FIXME: obv. this should be configurable, perhaps in a dotfile

# grab all of the javascript files in #{gnome_shell_dir}/source/gnome-shell/js/ui
js_ui_dir = gnome_shell_dir + "/source/gnome-shell/js/ui"
js_files = Dir.entries(js_ui_dir).select{|f| f =~ /.js/}
puts js_files.inspect

js_files.each do |filename|
  # Initially, we'll just iterate over the hash we get out of the yaml file and do a strict gsub,
  # that should work fairly well for now.
  file = File.open(js_ui_dir + "/" + filename, "r+")
  str = file.read
  config.each_pair do |key, value|
    puts key 
    puts value

    # handle colors
    str.gsub!(/#{key}.from_pixel\(([^)]*)\)/) do
      "#{key}.from_pixel(#{value})"
    end

    # handle other constants
    str.gsub!(/const #{key} = (\d*);/) do
      "const #{key} = #{value};"
    end
  end
  file.rewind
  file.write(str)
end
