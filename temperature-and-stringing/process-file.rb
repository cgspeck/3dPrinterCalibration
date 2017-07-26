require 'stringio'

if ARGV.count < 5 || ARGV.count > 6
    puts %q(Usage:
  process-file.rb INPUT_FILE OUTPUT_FILE START STEP STOP [EXTRUDER_NUM]

  E.g.:
  process-file.rb foo.scad foo-processed.scad 180 2 220 2
)
    exit
end

output_file = File.open(ARGV[1], mode="w")
input_start = ARGV[2].to_i
step = ARGV[3].to_i
input_end = ARGV[4].to_i
extruder_num = ARGV[5]

if extruder_num
    extruder_num = " T#{extruder_num.to_i}"
end

base_hieght = 2
cube_hieght = 10

level_change_regex = /G1 Z([\d]+\.[\d]+) F[\d]+\.[\d]+/

# normalise start and end so that end < start
m_start = input_start > input_end ? input_start : input_end
m_end = input_end < input_start ? input_end : input_start
steps = (m_start - m_end) / step

puts "Start #{m_start}"
puts "Step #{step}"
puts "End #{m_end}"

level_temperature = (1..steps + 1).inject({}) { |h,step|
    h.merge(base_hieght + (step - 1) * cube_hieght => m_start - (step - 1) * 10)
}

# generate a map of level <-> temperature
puts "level_temperature map is #{level_temperature}"
hunt_val = level_temperature.shift

buffer = StringIO.new('rw')

File.open(ARGV[0], mode="r") do |input_file|
    input_file.each_line do |line|
        buffer.write(line)
        line_match = level_change_regex.match(line)
        if hunt_val
            if line_match && line_match[1].to_f >= hunt_val[0]
                puts "Level change detected #{line_match[1]} for #{hunt_val[0]}"
                buffer.write("// inserted by process-file.rb for #{hunt_val}\n")
                buffer.write("M104 S#{hunt_val[1]}#{extruder_num}\n")
                buffer.write("M109 S#{hunt_val[1]}\n")
                hunt_val = level_temperature.shift
            end
        end
    end
end

if hunt_val
    puts "Warning! End of input while looking for level #{hunt_val}"
    puts "These level_temperature values remain: #{level_temperature}"
    exit
else
    File.open(ARGV[1], mode="w") do |output_file|
        buffer.seek 0
        output_file.write buffer.read
    end
    puts "#{ARGV[1]} written"
end