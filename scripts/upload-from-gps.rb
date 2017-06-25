#!/usr/bin/ruby -w

require "digest"
require "gpx"
#require "../../gpx/lib/gpx"
require "json"
require "pp"


def diff?(wp1, wp2)

  wp1.lat != wp2.lat or wp1.lon != wp2.lon

end

def wp_type(name)

  case name
    when /^RT/
      'rt'
    when /^B/
      'nb'
    when /^S/
      'sign'
    when /^T/
      'track'
    when /^W/
      'weed'
  end
end


upload = true

#garmin_base = %r|/Volumes/GARMIN|
repository = '/Users/rful011/GPS-Data'
new_dir ||= Time.new.strftime("%Y-%m-%d")

current = "current"
#keep_data_for = ' 6 months'
devices = {}

Dir.chdir repository


Dir.mkdir(new_dir) unless Dir.exist?(new_dir)
Dir.mkdir(current) unless Dir.exist?(current)

archive = {}

# copy all the files from the latest directory to new_dir and compute md5 for all gpx files

Dir.foreach("latest") do |f|
  next if File.directory?("latest/#{f}")
  digest = nil

#  next unless f.match(/-(Track|Wayp).+\.gpx$/)

  if File.exist? "#{new_dir}/#{f}"
    digest = Digest::MD5.file("latest/#{f}")
    next if digest == Digest::MD5.file("#{new_dir}/#{f}") # they are the same
  end

  system('cp', '-p', "latest/#{f}", "#{new_dir}/#{f}") if upload
  archive[f] = {:mtime => File.mtime("latest/#{f}")}
  archive[f][:digest] ||= Digest::MD5.file("latest/#{f}")

  puts "#{f}: #{archive[f]}"
end

if upload

  if File.exist?("#{repository}/devices.json")
    json = ''
    File.foreach("#{repository}/devices.json") { |l| json += l.chomp }
    devices = JSON.parse(json)['devices']
  end


#find mounted gpses and loop over them

  Dir.foreach('/Volumes') do |vol|
    next unless vol.match(/^GARMIN/);

    device = ''

# get the device ID form the device file

    id = ''
    garmin_dir = "/Volumes/#{vol}/Garmin/"

    File.foreach("/#{garmin_dir}/GarminDevice.xml") { |l| l.match(/<Id>(\d+)<\/Id>/) { |m| id = m.captures[0] } }

    device = devices[id]

# for each gpx file on the device  copy new or changed files to current
#   all have already been copied to

    Dir.foreach("#{garmin_dir}/GPX") do |f|
      next unless f.match(/^(Track|Wayp).+\.gpx$/)
      ff = "#{device}-#{f}"

      d = Digest::MD5.file("#{garmin_dir}/GPX/#{f}")
      puts "#{archive[ff][:digest]} #{d}" if archive[ff]
      if !archive[ff] or (archive[ff] and archive[ff][:digest] != Digest::MD5.file("#{garmin_dir}/GPX/#{f}"))
        ## new or changed
        system('cp', '-p', "#{garmin_dir}/GPX/#{f}", "#{current}/#{ff}") # Copy it to current for further processing
      end
      system('cp', '-p', "#{garmin_dir}/GPX/#{f}", "#{new_dir}/#{ff}") # Copy it to new archive
    end
  end

end

# At this point we should have an archive copy of the GPX directory in new_dir
# and a copy of all new/chagned files in current

#instantiate gpx object to hold new and changed objects

changed = GPX::GPXFile.new()
new = GPX::GPXFile.new()

Dir.foreach(current) do |f|

  next unless f.match(/Waypoints/)

  original = nil
  if archive[f] # existing file -- read it so we can figure out what changed
    original = {}
    gpx = GPX::GPXFile.new(:gpx_file => "latest/#{f}")
    gpx.waypoints.each do |wp|
      original[wp.name] = wp
    end
  end

  gpx = GPX::GPXFile.new(:gpx_file => "current/#{f}")

  gpx.waypoints.each do |wp|
    wp.src = 'RJF'
    wp.type = wp_type(wp.name)
    wp.cmt = wp.extensions.to_s

    if original
      if !original[wp.name]
        new.waypoints << wp
      elsif diff?(original[wp.name], wp)
        changed.waypoints << wp
      end
    else
      new.waypoints << wp
    end
  end
end # loop for files in current


new.write('current/new.gpx') if new.waypoints.size > 0
changed.write('current/changed.gpx') if changed.waypoints.size > 0