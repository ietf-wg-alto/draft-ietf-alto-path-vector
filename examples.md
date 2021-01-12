# Examples {#Examples}

This section lists some examples of Path Vector queries and the corresponding
responses. Some long lines are truncated for better readability.

## Example: Information Resource Directory {#example-ird}

To give a comprehensive example of the Path Vector extension, we consider the
network in {{fig-pe}}. The example ALTO server provides the following
information resources:

- `my-default-networkmap`: A Network Map resource which contains the PIDs in the
  network.

- `filtered-cost-map-pv`: A Multipart Filtered Cost Map resource for Path Vector,
  which exposes the `max-reservable-bandwidth` property for the PIDs in
  `my-default-networkmap`.

- `ane-props`: A filtered Unified Property resource that exposes the
  information for persistent ANEs in the network.

- `endpoint-cost-pv`: A Multipart Endpoint Cost Service for Path Vector, which
  exposes the `max-reservable-bandwidth` and the `persistent-entity-id` properties.

- `update-pv`: An Update Stream service, which provides the incremental update
  service for the `endpoint-cost-pv` service.

Below is the Information Resource Directory of the example ALTO server. To
enable the Path Vector extension, the `path-vector` cost type
({{cost-type-spec}}) is defined in the `cost-types` of the `meta` field, and is
included in the `cost-type-names` of resources `filetered-cost-map-pv` and
`endpoint-cost-pv`.

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
      "uri" : "https://alto.example.com/networkmap",
      "media-type" : "application/alto-networkmap+json"
    },
    "filtered-cost-map-pv": {
      "uri": "https://alto.example.com/costmap/pv",
      "media-type": "multipart/related;
                     type=application/alto-costmap+json",
      "accepts": "application/alto-costmapfilter+json",
      "capabilities": {
        "cost-type-names": [ "path-vector" ],
        "ane-property-names": [ "max-reservable-bandwidth" ]
      },
      "uses": [ "my-default-networkmap" ]
    },
    "ane-props": {
      "uri": "https://alto.example.com/ane-props",
      "media-type": "application/alto-propmap+json",
      "accepts": "application/alto-propmapparams+json",
      "capabilities": {
        "mappings": {
          ".ane": [ "cpu" ]
        }
      }
    },
    "endpoint-cost-pv": {
      "uri": "https://alto.exmaple.com/endpointcost/pv",
      "media-type": "multipart/related;
                     type=application/alto-endpointcost+json",
      "accepts": "application/alto-endpointcostparams+json",
      "capabilities": {
        "cost-type-names": [ "path-vector" ],
        "ane-property-names": [
          "max-reservable-bandwidth", "persistent-entity-id"
        ]
      },
      "uses": [ "ane-props" ]
    },
    "update-pv": {
      "uri": "https://alto.example.com/updates/pv",
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

## Example: Multipart Filtered Cost Map

The following examples demonstrate the request to the `filtered-cost-map-pv`
resource and the corresponding response.

The request uses the "path-vector" cost type in the `cost-type` field. The
`ane-property-names` field is missing, indicating that the client only requests
for the Path Vector but not the ANE properties.

The response consists of two parts. The first part returns the array of ANEName
for each source and destination pair. There are two ANEs, where `L1` represents
the interconnection link L1, and `L2` represents the interconnection link L2.

The second part returns an empty Property Map. Note that the ANE entries are
omitted since they have no properties (See Section 3.1 of
{{I-D.ietf-alto-unified-props-new}}).

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
    "dsts": [ "PID3", "PID4" ]
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
      "resource-id": "filtered-cost-map-pv.costmap",
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
      "PID3": [ "L1" ],
      "PID4": [ "L1", "L2" ]
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
        "resource-id": "filtered-cost-map-pv.costmap",
        "tag": "d827f484cb66ce6df6b5077cb8562b0a"
      }
    ]
  },
  "property-map": {
  }
}
~~~

## Example: Multipart Endpoint Cost Resource

The following examples demonstrate the request to the `endpoint-cost-pv`
resource and the corresponding response.

The request uses the path vector cost type in the `cost-type` field, and
queries the Maximum Reservable Bandwidth ANE property and the Persistent Entity
property.

The response consists of two parts. The first part returns the array of ANEName
for each valid source and destination pair, where `NET1` represent sub-network
NET1, and `AGGR` is the aggregation of L1 and NET3.

The second part returns the requested properties of ANEs. Since NET1 has
sufficient bandwidth, it sets the `max-reservable-bandwidth` to a sufficiently
large number. It also represents a persistent ANE defined in the `ane-props`
resource, identified by `ane-props.ane:datacenter1`. The aggregated
`max-reservable-bandwidth` of ane:AGGR is constrained by the link capacity of
L1. The `persistent-entity-id` property is omitted as both L1 and NET3 do not
represent any persistent entity.

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
    "srcs": [ "ipv4:192.0.2.2", "ipv4:198.51.100.2" ],
    "dsts": [ "ipv4:203.0.113.2" ]
  },
  "ane-property-names": [
    "max-reservable-bandwidth",
    "persistent-entity-id"
  ]
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
      "ipv4:203.0.113.2":   [ "NET1", "AGGR" ]
    },
    "ipv4:198.51.100.2": {
      "ipv4:203.0.113.2":   [ "NET1", "AGGR" ]
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
        "resource-id": "ane-props",
        "tag": "bf3c8c1819d2421c9a95a9d02af557a3"
      }
    ]
  },
  "property-map": {
    ".ane:NET1": {
      "max-reservable-bandwidth": 50000000000,
      "persistent-entity-id": "ane-props.ane:datacenter1",
    },
    ".ane:AGGR": {
      "max-reservable-bandwidth": 10000000000
    }
  }
}
~~~

After the client obtains `ane-props.ane:datacenter1`, it can query the
`ane-props` resource to get the properties of the persistent ANE.

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

Based on the server-side process defined in {{RFC8895}}, the ALTO server will
send the `control-uri` first using Server-Sent Event (SSE), followed by the full
response of the multipart message.

~~~
HTTP/1.1 200 OK
Connection: keep-alive
Content-Type: text/event-stream

event: application/alto-updatestreamcontrol+json
data: {"control-uri": "https://alto.example.com/updates/streams/123"}

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
