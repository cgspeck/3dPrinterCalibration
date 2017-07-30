require 'stringio'

if ARGV.count < 5
    puts %q(Usage:
  process-file.rb INPUT_FILE OUTPUT_FILE SLIC3R_SPEED_MM_PER_SEC START_MM_PER_SEC STEP END_MM_PER_SEC

  E.g.:
  process-file.rb foo.scad foo-processed.scad 24 12 2 24
)
    exit
end

output_file = File.open(ARGV[1], mode="w")
slic3r_speed_per_mm = ARGV[2].to_i
start_speed_per_mm = ARGV[3].to_i
step = ARGV[4].to_i
end_mm_per_sec = ARGV[5].to_i

level_change_regex = /G1 Z([\d]+\.[\d]+) F[\d]+\.[\d]+/
extrude_regex = /G1 X[\d]+\.[\d]+ Y[\d]+\.[\d]+ E[\d]+\.[\d]+ F([\d]+\.[\d]+)/

# normalise start and end so that start < end
m_start = end_mm_per_sec > start_speed_per_mm ? start_speed_per_mm : end_mm_per_sec
m_end = end_mm_per_sec > start_speed_per_mm ? end_mm_per_sec : start_speed_per_mm
steps = (m_end - m_start) / step

puts "Start #{m_start}"
puts "Step #{step}"
puts "Steps #{steps}"
puts "End #{m_end}"

base_slic3r_feed_rate = (slic3r_speed_per_mm * 60).to_f

puts "base_slic3r_feed_rate #{base_slic3r_feed_rate}"

base_hieght = 0
cube_hieght = 10

level_speed = (1..steps + 1).inject({}) { |h,i|
    h.merge(base_hieght + (i - 1) * cube_hieght => (m_start * 60 + (i - 1) * step * 60).to_f)
}

# generate a map of level <-> temperature
puts "level_speed map is #{level_speed}"
exit
next_level_change, next_feed_rate = level_speed.shift
feed_rate = nil
changed = false

buffer = StringIO.new('rw')

File.open(ARGV[0], mode="r") do |input_file|
    input_file.each_line do |line|
        # if feed_rate is set then process the incoming line and add it to the buffer
        if feed_rate
            line, changed = RewriteFeedrate(line, base_slic3r_feed_rate, new_feedrate)
        end

        # TODO: check the line to see if it is actually a level change that we are looking for
        if level_change
            raise "Could not find a G1 line with F#{base_slic3r_feed_rate}!" unless changed
            feed_rate = next_feed_rate
            # TODO: insert a comment
            next_level_change, next_feed_rate = level_speed.shift
            changed = false
        end
    end
end

if next_level_change
    puts "Warning! End of input while looking for level #{next_level_change}"
    puts "These level_speed values remain: #{level_speed}"
    exit
else
    File.open(ARGV[1], mode="w") do |output_file|
        buffer.seek 0
        output_file.write buffer.read
    end
    puts "#{ARGV[1]} written"
end