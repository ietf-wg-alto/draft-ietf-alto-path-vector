# Specification: Service Extensions {#Services}

## Notations

This document uses the same syntax and notations as introduced in Section 8.2 of
RFC 7285 {{RFC7285}} to specify the extensions to existing ALTO resources and
services.

## Multipart Filtered Cost Map for Path Vector # {#pvcm-spec}

This document introduces a new ALTO resource called multipart filtered cost map
resource, which allows an ALTO server to provide other ALTO resources associated
to the cost map resource in the same response.

### Media Type ##

The media type of the multipart filtered cost map resource is
`multipart/related;type=application/alto-costmap+json`.

### HTTP Method ##

The multipart filtered cost map is requested using the HTTP POST method.

### Accept Input Parameters ## {#pvcm-accept}

The input parameters of the multipart filtered cost map are supplied in the body
of an HTTP POST request. This document extends the input parameters to a
filtered cost map, which is defined as a JSON object of type
`ReqFilteredCostMap` in Section 11.3.2.3 of RFC 7285 {{RFC7285}}, with a data
format indicated by the media type `application/alto-costmapfilter+json`, which
is a JSON object of type PVReqFilteredCostMap, where:

~~~
object {
  [EntityPropertyName ane-property-names<0..*>;]
} PVReqFilteredCostMap : ReqFilteredCostMap;
~~~

with fields:

ane-property-names:
: A list of selected ANE properties to be included in the response. Each
  property in this list MUST match one of the supported ANE properties indicated
  in the resource's `ane-property-names` capability (See {{pvcm-cap}}). If the
  field is NOT present, it MUST be interpreted as an empty list.

Example: Consider the network in {{fig-dumbbell}}. If an ALTO client wants to
query the `max-reservable-bandwidth` between PID1 and PID2, it can submit the
following request.

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
       "dsts": [ "PID2" ]
     },
     "ane-property-names": [ "max-reservable-bandwidth" ]
   }
~~~

### Capabilities ## {#pvcm-cap}

The multipart filtered cost map resource extends the capabilities defined
in Section 11.3.2.4 of {{RFC7285}}. The capabilities are defined by a JSON
object of type PVFilteredCostMapCapabilities:

~~~
object {
  [EntityPropertyName ane-property-names<0..*>;]
} PVFilteredCostMapCapabilities : FilteredCostMapCapabilities;
~~~

with fields:

cost-type-names:
: The `cost-type-names` field MUST only include the Path Vector cost type,
  unless explicitly documented by a future extension. This also implies that the
  Path Vector cost type MUST be defined in the `cost-types` of the Information
  Resource Directory's `meta` field.

cost-constraints:
: If the `cost-type-names` field includes the Path Vector cost type,
  `cost-constraints` field MUST be `false` or not present unless specifically
  instructed by a future document.

testable-cost-type-names:
: If the `cost-type-names` field includes the Path Vector cost type, the Path
  Vector cost type MUST NOT be included in the `testable-cost-type-names` field
  unless specifically instructed by a future document.

ane-property-names:
: Defines a list of ANE properties that can be returned. If the field is NOT
  present, it MUST be interpreted as an empty list, indicating the ALTO server
  cannot provide any ANE property.

### Uses ##

This member MUST include the resource ID of the network map based on which the
PIDs are defined. If this resource supports `persistent-entity-id`, it MUST also
include the defining resources of persistent ANEs that may appear in the response.

### Response ## {#pvcm-resp}

The response MUST indicate an error, using ALTO protocol error handling, as
defined in Section 8.5 of {{RFC7285}}, if the request is invalid.

The "Content-Type" header of the response MUST be `multipart/related` as defined
by {{RFC2387}} with the following parameters:

type:
: The type parameter MUST be "application/alto-costmap+json". Note that
  {{RFC2387}} permits both parameters with and without the double quotes.

start:
: The start parameter is as defined in {{RFC2387}}. If present, it MUST have the
  same value as the `Content-ID` header of the Path Vector part.

boundary:
: The boundary parameter is as defined in {{RFC2387}}.

The body of the response MUST consist of two parts:

- The Path Vector part MUST include `Content-ID` and `Content-Type` in its
  header. The value of `Content-ID` MUST has the format of a Part Resource ID.
  The `Content-Type` MUST be `application/alto-costmap+json`.

  The body of the Path Vector part MUST be a JSON object with the same format as
  defined in Section 11.2.3.6 of {{RFC7285}}. The JSON object MUST include the
  `vtag` field in the `meta` field, which provides the version tag of the
  returned cost map. The resource ID of the version tag MUST follow the format of
  ~~~
  resource-id '.' part-resource-id
  ~~~
  where `resource-id` is the resource Id of the Path Vector resource, and
  `part-resource-id` has the same value as the `Content-ID` of the Path Vector
  part.
  The `meta` field MUST also include the `dependent-vtags` field, whose value is
  a single-element array to indicate the version tag of the network map used,
  where the network map is specified in the `uses` attribute of the multipart
  filtered cost map resource in IRD.

