# Notes

- git clone elixir-on-docker name

- docker-compose run www mix deps.get

- docker-cloud create node cluster

- docker-compose up

- localhost:8080

- Edit lib/www/home_page.html.eex, show reloading

- Add <%= Node.self() %>

- localhost:8080

- docker-compose up --build

- docker images

- show docker-compose

- docker tag meetup_www crowdhailer/www

- docker push crowdhailer/www

- docker-cloud, create stack

- repositories tab, lauch a service
  - name www
  - stack meetup
  - deployment strategy, every node
  - autoredeploy
  - add ports 8080, 8443, 4001
  - environment variables, PEER_LIST, ERLANG_COOKIE

- open container url show `@app@www-1` and `app@www-2`

- docker-compose <files> run integration mix test

- checkout integration test suite for chat app

- show test suite

- show failing

- show `Raxx.Blueprint` and `www.apib`

- create `subscribe_to_updates.ex`
  - use `Raxx.Server`

- show raxx server info page

- show integration tests still failing

- checkout biz `chat.ex`

- Finish subscribe_to_updates
  - `@impl Raxx.Server`
  - `handle_request/2`
  - `WWW.Chat.join`
  - response, `text/event-stream`, body true
  - return `{[response], state}`

- Run tests

- checkout publish_a_message.ex

- checkout rest of subscribe_to_updates
  - show `handle_info`

- add server_sent_events to mix deps

- tests should be green

- git checkout javascript

- show chat in two localhost terminals

- docker-compose up --build

- docker images

- docker tag

- docker push

- show redeploy service on cloud

- show container logs, see nodes connected to

- show post accross cluster
