# Service Extensions {#Services}

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
filtered cost map with a data format indicated by the media type
`application/alto-costmapfilter+json`, which is a JSON object of type
PVReqFilteredCostMap, where:

~~~
object {
  [EntityPropertyName ane-property-names<0..*>;]
} PVReqFilteredCostMap : ReqFilteredCostMap;
~~~

with fields:

ane-property-names:
: A list of properties that are associated with the ANEs. Each property in this
  list MUST match one of the supported ANE properties indicated in the
  resource's `ane-property-names` capability. If the field is NOT present, it
  MUST be interpreted as an empty list, indicating that the ALTO server MUST NOT
  return any property in the unified property part.

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
  CANNOT provide any ANE property.

### Uses ##

The resource ID of the network map based on which the PIDs in the returned cost
map will be defined. If this resource supports `persistent-entities`, it MUST
also include ALL the resources that exposes the entities that MAY appear in the
response.

### Response ##

The response MUST indicate an error, using ALTO protocol error handling, as
defined in Section 8.5 of {{RFC7285}}, if the request is invalid.

The "Content-Type" header of the response MUST be `multipart/related` as defined
by {{RFC2387}} with the following parameters:

type:
: The type parameter MUST be "application/alto-costmap+json". Note that
  {{RFC2387}} permits both parameters with and without the double quotes.

start:
: The start parameter MUST be a quoted string where the quoted part has the same
  value as the "Resource-ID" header in the first part.

boundary:
: The boundary parameter is as defined in {{RFC2387}}.

The body of the response consists of two parts.

The first part MUST include `Resource-Id` and `Content-Type` in its header. The
value of `Resource-Id` MUST has the format of a Part Resource ID. The
`Content-Type` MUST be `application/alto-costmap+json`.

The body of the first part MUST be a JSON object with the same format as defined
in Section 11.2.3.6 of {{RFC7285}}. The JSON object MUST include the `vtag`
field in the `meta` field, which provides the version tag of the returned cost
map. The resource ID of the version tag MUST follow the format
in {{ref-partmsg-design}}. The `meta` field MUST also include the `dependent-vtags`
field, whose value is a single-element array to indicate the version tag of the
network map used, where the network map is specified in the `uses` attribute of
the multipart filtered cost map resource in IRD.

The second part MUST also include `Resource-Id` and `Content-Type` in its
header. The value of `Resource-Id` has the format of a Part Resource ID. The
`Content-Type` MUST be `application/alto-propmap+json`.

The body of the second part MUST be a JSON object with the same format as
defined in Section 4.6 of {{I-D.ietf-alto-unified-props-new}}. The JSON object
MUST include the `dependent-vtags` field in the `meta` field. The value of the
`dependent-vtags` field MUST be an array of VersionTag objects as defined by
Section 10.3 of {{RFC7285}}. The `vtag` of the first part MUST be included in
the `dependent-vtags`. If `persistent-entities` is requested, the version tags
of the dependent resources that MAY expose the entities in the response MUST
also be included. The PropertyMapData has one member for each ANEName that
appears in the first part, where the EntityProps has one member for each
property requested by the client if applicable.

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

### Accept Input Parameters ##

The input parameters of the multipart endpoint cost resource are supplied in the
body of an HTTP POST request. This document extends the input parameters to an
endpoint cost map with a data format indicated by the media type
`application/alto-endpointcostparams+json`, which is a JSON object of type
PVEndpointCostParams, where

~~~
object {
  [EntityPropertyName ane-property-names<0..*>;]
} PVReqEndpointcost : ReqEndpointcost;
~~~

with fields:

ane-property-names:
: This document defines the `ane-property-names` in PVReqEndpointcost as the
  same as in PVReqFilteredCostMap. See {{pvcm-accept}}.

### Capabilities ##

The capabilities of the multipart endpoint cost resource are defined by a JSON
object of type PVEndpointcostCapabilities, which is defined as the same as
PVFilteredCostMapCapabilities. See {{pvcm-cap}}.

### Uses ##

If a multipart endpoint cost resource supports `persistent-entities`, the `uses`
field in its IRD entry MUST include ALL the resources which exposes the entities
that MAY appear in the response.

### Response ##

The response MUST indicate an error, using ALTO protocol error handling, as
defined in Section 8.5 of {{RFC7285}}, if the request is invalid.

The "Content-Type" header of the response MUST be `multipart/related` as defined
by {{RFC7285}} with the following parameters:

type:
: The type parameter MUST be "application/alto-endpointcost+json".

start:
: The start parameter MUST be a quoted string where the quoted part has the same
  value as the "Resource-ID" header in the first part.

boundary:
: The boundary parameter is as defined in [RFC2387].

The body consists of two parts:

The first part MUST include `Resource-Id` and `Content-Type` in its header. The
value of `Resource-Id` MUST has the format of a Part Resource ID. The
`Content-Type` MUST be `application/alto-endpointcost+json`.

The body of the first part MUST be a JSON object with the same format as defined
in Section 11.5.1.6 of {{RFC7285}}. The JSON object MUST include the `vtag`
field in the `meta` field, which provides the version tag of the returned
endpoint cost map. The resource ID of the version tag MUST follow the format
in {{ref-partmsg-design}}.

The second part MUST also include `Resource-Id` and `Content-Type` in its
header. The value of `Resource-Id` MUST has the format of a Part Resource ID.
The `Content-Type` MUST be `application/alto-propmap+json`.

The body of the second part MUST be a JSON object with the same format as
defined in Section 4.6 of {{I-D.ietf-alto-unified-props-new}}. The JSON object
MUST include the `dependent-vtags` field in the `meta` field. The value of the
`dependent-vtags` field MUST be an array of VersionTag objects as defined by
Section 10.3 of {{RFC7285}}. The `vtag` of the first part MUST be included in
the `dependent-vtags`. If `persistent-entities` is requested, the version tags
of the dependent resources that MAY expose the entities in the response MUST
also be included. The PropertyMapData has one member for each ANEName that
appears in the first part, where the EntityProps has one member for each
property requested by the client if applicable.
