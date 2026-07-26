# petersaxton.uk

## Technical

- Built with Gleam, Pamphlet, and Lustre
- Served as a static site by Caddy

## Development

```sh
gleam dev build
```

The build runs a pinned ImageMagick container to generate gallery thumbnails.

For Caddy with automatic rebuilds and browser live reload:

```sh
HOST_PROJECT_DIR="$PWD" HOST_UID=$(id -u) HOST_GID=$(id -g) docker compose up --build
```

Visit [localhost:3000](http://localhost:3000).
