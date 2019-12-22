# Hyder Product Server

This project aim to provide a product server for [hyder][hyder] applications.

### Quick Start

#### Preparation

##### Elixir

Before running the project, you need to install [Elixir][elixir] first. There is [an official guide](https://elixir-lang.org/install.html) for it.

##### Docker (recommended)

Optionally, you can install [docker][docker] for running the database in docker. This can be skipped as you wish,
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

You can visit an interactive document in [http://127.0.0.1:4000/doc](http://127.0.0.1:4000/doc) via a [swagger_ui][swagger_ui] service.

[hyder]: https://github.com/hyderapp/
[elixir]: https://elixir-lang.org/
[docker]: https://www.docker.com/
[swagger_ui]: https://swagger.io/tools/swagger-ui/
