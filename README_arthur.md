## Go to


## WARNING
Due to the rails version for this project, activestorage, actionview and activesupport
need to be upgraded to versions 7.2.3.1 (now on version:7.1.6 as rails).
Time constraints led me to keep it as is to avoid unforeseen changes.

## User stories
- on home page : check key indicators and the pav that needs to be emptied soon (70%>x>85% and x>85%)
- on home page : select a pav on the map to see filling history, incidents opened
- on home page : select pavs depending on their waste_type
- see all the pavs filling
- check all the open incidents [and mark them as resolved]
- [see badge deposit anomaly by location and provider]

## Dependencies
* Ruby version: 3.3.5
* Rails version:7.1.6

* System dependencies
RubyGems version          3.5.22
Rack version              3.2.5
Database adapter          PostgreSQL 13+
database adapter docker  PostgreSQL 13

* Database creation
rails db:create

* Database initialization
rails db:migrate db:seed

* How to run the test suite
rails test

* Deployment instructions
docker-compose up --build in prod,
else create and initialize db then ./bin/dev
