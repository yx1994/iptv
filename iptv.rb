#!/usr/bin/env ruby

# author: yang xin<yx-1994@hotmail.com>

require 'open-uri'
require 'fiddle'
require 'timeout'

queue=Queue.new
url=ARGV[0]||'http://tv6.byr.cn/hls/hunanhd.m3u8'
name="#{File.basename(url,'.*')}.#{Time.now.strftime('%H.%M.%S')}.ts"

$log=open(name+'.log','ab')
$err=0

at_exit do
	$log.close
end

def log(s)
	puts s
	$log.puts s
end

producer=Thread.new do
	last=[]
	loop do
		open(url) do |list|
			this=list.each_line.grep(/^[^\#]/).map &:chop
			(this-last).each do |i|
				queue << Thread.new do
					Thread.current[:i]=i
					open(URI.join(url,i)).read
				end
				log " + #{i} #{Time.now}"
			end
			last=this
		end
		sleep 5
	end
	queue << nil
end

consumer=Thread.new do
	open(name,'ab') do |file|
		while i=queue.pop
			begin
				Timeout::timeout(30){file << i.value}
			rescue Timeout::Error => e
				log e
				$err+=1
			end
			log " - #{i[:i]} #{Time.now} #{$err}"
		end
	end
end

kernel=Fiddle.dlopen 'kernel32.dll'
func=Fiddle::Function.new kernel['SetThreadExecutionState'],[Fiddle::TYPE_LONG_LONG],Fiddle::TYPE_LONG_LONG
func.call 0x00000040|0x80000000|0x00000001

producer.join
consumer.join
