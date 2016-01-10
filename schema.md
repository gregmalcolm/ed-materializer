Schema
======

World Survey
------------

Data is described here:

https://github.com/gregmalcolm/ed-materializer/blob/master/db/schema.rb

GET index urls
--------------

`GET /api/v1/world_surveys`

Page size is currently 500 items

Example through CURL (runnable in git bash or unix):

`curl -i -H "Content-Type: application/json" https://ed-materializer.herokuapp.com/api/v1/world_surveys/\?page=1`

GET show urls
-------------

`GET /api/v1/world_surveys/:id`

Currently uses numerical ids

This returns the record where id=1

`curl -i -H "Content-Type: application/json" https://ed-materializer.herokuapp.com/api/v1/world_surveys/1`


POST record inserts
-------------------

`POST /api/v1/world_surveys`

`curl -i -H "Accept: application/json" -H "Content-Type: application/json" -X POST -d '{"world_survey":{"system": "test", "commander": "test", "world": "A 1", "iron": "true"}}' https://ed-materializer.herokuapp.com/api/v1/world_surveys`

PUT/PATCH single record update
------------------------------

`PATCH /api/v1/world_surveys/:id'

This example assumes we want to change the record where id=4:

`curl -i -H "Accept: application/json" -H "Content-Type: application/json" -X PATCH -d '{"world_survey":{"system": "test2", "commander": "test", "world": "A 1", "iron": "true"}}' https://ed-materializer.herokuapp.com/api/v1/world_surveys/4`

If the return code is 204 then you were successful

DELETE single record
--------------------

`DELETE /api/v1/world_surveys/:id'