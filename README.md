# nim-nominatim

- [OpenStreetMap](https://openstreetmap.org) [Nominatim](https://nominatim.openstreetmap.org) API Lib for [Nim](https://nim-lang.org), Async & Sync, Pull Requests welcome.

![OpenStreetMap](https://raw.githubusercontent.com/juancarlospaco/nim-overpass/master/osm.jpg)


# Install

- `nimble install nominatim`


# Use

**From Nim code:**

```nim
import nominatim

# Sync Client.
let openstreetmap_client = Nominatim(timeout: 5)
# Searching OpenStreetMap Example.
echo openstreetmap_client.search(query="135+pilkington+avenue,+birmingham").pretty
# Lookup on OpenStreetMap Example.
echo openstreetmap_client.lookup(osm_ids="R146656,W104393803,N240109189").pretty
# Reverse query on OpenStreetMap Example.
echo openstreetmap_client.reverse(lat = -34.44076, lon = -58.70521).pretty

## Async client.
proc async_nominatim() {.async.} =
  let
    async_nominatim_client = AsyncNominatim(timeout: 9)
    async_response = await async_nominatim_client.search(query="135+pilkington+avenue,+birmingham")
  echo async_response.pretty

wait_for async_nominatim()
```

**Search as a command line app:**

```bash
$ ./nominatim --color --lower --timeout=9 --search "135 pilkington avenue, birmingham"
```

**Lookup as a command line app:**

```bash
$ ./nominatim --color --lower --lookup "R146656,W104393803,N240109189"
```

**Reverse as a command line app:**

```bash
$ ./nominatim --color --lower --lon=-58.70521 --lat=-34.44076  --reverse "reverse"
```


# Requisites

- None.


# API

- The `timeout` argument is on Seconds.
- All the responses are JSON, `JsonNode` type.
- OpenStreetMap API limits the length of all key and value strings to a maximum of 255 characters.
- For Proxy support define a `Nominatim.proxy` or `AsyncNominatim.proxy` of `Proxy` type.
- No OS-specific code, so it should work on Linux, Windows and Mac. Not JS.

### Search

`search*(this: Nominatim | AsyncNominatim, query: string, api_url = api_url)`

- `this` is `Nominatim(timeout=int8)` for Synchronous code or `AsyncNominatim(timeout=int8)` for Asynchronous code.
- `query` is an Nominatim query, `string` type, required.
- `api_url` is an Nominatim HTTP API URL, `string` type, optional.

### Lookup

`lookup*(this: Nominatim | AsyncNominatim, osm_ids: string, addressdetails = true, extratags = true, namedetails = true, email = "", accept_language = "EN", api_url = api_url)`

- `this` is `Nominatim(timeout=int8)` for Synchronous code or `AsyncNominatim(timeout=int8)` for Asynchronous code.
- `osm_ids` is an Nominatim OpenStreetMap IDs, `string` type, comma separated, max 50 items, required.
- `addressdetails` Set to `true` to show address details, `bool` type, optional, defaults to `true`.
- `extratags` Set to `true` to show extra tags, `bool` type, optional, defaults to `true`.
- `namedetails` Set to `true` to show name details, `bool` type, optional, defaults to `true`.
- `email` Set to your email address (for massive heavy use of the API), `string` type, defaults to `""`, optional.
- `accept_language` Set output spoken language, `string` type, defaults to `"EN"`, optional.
- `api_url` is an Nominatim HTTP API URL, `string` type, optional.

### Reverse

`reverse*(this: Nominatim | AsyncNominatim, lat: float, lon: float, osm_ids = "", osm_type = ' ', zoom: range[-1..18] = -1, addressdetails = true, extratags = true, namedetails = true, email = "", accept_language = "EN", api_url = api_url)`

- `this` is `Nominatim(timeout=int8)` for Synchronous code or `AsyncNominatim(timeout=int8)` for Asynchronous code.
- `osm_ids` is an Nominatim OpenStreetMap IDs, `string` type, comma separated, max 50 items, required.
- `addressdetails` Set to `true` to show address details, `bool` type, optional, defaults to `true`.
- `extratags` Set to `true` to show extra tags, `bool` type, optional, defaults to `true`.
- `namedetails` Set to `true` to show name details, `bool` type, optional, defaults to `true`.
- `email` Set to your email address (for massive heavy use of the API), `string` type, defaults to `""`, optional.
- `accept_language` Set output spoken language, `string` type, defaults to `"EN"`, optional.
- `api_url` is an Nominatim HTTP API URL, `string` type, optional.
- `zoom` is the Zoom, a positive integer between `-1` and `18`, `range[-1..18]` type, defaults to `-1`, `-1` means disabled, optional.
- `lat` is the Latitude, `float` type, required.
- `lon` is the Longitude, `float` type, required.
