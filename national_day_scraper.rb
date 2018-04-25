#!/usr/bin/env ruby

require 'httparty'
require 'nokogiri'
require 'json'
require 'sinatra'
require 'sinatra/json'

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
    page = HTTParty.get("http://www.nationaldaycalendar.com/#{@month_string}/")
    parse_page = Nokogiri::HTML(page)
    @national_day_section = parse_page.css('.entry-content')
  end

  def get_days_of_the_year_days(date)
    parse_page = Nokogiri::HTML(days_of_the_year_page(date))
    @days_of_the_year_days_section = parse_page.css('section>div.container.breathe')
  end

  def get_days_of_the_year_months(date)
    parse_page = Nokogiri::HTML(days_of_the_year_page(date))
    @days_of_the_year_month_section = parse_page.css('section.breathe--light>div.container')
  end

  def days_of_the_year_page(date)
    HTTParty.get("http://www.daysoftheyear.com/days/#{date.year}/#{("%02d" % date.month)}/#{("%02d" % date.day)}")
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

    # different markup changes this line (i think)
    # ok so the first line should work if the section numbers start at _0
    section_number = (day % 4 != 0) ? day/4 : (day/4 - 1)
    # section_number = (day % 4 != 0) ? (day/4 + 1) : day/4
    list_number = (day % 4 != 0) ? (day % 4) : 4
    list_number -= 1

    national_days = @national_day_section.css(".et_pb_section_#{section_number}")
                                         .css('.et_pb_blurb_container')
                                         .css('ul')[list_number]
                                         .css('li')
                                         .map{ |d| d.text.include?("National ") ? d.text.sub!("National ", "") : d.text }


    national_days << @days_of_the_year_days_section.css('h3.card-title').css('a').map(&:text)
    national_days << ["Giles Appreciation Day"] if day == 27 && @month_string == 'April'

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
