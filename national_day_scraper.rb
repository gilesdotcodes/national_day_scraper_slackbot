#!/usr/bin/env ruby

require 'httparty'
require 'nokogiri'
require 'json'
require 'sinatra'

class NationalDay
  def initialize
  end

  def today
    anyday(Date.today)
  end

  def tomorrow
    anyday(Date.today + 1)
  end

  def month
    get_days_of_the_year_months(Date.today)

    make_response(months_output(Date.today))
  end

  private

  def get_national_day_section(month)
    @month_string = Date::MONTHNAMES[month]
    page = HTTParty.get("https://nationaldaycalendar.com/#{@month_string}/")
    parse_page = Nokogiri::HTML(page)
    @national_day_section = parse_page.css('.et_pb_section_1').css('.et_pb_text_inner')
  end

  def get_days_of_the_year_days(date)
    parse_page = Nokogiri::HTML(days_of_the_year_page(date))
    @days_of_the_year_days_section = parse_page.css('section>div.container.breathe').first
  end

  def get_days_of_the_year_months(date)
    parse_page = Nokogiri::HTML(days_of_the_year_page(date))
    @days_of_the_year_month_section = parse_page.css('section>div.container.breathe').last
  end

  def days_of_the_year_page(date)
    HTTParty.get("https://www.daysoftheyear.com/days/#{date.year}/#{("%02d" % date.month)}/#{("%02d" % date.day)}")
  end

  def anyday(date)
    @date = date
    get_national_day_section(@date.month)
    get_days_of_the_year_days(@date)
    make_response(days_output(@date))
  end

  def days_output(date)
    day = date.day
    str = ""
    str << "Days of the Year for #{@month_string} #{day}\n"

    national_days = @national_day_section.css('ul')[day - 1]
                                         .css('li')
                                         .map{ |d| d.text.include?("National ") ? d.text.sub!("National ", "") : d.text }


    national_days << @days_of_the_year_days_section.css('h3.card-title').css('a').map(&:text)
    national_days << ["Giles Appreciation Day"] if day == 27 && @month_string == 'April'
    national_days << ["Al Hates Marmite Day"] if day == 28 && @month_string == 'September'

    national_days.flatten.uniq(&:downcase).each do |national_day|
      str << "- #{national_day}\n"
    end

    str
  end

  def months_output(date)
    "".tap do |str|
      str << "#{Date::MONTHNAMES[date.month]} is:\n"
      str << @days_of_the_year_month_section.css('h3.card-title').css('a').map{ |a| "- #{a.text}" }.join("\n")
    end
  end

  def make_response(text, attachments = [], response_type = 'in_channel')
    {
      text: text,
      attachments: attachments,
      username: 'National Day Bot',
      icon_url: 'http://www.nationaldaycalendar.com/wp-content/uploads/2016/08/750x165_NDC_Logo_Conformity1.png',
      icon_emoji: 'http://www.nationaldaycalendar.com/wp-content/uploads/2016/08/750x165_NDC_Logo_Conformity1.png',
      response_type: response_type
    }
  end
end

post '/national_days' do
  national_day = NationalDay.new
  json national_day.today
end

post '/national_days_tomorrow' do
  national_day = NationalDay.new
  json national_day.tomorrow
end

post '/national_months' do
  national_day = NationalDay.new
  json national_day.month
end
