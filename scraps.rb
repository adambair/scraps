# Original idea found here in python:
# http://www.djangosnippets.org/snippets/143/
def convert_newlines_to_html(string)
  return "<p>#{string}</p>" unless string.scan /\n/
  paragraphs = string.squeeze.split(/\n/)
  paragraphs.collect! {|paragraph| "<p>#{paragraph}</p>"}
  paragraphs.join(' ')
end

def break_long_text(string, length=90)
  string.split(/(\s)/).map! { |word| word.gsub(/.{#{length}}/, '\0<wbr />') }.join
end

# Original code found here:
# http://snippets.dzone.com/posts/show/804
def truncate_text(text, length = 30, end_string = '')
  words = text.split
  words[0..(length-1)].join(' ') + (words.length > length ? end_string : '')
end

# A modification of the truncate_words method found here:
# http://snippets.dzone.com/posts/show/804
def truncate_text_reverse(text, length = 30, start_string = '')
  words = text.split()
  (words.length > length ? start_string : '') + words[(length)..words.size].join(' ')
end

# Split an array of elements into a set of smaller arrays of equal size. 
# http://snippets.dzone.com/posts/show/3486
class Array
  def chunk(pieces=2)
    len = self.length;
    mid = (len/pieces)
    chunks = []
    start = 0
    1.upto(pieces) do |i|
      last = start+mid
      last = last-1 unless len%pieces >= i
      chunks << self[start..last] || []
      start = last+1
    end
    chunks
  end
end

# render a specific error page based on url path
def rescue_action_in_public(exception)
  request_root = request.env["REQUEST_URI"].split('/')[1]
    
  three_things_paths = ['3things', 'tastebox']
  site = three_things_paths.include?(request_root) ? '3t' : 'ac'
  
  case exception
    when ActionController::UnknownAction, ActionController::RoutingError
      render :file => "#{RAILS_ROOT}/public/404_#{site}.html", :layout => false, :status => 404
    else
      render :file => "#{RAILS_ROOT}/public/500_#{site}.html", :layout => false, :status => 500
  end
end

# creates a timeline / lifespan that can be styled
# probably could be more dry/efficient
def timeline(label, first_date = nil, second_date = nil)
  return "(not entered)" if first_date.nil?
  first_date = first_date.strftime("%Y") 
  
  if second_date.nil?
    second_date = Time.now.strftime('%Y')
    alive = "'#{(second_date.to_i + 1 ).to_s.slice(2..3)}"
  else
    second_date = second_date.strftime("%Y")
  end
  
  years = String.new
  years << "<span class='year'>#{first_date}</span>"
  
  first_date.to_i.upto(second_date.to_i) do |date| 
    if date.modulo(50) == 0
      years << "<span class='major_year'>#{date.to_s}</span>"
    else
      years << "<span class='minor_year'>'#{date.to_s.slice(2..3)}</span>" if date.modulo(10) == 0
    end
  end
  
  years << "<span class='year end'>#{second_date}</span>"
  years << "<span class='minor_year'>#{alive}</span>" if alive
  years
end

# determine the orientation given the width and height
def orientation(width, height)
  width > height ? 'horizontal' : 'vertical'
end

# a collection of youtube utils
module Youtube
  
  include Net::HTTP
  
  # default youtube video size is 425x350
  # default youtube thumbnail is  130x97

  # youtube url format expected is:
  # http://youtube.com/watch?v=8tS4OWiozmw
  def youtube_id(url)
    youtube_regex = /watch\?v=([a-zA-Z0-9]*)/ # this regex is not complete
    url.scan(youtube_regex)
  end

  # tests to see if a thumbnail exists for a youtube video
  # filename can also be default.jpg
  def youtube_thumb_exists?(url, filename='1.jpg')
    youtube_id = self.youtube_id(url)
    url = "/vi/#{self.youtube_id}/#{filename}"
    request = Net::HTTP.new('img.youtube.com', 80)
    response_code = request.get(url).code
    response_code == '200'
  end

  # markup for the embeded youtube player
  def youtube_player_markup(url, width=425, height=350)
    markup =  "<object width='#{width}' height='#{height}'>"
    markup << "<param name='movie' value='#{url}' align='left'></param>"
    markup << "<embed src='#{url}' type='application/x-shockwave-flash' width='#{width}' height='#{height}'></embed>"
    markup << "</object>"
  end

end

# YAML
# write yaml to a file
open('filename', 'w') {|f| f << something.to_yaml}
# read yaml from a file
something = YAML.load(open('filename'))

# reading config information from a yml file
@@settings = YAML.load_file(File.join(RAILS_ROOT, 'config/settings.yml'))[RAILS_ENV].symbolize_keys

development:
  something: "some_value"
  something2: "some_value2"

staging:
  something: "some_value"
  something2: "some_value2"

@@settings[:something] # => "some_value"

# yaml variables
login: &login
  username: username
  password: password
  adapter:  mysql
  host:     localhost

development:
  database: development_db
  <<: *login

test:
  database: testing_db
  <<: *login

production:
  database: production_db
  <<: *login


# read an entire file in as a string
file = File.open(File.expand_path(File.dirname(__FILE__) + "../fixtures/data/" + "jack_paper_1.xml"))
file_contents_as_string = file.read

# benchmark
require 'yaml'
require 'benchmark'

n = 50
puts "  Run #{n} times"
Benchmark.bm do |x|
  x.report { 1.upto(n) do ; ProfanityFilter::Base.clean(text); end }
end

# silently do something (ignore warnings)

def silently(&block)
  warn_level = $VERBOSE
  $VERBOSE = nil
  result = block.call
  $VERBOSE = warn_level
  result
end

silently {some_code}

# dump = File.expand_path(File.dirname(__FILE__) + "/data/" + "artist_profile_image.yml")
# artists_dump = YAML.load(open(dump)).compact!
# 
# artists_dump.each_with_index do |d, index|
#   artist = Artist.find_by_first_name(d[:first_name], :conditions => "last_name = \"#{d[:last_name]}\"")
#   if artist
#     dump_image = File.expand_path(File.dirname(__FILE__) + "/data/" + "/artist_profile_images/" + d[:image])
#     data = ''
#     open(dump_image, 'rb') {|f| data << f.read}        
#     image = Image.new(:id => index, :content_type => 'image/jpeg', :filename => d[:filename], 
#             :is_illustration => true, :user_id => artist.id, :uploaded_data => imageio_for_data(data.to_s, d[:filename]) )
#     if image.save
#       artist.image_id = image.id
#       artist.save
#     end  
#     print '.'
#   else
#     print 'x'
#   end
# end
#


# class MyStringIO < StringIO
#   attr_reader :content_type, :original_filename
#   attr_writer :content_type, :original_filename
# end
# 
#  def self.imageio_for_data(data, fname)  
#    imgio = MyStringIO.new(data)
#    ext = 'jpeg' if 'jpg'==ext  # attachment_fu content type must say jpeg
#    imgio.content_type, imgio.original_filename = "image/png", fname
#    return imgio
# end
#



      # def find_resource_hash(path)
      #   Dir["#{full_path}/*"].inject({}){ |result, resource|
      #     puts resource.inspect
      #     metafile = MetaFile.meta_data(resource)
      #     metafile.merge!({'location' => find_location(resource),
      #                     'name'     => find_name(resource),
      #                     'contents' => MetaFile.read(resource)})
      #     result[metafile['name']] = metafile
      #     result
      #   }
      # end


# create unfuddle tickets from a list
# api reference: http://unfuddle.com/docs/api 
# ticket sructure: http://unfuddle.com/docs/api/data_models#ticket
tickets = <<TIX
Fix/Implement edit and save functionality for Contracts
Fix derived fields on Contracts/Contractors
Figure out how to persist fields from the r/o database (language, comments)
Allow users to manually add contracts to contractors
Move contract_type from Contractor to Contract
Fix pagination on Contractor search when there are no results (should have no pagination)
Add a date picker to all date fields in the application
Allow users to batch upload/import a csv of Contracts (business logic involved)
Create a custom report generator (filters/fields) that can export pdf and csv
Integrate Joe's work with X509 auth sessions
Create a rake task to export ERD diagrams (railroad, dot, conversion to png)
TIX

tickets.each_line do |summary|
  `curl -i -u uname:pword -X POST -H 'Accept: application/xml' -H 'Content-type: application/xml' -d "<ticket><priority>3</priority><summary>#{summary}</summary></ticket>" 'http://intridea.unfuddle.com/api/v1/projects/155780/tickets'`
end

