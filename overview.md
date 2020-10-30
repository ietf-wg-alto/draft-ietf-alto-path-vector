# Path Vector Extension: Overview {#Overview}

This section gives a non-normative overview of the Path Vector extension. It is
assumed that readers are familiar with both the base protocol {{RFC7285}} and
the Unified Property Map extension {{I-D.ietf-alto-unified-props-new}}.

To satisfies the additional requirements, this extension:

1. introduces Abstract Network Element (ANE) as the abstraction of components in
   a network whose properties may have an impact on the end-to-end performance
   of the traffic handled by those component,

2. extends the Cost Map and Endpoint Cost Service to convey the ANEs traversed
   by the path of a <source, destination> pair as Path Vectors,

3. uses the Unified Property Map to convey the association between the
   ANEs and their properties.

Thus, an ALTO client can learn about the ANEs that are critical to the QoE of a
<source, destination> pair by investigating the corresponding Path Vector value
(AR1), identify common ANEs if an ANE appears in the Path Vectors of multiple
<source, destination> pairs (AR2), and retrieve the properties of the ANEs by
searching the Unified Property Map (AR3).

## Abstract Network Element {#ane-design}

This extension introduces Abstract Network Element (ANE) as an indirect and
network-agnostic way to specify a component or an aggregation of components of a
network whose properties have an impact on the end-to-end performance for
traffic between a source and a destination.

When an ANE is defined by the ALTO server, it MUST be assigned an identifier,
i.e., string of type ANEName as specified in {{ane-name-spec}}, and a set of
associated properties.

### ANE Domain

In this extension, the associations between ANE and the properties are conveyed
in a Unified Property Map. Thus, they must follow the mechanisms specified in
the {{I-D.ietf-alto-unified-props-new}}.

Specifically, this document defines a new entity domain called `ane` as
specified in {{ane-domain-spec}} and defines two initial properties for the `ane`
domain.

### Ephemeral ANE and Persistent ANE {#assoc}

For different requests, there can be different ways of grouping components of a
network and assigning ANEs. For example, an ALTO server may define an ANE for
each aggregated bottleneck link between the sources and destinations specified
in the request. As the aggregated bottleneck links vary for different
combinations of sources and destinations, the ANEs are ephemeral and are no
longer valid after the request completes. Thus, the scope of ephemeral ANEs are
limited to the corresponding Path Vector response.

While ephemeral ANEs returned by a Path Vector response do not exist beyond that
response, some of them may represent entities that are persistent and defined in
a standalone Property Map. Indeed, it may be useful for clients to occasionally
query properties on persistent entities, without caring about the path that
traverses them. Persistent entities have a persistent ID that is registered in a
Property Map, together with their properties.

### Property Filtering

Resource-constrained ALTO clients may benefit from the filtering of Path Vector
query results at the ALTO server, as an ALTO client may only require a subset of
the available properties.

Specifically, the available properties for a given resource are announced in the
Information Resource Directory as a new capability called `ane-property-names`.
The selected properties are specified in a filter called `ane-property-names` in
the request body, and the response MUST only return the selected properties for
the ANEs in the response.

The `ane-property-names` capability for Cost Map and for Endpoint Cost Service
are specified in {{pvcm-cap}} and {{pvecs-cap}} respectively. The
`ane-property-names` filter for Cost Map and Endpoint Cost Service are specified
in {{pvcm-accept}} and {{pvecs-accept}} accordingly.

## Path Vector Cost Type {#path-vector-design}

For an ALTO client to correctly interpret the Path Vector, this extension
specifies a new cost type called the Path Vector cost type, which must be
included both in the Information Resource Directory and the ALTO Cost Map or
Endpoint Cost Map so that an ALTO client can correctly interpret the cost values.

The Path Vector cost type must convey both the interpretation and semantics in
the "cost-mode" and "cost-metric" respectively. Unfortunately, a single
"cost-mode" value cannot fully specify the interpretation of a Path Vector,
which is a compound data type. For example, in programming languages such as
Java, a Path Vector will have the type of JSONArray[ANEName].

Instead of extending the "type system" of ALTO, this document takes a simple
and backward compatible approach. Specifically, the "cost-mode" of the Path
Vector cost type is "array", which indicates the value is a JSON array. Then, an
ALTO client must check the value of the "cost-metric". If the value is
"ane-path", meaning the JSON array should be further interpreted as a path of
ANENames.

The Path Vector cost type is specified in {{cost-type-spec}}.

## Multipart Path Vector Response

For a basic ALTO information resource, a response contains only one type of
ALTO resources, e.g., Network Map, Cost Map, or Property Map. Thus, only one
round of communication is required: An ALTO client sends a request to an ALTO
server, and the ALTO server returns a response, as shown in {{fig-alto}}.

~~~~~~~~~~ drawing
  ALTO client                              ALTO server
       |-------------- Request ---------------->|
       |<------------- Response ----------------|
