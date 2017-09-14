#!/usr/bin/env ruby

require 'httparty'
require 'nokogiri'
require 'json'
require 'sinatra'
require 'sinatra/json'

class NationalDay

  def initialize
    get_national_day_section
    get_days_of_the_year_section
  end

  def get_national_day_section
    current_month = Date::MONTHNAMES[Date.today.month]
    page = HTTParty.get("http://www.nationaldaycalendar.com/#{current_month}/")
    parse_page = Nokogiri::HTML(page)
    @national_day_section = parse_page.css('.post-wrap')
  end

  def get_days_of_the_year_section
    # current_month = Date.today.month
    page = HTTParty.get("http://www.daysoftheyear.com")
    parse_page = Nokogiri::HTML(page)
    @days_of_the_year_section = parse_page.css('.mainBanner')
  end

  def today
    date = Date.today.day - 1
    output(date)
  end

  def tomorrow
    date = (Date.today + 1).day - 1
    output(date, true)
  end

  def day(date)
    output(date - 1)
  end

  def output(date, tomorrow=false)
    str = ""
    str << "Days of the Year for #{@national_day_section.css('h4')[date].text}\n"

    national_days = @national_day_section.css(".et_pb_section_#{(date/4)+1}").css('.et_pb_blurb_container').css('ul')[(date - (date/4 * 4))].css('li').map{ |d| d.text.include?("National ") ? d.text.sub!("National ", "") : d.text }


    unless tomorrow
      # str << "Days of the Year for #{@national_day_section.css('h4')[date].text}\n"
      national_days << @days_of_the_year_section.css('h2').css('a').map(&:text)
      # days_of_the_year = @days_of_the_year_section.css('h2').css('a')

      # days_of_the_year.each_with_index do |day_of_year, i|
      #   str << "#{i+1}. #{day_of_year.text}\n"
      # end
    end

    national_days.flatten.uniq.each do |national_day|
      str << "- #{national_day}\n"
    end

    make_response(str)
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
