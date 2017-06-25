#require "nokogiri"

require '../../gpx/lib/gpx'
require "pp"

fn = ARGV.shift

if ! fn
  puts "fn:"
  fn = gets.chomp
end

gpx =  GPX::GPXFile.new(:gpx_file => fn )

gpx.waypoints.each do |wp|
  next unless wp.extensions
    puts "#{wp.name} #{wp.extensions} "
#  #ext = wp.extensions.split(/\n\s*/)
end

exit

doc = File.open(fn) { |f| Nokogiri::XML(f) }

#puts doc.at('wpt')

gpx_element = doc.at('gpx')
attributes = gpx_element.attributes
puts attributes

gpx_element.elements.each do |k|
  puts ">>>"
  puts "#{k.at('extensions')}"
end


