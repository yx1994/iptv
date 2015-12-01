#!/usr/bin/env ruby
require 'open-uri'
open('http://tv.byr.cn/mobile/').read.force_encoding('utf-8').scan(/<a href="([^"]+)" target="_blank" class="btn btn-block btn-primary">(.+高清)<\/a>/).each{|i| puts('%-40s%s'%i)}
puts open('http://hdtv.neu6.edu.cn/hdtv.txt').read.gsub(',','    ')