~~~~~~~~~~
{: #fig-alto artwork-align="center" title="A Typical ALTO Request and Response"}

The Path Vector extension, on the other hand, involves two types of information
resources: Path Vectors conveyed in a Cost Map or an Endpoint Cost Map, and ANE
properties conveyed in a Unified Property Map. Instead of two consecutive
message exchanges, the Path Vector extension enforces one round of
communication. Specifically, the ALTO client must include the source and
destination pairs and the requested ANE properties in a single request, and the
ALTO server must encapsulate both Path Vectors and properties associated with
the ANEs in a single response, as shown in {{fig-pv}}. Since the two parts are
bundled together in one response message, their orders are interchangeable. See
{{pvcm-resp}} and {{pvecs-resp}} for details.


~~~~~~~~~~ drawing
  ALTO client                              ALTO server
       |------------- PV Request -------------->|
       |<----- PV Response (Cost Map Part) -----|
       |<--- PV Response (Property Map Part) ---|
~~~~~~~~~~
{: #fig-pv artwork-align="center" title="The Path Vector Extension Request and Response"}

This design is based on the following considerations:

1. Since ANEs may be constructed on demand, and potentially based on the
   requested properties (See {{ane-design}} for more details). If sources and
   destinations are not in the same request as the properties, an ALTO server
   either cannot construct ANEs on-demand, or must wait until both requests are
   received.

2. As ANEs may be constructed on demand, mappings of each ANE to its underlying
   network devices and resources can be specific to the request. In order
   to respond to the Property Map request correctly, an ALTO server must store
   the mapping of each Path Vector request until the client fully retrieves the
   property information. The "stateful" behavior may substantially harm the
   server scalability and potentially lead to Denial-of-Service attacks.

One approach to realize the one-round communication is to define a new media
type to contain both objects, but this violates modular design. This document
follows the standard-conforming usage of `multipart/related` media type defined
in {{RFC2387}} to elegantly combine the objects. Path Vectors are encoded as a
Cost Map or an Endpoint Cost Map, and the Property Map is encoded as a Unified
Propert Map. They are encapsulated as parts of a multipart message. The modular
composition allows ALTO servers and clients to reuse the data models of the
existing information resources. Specifically, this document addresses the
following practical issues using `multipart/related`.

### Identifying the Media Type of the Root Object

ALTO uses media type to indicate the type of an entry in the Information
Resource Directory (IRD) (e.g., `application/alto-costmap+json` for Cost Map
and `application/alto-endpointcost+json` for Endpoint Cost Map). Simply
putting `multipart/related` as the media type, however, makes it impossible
for an ALTO client to identify the type of service provided by related
entries.

To address this issue, this document uses the `type` parameter to indicate the
root object of a multipart/related message. For a Cost Map resource, the
`media-type` in the IRD entry must be `multipart/related` with the parameter
`type=application/alto-costmap+json`; for an Endpoint Cost Service, the
parameter must be `type=application/alto-endpointcost+json`.

### References to Part Messages {#ref-partmsg-design}

The ALTO SSE extension (see {{I-D.ietf-alto-incr-update-sse}}) uses
`client-id` to demultiplex push updates. However, `client-id` is provided
for each request, which introduces ambiguity when applying SSE to a Path Vector
resource.

To address this issue, an ALTO server must assign a unique identifier to each
part of the `multipart/related` response message. This identifier, referred to
as a Part Resource ID (See {{part-rid-spec}} for details), must be present in
the part message's `Resource-Id` header. The MIME part header must also contain
the `Content-Type` header, whose value is the media type of the part (e.g.,
`application/alto-costmap+json`, `application/alto-endpointcost+json`, or
`application/alto-propmap+json`).

If an ALTO server provides incremental updates for this Path Vector resource, it
must generate incremental updates for each part separately. The client-id must
have the following format:

~~~~~~~~~~
   pv-client-id '.' part-resource-id
~~~~~~~~~~

where pv-client-id is the client-id assigned to the Path Vector request, and
part-resource-id is the `Resource-Id` header value of the part. The media-type
must match the `Content-Type` of the part.

The same problem applies to the part messages as well. The two parts must
contain a version tag, which SHOULD contain a unique Resource ID. This document
requires the resource-id in a Version Tag to have the following format:

~~~~~~~~~~
   pv-resource-id '.' part-resource-id
~~~~~~~~~~

where pv-resource-id is the resource ID of the Path Vector resource in the IRD
entry, and the part-resource-id has the same value as the `Resource-Id` header
of the part.

### Order of Part Messages

According to {{RFC2387}}, the Path Vector part, whose media type is
the same as the `type` parameter of the multipart response message, is the root
object. Thus, it is the element the application processes first. Even though the
`start` parameter allows it to be placed anywhere in the part sequence, it is
RECOMMENDED that the parts arrive in the same order as they are processed, i.e.,
the Path Vector part is always put as the first part, followed by the property
map part. It is also RECOMMENDED that when doing so, an ALTO server SHOULD NOT
set the `start` parameter, which implies the first part is the root object.
