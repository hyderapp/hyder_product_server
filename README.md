# Hyder Product Server

This project aim to provide a product server for [hyder]() applications.

### Quick Start

#### Preparation

Before running the project, you need to install [Elixir]() first. There is [an official guide]() for it.

Optionally, you can install [docker]() for running the database in docker. This can be skipped as you wish,
but then you may need to change `config/dev.exs` to match you database configuration.

#### Run the project

```sh
# start postgreSQL (optional)
docker-compose --file docker/docker-compose.yml

# run the project
mix do deps.get, ecto.setup, phx.server
```

The server is running at [http://127.0.0.1:4000](http://127.0.0.1:4000), you can visit it your browser now.

### API

TODO: to be documented.
