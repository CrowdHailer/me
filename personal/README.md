# petersaxton.uk

## Technical

- Built with [Zola](https://github.com/getzola/zola)
- Hosted on Netlify

## Development

```
docker run -v $PWD:/app --workdir /app balthek/zola:0.13.0 build
docker run -v $PWD:/app --workdir /app -p 8080:8080 balthek/zola:0.13.0 serve --interface 0.0.0.0 --port 8080 --base-url localhost
```