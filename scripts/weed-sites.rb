#! /usr/bin/ruby

require "gpx"
require "pp"

colours = {
    'Block' => %W(Red, Blue, Green),
    'Flag' => %W(Red, Blue, Green),
    'Pin' => %W(Red, Blue, Green),
    'Rectangle' => %W(Red, Blue, Green),

}

files = {}

markers = {  # by type
      '1' => ['Weed Site', 'Block, Blue' ],
      '2' => ['Nest Box',  'Circle, Red' ],
      '4' => ['Weed Site', 'block , Red' ],
      '5' => ['Sign', 'Pin, Green' ],
      '6' => ['Track', 'Flag, Blue' ],
      '9' => ['Nest box', 'Flag, Red' ],
}

nestbox = {
      'hihi' => ['hihi', 'Circle, Black'],
      'saddleback' => ['saddelback', 'Circle, Orange'],
      'kakariki' => ['Kakariki', 'Circle, Red']
}

fn = ARGV.shift
gpx =  GPX::GPXFile.new(:gpx_file => fn )

gpx.waypoints.each do |wp|
  ext = wp.extensions.split(/\n\s*/)
  wp.cmt = ext[2]  # description
  #pp ext if wp.type == '2'
  if wp.type == '2' and ext[5] and nb = nestbox[ext[5].downcase]# bird
   # puts ">>> #{ext[5]}"
    wp.sym = nb[1]
    wp.type =  nb[0]
   elsif markers[wp.type]
    wp.sym = markers[wp.type][1]
    wp.type =  markers[wp.type][0]
  else
    puts "????"
    puts wp
  end
  wp.extensions = nil
end

fn = fn.sub(/\.gpx$/, '')

gpx.write("#{fn}-new.gpx")