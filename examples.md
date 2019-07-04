# Examples # { #SecExample }

This section lists some examples of path vector queries and the corresponding
responses. Some long lines are truncated for better readability.

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

Below is an example of an Information Resource Directory which enables the path
vector extension. Some critical modifications include:

- The `path-vector` cost type ([](#SecCostType)) is defined in the `cost-types`
  of the `meta` field.

- The `cost-map-pv` information resource provides a Multipart Cost Map resource,
  which provides abstract network elements providing the equivalent Maximum
  Reservable Bandwidth (`maxresbw`) property.

- The `endpoint-cost-pv` information resource provides a Multipart Endpoint Cost
  Service. It also provides abstract network elements providing the equivalent
  Maximum Reservable Bandwidth (`maxresbw`) property.

- The `update-pv` information resource provides the incremental update
  ([](#I-D.ietf-alto-incr-update-sse)) service for the `endpoint-cost-pv`
  resource.

```
{
  "meta": {
    "cost-types": {
      "path-vector": {
        "cost-mode": "array",
        "cost-metric": "ane-path"
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
      "media-type": "multipart/related;type=application/alto-costmap+json",
      "accepts": "application/alto-costmapfilter+json",
      "capabilities": {
        "cost-type-names": [ "path-vector" ],
        "ane-equiv-properties": [ "maxresbw" ]
      },
      "uses": [ "my-default-networkmap" ]
    },
    "endpoint-cost-pv": {
      "uri": "http://alto.exmaple.com/endpointcost/pv",
      "media-type": "multipart/related;type=application/alto-endpointcost+json",
      "accepts": "application/alto-endpointcostparams+json",
      "capabilities": {
        "cost-type-names": [ "path-vector" ],
        "ane-equiv-properties": [ "maxresbw" ]
      }
    },
    "update-pv": {
      "uri": "http://alto.example.com/updates/pv",
      "media-type": "text/event-stream",
      "uses": [ "endpoint-cost-pv" ],
      "accepts": "application/alto-updatestreamparams+json",
      "capabilities": {
        "support-stream-control": true
      }
    }
  }
}
```

## Example: Multipart Filtered Cost Map##

The following examples demonstrate the request to the `cost-map-pv` resource and
the corresponding response.

The request uses the path vector cost type in the `cost-type` field. Also, it
queries the Maximum Reservable Bandwidth ANE property.

The response consists of two parts. The first part returns the array of ANE
identifiers for each source and destination pair. There are three ANEs, where
`ane:L001` is shared by traffic from `PID1` to both `PID2` and `PID3`.

The second part returns the property map that maps all ANE identifiers to their
`maxresbw` properties.

```
POST /costmap/pv HTTP/1.1
Host: alto.example.com
Accept: multipart/related;type=application/alto-costmap+json,
        application/alto-error+json
Content-Length: [TBD]
Content-Type: application/alto-costmapfilter+json

{
  "cost-type": {
    "cost-mode": "array",
    "cost-metric": "ane-path"
  },
  "pids": {
    "srcs": [ "PID1" ],
    "dsts": [ "PID2", "PID3" ]
  },
  "ane-equiv-properties": [ "maxresbw" ]
}
```

```
HTTP/1.1 200 OK
Content-Length: [TBD]
Content-Type: multipart/related;
              boundary=example-1;
              start=cost-map-pv.costmap;
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
      "cost-mode": "array",
      "cost-metric": "ane-path"
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

## Example: Multipart Endpoint Cost Service ##

The following examples demonstrate the request to the `endpoint-cost-pv`
resource and the corresponding response.

Again, the request uses the path vector cost type in the `cost-type` field, and
queries the Maximum Reservable Bandwidth ANE property.

The response consists of two parts. The first part returns the array of ANE
identifiers for each valid source and destination pair.

The second part returns the property map that maps all ANE identifiers to their
`maxresbw` properties.

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
    "cost-mode": "array",
    "cost-metric": "ane-path"
  },
  "endpoints": {
    "srcs": [ "ipv4:192.0.2.2" ],
    "dsts": [ "ipv4:192.0.2.89",
              "ipv4:203.0.113.45",
              "ipv6:2001:db8::10" ]
  },
  "ane-equiv-properties": [ "maxresbw" ]
}
```

```
HTTP/1.1 200 OK
Content-Length: [TBD]
Content-Type: multipart/related; boundary=example-2;
              start=endpoint-cost-pv.ecs;
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
      "cost-mode": "array",
      "cost-metric": "ane-path"
    }
  },
  "endpoint-cost-map": {
    "ipv4:192.0.2.2": {
      "ipv4:192.0.2.89":   [ "ane:L001", "ane:L003",
                             "ane:L004" ],
      "ipv4:203.0.113.45": [ "ane:L001", "ane:L005",
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

## Example: Incremental Updates

In this example, an ALTO client subscribes to the incremental update for the
Multipart Endpoint Cost resource `endpoint-cost-pv`.

```
POST /updates/pv HTTP/1.1
Host: alto.example.com
Accept: text/event-stream
Content-Type: application/alto-updatestreamparams+json
Content-Length: [TBD]

{
  "add": {
    "ecspvsub1": {
      "resource-id": "endpoint-cost-pv",
      "input": <ecs-input>
    }
  }
}
```

Based on the server-side process defined in [](#I-D.ietf-alto-incr-update-sse),
the ALTO server will send the `control-uri` first using Server-Sent Event (SSE),
followed by the full response of the multipart message.

```
HTTP/1.1 200 OK
Connection: keep-alive
Content-Type: text/event-stream

event: application/alto-updatestreamcontrol+json
data: {"control-uri": "http://alto.example.com/updates/streams/1414"}

event: multipart/related;boundary=example-3;start=pvmap;
       type=application/alto-endpointcost+json,ecspvsub1
data: --example-3
data: Resource-ID: endpoint-cost-pv.ecsmap02695067
data: Content-Type: application/alto-endpointcost+json
data:
data: <endpoint-cost-map-entry>
data: --example-3
data: Resource-ID: endpoint-cost-pv.propmapbbc868aa
data: Content-Type: application/alto-propmap+json
data:
data: <property-map-entry>
data: --example-3--
```

When the contents change, the ALTO server will publish the updates for each node
in this tree separately.

```
event: application/merge-patch+json,ecspvsub1.endpoint-cost-pv.ecsmap02695067
data: <Merge patch for endpoint-cost-map-update>

event: application/merge-patch+json,ecspvsub1.endpoint-cost-pv.propmapbbc868aa
data: <Merge patch for property-map-update>
```

<!-- TODO: the remaining issue is where to specify the json-merge-patch capability for each node -->