- The Unified Property Map part MUST also include `Content-ID` and
  `Content-Type` in its header. The value of `Content-ID` has the format of a
  Part Resource ID. The `Content-Type` MUST be `application/alto-propmap+json`.

  The body of the Unified Property Map part is a JSON object with the same
  format as defined in Section 4.6 of {{I-D.ietf-alto-unified-props-new}}. The
  JSON object MUST include the `dependent-vtags` field in the `meta` field. The
  value of the `dependent-vtags` field MUST be an array of VersionTag objects as
  defined by Section 10.3 of {{RFC7285}}. The `vtag` of the Path Vector part MUST
  be included in the `dependent-vtags`. If `persistent-entity-id` is requested, the
  version tags of the dependent resources that MAY expose the entities in the
  response MUST also be included.

  The PropertyMapData has one member for each ANEName that appears in the Path
  Vector part, which is an entity identifier belonging to the self-defined
  entity domain as defined in Section 5.1.2.3 of
  {{I-D.ietf-alto-unified-props-new}}. The EntityProps for each ANE has one
  member for each property that is both 1) associated with the ANE, and 2)
  specified in the `ane-property-names` in the request.

A complete and valid response MUST include both the Path Vector part and the
Property Map part in the multipart message. If any part is NOT present, the
client MUST discard the received information and send another request if
necessary.

According to {{RFC2387}}, the Path Vector part, whose media type is
the same as the `type` parameter of the multipart response message, is the root
object. Thus, it is the element the application processes first. Even though the
`start` parameter allows it to be placed anywhere in the part sequence, it is
RECOMMENDED that the parts arrive in the same order as they are processed, i.e.,
the Path Vector part is always put as the first part, followed by the Property
Map part. When doing so, an ALTO server MAY NOT set the `start` parameter, which
implies the first part is the root object.

Example: Consider the network in {{fig-dumbbell}}. The response of the example
request in {{pvcm-accept}} is as follows, where `ANE1` represents the
aggregation of all the switches in the network.

~~~
HTTP/1.1 200 OK
Content-Length: [TBD]
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
    "cost-type": { "cost-mode": "array", "cost-metric": "ane-path" }
  },
  "cost-map": {
    "PID1": { "PID2": ["ANE1"] }
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
    ".ane:ANE1": { "max-reservable-bandwidth": 100000000 }
  }
}
~~~

<!-- TODO: Error Handling -->

## Multipart Endpoint Cost Service for Path Vector # {#pvecs-spec}

This document introduces a new ALTO resource called multipart endpoint cost
resource, which allows an ALTO server to provide other ALTO resources associated
to the endpoint cost resource in the same response.

### Media Type ##

The media type of the multipart endpoint cost resource is
`multipart/related;type=application/alto-endpointcost+json`.

### HTTP Method ##

The multipart endpoint cost resource is requested using the HTTP POST method.

### Accept Input Parameters ## {#pvecs-accept}

The input parameters of the multipart endpoint cost resource are supplied in the
body of an HTTP POST request. This document extends the input parameters to an
endpoint cost map, which is defined as a JSON object of type ReqEndpointCost in
Section 11.5.1.3 in RFC 7285 {{RFC7285}}, with a data format indicated by the
media type `application/alto-endpointcostparams+json`, which is a JSON object of
type PVEndpointCostParams, where

~~~
object {
  [EntityPropertyName ane-property-names<0..*>;]
} PVReqEndpointcost : ReqEndpointcost;
~~~

with fields:

ane-property-names:
: This document defines the `ane-property-names` in PVReqEndpointcost as the
  same as in PVReqFilteredCostMap. See {{pvcm-accept}}.

Example: Consider the network in {{fig-dumbbell}}. If an ALTO client wants to
query the `max-reservable-bandwidth` between eh1 and eh2, it can submit the
following request.

~~~
POST /ecs/pv HTTP/1.1
Host: alto.example.com
Accept: multipart/related;type=application/alto-endpointcost+json,
        application/alto-error+json
Content-Length: [TBD]
Content-Type: application/alto-endpointcostparams+json

{
  "cost-type": {
    "cost-mode": "array",
    "cost-metric": "ane-path"
  },
  "endpoints": {
    "srcs": [ "ipv4:1.2.3.4" ],
    "dsts": [ "ipv4:2.3.4.5" ]
  },
  "ane-property-names": [ "max-reservable-bandwidth" ]
}
~~~

### Capabilities {#pvecs-cap}

