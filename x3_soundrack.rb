#!/usr/bin/env ruby
#
#  Created by Adam Bair on 2007-09-25.
#  Copyright (c) 2007. All rights reserved.

url     = "http://gamemusichall.net/music/x3/"

tracks  = [ "01_-_x_-_reunion_theme.mp3", "02_-_peace_1.mp3", "03_-_peace_2.mp3", "04_-_peace_3.mp3", 
            "05_-_peace_4_(var_1).mp3", "06_-_peace_5.mp3", "07_-_peace_6.mp3", "08_-_peace_7.mp3", 
            "09_-_battle_1.mp3", "10_-_battle_2.mp3", "11_-_battle_3.mp3", "12_-_battle_4.mp3", 
            "13_-_battle_5.mp3", "14_-_earth_orbit_battle.mp3", "15_-_earth.mp3", "16_-_suspense_1.mp3", 
            "17_-_suspense_2.mp3", "18_-_suspense_3.mp3", "19_-_suspense_4.mp3", "20_-_drama.mp3", 
            "21_-_08208.mp3", "22_-_08209.mp3", "23_-_08210.mp3" ]

destination = "x3_soundtrack"

begin
  Dir.mkdir(destination) unless File.exists?(destination)
rescue => e
  puts "Unable to create #{destination} => #{e}"
end

`cd #{destination}`

tracks.each_with_index do |track, index|
  begin
    # Sometimes you need to include the referer otherwise the side will just 302 you.
    `wget --referer #{url}#{index}.php #{url}#{track} -O #{destination}/#{track}`
  rescue => e
    puts "Unable to download file => #{url}#{track}"
  end
end