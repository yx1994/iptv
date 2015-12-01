#!/usr/bin/env ruby
require 'open-uri'

queue=SizedQueue.new 10
url=ARGV[0]
name=File.basename(url,'.*')<<'.ts'
Thread.new do
	open(url) do |list|
		list.each_line.grep(/^[^\#]/).map(&:chomp).each do |i|
			puts i
			queue<<Thread.new do
				begin
					open(URI.join(url,i)).read
				rescue
					retry
				end
			end
		end
	end
	queue<<nil
end

Thread.new do
	open(name,'wb') do |file|
		while i=queue.pop
			file<<i.value
		end
	end
end.join
