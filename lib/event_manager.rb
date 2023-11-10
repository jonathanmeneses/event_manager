require 'csv'
require 'google/apis/civicinfo_v2'
require 'erb'
require 'date'
require 'time'




def clean_zipcode(zipcode)
  zipcode.to_s.rjust(5, '0')[0..4]
end

def legislators_by_zipcode(zipcode)
  civic_info = Google::Apis::CivicinfoV2::CivicInfoService.new
  civic_info.key = 'AIzaSyClRzDqDh5MsXwnCWi0kOiiBivP6JsSyBw'

  begin
    civic_info.representative_info_by_address(
      address: zipcode,
      levels: 'country',
      roles: ['legislatorUpperBody', 'legislatorLowerBody']
    ).officials
  rescue
    'You can find your representatives by visiting www.commoncause.org/take-action/find-elected-officials'
  end

end

def save_thank_you_letter(id,form_letter)
  Dir.mkdir('output') unless Dir.exist?('output')

  filename = "output/thanks_#{id}.html"

  File.open(filename, 'w') do |file|
    file.puts form_letter
  end
end

def clean_phone_number(phonenumber)
  stripped_number = phonenumber.gsub(/\D/, '')
  if stripped_number.length == 10
    return stripped_number
  elsif stripped_number.length == 11 && stripped_number[0] =='1'
    return stripped_number[1..]
  else
    return nil
  end

end

def parse_date(regdate)
  DateTime.strptime(regdate, '%m/%d/%y %H:%M').to_time
end

puts 'EventManager initialized.'

contents = CSV.open(
  'event_attendees.csv',
  headers: true,
  header_converters: :symbol
)


template_letter = File.read('form_letter.erb')
erb_template = ERB.new template_letter

# contents.each do |row|
#   id = row[0]
#   name = row[:first_name]

#   zipcode = clean_zipcode(row[:zipcode])

#   phonenumber = clean_phone_number(row[:homephone])

#   legislators = legislators_by_zipcode(zipcode)

#   form_letter = erb_template.result(binding)

#   save_thank_you_letter(id,form_letter)


# end


contents.rewind
week_distribution = contents.map do |row|
  datetime = parse_date(row[:regdate]).wday
  # hour = datetime.hour
  #signup_hours.append(row[:regdate].hour)
end

contents.rewind
hour_distribution = contents.map do |row|
  datetime = parse_date(row[:regdate]).hour
  # hour = datetime.hour
  #signup_hours.append(row[:regdate].hour)
end



week_sorting = week_distribution.tally.sort_by { |key, value| -value}.to_h
hour_sorting = hour_distribution.tally.sort_by { |key, value| -value}.to_h

p week_sorting
p hour_sorting
