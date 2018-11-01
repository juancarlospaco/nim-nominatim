import asyncdispatch, json, httpclient, strformat, strutils, httpcore, uri

const api_url* = "https://nominatim.openstreetmap.org" ## OpenStreetMap Nominatim API (SSL).

type
  NominatimBase*[HttpType] = object  ## Base Object
    timeout*: byte  ## Timeout Seconds for API Calls, byte type, 0~255.
    proxy*: Proxy  ## Network IPv4 / IPv6 Proxy support, Proxy type.
  Nominatim* = NominatimBase[HttpClient]           ##  Sync OpenStreetMap Nominatim Client.
  AsyncNominatim* = NominatimBase[AsyncHttpClient] ## Async OpenStreetMap Nominatim Client.

proc search*(this: Nominatim | AsyncNominatim, query: string, api_url = api_url): Future[JsonNode] {.multisync.} =
  ## Take a Nominatim query and return results from OpenStreetMap, Asynchronously or Synchronously, JSON or XML.
  assert query.len < 255, "OpenStreetMap API limits the length of all key and value strings to a maximum of 255 characters."
  let
    query_url = api_url & "/search?format=json&q=" & query.strip
    response =
      when this is AsyncNominatim:
        await newAsyncHttpClient(proxy = when declared(this.proxy): this.proxy else: nil).get(query_url) # Async.
      else:
        newHttpClient(timeout=this.timeout.int * 1000, proxy = when declared(this.proxy): this.proxy else: nil).get(query_url) # Sync.
  result = parse_json(await response.body)

proc lookup*(this: Nominatim | AsyncNominatim, osm_ids: string,
             addressdetails = true, extratags = true, namedetails = true,
             email = "", accept_language = "EN", api_url = api_url): Future[JsonNode] {.multisync.} =
  ## Take a Nominatim lookup and return results from OpenStreetMap, Asynchronously or Synchronously.
  assert osm_ids.split(',').len < 50, "Max 50 specific OSM nodes/way/relations IDs."
  assert osm_ids.len < 255, "OpenStreetMap API limits the length of all key and value strings to a maximum of 255 characters."
  let
    a = if accept_language != "": fmt"&accept-language={accept_language}" else: ""
    b = if addressdetails: "&addressdetails=1" else: ""
    c = if email != "": fmt"&email={email}" else: ""
    d = if extratags: "&extratags=1" else: ""
    e = if namedetails: "&namedetails=1" else: ""
    all_args = a & b & c & d & e
    query_url = api_url & fmt"/lookup?format=json&osm_ids={osm_ids}" & all_args
  let response =
      when this is AsyncNominatim:
        await newAsyncHttpClient(proxy = when declared(this.proxy): this.proxy else: nil).get(query_url) # Async.
      else:
        newHttpClient(timeout=this.timeout.int * 1000, proxy = when declared(this.proxy): this.proxy else: nil).get(query_url) # Sync.
  result = parse_json(await response.body)

proc reverse*(this: Nominatim | AsyncNominatim, lat: float, lon: float,
              osm_ids = "", osm_type = ' ', zoom: range[-1..18] = -1,
              addressdetails = true, extratags = true, namedetails = true,
              email = "", accept_language = "EN", api_url = api_url): Future[JsonNode] {.multisync.} =
  ## Take a Nominatim reverse and return results from OpenStreetMap, Asynchronously or Synchronously.
  let
    a = if accept_language != "": fmt"accept-language={accept_language}" else: ""
    b = if addressdetails: "&addressdetails=1" else: ""
    c = if email != "": fmt"&email={email}" else: ""
    d = if extratags: "&extratags=1" else: ""
    f = if namedetails: "&namedetails=1" else: ""
    h = if osm_ids != "": fmt"&osm_ids={osm_ids}" else: ""
    i = if osm_type != ' ': fmt"&osm_type={$osm_type}" else: ""
    j = if zoom != -1: fmt"&zoom={$zoom}" else: ""
    k = fmt"&lat={lat}&lon={lon}"
    all_args = a & b & c & d & f & h & i & j & k & "&format=json"
    query_url = api_url & fmt"/reverse?" & all_args
  let response =
      when this is AsyncNominatim:
        await newAsyncHttpClient(proxy = when declared(this.proxy): this.proxy else: nil).get(query_url) # Async.
      else:
        newHttpClient(timeout=this.timeout.int * 1000, proxy = when declared(this.proxy): this.proxy else: nil).get(query_url) # Sync.
  result = parse_json(await response.body)


when is_main_module and not defined(js):
  when defined(release):
    import parseopt, terminal, random
    var
      taimaout = 99.byte
      lat, lon: float
      minusculas: bool
      resultadito, endpoint: string
    for tipoDeClave, clave, valor in getopt():
      case tipoDeClave
      of cmdShortOption, cmdLongOption:
        case clave
        of "version":             quit("0.1.5", 0)
        of "license", "licencia": quit("MIT", 0)
        of "help", "ayuda":       quit("""./nominatim --color --lower --search "pilkington avenue" """, 0)
        of "minusculas", "lower": minusculas = true      # Force lowercase.
        of "lat":                 lat = valor.parseFloat # Only for Reverse.
        of "lon":                 lon = valor.parseFloat # Only for Reverse.
        of "timeout":             taimaout = taimaout.byte # HTTTP Timeout.
        of "search", "lookup", "reverse":
          endpoint = clave
        of "color":
          randomize()
          setBackgroundColor(bgBlack)
          setForegroundColor([fgRed, fgGreen, fgYellow, fgBlue, fgMagenta, fgCyan, fgWhite].rand)
      of cmdArgument:
        let
          clientito = Nominatim(timeout: taimaout)
          cueri = encodeUrl(clave.strip, usePlus=true).replace("%2C", ",") # OPTIMIZE
        case endpoint
        of "search":  resultadito = clientito.search(query=cueri).pretty
        of "lookup":  resultadito = clientito.lookup(osm_ids=clave.strip).pretty
        of "reverse": resultadito = clientito.reverse(lat=lat, lon=lon).pretty
        else: quit("Wrong parameters, must be one of search or lookup or reverse.", 1)
        if minusculas: echo resultadito.toLowerAscii else: echo resultadito
      of cmdEnd: quit("Wrong parameters, see the help with --help", 1)
  else:
    # Sync Client.
    let
      openstreetmap_client = Nominatim(timeout: 5)
      example_search = "135+pilkington+avenue,+birmingham" # Just a string with URLEncoded values.
      example_lookup = "R146656,W104393803,N240109189"  # Just a string with comma separated values.
    # Searching OpenStreetMap Example.
    echo openstreetmap_client.search(query=example_search).pretty
    # Lookup on OpenStreetMap Example.
    echo openstreetmap_client.lookup(osm_ids=example_lookup).pretty
    # Reverse query on OpenStreetMap Example.
    echo openstreetmap_client.reverse(lat = -34.44076, lon = -58.70521).pretty

    ## Async client.
    proc async_nominatim() {.async.} =
      let
        async_nominatim_client = AsyncNominatim(timeout: 9)
        async_response = await async_nominatim_client.search(query=example_search)
      echo async_response.pretty

    wait_for async_nominatim()
