# RenewEx

![RenewEx](./guides/images/logo.png)

[Renew](http://renew.de/) file parser in Elixir.

[![Hex.pm](https://img.shields.io/hexpm/v/renewex.svg)](https://hex.pm/packages/renewex) [![Documentation](https://img.shields.io/badge/documentation-gray)](https://hexdocs.pm/renewex/)

---

## Running tests

All test:
```sh
mix test
```

Only fast tests:
```
mix test --exclude slow
```

## Example Usage

```example.ex
# Read rnw file
{:ok, file_content} = File.read("example.rnw")

# Parse file content
{:ok, %Renewex.Document{} = document} = Renewex.parse_document(file_content)

# Inspect document:
IO.puts(document.version)
IO.puts(document.root)
IO.puts(Enum.count(document.refs))

# Do some work with `document`
# ...

# serialize document back into string
{:ok, serialized} = Renewex.serialize_document(document)

# Write rnw file
File.write("modified.rnw", serialized)
```