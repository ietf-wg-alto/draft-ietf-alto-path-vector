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

### ANE Property: Maximum Reservable Bandwidth {#maxresbw}

The maximum reservable bandwidth property conveys the maximum bandwidth that can
be reserved for traffic from a source to a destination and is indicated by the
property name "maxresbw". The value MUST be encoded as a numerical cost value as
defined in Section 6.1.2.1 of [](#RFC7285) and the unit is bit per second.

If this property is requested but is missing for a given ANE, it MUST be
interpreted as that the ANE does not support bandwidth reservation but have
sufficiently large bandwidth for all traffic that traverses it.

### ANE Property: Persistent Entity

The persistent entity property conveys the physical or logical network entities
(e.g., links, in-network caching service) that are contained by an abstract
network element. It is indicated by the property name `persistent-entity`. The
value is encoded as a JSON array of entity identifiers
([](#I-D.ietf-alto-unified-props-new)). These entity identifiers are persistent
so that a client CAN further query their properties for future use.

If this property is requested but is missing for a given ANE, it MUST be
interpreted as that no such entities exist in this ANE.

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
  [PropertyName ane-properties<0..*>;]
} PVReqFilteredCostMap : ReqFilteredCostMap;
~~~

with fields:

ane-properties:
~ A list of properties that are associated with the ANEs. Each property in this
list MUST match one of the supported ANE properties indicated in the resource's
`ane-properties` capability. If the field is NOT present, it MUST be interpreted
as an empty list, indicating that the ALTO server MUST NOT return any property
in the unified property part.

### Capabilities ## {#pvcm-cap}

The Multipart Filtered Cost Map resource extends the capabilities defined
in Section 11.3.2.4 of [](#RFC7285). The capabilities are defined by a JSON
object of type PVFilteredCostMapCapabilities:

~~~
object {
  [PropertyName ane-properties<0..*>;]
} PVFilteredCostMapCapabilities : FilteredCostMapCapabilities;
~~~

with fields:

cost-type-names:
~ The `cost-type-names` field MUST only include the path vector cost type,
unless explicitly documented by a future extension. This also implies that the
path vector cost type MUST be defined in the `cost-types` of the Information
Resource Directory's `meta` field.

ane-properties:
~ Defines a list of ANE properties that can be returned. If the field is NOT
present, it MUST be interpreted as an empty list, indicating the ALTO server
CANNOT provide any ANE property.

### Uses ##

The resource ID of the network map based on which the PIDs in the returned cost
map will be defined. If this resource supports `persistent-entities`, it MUST
also include ALL the resources that exposes the entities that MAY appear in the
response.

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
defined in Section 4.6 of [](#I-D.ietf-alto-unified-props-new). The JSON object
MUST include the `dependent-vtags` field in the `meta` field. The value of the
`dependent-vtags` field MUST be an array of VersionTag objects as defined by
Section 10.3 of [](#RFC7285). The `vtag` of the first part MUST be included in
the `dependent-vtags`. If `persistent-entities` is requested, the version tags
of the dependent resources that MAY expose the entities in the response MUST
also be included. The PropertyMapData has one member for each ANE identifier
that appears in the first part, where the EntityProps has one member for each
property requested by the client if applicable.

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
  [PropertyName ane-properties<0..*>;]
} PVReqEndpointCostMap : ReqEndpointCostMap;
~~~

with fields:

ane-properties:
~ This document defines the `ane-properties` in PVReqEndpointCostMap as
the same as in PVReqFilteredCostMap. See [](#pvcm-accept).

### Capabilities ##

The capabilities of the Multipart Endpoint Cost Service are defined by a JSON
object of type PVEndpointCostMapCapabilities, which is defined as the same as
PVFilteredCostMapCapabilities. See [](#pvcm-cap).

### Uses ##

If a Multipart Endpoint Cost resource supports `persistent-entities`, the `uses`
field in its IRD entry MUST include ALL the resources which exposes the entities
that MAY appear in the response.

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
defined in Section 4.6 of [](#I-D.ietf-alto-unified-props-new). The JSON object
MUST include the `dependent-vtags` field in the `meta` field. The value of the
`dependent-vtags` field MUST be an array of VersionTag objects as defined by
Section 10.3 of [](#RFC7285). The `vtag` of the first part MUST be included in
the `dependent-vtags`. If `persistent-entities` is requested, the version tags
of the dependent resources that MAY expose the entities in the response MUST
also be included. The PropertyMapData has one member for each ANE identifier
that appears in the first part, where the EntityProps has one member for each
property requested by the client if applicable.
