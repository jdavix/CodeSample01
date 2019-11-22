# README

## What is the project About?

Background:
A group event will be created by a user. The group event should run for a whole number of days e.g.. 30 or 60. There should be attributes to set and update the start, end or duration of the event (and calculate the other value). The event also has a name, description (which supports formatting) and location. The event should be draft or published. To publish all of the fields are required, it can be saved with only a subset of fields before it’s published. When the event is deleted/remove it should be kept in the database and marked as such.

Deliverable:
Write an AR model, spec and migration for a GroupEvent that would meet the needs of the description above. Then write the api controller and spec to support JSON request/responses to manage these GroupEvents. For the purposes of this exercise, ignore auth. Please provide your solution as a rails app called exercise_YYMMDD_yourname, sent as a zip file.

## Technical details:

* Ruby version
Project has been tested with ruby-2.2.6

* System dependencies
All dependencies are included in the Gemfile, please make sure bundle install sucess

* Configuration
1. bundle install
2. rake db:migrate
3. rspec spec



* Important Note about Solution:
- I'm including start date and end date as part of the total duration days, which means 2017-06-23 as start date and 2017-06-25 as end date, total dates will be 3, (23, 24, and 25)
