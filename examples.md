# Examples {#Examples}

This section lists some examples of path vector queries and the corresponding
responses. Some long lines are truncated for better readability.

## Example: Information Resource Directory ## { #id-example-ird }

Below is an example of an Information Resource Directory which enables the path
vector extension. Some critical modifications include:

- The `path-vector` cost type ({{cost-type}}) is defined in the `cost-types`
  of the `meta` field.

- The `cost-map-pv` information resource provides a multipart filtered cost map
  resource, which exposes the Maximum Reservable Bandwidth (`maxresbw`)
  property.

- The `http-proxy-props` information resource provides a filtered unified
  property map resource, which exposes the HTTP proxy entity domain (encoded as
  `http-proxy`) and the `price` property. Note that HTTP proxy is NOT a valid
  entity domain yet and is used here only for demonstration.

- The `endpoint-cost-pv` information resource provides a multipart endpoint cost
  resource. It exposes the Maximum Reservable Bandwidth (`maxresbw`)
  property and the Persistent Entity property (`persistent-entities`). The
  persistent entities MAY come from the `http-proxy-props` resource.

- The `update-pv` information resource provides the incremental update
  ({{I-D.ietf-alto-incr-update-sse}}) service for the `endpoint-cost-pv`
  resource.

~~~
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
      "media-type": "multipart/related;
                     type=application/alto-costmap+json",
      "accepts": "application/alto-costmapfilter+json",
      "capabilities": {
        "cost-type-names": [ "path-vector" ],
        "ane-properties": [ "maxresbw" ]
      },
      "uses": [ "my-default-networkmap" ]
    },
    "http-proxy-props": {
      "uri": "http://alto.example.com/proxy-props",
      "media-type": "application/alto-propmap+json",
      "accpets": "application/alto-propmapparams+json",
      "capabilities": {
        "mappings": {
          "http-proxy": [ "price" ]
        }
      }
    },
    "endpoint-cost-pv": {
      "uri": "http://alto.exmaple.com/endpointcost/pv",
      "media-type": "multipart/related;
                     type=application/alto-endpointcost+json",
      "accepts": "application/alto-endpointcostparams+json",
      "capabilities": {
        "cost-type-names": [ "path-vector" ],
        "ane-properties": [ "maxresbw", "persistent-entities" ]
      },
      "uses": [ "http-proxy-props" ]
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
~~~

## Example: Multipart Filtered Cost Map##

The following examples demonstrate the request to the `cost-map-pv` resource and
the corresponding response.

The request uses the path vector cost type in the `cost-type` field. The
`ane-properties` field is missing, indicating that the client only requests for
the path vector but not the ANE properties.

The response consists of two parts. The first part returns the array of ANE
identifiers for each source and destination pair. There are three ANEs, where
`ane:L001` is shared by traffic from `PID1` to both `PID2` and `PID3`.

The second part returns an empty property map. Note that the ANE entries are
omitted since they have no properties (See Section 3.1 of {{I-D.ietf-alto-unified-props-new}}).

~~~
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
  }
}
~~~

~~~
HTTP/1.1 200 OK
Content-Length: [TBD]
Content-Type: multipart/related; boundary=example-1;
              type=application/alto-costmap+json

--example-1
Resource-Id: costmap
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
Resource-Id: propmap
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
  }
}
~~~

## Example: Multipart Endpoint Cost Resource ##

The following examples demonstrate the request to the `endpoint-cost-pv`
resource and the corresponding response.

The request uses the path vector cost type in the `cost-type` field, and
queries the Maximum Reservable Bandwidth ANE property and the Persistent Entity
property.

The response consists of two parts. The first part returns the array of ANE
identifiers for each valid source and destination pair.

The second part returns the requested properties of ANEs in the first part. The
"ane:NET001" element contains an HTTP proxy entity, which can be further used by
the client. Since it does not contain a `maxresbw` property, the client SHOULD
assume it does NOT support bandwidth reservation but will NOT become a traffic
bottleneck, as specified in {{maxresbw}}.

~~~
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
  "ane-properties": [ "maxresbw", "persistent-entities" ]
}
~~~

~~~
HTTP/1.1 200 OK
Content-Length: [TBD]
Content-Type: multipart/related; boundary=example-2;
              type=application/alto-endpointcost+json

--example-2
Resource-Id: ecs
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
      "ipv4:192.0.2.89":   [ "ane:NET001", "ane:L002" ],
      "ipv4:203.0.113.45": [ "ane:NET001", "ane:L003" ]
    }
  }
}
--example-2
Resource-Id: propmap
Content-Type: application/alto-propmap+json

{
  "meta": {
    "dependent-vtags": [
      {
        "resource-id": "endpoint-cost-pv.ecs",
        "tag": "bb6bb72eafe8f9bdc4f335c7ed3b10822a391cef"
      },
      {
        "resource-id": "http-proxy-props",
        "tag": "bf3c8c1819d2421c9a95a9d02af557a3"
      }
    ]
  },
  "property-map": {
    "ane:NET001": {
      "persistent-entities": [ "http-proxy:192.0.2.1" ]
    },
    "ane:L002": { "maxresbw": 48000000 },
    "ane:L003": { "maxresbw": 35000000 }
  }
}
~~~

## Example: Incremental Updates

In this example, an ALTO client subscribes to the incremental update for the
multipart endpoint cost resource `endpoint-cost-pv`.

~~~
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
~~~

Based on the server-side process defined in {{I-D.ietf-alto-incr-update-sse}}, the ALTO server will
send the `control-uri` first using Server-Sent Event (SSE), followed by the full
response of the multipart message.

~~~
HTTP/1.1 200 OK
Connection: keep-alive
Content-Type: text/event-stream

event: application/alto-updatestreamcontrol+json
data: {"control-uri": "http://alto.example.com/updates/streams/1414"}

event: multipart/related;boundary=example-3;
       type=application/alto-endpointcost+json,ecspvsub1
data: --example-3
data: Resource-ID: ecsmap
data: Content-Type: application/alto-endpointcost+json
data:
data: <endpoint-cost-map-entry>
data: --example-3
data: Resource-ID: propmap
data: Content-Type: application/alto-propmap+json
data:
data: <property-map-entry>
data: --example-3--
~~~

When the contents change, the ALTO server will publish the updates for each node
in this tree separately.

~~~
event: application/merge-patch+json, ecspvsub1.ecsmap
data: <Merge patch for endpoint-cost-map-update>

event: application/merge-patch+json, ecspvsub1.propmap
data: <Merge patch for property-map-update>
~~~

<!-- TODO: the remaining issue is where to specify the json-merge-patch capability for each node -->
