#!/usr/bin/ruby -w

prefix = ARGV.shift
prefix = "#{prefix}-" if prefix.match(/\w$/)  # append - if the prefix ends in alphanumeric


Dir.foreach('.') {|fn| File.rename(fn, "#{prefix}#{fn}") unless File.directory?(fn) }