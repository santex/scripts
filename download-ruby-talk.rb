#!/usr/bin/ruby
#
# download_talk.rb
#
# utility to download ruby talk news from Ruby Talk web site
#         http://www.ruby-talk.org/cgi-bin/scat.rb/ruby/ruby-talk/
#         each news requires at least 7KB, and Ruby talk is upto 30,000
#         so allocate enough space in your drive.
#         it takes 1 hour to D/L 1000 news by 56KB modem( 42KB)
#         But you can adjust the number of news you want to download
#
# usage: ruby download_talk.rb   from   to  folder
#         from:  starting number of news
#         to:  ending number of news
#         folder:  folder name to save the news,  created automatically by this
#
# example: 
#        to download ruby talk news from 1 to 1000 to the folder talk001,
#
#        ruby download_talk.rb 1 1000 talk001
#
# tips for fast downloading
#        run several of this program at the same time
#        I run 8 of this program sucessfully with 56K modem
#
# no error handling but you can run again
# because it checks the file is already downloaded before it downloads the file
#
# need   http, ftools
#
# by Sungjin Moon
#

require 'net/http'
require 'ftools'

RUBY_TALK_HOST = "www.ruby-talk.org"
DIR = "/cgi-bin/scat.rb/ruby/ruby-talk/"

def download( from, to, folder )
   # this creates a  folder if it doesn't exist,
   # but do nothing if the folder exists.
   File.makedirs( "#{folder}" )

   Net::HTTP.start( RUBY_TALK_HOST , 80 ) {|http|

      (from.to_i .. to.to_i).each { | num |
         num_s = num.to_s    # covert to string
         file_name = DIR + num_s
         path = folder + "/" + num_s

         next if FileTest.exist?  path  # if the file exists, skip
         print "Downloading..... ", num_s, "\n"

         response , = http.get( "#{file_name}" )
         File.open( path, 'wb' ) {|f| f.write( response.body )}
     }
   }
end

def usage
  $stderr.puts 'usage: ruby download_talk.rb from to folder'
  exit 1
end

usage unless $*.size == 3 
from = $*.shift    # starting number
to = $*.shift# ending number
folder = $*.shift    # folder to save

download(from, to, folder)
# end of program
