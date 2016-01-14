ED Materializer
===============

[![Build Status](https://travis-ci.org/gregmalcolm/ed-materializer.svg)](https://travis-ci.org/gregmalcolm/ed-materializer)

This is a simple API for storing Elite Dangerous exploration data on Worlds.
Prospecting materials and the like.

Primarily implemented so that [EDDiscovery](https://github.com/EDDiscovery/EDDiscovery)
can have a place to store prospecting materials data.

Setup
-----

1) Install Ruby 2.2.4

2) Install Postgres

3) Create a role for postgres:
```
createuser -r ed_materializer
```

4) Run this to setup:
```
bundle
rake db:create
rake db:migrate
```

5) Optional, seeds sample data in the db:
```rake db:seed```

6) Start the rails server on port 3000:

```rails s```

Schema
------

Documented in [schema.md](/schema.md)