The capabilities of the multipart endpoint cost resource are defined by a JSON
object of type PVEndpointcostCapabilities, which is defined as the same as
PVFilteredCostMapCapabilities. See {{pvcm-cap}}.

### Uses

If this resource supports `persistent-entity-id`, it MUST also include the
defining resources of persistent ANEs that may appear in the response.

### Response {#pvecs-resp}

The response MUST indicate an error, using ALTO protocol error handling, as
defined in Section 8.5 of {{RFC7285}}, if the request is invalid.

The "Content-Type" header of the response MUST be `multipart/related` as defined
by {{RFC7285}} with the following parameters:

type:
: The type parameter MUST be "application/alto-endpointcost+json".

start:
: The start parameter is as defined in {{pvcm-resp}}.

boundary:
: The boundary parameter is as defined in {{RFC2387}}.

The body MUST consist of two parts:

- The Path Vector part MUST include `Content-ID` and `Content-Type` in its
  header. The value of `Content-ID` MUST has the format of a Part Resource ID.
  The `Content-Type` MUST be `application/alto-endpointcost+json`.

  The body of the Path Vector part MUST be a JSON object with the same format as
  defined in Section 11.5.1.6 of {{RFC7285}}. The JSON object MUST include the
  `vtag` field in the `meta` field, which provides the version tag of the returned
  endpoint cost map. The resource ID of the version tag MUST follow the format of
  ~~~
  resource-id '.' part-resource-id
  ~~~
  where `resource-id` is the resource Id of the Path Vector resource, and
  `part-resource-id` has the same value as the `Content-ID` of the Path Vector
  part.

- The Unified Property Map part MUST also include `Content-ID` and
  `Content-Type` in its header. The value of `Content-ID` MUST has the format
  of a Part Resource ID. The `Content-Type` MUST be
  `application/alto-propmap+json`.

  The body of the Unified Property Map part MUST be a JSON object with the same
  format as defined in Section 4.6 of {{I-D.ietf-alto-unified-props-new}}. The
  JSON object MUST include the `dependent-vtags` field in the `meta` field. The
  value of the `dependent-vtags` field MUST be an array of VersionTag objects as
  defined by Section 10.3 of {{RFC7285}}. The `vtag` of the Path Vector part MUST
  be included in the `dependent-vtags`. If `persistent-entity-id` is requested, the
  version tags of the dependent resources that MAY expose the entities in the
  response MUST also be included.

  The PropertyMapData has one member for each ANEName that appears in the Path
  Vector part, which is an entity identifier belonging to the self-defined
  entity domain as defined in Section 5.1.2.3 of
  {{I-D.ietf-alto-unified-props-new}}. The EntityProps for each ANE has one
  member for each property that is both 1) associated with the ANE, and 2)
  specified in the `ane-property-names` in the request.

A complete and valid response MUST include both the Path Vector part and the
Property Map part in the multipart message. If any part is NOT present, the
client MUST discard the received information and send another request if
necessary.

According to {{RFC2387}}, the Path Vector part, whose media type is
the same as the `type` parameter of the multipart response message, is the root
object. Thus, it is the element the application processes first. Even though the
`start` parameter allows it to be placed anywhere in the part sequence, it is
RECOMMENDED that the parts arrive in the same order as they are processed, i.e.,
the Path Vector part is always put as the first part, followed by the Property
Map part. When doing so, an ALTO server MAY NOT set the `start` parameter, which
implies the first part is the root object.

Example: Consider the network in {{fig-dumbbell}}. The response of the example
request in {{pvecs-accept}} is as follows.

~~~
HTTP/1.1 200 OK
Content-Length: [TBD]
Content-Type: multipart/related; boundary=example-1;
              type=application/alto-endpointcost+json

--example-1
Content-ID: ecs
Content-Type: application/alto-endpointcost+json

{
  "meta": {
    "vtag": {
      "resource-id": "ecs-pv.costmap",
      "tag": "d827f484cb66ce6df6b5077cb8562b0a"
    },
    "dependent-vtags": [
      {
        "resource-id": "my-default-networkmap",
        "tag": "75ed013b3cb58f896e839582504f6228"
      }
    ],
    "cost-type": { "cost-mode": "array", "cost-metric": "ane-path" }
  },
  "cost-map": {
    "ipv4:1.2.3.4": { "ipv4:2.3.4.5": ["ANE1"] }
  }
}
--example-1
Content-ID: propmap
Content-Type: application/alto-propmap+json

{
  "meta": {
    "dependent-vtags": [
      {
        "resource-id": "ecs-pv.costmap",
        "tag": "d827f484cb66ce6df6b5077cb8562b0a"
      }
    ]
  },
  "property-map": {
    ".ane:ANE1": { "max-reservable-bandwidth": 100000000 }
  }
}
~~~
