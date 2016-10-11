#!/usr/bin/env ruby

require 'httparty'
require 'nokogiri'
require 'json'
require 'sinatra'
require 'sinatra/json'

class NationalDay

  def initialize
    current_month = Date::MONTHNAMES[Date.today.month]
    page = HTTParty.get("http://www.nationaldaycalendar.com/#{current_month}/")
    parse_page = Nokogiri::HTML(page)
    @main_section = parse_page.css('.post-wrap')
  end

  def all_month
    number_of_days = @main_section.css('h4').count.to_i

    #@main_section.css('h1').text

    number_of_days.times do |n|
      output(n)
    end
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
    str << "#{@main_section.css('h4')[date].text}"
    str << " (tomorrow)" if tomorrow
    str << "\n"

    national_days = @main_section.css(".et_pb_section_#{date/4}").css('.et_pb_blurb_container').css('ul')[(date - (date/4 * 4))].css('li')

    national_days.each_with_index do |national_day, i|
      str << "#{i+1}. #{national_day.text}\n"
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

post 'national_days_tomorrow' do
  national_day = NationalDay.new
  json national_day.tomorrow
end


