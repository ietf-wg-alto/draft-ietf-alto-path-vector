# Examples {#Examples}

This section lists some examples of Path Vector queries and the corresponding
responses. Some long lines are truncated for better readability.

## Example: Information Resource Directory {#example-ird}

To give a comprehensive example of the extension defined in this document, we
consider the network in {{fig-pe}}. Assume that the ALTO server provides the
following information resources:

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
enable the extension defined in this document, the `path-vector` cost type
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
Content-Length: 153
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
Content-Length: 818
Content-Type: multipart/related; boundary=example-1;
              type=application/alto-costmap+json

--example-1
Content-ID: costmap
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
Content-ID: propmap
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
property for two source and destination pairs: 192.0.4.2 -> 192.0.2.2 and
192.0.4.2 -> 192.0.5.2.

The response consists of two parts. The first part returns the array of ANEName
for each valid source and destination pair. As one can see in {{fig-pe}}, flow
192.0.4.2 -> 192.0.2.2 traverses NET2, L1 and NET1, and flow 192.0.4.2 ->
192.0.5.2 traverses NET2, L2 and NET3.

The second part returns the requested properties of ANEs. Assume NET1, NET2 and NET3 has
sufficient bandwidth and their `max-reservable-bandwidth` values are set to a sufficiently
large number (50 Gbps in this case). On the other hand, assume there are no
prior reservation on L1 and L2, and their `max-reservable-bandwidth` values are
the corresponding link capacity (10 Gbps for L1 and 15 Gbps for L2).

Both NET1 and NET2 have a mobile edge deployed, i.e., MEC1 in NET1 and MEC2 in
NET2. Assume the ANEName for MEC1 and MEC2 are `MEC1` and `MEC2` and their
properties can be retrieved from the property map `ane-props`. Thus, the
`persistent-entity-id` property of NET1 and NET3 are `ane-props.ane:MEC1` and
`ane-props.ane:MEC2` respectively.

~~~
POST /endpointcost/pv HTTP/1.1
Host: alto.example.com
Accept: multipart/related;
        type=application/alto-endpointcost+json,
        application/alto-error+json
Content-Length: 278
Content-Type: application/alto-endpointcostparams+json

{
  "cost-type": {
    "cost-mode": "array",
    "cost-metric": "ane-path"
  },
  "endpoints": {
    "srcs": [ "ipv4:192.0.4.2" ],
    "dsts": [ "ipv4:192.0.2.2", "ipv4:192.0.5.2" ]
  },
  "ane-property-names": [
    "max-reservable-bandwidth",
    "persistent-entity-id"
  ]
}
~~~

~~~
HTTP/1.1 200 OK
Content-Length: 1305
Content-Type: multipart/related; boundary=example-2;
              type=application/alto-endpointcost+json

--example-2
Content-ID: ecs
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
    "ipv4:192.0.4.2": {
      "ipv4:192.0.2.2":   [ "NET3", "L1", "NET1" ],
      "ipv4:192.0.5.2":   [ "NET3", "L2", "NET2" ]
    }
  }
}
--example-2
Content-ID: propmap
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
      "persistent-entity-id": "ane-props.ane:MEC1"
    },
    ".ane:NET2": {
      "max-reservable-bandwidth": 50000000000,
      "persistent-entity-id": "ane-props.ane:MEC2"
    },
    ".ane:NET3": {
      "max-reservable-bandwidth": 50000000000
    },
    ".ane:L1": {
      "max-reservable-bandwidth": 10000000000
    },
    ".ane:L2": {
      "max-reservable-bandwidth": 15000000000
    }
  }
}
~~~

As mentioned in {{metric-spec}}, an advanced ALTO server may obfuscate the
response in order to preserve its own privacy or conform to its own policies.
For example, an ALTO server may choose to aggregate NET1 and L1 as a new ANE
with ANE name `AGGR1`, and aggregate NET2 and L2 as a new ANE with ANE name
`AGGR2`. The `max-reservable-bandwidth` of `AGGR1` takes the value of L1, which
is smaller than that of NET1, and the `persistent-entity-id` of `AGGR1` takes
the value of NET1. The properties of `AGGR2` are computed in a similar way and
the obfuscated response is as shown below. Note that the obfuscation of Path
Vector responses is implementation-specific and is out of the scope of this
document, and developers may refer to {{Security}} for further references.

~~~
HTTP/1.1 200 OK
Content-Length: 1157
Content-Type: multipart/related; boundary=example-2;
              type=application/alto-endpointcost+json

--example-2
Content-ID: ecs
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
    "ipv4:192.0.4.2": {
      "ipv4:192.0.2.2":   [ "NET3", "AGGR1" ],
      "ipv4:192.0.5.2":   [ "NET3", "AGGR2" ]
    }
  }
}
--example-2
Content-ID: propmap
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
    ".ane:AGGR1": {
      "max-reservable-bandwidth": 10000000000,
      "persistent-entity-id": "ane-props.ane:MEC1"
    },
    ".ane:AGGR2": {
      "max-reservable-bandwidth": 15000000000,
      "persistent-entity-id": "ane-props.ane:MEC2"
    },
    ".ane:NET3": {
      "max-reservable-bandwidth": 50000000000
    }
  }
}
~~~

## Example: Incremental Updates {#example-sse}

In this example, an ALTO client subscribes to the incremental update for the
multipart endpoint cost resource `endpoint-cost-pv`.

~~~
POST /updates/pv HTTP/1.1
Host: alto.example.com
Accept: text/event-stream
Content-Type: application/alto-updatestreamparams+json
Content-Length: 112

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
data: Content-ID: ecsmap
data: Content-Type: application/alto-endpointcost+json
data:
data: <endpoint-cost-map-entry>
data: --example-3
data: Content-ID: propmap
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
