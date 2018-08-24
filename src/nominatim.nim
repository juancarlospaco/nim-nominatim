import asyncdispatch, json, httpclient, strformat, strutils, times, math

const api_url* = "https://nominatim.openstreetmap.org" ## OpenStreetMap Nominatim API (SSL).

type
  NominatimBase*[HttpType] = object
    timeout*: int8
  Nominatim* = NominatimBase[HttpClient]           ##  Sync OpenStreetMap Nominatim Client.
  AsyncNominatim* = NominatimBase[AsyncHttpClient] ## Async OpenStreetMap Nominatim Client.

proc search*(this: Nominatim | AsyncNominatim, query: string, use_json = true, api_url = api_url): Future[string] {.multisync.} =
  ## Take a Nominatim query and return results from OpenStreetMap, Asynchronously or Synchronously, JSON or XML.
  let
    formatos = if use_json: "&format=json" else: ""
    query_url = api_url & "/search" & query.strip & formatos
    response =
      when this is AsyncNominatim: await newAsyncHttpClient().get(query_url) # Async.
      else:        newHttpClient(timeout=this.timeout * 1000).get(query_url) # Sync.
  result = await response.body

proc lookup*(this: Nominatim | AsyncNominatim, osm_ids: string,
             addressdetails = true, extratags = true, namedetails = true, use_json = true,
             email = "", accept_language = "EN", api_url = api_url): Future[string] {.multisync.} =
  ## Take a Nominatim lookup and return results from OpenStreetMap, Asynchronously or Synchronously.
  assert osm_ids.split(',').len < 51, "Max 50 specific OSM nodes/way/relations IDs."
  let
    accept_lang = if accept_language != "": fmt"&accept-language={accept_language}" else: ""
    addresses   = if addressdetails: "&addressdetails=1" else: ""
    mail        = if email != "": fmt"&email={email}" else: ""
    xtratags    = if extratags: "&extratags=1" else: ""
    names       = if namedetails: "&namedetails=1" else: ""
    formatos    = if use_json: "&format=json" else: ""
    all_args    = accept_lang & addresses & mail & xtratags & names & formatos
    query_url   = api_url & fmt"/lookup&osm_ids={osm_ids}" & all_args
  let response =
      when this is AsyncNominatim: await newAsyncHttpClient().get(query_url) # Async.
      else:        newHttpClient(timeout=this.timeout * 1000).get(query_url) # Sync.
  result = await response.body


proc reverse*(this: Nominatim | AsyncNominatim, lat: float, lon: float,
              osm_ids = "", osm_type = ' ', zoom: range[-1..18] = -1,
              addressdetails = true, extratags = true, namedetails = true, use_json = true,
              email = "", accept_language = "EN", api_url = api_url): Future[string] {.multisync.} =
  ## Take a Nominatim reverse and return results from OpenStreetMap, Asynchronously or Synchronously.
  let
    a = if accept_language != "": fmt"accept-language={accept_language}" else: ""
    b = if addressdetails: "&addressdetails=1" else: ""
    c = if email != "": fmt"&email={email}" else: ""
    d = if extratags: "&extratags=1" else: ""
    f = if namedetails: "&namedetails=1" else: ""
    g = if use_json: "&format=json" else: ""
    h = if osm_ids != "": fmt"&osm_ids={osm_ids}" else: ""
    i = if osm_type != ' ': fmt"&osm_type={$osm_type}" else: ""
    j = if zoom != -1: fmt"&zoom={$zoom}" else: ""
    k = fmt"&lat={lat}&lon={lon}"
    all_args = a & b & c & d & f & g & h & i & j & k
    query_url = api_url & fmt"/reverse?" & all_args
  echo query_url
  let response =
      when this is AsyncNominatim: await newAsyncHttpClient().get(query_url) # Async.
      else:        newHttpClient(timeout=this.timeout * 1000).get(query_url) # Sync.
  result = await response.body


when is_main_module:
  let
    openstreetmap_client = Nominatim(timeout: 5)
    example_search = "?q=135+pilkington+avenue,+birmingham&format=xml&polygon=1&addressdetails=1"
    example_lookup = "R146656,W104393803,N240109189"

  # Searching OpenStreetMap Example.
  echo openstreetmap_client.search(query=example_search)

  # Lookup on OpenStreetMap Example.
  echo openstreetmap_client.lookup(osm_ids=example_lookup)

  # Reverse query on OpenStreetMap Example.
  echo openstreetmap_client.reverse(lat = -34.44076, lon = -58.70521)
