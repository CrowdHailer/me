# Me

All about [me](https://crowdhailer.me)

## Build

```sh
gleam dev build
```

The deployable static bundle is written to `_site/`.

## Development

```sh
HOST_UID=$(id -u) HOST_GID=$(id -g) docker compose up --build
```

Visit [localhost:3000](http://localhost:3000). Caddy serves `_site/` and the
browser reloads after the Gleam watcher rebuilds changed files.

## Migration Validation

Compare against a Jekyll reference bundle:

```sh
gleam dev validate /path/to/jekyll-site
```
