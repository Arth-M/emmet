# README

## WARNING
Due to the rails version for this project, activestorage, actionview and activesupport
need to be upgraded to versions 7.2.3.1 (now on version:7.1.6 as rails).
I received a dependabot alert two days ago ...
Time constraints led me to keep it as is to avoid unforeseen changes.

## Context
This is a test from Pennylane, the purpose of this app is to create an application that helps users find the most relevant recipes that they can prepare with the ingredients that they have at home

## User stories
- Get to first page, with top 5 recipes, check one
- Enter your ingredients by hand, submit, get recipes
- click on a found recipe from search then go back to search

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
else create and initialize db then rails s
