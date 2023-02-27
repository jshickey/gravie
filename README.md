# Gravie Test Project

## Files of Interest
* [search_live.ex](https://github.com/jshickey/gravie/blob/pagination/lib/gravie_web/live/checkout_live.ex)
* [checkout_live.exe](https://github.com/jshickey/gravie/blob/pagination/lib/gravie_web/live/checkout_live.ex)
* [giant_bomb_client.ex](https://github.com/jshickey/gravie/blob/pagination/test/gravie/giant_bomb_client_test.exs)

## TODOs
* Manage Tailwind CSS better
    * encapsulate Nav and Game Card into LiveView components
    * use @apply in app.css file
    * move nav bar from LiveView pages to Layouts
    * [Mike Clark combination of SASS and Tailwind](https://pragmaticstudio.com/tutorials/using-tailwind-css-in-phoenix)
* Search Screen
    * fresh queries don't reset the page parameter in the URL
    * add query to URL so that queries could be bookmarked
    * returning from Checkout should leave the previous search screen intact
    * add tests for event handling
    * display flash message that no results were found
    * display flash message when API server is down
    * hover over shopping cart should display cart contents
* API Client
    * error handling for API calls that fail
* Shopping Cart
    * key for cart is only based on session id, ideally would save cart to database for logged in user
    
## As An Architect Project Notes
### Thing I Like About Elixir, Phoenix, LiveView
* LiveView gives gives SPA performance with server side coding
* Built-in Dababase migrations
* Use of Elixir/Erlang's built-in pub sub for UI event messages to server side functions
* Eliminates whole layer of SPA coding
* Elixir is much cleaner than JavaScript or TypeScript
* Easy to write might meaningful tests for UI events without mocking
* Lighweight Map syntax is ideal for simple API process, no need for layer of classes/structs for simple use cases
* Cachex for sharing shopping cart was super simple
* Easy to handle hiding secrets
* Ease of on engineers, only one language to learn - functional by design (not bolted on)
* Resiliency: function crashing doesn't destroy server or even parent processes or session
* Super easy to develop locally versus cloud-native stacks, it just runs
* several million concurrent users per server, cheap to run on the cloud

### Challenges
* requires deploying servers, scales vertically first, then horizontally
* requires sockets, live connection to servers
* requires discipline - modular monolith


## MISC
### ECTO Notes
`mix phx.gen.schema Rental rentals email:string game_guid:string` \
`mix ecto.migrate` \
`psql -U postgres` \
`\connect gravie_dev` \
`\d` 

```
                List of relations
 Schema |       Name        |   Type   |  Owner   
--------+-------------------+----------+----------
 public | rentals           | table    | postgres
 public | rentals_id_seq    | sequence | postgres
 public | schema_migrations | table    | postgres
(3 rows)
```

