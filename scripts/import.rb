require "dbi"
require "pp"
require_relative '../parser'


patterns = [
    /B S(\d\d)(\d\d)/,
    /(\d+)\/(\d+)?(.*)/,
    /^K([A-Za-z]+)_?(\d+)?(.*)/,
    /^([A-Za-z]+)\/?(\d+)?(.*)/
]

box_classes = {}
name_classes = {}

patterns.each_index do |i|
  name_classes[patterns[i]] = []
end

name_classes['none'] = []

DBI.connect('DBI:Pg:tiritiri:localhost', 'rful011', 'rful011') do |dbh|
  dbh.execute("select * from base.wp_master where type = 2 ") do |sth|
    count = 0
    puts sth.rows
    sth.fetch_hash do |nb|
#      puts "name #{nb['name']}"
#        case  classification
#        when 'saddelback'
##      if m = ( nb['name'].match(/B S(\d\d)(\d\d)/) or nb['name'].match(/(\d+)\/(\d+)?(.*)/) or
#          nb['name'].match(/^K([A-Za-z]+)_?(\d+)?(.*)/) or  nb['name'].match(/^([A-Za-z]+)\/?(\d+)?(.*)/)   )
#        bush, num, more = m.captures
#        bush = bush[1..2] if nb['classification'] == 'Kakariki'
#        s = nb['classification']
#        species[s] ||= {}
#        numbers[s] ||= {}
#        numbers[s][bush] ||= []
#        numbers[s][bush] << num.to_i || 0
#        species[s][bush] ||= []
#        species[s][bush] << nb
#puts ">>>> #{nb['name']} #{bush} #{num}"
#      else
#        puts "no match for #{nb['name]']}"


      box_classes[nb['classification']] = nb

      match = false

      name_classes.each_key do |x|
        if nb['name'].match x
          match = true
          name_classes[x] << nb['name']
        end
      end

      unless match
        name_classes['none'] << nb['name']
      end

    end
    pp box_classes.keys
    pp name_classes

    n_matches = 0
    name_classes.each_value do |x|
      n_matches += x.size
      puts x.size
    end

    puts "Total match events: #{n_matches}"
#     end

  end
end