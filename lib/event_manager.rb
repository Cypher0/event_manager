require 'csv'
require 'sunlight/congress'
require 'erb'

Sunlight::Congress.api_key = 'e179a6973728c4dd3fb1204283aaccb5'

def clean_zipcode(zipcode)
  zipcode.to_s.rjust(5, '0')[0..4]
end

def legislators_by_zipcode(zipcode)
  Sunlight::Congress::Legislator.by_zipcode(zipcode)
end

def save_thank_you_letters(id, form_letter)
  Dir.mkdir('output') unless Dir.exist? 'output'

  filename = "output/thanks_#{id}.html"

  File.open(filename, 'w') do |file|
    file.puts form_letter
  end
end

def clean_phone_number(number)
  cleaned_number = []
  number.to_s.split('').each do |char|
    cleaned_number << char if /\d/ =~ char
  end
  if cleaned_number.length < 10 || cleaned_number.length > 11
    cleaned_number = []
  elsif cleaned_number.length == 11 && cleaned_number[0] == 1
    cleaned_number.shift!
  else
    cleaned_number
  end
end

puts 'EventManager initialized!'

contents = CSV.open 'event_attendees.csv', headers: true, header_converters: :symbol
template_letter = File.read 'form_letter.erb'
erb_template = ERB.new template_letter

#contents.each do |row|
#  id = row[0]
#  name = row[:first_name]
#  zipcode = clean_zipcode(row[:zipcode])
#  legislators = legislators_by_zipcode(zipcode)
#  form_letter = erb_template.result(binding)
#  save_thank_you_letters(id, form_letter)
#end

# Display all names and phone numbers.
def display_phone_numbers
  contents = CSV.open 'event_attendees.csv', headers: true, header_converters: :symbol
  contents.each do |row|
    name = row[:first_name]
    phone_number = row[:homephone]
    puts "#{name} #{clean_phone_number(phone_number).join}"
  end
end

def time_targeting
  contents = CSV.open 'event_attendees.csv', headers: true, header_converters: :symbol
  hours = Hash.new(0)
  contents.each do |row|
    reg_date_string = row[:regdate]
    reg_date = DateTime.strptime(reg_date_string, '%m/%d/%y %H:%M')
    hours[reg_date.hour] += 1
  end
  hours.sort_by {|k, v| v}.reverse.each do |hour, regs|
    puts "Hour: #{hour}, registered: #{regs}"
  end
end


display_phone_numbers
time_targeting
