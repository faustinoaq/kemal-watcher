# kemal-watcher

[![Build Status](https://travis-ci.org/faustinoaq/kemal-watcher.svg?branch=master)](https://travis-ci.org/faustinoaq/kemal-watcher)

[Kemal](https://github.com/kemalcr/kemal) plugin to watch files like client stuff.

## Installation

Add this to your application's `shard.yml`:

```yaml
dependencies:
  kemal-watcher:
    github: faustinoaq/kemal-watcher
```

## Usage

Add `Kemal.watch` to your Kemal app to watch files.

```crystal
require "kemal"
require "kemal-watcher"

get "/" do
  File.read "src/views/index.html"
end

files = [
  "public/*.js",
  "public/*.html"
]

Kemal.watch(files)
Kemal.run
```

# How does it works?

`Kemal.watch` uses [watcher](https://github.com/faustinoaq/watcher) to watch files and add a new handler to Kemal that inject a script in the response. When a change is detected an event handler is executed and then send a reload signal to the clients.

## Contributing

1. Fork it ( https://github.com/faustinoaq/kemal-watcher/fork )
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create a new Pull Request

## Disclaimer

`Kemal.watch` is intended for use in a development environment.

## Contributors

- [faustinoaq](https://github.com/faustinoaq) Faustino Aguilar - creator, maintainer
