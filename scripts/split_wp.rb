#! /usr/bin/ruby -w


# takes a GPX file exported from QGIS wp_master layer which has attribute data stored in the extensions
# and moves the data into fields where the garmin GPS expects them.
# it also sets symbols and colours according config tables below

# the output is written to several different GPX files which makes it easy to control what is dispayed on GPS



#require "gpx"
require_relative '../../gpx/lib/gpx.rb'

require "pp"

nestbox = {
    'hihi' =>  'Navaid, Black',
    'saddleback' => 'Navaid, Orange',
    'kakariki' =>  'Circle, Red',
    'rifleman' =>  'Circle, Green',
    'files' => true
    }
nestbox.default = 'Navaid, White',

weeds = {
    'mp' => 'Block, Blue',
    'sp' => 'Flag, Blue',
    'mm' => 'Diamond, Blue',
    'pw' => 'Square, Blue',
    'files' => false
    }
weeds.default = 'Pin, Blue'


markers = {  # by type
             'weed' => weeds,
             'nb' =>  nestbox ,
             'sign' => 'Pin, Green' ,
             'track' =>  'Flag, Red',
      }
markers.default = 'Flag, Black'

gpx_out = {}

# build a list of file from the config above

files = []

markers.each do |k,v|
    if v.class == Hash and v['files']
    v.each { |kk, vv| files << kk unless kk == 'files'}
  else
    files << k
  end
end


fn = ARGV.shift
gpx_in =  GPX::GPXFile.new(:gpx_file => fn )


# instantiate the GPX file objects for output

files.each {|f| gpx_out[f] = GPX::GPXFile.new }

gpx_in.waypoints.each do |wp|

  ext = wp.extensions_h
  puts ">>>>>", ext
  type =  wp.type
  next unless m = markers[ type ]

  if m.class == Hash   # there is a nested list
    next unless c = ext['classification']
    c = c.downcase
    next unless m = m[c]
    type = c  if markers[type]['files']  # true if we want individual files
  end

  next unless  gpx_out[type]

  # fiddle with the waypoint before adding it to the apprpriate file.
  wp.sym = m
  wp.extensions = nil
  wp.name = ext['rw_id'] if ext['rw_id']
  wp.cmt = ext['description']  # description
  gpx_out[type].waypoints << wp
end
exit
# Write out all the files

files.each do |f|
  gpx_out[f].write("#{f}.gpx")
end