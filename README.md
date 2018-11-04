# magic.cr

Bindings to `libmagic(2)` for Crystal.

## Installation

Add this to your application's `shard.yml`:

```yaml
dependencies:
  magic.cr:
    github: dscottboggs/magic.cr
```

## Usage

[API documentation](https://dscottboggs.github.io/magic.cr/index.html)

```crystal
require "magic.cr"
require "http" # for the HTTP example

TestImageURL = "https://upload.wikimedia.org/wikipedia/commons/d/db/Patern_test.jpg"

# get a description of the contents of the file at a path.
Magic.filetype_of "/path/to/a/video.mkv" # => "Matroska data"

# open your bashrc and check its mime type
File.open "~/.bashrc" do |bashrc|
    Magic.mime_type_of bashrc # => "text/plain"
end

# pull TestImageURL from the web and find out what the valid extensions are for
# the bytes received.
HTTP::Client.get TestImageURL do |result|
  Magic.valid_extensions_for result.body_io # => Set{"jpeg", "jpg", "jpe", "jfif"}
end
```

There is also a much more flexible and complicated API for more advanced usage.
For more information and some examples, see `Magic::TypeChecker` and
`spec/magic.cr_spec.cr`.

## Development

Create an issue if you think anything needs revision!

## Contributing

1. Fork it (<https://github.com/dscottboggs/magic.cr/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [dscottboggs](https://github.com/dscottboggs) D. Scott Boggs - creator, maintainer
