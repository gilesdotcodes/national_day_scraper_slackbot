# national_day_scraper_slackbot
This is a Slackbot that scrapes [National Day Calendar](http://www.nationaldaycalendar.com/) and outputs which National Days are today.

In Slack, go to 'Apps and intergrations', then click on 'Build' and then 'Make a custom integration'.

Select 'Slash Commands' from the list and then set your command name before clicking 'Add Slash Command Integration'. I chose `/nationaldays`.

From there just enter the URL as https://national-day-scraper-slackbot.herokuapp.com/national_days and ensure that Method is set to POST.

The other inputs are up to you.

Then, from within Slack, just type `/nationaldays` (or whatever you decided to call your Slash command) and it will output today's date and the National Days that occur today.

This is hosted on Heroku's free Dyno, so the first call you make using `/nationaldays` may receive a time-out error. Try a second time and it has usually kicked in by that point.


