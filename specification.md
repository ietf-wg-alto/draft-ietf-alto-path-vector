# Basic Data Types {#SecPV}

## ANE Identifier {#SecAneId}

An ANE identifier is encoded as a JSON string. The string MUST be no more than
64 characters, and it MUST NOT contain characters other than US-ASCII
alphanumeric characters (U+0030-U+0039, U+0041-U+005A, and U+0061-U+007A), the
hyphen (`-`, U+002D), the colon (`:`, U+003A), the at sign (`@`, code point
U+0040), the low line (`_`, U+005F), or the `.` separator (U+002E). The `.`
separator is reserved for future use and MUST NOT be used unless specifically
indicated in this document, or an extension document.

The type ANEIdentifier is used in this document to indicate a string of this
format.

## Path Vector Cost Type {#SecCostType}

This document defines a new cost type, which is referred to as the `path vector`
cost type. An ALTO server MUST offer this cost type if it supports the path
vector extension.

### Cost Metric: ane-path{#metric-spec}

This cost metric conveys an array of ANE identifiers, where each identifier
uniquely represents an ANE traversed by traffic from a source to a destination.

### Cost Mode: array {#mode-spec}

This cost mode indicates that every cost value in a cost map or an endpoint cost
map MUST be interpreted as a JSON array object.

