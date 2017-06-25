require '../../gpx/lib/gpx'

module GarminGPX
  class Point < GPX::Point

    def initialize(elem)
      @vals = {}
      elem.elements.each do |e|
        e.elements.each do |ext|
          m = ext.to_s.match(%r|wptx1:([^>]+)>(.+)</wptx1:|)
          @vals[m[1]] = m[2].match(/^\d+$/) ? m[2].to_i : m[2]
        end
      end
    end
  end
end
