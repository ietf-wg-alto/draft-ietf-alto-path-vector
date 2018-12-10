# Examples # { #SecExample }

This section lists a series of examples to proceed the multi-flow scheduling like the use case in [](#SecMF).

The recommended workflow is like the following:

<!-- FIXME: The workflow is out-of-date -->
## Workflow ## { #workflow }

- Send the GET request for the whole Information Resource Directory.  <!-- Ex1 -->

- Look for the resource of the (Filtered) Cost Map/Endpoint Cost Service which contains the path-vector cost type and get the resource id of the property map.  <!-- Ex2 -->

- Look for the resource of the property map to check whether it supports the desired "prop-types".  <!-- Ex3 -->

- Send request to the (Filtered) Cost Map/Endpoint Cost Service and get the response with "query-id" information. Meanwhile, the properties of the returned abstract network elements are generated in the corresponding Network Element Property Map. <!-- Ex4 -->

- Send request to the Network Element Property Map with the returned "query-id" information and get the response. <!-- Ex5 -->

## Information Resource Directory Example ## { #id-example-ird }

Here is an example of an ALTO server's Information Resource Directory. In this example, both "filtered-multi-cost-map" and "default-endpoint-cost-map" support the multi-cost extension and the path-vector extension. Resource "ne-property-map-availbw" supports property "availbw" and resource "ne-property-map-delay" supports property "delay".

```
  "meta": {
    "cost-types": {
      "pv-ne": {
        "cost-mode": "path-vector",
        "cost-metric": "ne"
      },
      "num-hopcount": {
        "cost-mode": "numerical",
        "cost-metric": "hopcount"
      },
      "num-routingcost": {
        "cost-mode": "numerical",
        "cost-metric": "routingcost"
      },
    }
  },
  "resources": {

    ... NetworkMap Resource ...

    "default-network-map": {
      "uri": "http://alto.example.com/networkmap",
      "media-type": "application/alto-networkmap+json"
    },

    ... Cost Map Resource ...

    "pv-cost-map": {
      "uri": "http://alto.example.com/pv/ne",
      "media-type": "application/alto-costmap+json",
      "capabilities": {
        "cost-type-names": ["pv-ne"]
      },
      "uses": ["default-network-map"],
      "propertymap": ["ne-property-map-delay",
                      "ne-property-map-availbw"]
    }

    ... Multi-Cost Filtered Map Resource ...

    "filtered-multi-cost-map": {
      "uri": "http://alto.example.com/costmap/multi/filtered",
      "media-type": "application/alto-costmap+json",
      "accepts": "application/alto-costmapfilter+json",
      "uses": ["default-network-map"],
      "capabilities": {
        "max-cost-types": 3,
        "cost-type-names": ["pv-ne",
                            "num-routingcost",
                            "num-hopcount"],
        "cost-constraints": true
      },
      "propertymap": ["ne-property-map-delay",
                      "ne-property-map-availbw"]
    },

    ... Endpoint Cost Service Resource ...

    "default-endpoint-cost-map": {
      "uri": "http://alto.example.com/endpointcost/lookup",
      "media-type": "application/alto-endpointcostmap+json",
      "accepts": "application/alto-endpointcostparams+json",
      "capabilities": {
        "max-cost-types": 3,
        "cost-type-names": ["pv-ne",
                            "num-routingcost",
                            "num-hopcount"],
        "testable-cost-types-names": ["num-hopcount",
                                      "num-routingcost"],
      },
      "propertymap": ["ne-property-map-delay"]
    }

    ... Network Element Property Map Resource ...

    "ne-property-map-delay": {
      "uri": "http://alto.example.com/propmap/lookup/delay",
      "media-type": "application/alto-propmap+json",
      "accepts": "application/alto-propmapparams+json",
      "capabilities": {
        "domain-types": ["ne"],
        "prop-types": ["delay"]
      }
    }

    "ne-property-map-availbw": {
      "uri": "http://alto.example.com/propmap/lookup/availbw",
      "media-type": "application/alto-propmap+json",
      "accepts": "application/alto-propmapparams+json",
      "capabilities": {
        "domain-types": ["ne"],
        "prop-types": ["availbw"]
      }
    }
  }
```

## Cost Map Example ## {#id-example-costmap}

Here is an example of the Cost Map request for path-vector and the corresponding response. In response, the extended "vtag" field is included in "meta" to provide "query-id" information.

```
  GET /costmap/pv/ne HTTP/1.1
  Host: alto.example.com
  Accept: application/alto-costmap+json,application/alto-error+json

  HTTP/1.1 200 OK
  Content-Length: [TBD]
  Content-Type: application/alto-costmap+json

  {
    "meta" : {
      "dependent-vtags" : [
        { "resource-id": "default-network-map",
          "tag": "5eb2cb7f8d63a9fab71d9b34cbf763436315542f"
        }
      ],
      "vtag": [
        { "resource-id": "pv-cost-map",
          "tag": "aef527ca2eb7a7566db0597407893e3f8eb1d9dff",
          "query-id": "query0"
        }
      ],
      "cost-type" : {"cost-mode"  : "pv",
                     "cost-metric": "ne"
      }
    },
    "cost-map" : {
        "PID1": { "PID2": ["ne:L001", "ne:L003"],
                  "PID3": ["ne:L002", "ne:L004"] },
        "PID2": { "PID1": ["ne:L003", "ne:L002"],
                  "PID3": ["ne:L003", "ne:L004"] },
        "PID3": { "PID1": ["ne:L004", "ne:L002"],
                  "PID2": ["ne:L004", "ne:L003"] }
    }
  }
```

## Multi-Cost Filtered Cost Map Example ## { #id-example-multicost-filteredcostmap }

The following example presents the request and response of "filtered-multi-cost-map". In this example, the client is interested in the path-vector and numerical routing cost information. The client uses "or-constraints" but all the results satisfy the conditions. In resposne, the extended "vtag" field is included in "meta" to provide "query-id" information.

```
  POST /costmap/multi/filtered HTTP/1.1
  Host: alto.example.com
  Accept: application/alto-costmap+json,application/alto-error+json
  Content-Length: [TBD]
  Content-Type: application/alto-costmapfilter+json

  {
    "multi-cost-types": [
      {
        "cost-mode": "path-vector",
        "cost-metric": "ne"
      },
      {
        "cost-mode": "numerical",
        "cost-metric": "routingcost"
      }
    ],
    "testable-cost-types": [
      { "cost-mode": "numerical", "cost-metric": "routingcost" },
      { "cost-mode": "numerical", "cost-metric": "hopcount" }
    ],
    "or-constraints": [
      ["[0] ge 50", "[1] le 60"]
    ],
    "pid-flows": [
      { "src": "PID1", "dst": "PID2" },
      { "src": "PID2", "dst": "PID3" }
    ]
  }

  HTTP/1.1 200 OK
  Content-Length: [TBD]
  Content-Type: application/alto-costmap+json

  {
    "meta": {
      "dependent-vtags": [
        {
          "resource-id": "default-network-map",
          "tag": "75ed013b3cb58f896e839582504f622838ce670f"
        }
      ],
      "vtag": [
        {
          "resource-id": "filtered-multi-cost-map",
          "tag": "27612897acf278ffu3287c284dd28841da78213",
          "query-id": "query1"
        }
      ]
    }
    "cost-type": {},
    "multi-cost-types": [
      { "cost-mode": "path-vector", "cost-metric": "ne" },
      { "cost-mode": "numerical",   "cost-metric": "routingcost"}
    ],

    "cost-map": {
      "PID1": {
        "PID2": [ [ "ne:L001", "ne:L003" ], 55 ]
      },
      "PID2": {
        "PID3": [ [ "ne:L003", "ne:L004" ], 60 ]
      }
    }
  }
```

## Endpoint Cost Service Example ## { #id-example-endpointcostmap }

If the ALTO client expects the routing state information between endpoints, it can also query the "default-endpoint-cost-map" resource which supports path vector. In resposne, the extended "vtag" field is included in "meta" to provide "query-id" information.

```
  POST /endpointcost/lookup HTTP/1.1
  Host: alto.example.com
  Accept: application/alto-endpointcost+json,application/alto-error+json
  Content-Length: [TBD]
  Content-Type: application/alto-endpointcostparams+json

  {
    "multi-cost-types": [
      { "cost-mode": "path-vector", "cost-metric": "ne" },
      { "cost-mode": "numerical",   "cost-metric": "hopcount" }

    ],
    "endpoint-flows": [
      { "src": "ipv4:192.0.2.2",     "dst": "ipv4:203.0.113.45"  },
      { "src": "ipv4:192.0.2.89",    "dst": "ipv4:198.51.100.34" },
      { "src": "ipv4:194.2.3.67",    "dst": "ipv4:202.56.54.230" },
      { "src": "ipv4:203.32.56.102", "dst": "ipv4:202.76.89.103" }
    ]
  }

  HTTP/1.1 200 OK
  Content-Length: [TBD]
  Content-Type: application/alto-endpointcost+json

  {
    "meta": {
      "vtag": [
        {
          "resource-id": "default-endpoint-cost-map",
          "tag": "73182ffa829dc28c218a1823bb1293dea232885",
          "query-id": "query2"
        }
      ],
      "cost-type": {},
      "multi-cost-types": [
        { "cost-mode": "path-vector", "cost-metric": "ne" },
        { "cost-mode": "numerical", "cost-metric": "hopcount" }
      ]
    },
    "endpoint-cost-map": {
      "ipv4:192.0.2.2": {
        "ipv4:203.0.113.45": [ [ "ne:L10", "ne:L11",
                                 "ne:L15", "ne:L16",
                                 "ne:L17", "ne:L13" ], 100]
      },
      "ipv4:192.0.2.89": {
        "ipv4:198.51.100.34": [ [ "ne:L14", "ne:L11",
                                  "ne:L12", "ne:L18",
                                  "ne:L19" ], 124]
      },
      "ipv4:194.2.3.67": {
        "ipv4:202.56.54.230": [ [ "ne:L21", "ne:L15",
                                  "ne:L16", "ne:L17",
                                  "ne:L18", "ne:L20"], 78]
      },
      "ipv4:203.32.56.102": {
        "ipv4:202.76.89.103": [ [ "ne:L22", "ne:L16",
                                  "ne:L23"], 168]
      }
    }
  }
```

## Network Element Property Map Example  # 1 ## {#id-example-nepmap-availbw }

After the client send the query to the Multi-Cost Filtered Cost Map "filtered-multi-cost-map" and get the response with query-id "query1" (See [](#id-example-multicost-filteredcostmap)). The client send request to the "ne-property-map-availbw" with query-id "query1" and get the response.

```
  POST /propmap/lookup/availbw HTTP/1.1
  Host: alto.example.com
  Accept: application/alto-propmap+json,application/alto-error+json
  Content-Length: [TBD]
  Content-Type: application/alto-propmapparams+json

  {
    "query-id": "query1",
    "entities" : [ "ne:L001",
                   "ne:L003",
                   "ne:L004" ],
    "properties" : [ "availbw" ]
  }

  HTTP/1.1 200 OK
  Content-Length: [TBD]
  Content-Type: application/alto-propmap+json

  {
    "property-map": {
      "ne:L001": { "availbw": "50" },
      "ne:L003": { "availbw": "70" },
      "ne:L004": { "availbw": "80" }
    }
  }
```

## Network Element Property Map Example  # 2 ## { #id-example-nepmap-delay }

After the client send the query to the Endpoint Cost Service "default-endpoint-cost-map" and get the response with query-id "query2" (See [](#id-example-endpointcostmap)). The client send request to the "ne-property-map-delay" with query-id "query2" and get the response.

```
  POST /propmap/lookup/delay HTTP/1.1
  Host: alto.example.com
  Accept: application/alto-propmap+json,application/alto-error+json
  Content-Length: [TBD]
  Content-Type: application/alto-propmapparams+json

  {
    "query-id": "query2",
    "entities" : [ "ne:L11",
                   "ne:L15",
                   "ne:L16",
                   "ne:L18" ],
    "properties" : [ "delay" ]
  }

  HTTP/1.1 200 OK
  Content-Length: [TBD]
  Content-Type: application/alto-propmap+json

  {
    "property-map": {
      "ne:L11": { "delay": "25" },
      "ne:L15": { "delay": "40" },
      "ne:L16": { "delay": "60" },
      "ne:L18": { "delay": "10" }
    }
  }
```
