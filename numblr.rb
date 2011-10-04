#!/usr/bin/env ruby

# Is this any good? No.

# Tumble in the Nox
# Tumblnan Massager
# Tumblnoc?
# Nubmlr?
# Numblr it is.
# Whatever, this converts Tumblr backups to nanoc-ey goodness.

# The Numblr
# Adam Bair
# 10/04/2011
# Usage: WYWIYDETUI**
# **(Whatever you want if you're dumb enough to use it... license.
#
# Converts output from the official Tumblr Exporter for Mac and converts it to
# nanoc friendly files.
#
# Learn about the "official" tumblr exporter for mac here:
# http://staff.tumblr.com/post/286303145/tumblr-backup-mac-beta
#
# Beware, this file is quick, dirty, and ugly and has not been refactored.
# Emphasis on quick and dirty 
#
# I only expect to use this one time. Which is still too many. Probably.
# I don't expect anyone else to touch this, ever. 
# Horribleness. You'll probably die in a fire. 
# If you do use this, and you die in a fire, nobody will miss you.
# And you desreve it. 
# I warned you.
#
# Pain.
#
# Remember that.
# ...

require 'rubygems'
require 'nokogiri'
require 'titleize'

# Why, oh god, why, the constants? Send. halp. naow.
TUMBLR_BACKUP_LOCATION = '~/workspace/personal/tumblr-backup/official-tumblr-back/blog.adambair.com'
TUMBLR_POSTS_PATH  = File.expand_path(TUMBLR_BACKUP_LOCATION + '/posts')
NANOC_OUTPUT_LOCATION = '~/workspace/personal/adambair.github.com/content'
NANOC_POSTS_PATH  = File.expand_path(NANOC_OUTPUT_LOCATION + '/posts/tumblr')
NANOC_IMAGE_PATH  = File.expand_path(NANOC_OUTPUT_LOCATION + '/images/tumblr')

# Inline classes... nice, nice.
class TumblrPost
  attr_reader :path, :doc, :xml, :metadata, :info, :content

  def initialize(path)
    @path = path
    @doc  = extract_doc
    @xml  = extract_xml
    @metadata = extract_metadata
    @content = extract_content
    @info = gather_info
  end # extract extract EXTRACT EXTERMINATE EXTERMINATE... wait.

  def extract_doc
    file = File.open(@path)
    doc = Nokogiri::XML(file)
    file.close
    doc
  end

  def extract_xml
    comment    = @doc.xpath("//comment()").text.strip.split("\n\n")[1]
    xml_string = comment.split(/\n/)[1].strip
    Nokogiri::XML.fragment(xml_string).children.first
  end

  def extract_metadata
    @xml.inject({}) do |sum, node|
      sum.merge({node.first => node.last})
    end
  end

  def extract_content
    remove_tumblr_metatags
    rewrite_image_paths
    @doc.xpath("//body").children.to_s.strip
  end

  def rewrite_image_paths
    if @metadata["type"] == "regular" && @doc.xpath("//img")[0] && @doc.xpath("//img")[0]["src"] =~ /posterous/
      # puts @doc.xpath("//img")[0]["src"]
      # DO STUFF HERE
    end
    # puts "regular" if @metadata[:type] == "regular"
    # puts "posterous" if @doc.xpath("//div")[0] && @doc.xpath("//div")[0]["class"] == "posterous_autopost"
    return unless @metadata["type"] == 'photo'
    src = @doc.xpath("//img")[0]["src"].gsub("..", "")
    dst = @doc.xpath("//img")[0]["src"].gsub("../images", "/images/tumblr")
    # Inline copy - nice, nice.
    `cp #{TUMBLR_BACKUP_LOCATION + '/' + src} #{NANOC_IMAGE_PATH}`
    @doc.xpath("//img")[0]["src"] = dst
  end

  def remove_tumblr_metatags
    @doc.xpath("//body").children.each do |node|
      begin
        node.remove if node.xpath("//div")[0]["class"] == "post_meta"
      rescue
        # ignore because if anything blows up, naturally we want to do nothing.
        # doesn't matter what it is. Even if it's unrelated to this shit method.
        # 
        # failure. is. not. an. option.
      end
    end
  end

  def gather_info # or build a hash
    { :id => @metadata["id"], 
      :slug => @metadata["slug"].to_s, 
      :type => @metadata["type"], 
      :url => @metadata["url"], 
      :created_at => Time.at(@metadata["unix-timestamp"].to_i) }
  end
end

class NanocBuilder
  attr_accessor :tumblr_post # because this is useful

  def initialize(tumblr_post)
    @tumblr_post = tumblr_post
  end

  # Let's do some damage. I won't let anyone know because...
  # I left off the exclamation suffix. 
  def write
    File.open(NANOC_POSTS_PATH + '/' + filename, 'w') {|f| f << metadata + content}
  end

  # Classy
  def filename
    @tumblr_post.metadata["date-gmt"].split(" ").first + "-" + @tumblr_post.metadata["slug"] + ".html"
  end

  # When in doubt, type, type as much as your pretty little fingers will let you.
  def metadata
    data = @tumblr_post.info
    output =  "---\n"
    output << "title: #{title}\n"
    output << "slug: #{data[:slug]}\n"
    output << "kind: article\n"
    output << "created_at: #{data[:created_at]}\n"
    output << "original_url: #{data[:url]}/#{data[:slug]}\n"
    output << "imported_from: Tumblr\n"
    output << "tags: #{tags}\n"
    output << "layout: \n"
    output << "published: true\n"
    output << "\n---\n\n"
  end

  def posterous?
    @tumblr_post.metadata["type"] == "regular" && @tumblr_post.doc.xpath("//img")[0] && @tumblr_post.doc.xpath("//img")[0]["src"] =~ /posterous/
  end

  def tags
    data = @tumblr_post.info
    type = data[:type] unless data[:type] == "regular"
    posterous = 'posterous, photo' if posterous?
    ["tumblr", type, posterous].compact.join(", ")
  end

  # NOOOOooooooo... Really? Let's just assign some things around uselessly.
  def content
    source = @tumblr_post.content
  end

  def title
    @tumblr_post.info[:slug].gsub("-", " ").titleize
  end
end

# It's business time.

posts = Dir.glob(TUMBLR_POSTS_PATH + '/*.html')

posts.each do |post|
  print '.'
  tp = TumblrPost.new(post)
  NanocBuilder.new(tp).write
end

puts 'done.' # amen

# if you made it this far you are either lauging your ass off
# or your face is covered in palms

