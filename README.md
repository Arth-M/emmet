# README
pe shortcut => <%= %>
er shortcut => <% %>


find PID of faulty db reader from rails :
psql postgres -c "SELECT pid, application_name, state FROM pg_stat_activity WHERE datname = 'dinner_time_development';"

This is a test from Pennylane, the purpose of this app is to create an application that helps users find the most relevant recipes that they can prepare with the ingredients that they have at home

##User stories

- Enter your ingredients by hand, submit, get recipes
- enter a recipe keyword, submit, get recipes
- if possible: filter results by category, rating, total cooking time

##Dependencies
* Ruby version: 3.3.5
* Rails version:7.1.6

* System dependencies

* Configuration

* Database creation

* Database initialization

* How to run the test suite

* Services (job queues, cache servers, search engines, etc.)

* Deployment instructions

* ...
