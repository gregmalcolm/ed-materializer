# Schema

## World Survey

Data is described here:

https://github.com/gregmalcolm/ed-materializer/blob/master/db/schema.rb

### GET "index" urls

`GET /api/v1/world_surveys`

Page size is currently 500 items

Example through CURL (runnable in git bash or unix):

`curl -i -H "Content-Type: application/json" https://ed-materializer.herokuapp.com/api/v1/world_surveys/\?page=1`

There are also querystring params availabe that will filter on:
* page
* per_page (defaults to 500)
* q (filter)

Filter arguments are a contained within `q` as the following indexes:
* system
* commander
* world
* updated_before
* updated_after

Examples:

Filter on commander and world:
`curl -i -H "Content-Type: application/json" https://ed-materializer.herokuapp.com/api/v1/world_surveys/?q[commander]=marlon%20blake&q[world]=A%205`

Find all records after 30th Dec 2015
`curl -i -H "Content-Type: application/json" https://ed-materializer.herokuapp.com/api/v1/world_surveys/?q[updated_after]=2015-12-30`

### GET "show" with ID urls

`GET /api/v1/world_surveys/:id`

Currently uses numerical ids

This returns the record where id=1

`curl -i -H "Content-Type: application/json" https://ed-materializer.herokuapp.com/api/v1/world_surveys/1`

### POST record inserts

Note: Requires an access_token

`POST /api/v1/world_surveys`

`curl -i -H "Accept: application/json" -H "Content-Type: application/json" -H "access_token: ACCESS_TOKEN" -H "client: CLIENT" -H "uid: jenny@example.com" -X POST -d '{"world_survey":{"system": "test", "commander": "test", "world": "A 1", "iron": "true"}}' https://ed-materializer.herokuapp.com/api/v1/world_surveys`

### PATCH/PUT single record update

Note: Requires an access_token

`PATCH /api/v1/world_surveys/:id'

This example assumes we want to change the record where id=4:

`curl -i -H "Accept: application/json" -H "Content-Type: application/json" -H "access_token: ACCESS_TOKEN" -H "client: CLIENT" -H "uid: jenny@example.com" -X PATCH -d '{"world_survey":{"system": "test2", "commander": "test", "world": "A 1", "iron": "true"}}' https://ed-materializer.herokuapp.com/api/v1/world_surveys/4`

If the return code is 204 then you were successful

### DELETE single record

Note: Requires an access_token

`DELETE /api/v1/world_surveys/:id'

## Change Log

This one is only available as a simple GET Index with paging currently. Data is
in date descending order.

`GET /api/v1/change_logs/`

`curl -i -H "Content-Type: application/json" https://ed-materializer.herokuapp.com/api/v1/change_logs/\?page=1`

## Auth

Authorization is token based. Which means you sign in at the start of a session then pass the tokens with
each request requiring authorization.

If the token times out you'll need to sign in again

#### Sign in

curl -i -H "Accept: application/json" -H "Content-Type: application/json" -X POST -d '{"email": "jenny@example.com", "password": "SECRET"}' http://ed-materializer.herokuapp.com/api/v1/auth/sign_in

This will give you the necssary tokens

#### Validation test

http://ed-materializer.heroku.com/api/v1/auth/validate_token/?uid=jenny@example.com&access-token=TOKEN_HERE&client=CLIENT_HERE

#### Make a request

curl -i -H "Accept: application/json" -H "Content-Type: application/json" -H "access_token: ACCESS_TOKEN" -H "client: CLIENT" -H "uid: jenny@example.com" -X POST -d '{"world_survey":{"system": "test", "commander": "test", "world": "A 1", "iron": "true"}}' http://ed-materializer.heroku.com/api/v1/world_surveys