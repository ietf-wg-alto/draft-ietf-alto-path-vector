# Examples # { #SecExample }

This section lists some examples of path vector queries and the corresponding responses.

<!--
## Workflow ## { #workflow }

This section gives a typical workflow of how an ALTO client query path vectors
using the extension.

1. Send a GET request for the whole Information Resource Directory.

1. Look for the resource of the (Filtered) Cost Map/Endpoint Cost Service which
   supports the `path-vector` cost mode and get the resource ID of the dependent
   property map.

1. Check whether the capabilities of the property map includes the desired
   "prop-types".

1. Check whether the (Filtered) Cost Map/Endpoint Cost Service allows the
   compound response.

   1. If allowed, the ALTO client can send a request including the desired ANE
      properties to the ALTO server and receive a compound response with the
      cost map/endpoint cost map and the property map.

   1. If not allowed, the ALTO client sends a query for the cost map/endpoint
      cost map first. After receiving the response, the ALTO client interprets
      all the ANE names appearing in the response and sends another query for
      the property map on those ANE names.
-->


## Information Resource Directory Example ## { #id-example-ird }

Here is an example of an Information Resource Directory. In this example,
the `cost-map-pv` information resource provides a Multipart Cost Map resource for
path-vector; the `endpoint-cost-pv` information resource provides a
MultipartEndpoint Cost resource for path-vector. Both of them support the
Maximum Reservable Bandwidth (`maxresbw`) cost metric in `path-vector` cost mode.

<!-- TODO: Use the coherent example with the use case section -->

```
  {
    "meta": {
      "cost-types": {
        "pv-maxresbw": {
          "cost-mode": "path-vector",
          "cost-metric": "maxresbw"
        }
      }
    },
    "resources": {
      "my-default-networkmap": {
        "uri" : "http://alto.example.com/networkmap",
        "media-type" : "application/alto-networkmap+json"
      },
      "cost-map-pv": {
        "uri": "http://alto.example.com/costmap/pv",
        "media-type": `multipart/related;
                       type=application/alto-costmap+json`,
        "accepts": "application/alto-costmapfilter+json",
        "capabilities": {
          "cost-type-names": [ "pv-maxresbw" ]
        },
        "uses": [ "my-default-networkmap" ]
      },
      "endpoint-cost-pv": {
        "uri": "http://alto.exmaple.com/endpointcost/pv",
        "media-type": `multipart/related;
                       type=application/alto-endpointcost+json`,
        "accepts": "application/alto-endpointcostparams+json",
        "capabilities": {
          "cost-type-names": [ "pv-maxresbw" ]
        }
      }
    }
  }
```

## Example #1##

Query filtered cost map to get the path vectors.

```
POST /costmap/pv HTTP/1.1
Host: alto.example.com
Accept: multipart/related;
        type=application/alto-costmap+json,
        application/alto-error+json
Content-Length: [TBD]
Content-Type: application/alto-costmapfilter+json

{
  "cost-type": {
    "cost-mode": "path-vector",
    "cost-metric": "maxresbw"
  },
  "pids": {
    "srcs": [ "PID1" ],
    "dsts": [ "PID2", "PID3" ]
  }
}
```

```
HTTP/1.1 200 OK
Content-Length: [TBD]
Content-Type: multipart/related; boundary=example-1;
              start=cost-map-pv.costmap
              type=application/alto-costmap+json

--example-1
Resource-Id: cost-map-pv.costmap
Content-Type: application/alto-costmap+json

{
  "meta": {
    "vtag": {
      "resource-id": "cost-map-pv.costmap",
      "tag": "d827f484cb66ce6df6b5077cb8562b0a"
    },
    "dependent-vtags": [
      {
        "resource-id": "my-default-networkmap",
        "tag": "75ed013b3cb58f896e839582504f6228"
      }
    ],
    "cost-type": {
      "cost-mode": "path-vector",
      "cost-metric": "maxresbw"
    }
  },
  "cost-map": {
    "PID1": {
      "PID2": [ "ane:L001", "ane:L003" ],
      "PID3": [ "ane:L001", "ane:L004" ]
    }
  }
}
--example-1
Resource-Id: cost-map-pv.propmap
Content-Type: application/alto-propmap+json

{
  "meta": {
    "dependent-vtags": [
      {
        "resource-id": "cost-map-pv.costmap",
        "tag": "d827f484cb66ce6df6b5077cb8562b0a"
      }
    ]
  },
  "property-map": {
    "ane:L001": { "maxresbw": 100000000},
    "ane:L003": { "maxresbw": 150000000},
    "ane:L004": { "maxresbw": 50000000}
  }
}
```

## Example #2 ##

```
POST /endpointcost/pv HTTP/1.1
Host: alto.example.com
Accept: multipart/related;
        type=application/alto-endpointcost+json,
        application/alto-error+json
Content-Length: [TBD]
Content-Type: application/alto-endpointcostparams+json

{
  "cost-type": {
    "cost-mode": "path-vector",
    "cost-metric": "maxresbw"
  },
  "endpoints": {
    "srcs": [ "ipv4:192.0.2.2" ],
    "dsts": [ "ipv4:192.0.2.89",
              "ipv4:203.0.113.45",
              "ipv6:2001:db8::10" ]
  }
}
```

```
HTTP/1.1 200 OK
Content-Length: [TBD]
Content-Type: multipart/related; boundary=example-2;
              start=endpoint-cost-pv.ecs
              type=application/alto-endpointcost+json

--example-2
Resource-Id: endpoint-cost-pv.ecs
Content-Type: application/alto-endpointcost+json

{
  "meta": {
    "vtags": {
      "resource-id": "endpoint-cost-pv.ecs",
      "tag": "bb6bb72eafe8f9bdc4f335c7ed3b10822a391cef"
    },
    "cost-type": {
      "cost-mode": "path-vector",
      "cost-metric": "maxresbw"
    }
  },
  "endpoint-cost-map": {
    "ipv4:192.0.2.2": {
      "ipv4:192.0.2.89":   [ "ane:L001", "ane:L003",
                             "ane:L004" ],
      "ipv4:203.0.113.45": [ "ane:L001", "ane:L004",
                             "ane:L005" ],
      "ipv6:2001:db8::10": [ "ane:L001", "ane:L005",
                             "ane:L007" ]
    }
  }
}
--example-2
Resource-Id: endpoint-cost-pv.propmap
Content-Type: application/alto-propmap+json

{
  "meta": {
    "dependent-vtags": [
      {
        "resource-id": "endpoint-cost-pv.ecs",
        "tag": "bb6bb72eafe8f9bdc4f335c7ed3b10822a391cef"
      }
    ]
  },
  "property-map": {
    "ane:L001": { "maxresbw": 50000000 },
    "ane:L003": { "maxresbw": 48000000 },
    "ane:L004": { "maxresbw": 55000000 },
    "ane:L005": { "maxresbw": 60000000 },
    "ane:L007": { "maxresbw": 35000000 }
  }
}
```
