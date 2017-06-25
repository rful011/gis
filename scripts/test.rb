require "dbi"
require "pp"

species = {}
#bushes={}
numbers={}


DBI.connect('DBI:Pg:tiri_pub:localhost', 'rful011', 'rful011') do |dbh|
  dbh.execute("drop table IF exists public.wp_master_tmp")
  dbh.execute("create table base.wp_master_tmp (like base.wp_master INCLUDING ALL )")

  ins=dbh.prepare("insert into base.wp_master_tmp (name, description, created, source, the_geom, type, classification, rw_id)" +
                      "values( ?, ?, ?, ?, ?, ?, ?, ?) ")

  dbh.execute("select * from base.wp_master where") do |sth|
    count = 0
#    puts sth.rows
    sth.fetch_hash do |wp|
      case wp['type']
        when 'nb'
          if m = (wp['name'].match(/B S(\d\d)(\d\d)/) or wp['name'].match(/(\d+)\/(\d+)?(.*)/) or
              wp['name'].match(/^K([A-Za-z]+)_?(\d+)?(.*)/) or wp['name'].match(/^([A-Za-z]+)\/?(\d+)?(.*)/))
            bush, num, more = m.captures
            bush = bush[1..2] if wp['classification'] == 'Kakariki'
            s = wp['classification']
            species[s] ||= {}
            numbers[s] ||= {}
            numbers[s][bush] ||= []
            numbers[s][bush] << num.to_i || 0
            species[s][bush] ||= []
            species[s][bush] << nb
          else
            puts "no match for #{wp['name]']}"
          end
#     end

        when 'weed'
          ins.execute('W '+wp['name'], wp['description'], wp['created'], wp['source'], wp['the_geom'], 'weed', wp['name'])
        else
          ins.execute(wp['name'], wp['description'], wp['created'], wp['source'], wp['the_geom'], wp['type'], wp['name'])
      end
    end
  end
#  upd=dbh.prepare("update public.wp_master_tmp set name = ?, rw_id = ? where gid = ?")


  names = {}
  species.each do |s, bushes|

    bushes.each do |bush, boxes|
      next unless numbers[s][bush].size > 0
      max = numbers[s][bush].max

      boxes.each do |box|

        if m = (box['name'].match(/^B(\d+)\/(\d+)?(\w+)?/) or box['name'].match(/^B S(\d\d)(\d\d)/) or
            box['name'].match(/^(\d+)\/(\d+)(.*)/) or
            box['name'].match(%r!^([A-Za-z]+)[_/]?(\d+)?(.*)!) or box['name'].match(/^(\d+)\/(Ro\d+)?(.*)/)
        )
          bush, num, more = m.captures
          bush = bush[1..2] if s == 'Kakariki'
          if (num and num.match(/Ro/)) or (more and more.match(/Ro/))
            num = ''
            more = 'Ro'
          elsif more and more.match(/^G/)
            num = 1
          end
          sp = s[0].upcase
          rw_id = box['name']
          format = bush.match(/^\d+$/) ? "B #{sp}%02d%02d" : "B #{sp}%2s%02d"
          if more and x= (more.match(/(.*)&(.+)/) or more.match(/(.+)/))
            puts "more :#{rw_id}: '#{more}' #{x.captures}"
            x.captures.each do |xx|
              box_num = xx.downcase == 'a' ? num : max+=1
              puts "Original box ID -- #{box['name']}"
              ins.execute(sprintf(format, bush, box_num), box['description'], box['created'], box['source'], box['the_geom'],
                          2, s == 'saddelback' ? 'saddleback' : s, "#{bush}/#{num}#{xx}")
            end
          else
            ins.execute(sprintf(format, bush, num), box['description'], box['created'], box['source'], box['the_geom'],
                        2, s == 'saddelback' ? 'saddleback' : s, rw_id)
          end
        else
          puts "no match #{box['name']} "
        end
      end
    end
  end
end
