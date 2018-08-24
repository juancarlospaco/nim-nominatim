# nim-nominatim

- [OpenStreetMap](https://openstreetmap.org) [Nominatim](https://nominatim.openstreetmap.org) API Lib for [Nim](https://nim-lang.org), Async & Sync.

![OpenStreetMap](https://raw.githubusercontent.com/juancarlospaco/nim-overpass/master/osm.jpg)


# Install

- `nimble install nominatim`


# Use

```nim
import nominatim
echo Nominatim(timeout: 5).lookup(osm_ids="R146656,W104393803,N240109189")
```


# Requisites

- None.


# API

### Search

`search*(this: Nominatim | AsyncNominatim, query: string, use_json = true, api_url = api_url)`

- `this` is `Nominatim(timeout=int8)` for Synchronous code or `AsyncNominatim(timeout=int8)` for Asynchronous code.
- `query` is an Nominatim query, `string` type, required.
- `api_url` is an Nominatim HTTP API URL, `string` type, optional.


### Lookup

`lookup*(this: Nominatim | AsyncNominatim, osm_ids: string, addressdetails = true, extratags = true, namedetails = true, use_json = true, email = "", accept_language = "EN", api_url = api_url)`

- `this` is `Nominatim(timeout=int8)` for Synchronous code or `AsyncNominatim(timeout=int8)` for Asynchronous code.
- `osm_ids` is an Nominatim OpenStreetMap IDs, `string` type, comma separated, max 50 items, required.
- `addressdetails` Set to `true` to show address details, `bool` type, optional, defaults to `true`.
- `extratags` Set to `true` to show extra tags, `bool` type, optional, defaults to `true`.
- `namedetails` Set to `true` to show name details, `bool` type, optional, defaults to `true`.
- `use_json` Set to `true` to use json, `bool` type, optional, defaults to `true`.
- `email` Set to your email address (for massive heavy use of the API), `string` type, defaults to `""`, optional.
- `accept_language` Set output spoken language, `string` type, defaults to `"EN"`, optional.
- `api_url` is an Nominatim HTTP API URL, `string` type, optional.


### Reverse

- **TBD!, WIP!.**