Note that this cost mode only requires the cost value to be a JSON array of
JSONValue. However, an ALTO server that enables this extension MUST return a
JSON array of ANEIdentifier ([](#SecAneId)) when the cost metric is "ane-path".

## ANE Domain {#SecANEDomain}

This document specifies a new ALTO entity domain called `ane` in addition to the
ones in [](#I-D.ietf-alto-unified-props-new). The ANE domain associates property
values with the ANEs in a network. The entity in ANE domain is often used in the
path vector by cost maps or endpoint cost resources. Accordingly, the ANE domain
always depends on a cost map or an endpoint cost map.

### Domain Name ##

ane

### Domain-Specific Entity Identifier ## {#entity-address}

The entity identifier of ANE domain uses the same encoding as ANEIdentifier
([](#SecAneId)).

### Hierarchy and Inheritance

There is no hierarchy or inheritance for properties associated with ANEs.

## ANE Properties {#SecANEProp}

This document defines three properties that can be associated with the ANE
domain. These properties are numerical and can be aggregated for a path vector
between a source and a destination to compute the end-to-end cost.

### ANE Property: Hop Count

The hop count property conveys the number of hops contained in an ANE and is
indicated by the property name "hopcount". The value MUST be encoded as a
numerical cost value as defined in Section 6.1.2.1 of [](#RFC7285). The
aggregated value of the hop count property for a path vector is the sum of hop
count values of all ANEs contained in the path vector.

### ANE Property: Routing Cost

The routing cost property conveys the same meaning as the cost metric
"routingcost" in Section 6.1.1 of [](#RFC7285) and is indicated by the property
name "routingcost". The value MUST be encoded as a numerical cost value as
defined in Section 6.1.2.1 of [](#RFC7285). The aggregated value of the routing
cost property for a path vector is the sum of routing cost values of all ANEs
contained in the path vector.

### ANE Property: Maximum Reservable Bandwidth

The maximum reservable bandwidth property conveys the maximum bandwidth that can
be reserved for traffic from a source to a destination and is indicated by the
property name "maxresbw". The value MUST be encoded as a numerical cost value as
defined in Section 6.1.2.1 of [](#RFC7285) and the unit is bit per second. The
aggregated value of the maximum reservable bandwidth property for a path vector
is the minimum of maximum reservable bandwidth values of all ANEs contained in
the path vector.

# Service Extensions

## Multipart Filtered Cost Map for Path Vector # {#SecMultiFCM}

This document introduces a new ALTO resource called Multipart Filtered Cost Map
resource, which allows an ALTO server to provide other ALTO resources associated
to the Cost Map resource in the same response.

### Media Type ##

The media type of the Multipart Filtered Cost Map Resource is
`multipart/related;type=application/alto-costmap+json`.

### HTTP Method ##

The Multipart Filtered Cost Map is requested using the HTTP POST method.

### Accept Input Parameters ## {#pvcm-accept}

The input parameters of the Multipart Filtered Cost Map are supplied in the body
of an HTTP POST request. This document extends the input parameters to a
filtered Cost Map with a data format indicated by the media type
`application/alto-costmapfilter+json`, which is a JSON object of type
PVReqFilteredCostMap, where:

~~~
object {
  [PropertyName ane-equiv-properties<1..*>;]
  [PropertyName ane-additional-properties<0..*>;]
} PVReqFilteredCostMap : ReqFilteredCostMap;
~~~

with fields:

ane-equiv-properties:
~ A list of properties that are used to create ANEs. If the cost type is the
path vector cost type, this field MUST exist and MUST NOT be empty. Each
property in this list MUST match one of the supported ANE properties indicated
in the resource's "ane-equiv-properties" capability. If a property appears in
this list, an ALTO server MUST guarantee the abstracted path vector provides
accurate end-to-end property values. Thus, an ALTO client CAN safely use the
aggregated property value as the end-to-end performance metric between a source
and a destination.

ane-additional-properties:
~ A list of additional properties that are attached to the ANEs. Each property
in this list MUST match one of the supported ANE properties indicated in the
resource's "ane-equiv-properties" or "ane-additional-properties" capability. If
a property ONLY appears in this list, an ALTO server MAY or MAY NOT guarantee
the equivalence of the end-to-end value in the abstract path vector and in the
real underlying network. Accordingly, an ALTO client SHOULD NOT use the
aggregated property value, if applicable, as the end-to-end performance metric
between a source and a destination, as it MAY NOT be accurate.

### Capabilities ## {#pvcm-cap}

The Multipart Filtered Cost Map resource extends the capabilities defined
in Section 11.3.2.4 of [](#RFC7285). The capabilities are defined by a JSON
object of type PVFilteredCostMapCapabilities:

~~~
object {
  [PropertyName ane-equiv-properties<1..*>;]
  [PropertyName ane-additional-properties<0..*>;]
} PVFilteredCostMapCapabilities : FilteredCostMapCapabilities;
~~~

with fields:

cost-type-names:
~ The `cost-type-names` field MUST only include the path vector cost type,
unless explicitly documented by a future extension. This also implies that the
path vector cost type MUST be defined in the `cost-types` of the Information
Resource Directory's `meta` field.

ane-equiv-properties:
~ Defines a list of ANE properties that can be used to create the ANEs. If an
ALTO resource provides the path vector service, this capability MUST exist and
MUST have at least one property. The properties MUST be aggregatable, i.e., the
property values of all ANEs in a path vector can be reduced to a single property
value using an aggregation operator.

ane-additional-properties:
~ Defines a list of additional ANE properties that can be attached to the ANEs.
If a property already exists in "ane-equiv-properties", it MAY NOT appear in
the "ane-additional-properties" field.

### Uses ##

The resource ID of the network map based on which the PIDs in the returned cost
map will be defined.

### Response ##

The response MUST indicate an error, using ALTO protocol error handling, as
defined in Section 8.5 of [](#RFC7285), if the request is invalid.

The "Content-Type" header of the response MUST be `multipart/related` as defined
by [](#RFC2387) with the following parameters:

type:
~ The type parameter MUST be "application/alto-costmap+json". Note that
[](#RFC2387) permits both parameters with and without the double quotes.

start:
~ The start parameter MUST be a quoted string where the quoted part has the same
value as the "Resource-ID" header in the first part.

boundary:
~ The boundary parameter is as defined in [](#RFC2387).

The body of the response consists of two parts.

The first part MUST include `Resource-Id` and `Content-Type` in its header. The
value of `Resource-Id` MUST be prefixed by the resource id of the Multipart
Filtered Cost Map appended by a `.` character. The `Content-Type` MUST be
`application/alto-costmap+json`.

The body of the first part MUST be a JSON object with the same format as defined
in Section 11.2.3.6 of [](#RFC7285). The JSON object MUST include the `vtag`
field in the `meta` field, which provides the version tag of the returned cost
map. The resource id of the version tag MUST be the same as the value of the
`Resource-Id` header. The `meta` field MUST also include the `dependent-vtags`
field, whose value is a single-element array to indicate the version tag of the
network map used, where the network map is specified in the `uses` attribute of
the Multipart Cost Map resource in IRD.

The second part MUST also include `Resource-Id` and `Content-Type` in its
header. The value of `Resource-Id` MUST be prefixed by the resource id of the
Multipart Filtered Cost Map appended by a `.` character. The `Content-Type` MUST
be `application/alto-propmap+json`.

The body of the second part MUST be a JSON object with the same format as
defined in Section 4.6 of [](#I-D.ietf-alto-unified-props-new), where the
`property-map` field MUST contain all properties appeared in
"ane-equiv-properties" and "ane-additional-properties", if present, for all
ANE identifiers that exists in the first part. The JSON object MUST include the
`dependent-vtags` field in the `meta` field. The value of the `dependent-vtags`
field MUST be an array with a single VersionTag object as defined by section
10.3 of [](#RFC7285). The `resource-id` of this VersionTag MUST be the value of
`Resource-Id` header of the first part. The `tag` of this VersionTag MUST be the
`tag` of `vtag` of the first part body.

<!-- TODO: Error Handling -->

## Multipart Endpoint Cost Service for Path Vector # {#SecMultiECS}

This document introduces a new ALTO resource called Multipart Endpoint Cost
resource, which allows an ALTO server to provide other ALTO resources associated
to the Endpoint Cost resource in the same response.

### Media Type ##

The media type of the Multipart Endpoint Cost Resource is
`multipart/related;type=application/alto-endpointcostmap+json`.

### HTTP Method ##

The Multipart Endpoint Cost resource is requested using the HTTP POST method.

### Accept Input Parameters ##

The input parameters of the Multipart Endpoint Cost resource are supplied in the
body of an HTTP POST request. This document extends the input parameters to an
Endpoint Cost Map with a data format indicated by the media type
`application/alto-endpointcostparams+json`, which is a JSON object of type
PVEndpointCostParams, where

~~~
object {
  [PropertyName ane-equiv-properties<1..*>;]
  [PropertyName ane-additional-properties<0..*>;]
} PVReqEndpointCostMap : ReqEndpointCostMap;
~~~

with fields:

ane-equiv-properties:
~ This document defines the `ane-equiv-properties` in PVReqEndpointCostMap as
the same as in PVReqFilteredCostMap. See [](#pvcm-accept).

ane-additional-properties:
~ This document defines the `ane-additional-properties` in PVReqEndpointCostMap
as the same as in PVReqFilteredCostMap. See [](#pvcm-accept).

### Capabilities ##

The capabilities of the Multipart Endpoint Cost Service are defined by a JSON
object of type PVEndpointCostMapCapabilities, which is defined as the same as
PVFilteredCostMapCapabilities. See [](#pvcm-cap).

### Uses ##

The Multipart Endpoint Cost resource MUST NOT specify the `uses` attribute.

### Response ##

The response MUST indicate an error, using ALTO protocol error handling, as
defined in Section 8.5 of [](#RFC7285), if the request is invalid.

The "Content-Type" header of the response MUST be `multipart/related` as defined
by [](#RFC2387) with the following parameters:

type:
~ The type parameter MUST be "application/alto-endpointcostmap+json".

start:
~ The start parameter MUST be a quoted string where the quoted part has the same
value as the "Resource-ID" header in the first part.

boundary:
~ The boundary parameter is as defined in [RFC2387].

The body consists of two parts:

The first part MUST include `Resource-Id` and `Content-Type` in its header. The
value of `Resource-Id` MUST be prefixed by the resource id of the Multipart
Endpoint Cost Service appended by a `.` character (U+002E). The `Content-Type`
MUST be `application/alto-endpointcostmap+json`.

The body of the first part MUST be a JSON object with the same format as defined
in Section 11.5.1.6 of [](#RFC7285); The JSON object MUST include the `vtag`
field in the `meta` field, which provides the version tag of the returned
endpoint cost map. The resource id of the version tag MUST be the same as the
value of the `Resource-Id` header.

The second part MUST also include `Resource-Id` and `Content-Type` in its
header. The value of `Resource-Id` MUST be prefixed by the resource id of the
Multipart Filtered Cost Map appended by a `.` character (U+002E). The
`Content-Type` MUST be `application/alto-propmap+json`.

The body of the second part MUST be a JSON object with the same format as
defined in Section 4.6 of [](#I-D.ietf-alto-unified-props-new), where the
`property-map` field MUST contain all properties appeared in
`ane-equiv-properties` and `ane-additional-properties`, if present, for all ANE
identifiers that exists in the first part. The JSON object MUST include the
`dependent-vtags` field in the `meta` field. The value of the `dependent-vtags`
field MUST be an array with a single VersionTag object as defined by section
10.3 of [](#RFC7285). The `resource-id` of this VersionTag MUST be the value of
`Resource-Id` header of the first part. The `tag` of this VersionTag MUST be the
`tag` of `vtag` of the first part body.
