[![Stories in Ready](https://badge.waffle.io/tenders-exposed/elvis-backend.png?label=ready&title=Ready)](http://waffle.io/tenders-exposed/elvis-backend)


Elvis is a tool that enables investigative journalists to analyze and visualize public
procurements data and look for patterns that suggest corrupt behavior in public spending.

This is a Rails API, using MongoDB for storing and ElasticSearch for indexing/querying the data.
It also has the purpose of filtering, analyzing and converting the results into a JSON the Vis.js
frontend can draw.

#### Usage

*NOTE*: The use of `Endpoint` in the following examples assumes the path is applied on the domain
`oz.tenders.exposed`.

Authentication is still bound to frontend. Please use the [interface](http://elvis.tenders.exposed)
to create an account and confirm it.

Authorization:

Endpoint: `POST  api/v1/users/sign_in`

Payload:

```json
{
  "user": {
      "email": "somebuddy@domain.com",
      "password": "123123123"
  }
}
```

Get your `authentication_token` from the response. You will need it to create networks.

### Search contracts

*NOTE*: Any request related to contracts is an extension of the route `/api/v1/contracts/`.

Contracts can be sorted by years, countries, [cpvs](http://ec.europa.eu/growth/single-market/public-procurement/rules-implementation/common-vocabulary/index_en.html),
suppliers or procuring_entities.

Common use cases:

####1. Get raw contracts:

  Endpoint: `POST api/v1/contracts`

  Payload:

  ```json
  {
      "query": {
          "countries": ["NL", "UK"],
          "years": [2013, 2014],
          "cpvs": ["79000000"],
          "suppliers": ["476105"],
          "procuring_entities": ["901"]
      }
  }
  ```

  All the parameters are optional. They act as filters. If you don't provide any,
  you will get  all the contracts in the database (though I don't recommend trying that). Ex:

  ```json
  {
      "query": {
      }
  }
  ```

   You can provide as many of them as you like. For `suppliers` and `procuring_entities`, you have
   to use their `slug_id` attribute. You can get it from the response by using other filters.

*NOTE*: You can use the above `Payload` format for all `POST` requests under `api/v1/contracts`.

####2. Count contracts:

  Endpoint: `POST api/v1/contracts/count`
  Payload: Same as above.

####3. Get aggregations based on filters:

  You can use the following endpoints to get aggregations on certain filters (optionally based on other filters).
  For example:

  Endpoint: `POST api/v1/contracts/cpvs`

  Payload:

  ```json
  {
      "query": {
          "year": ["2013"]
      }
  }
  ```

  will give you a response like this:

  ```json
  {
    "search": {
      "count": 2409,
      "results": [
        {
          "key": "45000000",
          "doc_count": 3566,
          "name": "Construction work"
        },
        {
          "key": "60120000",
          "doc_count": 2028,
          "name": "Taxi services"
        },
        {
          "key": "66510000",
          "doc_count": 1613,
          "name": "Insurance services"
        }
      ]
    }
}
```

  Let's break it down. It tells us that in all the contracts from 2013 we
  have 2409 unique CPVs. Then it gives us a list of them ordered descending.
  For each CPV, we have its `key`, which is the actual CPV code,
  a `doc_count` i.e. how many contracts with that CPV there were in 2013,
  and `name` which is the
  name of the industry field corresponding to that CPV code.

  Again, you can play around with parameters to find facts about industries
  or just leave it empty to get a list with all the CPVs of all the contracts in the database.

  The exact same rules apply for _years_ and _countries_, with their corresponding endpoints:
  `POST api/v1/contracts/years`, `POST api/v1/contracts/countries`.

####4. Get details on certain suppliers / procuring entities:

  Endpoint: `POST api/v1/contracts/suppliers_details`

  Payload:

  The usual, except for `procuring_entities` because in this case they are mutually exclusive. You can
  get details for certain suppliers by their `x_slug_id`. The following payload:

  ```json
  {
      "query": {
          "suppliers": ["441869"]
      }
  }
  ```

  will return a response like this:

  ```json
  {
    "search": {
      "count": 1,
      "results": [
        {
          "x_slug_id": "441869",
          "name": "Agilent Technologies Ltd",
          "total_earnings": 875536.18,
          "missing_values": 6,
          "median": {
            "50.0": 3
          },
          "contracts": []
        }
      ]
    }
  }
  ```

  Let's break it down. `name` is the name of the company; `total_earnings` is the total
  amount of money in EUR this company made in all the contracts from the database;
  `missing_values` represents its number of contracts where the value is missing.
  `median` is the [median](https://www.mathsisfun.com/median.html) of the number of tenderers
  in all the contracts this supplier was involved. If you want to restrict the extent
  of these aggregations to contracts from a certain year etc., you can
  use their corresponding filters.

  The same rules apply for procuring entities details, using the endpoint
  `POST api/v1/contracts/procuring_entities_details`.

### Autocomplete for suppliers or procuring entities names

To retrieve autocomplete suggestions for a given string you have to:

`GET api/v1/actor_autocomplete`

Parameters:
*  `text` - the string to autocomplete. _The string to be longer than 1 character_ (>=2)
*  `max_suggestions` - optional integer maximum number of suggestions - default 10

Example:

`localhost:3000/api/v1/actor_autocomplete?text=hav&max_suggestions=100`

Returns:

```json
{
  "search": {
    "count": 2,
    "results": [
      {
        "name": "HAVANA BLUE B.V.",
        "x_slug_id": "441869"
      },
      {
        "name": "HAVERKAMP&BERGERS PROJECT COMMUNICATIE, KANDIDAAT A. BERGERS",
        "x_slug_id": "441870"
      }
    ]
  }
}
```
