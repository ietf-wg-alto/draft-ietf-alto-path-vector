# Path Vector Extension: Overview {#Overview}

This section gives a non-normative overview of the extension defined in this
document. It is assumed that readers are familiar with both the base protocol
{{RFC7285}} and the Unified Property Map extension
{{I-D.ietf-alto-unified-props-new}}.

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

When an ANE is defined by the ALTO server, it is assigned an identifier, i.e.,
string of type ANEName as specified in {{ane-name-spec}}, and a set of
associated properties.

### ANE Domain

In this extension, the associations between ANE and the properties are conveyed
in a Unified Property Map. Thus, ANEs must constitute an entity domain (Section
5.1 of {{I-D.ietf-alto-unified-props-new}}), and each ANE property must be an
entity property (Section 5.2 of {{I-D.ietf-alto-unified-props-new}}).

Specifically, this document defines a new entity domain called `ane` as
specified in {{ane-domain-spec}} and defines two initial properties for the `ane`
domain.

### Ephemeral ANE and Persistent ANE {#assoc}

By design, ANEs are ephemeral and not to be used in further requests. More
precisely, the corresponding ANE names are no longer valid beyond the scope of
the Path Vector response or the incremental update stream for a Path Vector
request. This has several benefits including better privacy of the ISPs and more
flexible ANE computation.

For example, an ALTO server may define an ANE for each aggregated bottleneck
link between the sources and destinations specified in the request. For requests
with different sources and destinations, the bottlenecks may be different but
can safely reuse the same ANE names. The client can still adjust its traffic
based on the information but is difficult to infer the underlying topology with
multiple queries.

However, sometimes an ISP may intend to selectively reveal some "persistent"
network components which, opposite to being ephemeral, have a longer life cycle.
For example, an ALTO server may define an ANE for each service edge cluster.
Once a client chooses to use a service edge, e.g., by deploying some
user-defined functions, it may want to stick to the service edge to avoid the
complexity of state transition or synchronization, and continuously query the
properties of the edge cluster.

This document provides a mechanism to expose such network components as
persistent ANEs. A persistent ANE has a persistent ID that is registered in a
Property Map, together with their properties. See {{domain-defining}} and
{{persistent-entity-id}} for more detailed instructions on how to identify
ephemeral ANEs and persistent ANEs.

### Property Filtering

Resource-constrained ALTO clients may benefit from the filtering of Path Vector
query results at the ALTO server, as an ALTO client may only require a subset of
the available properties.

Specifically, the available properties for a given resource are announced in the
Information Resource Directory as a new capability called `ane-property-names`.
The selected properties are specified in a filter called `ane-property-names` in
the request body, and the response includes and only includes the selected
properties for the ANEs in the response.

The `ane-property-names` capability for Cost Map and for Endpoint Cost Service
are specified in {{pvcm-cap}} and {{pvecs-cap}} respectively. The
`ane-property-names` filter for Cost Map and Endpoint Cost Service are specified
in {{pvcm-accept}} and {{pvecs-accept}} accordingly.

## Path Vector Cost Type {#path-vector-design}

For an ALTO client to correctly interpret the Path Vector, this extension
specifies a new cost type called the Path Vector cost type.

The Path Vector cost type must convey both the interpretation and semantics in
the "cost-mode" and "cost-metric" respectively. Unfortunately, a single
"cost-mode" value cannot fully specify the interpretation of a Path Vector,
which is a compound data type. For example, in programming languages such as
C++, a Path Vector will have the type of `JSONArray<ANEName>`.

Instead of extending the "type system" of ALTO, this document takes a simple
and backward compatible approach. Specifically, the "cost-mode" of the Path
Vector cost type is "array", which indicates the value is a JSON array. Then, an
ALTO client must check the value of the "cost-metric". If the value is
"ane-path", it means that the JSON array should be further interpreted as a path
of ANENames.

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

The extension defined in this document, on the other hand, involves two types of
information resources: Path Vectors conveyed in an InfoResourceCostMap (defined
in Section 11.2.3.6 of {{RFC7285}}) or an InfoResourceEndpointCostMap (defined
in Section 11.5.1.6 of {{RFC7285}}), and ANE properties conveyed in an
InfoResourceProperties (defined in Section 7.6 of {{I-D.ietf-alto-unified-props-new}}).

Instead of two consecutive message exchanges, the extension defined in this
document enforces one round of communication. Specifically, the ALTO client must
include the source and destination pairs and the requested ANE properties in a
single request, and the ALTO server must return a single response containing
both the Path Vectors and properties associated with the ANEs in the Path
Vectors, as shown in {{fig-pv}}. Since the two parts are bundled together in one
response message, their orders are interchangeable. See {{pvcm-resp}} and
{{pvecs-resp}} for details.


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
in {{RFC2387}} to elegantly combine the objects. Path Vectors are encoded in an
InfoResourceCostMap or an InfoResourceEndpointCostMap, and the Property Map is
encoded in an InfoResourceProperties. They are encapsulated as parts of a
multipart message. The modular composition allows ALTO servers and clients to
reuse the data models of the existing information resources. Specifically, this
document addresses the following practical issues using `multipart/related`.

### Identifying the Media Type of the Root Object

ALTO uses media type to indicate the type of an entry in the Information
Resource Directory (IRD) (e.g., `application/alto-costmap+json` for Cost Map
and `application/alto-endpointcost+json` for Endpoint Cost Service). Simply
putting `multipart/related` as the media type, however, makes it impossible
for an ALTO client to identify the type of service provided by related
entries.

To address this issue, this document uses the `type` parameter to indicate the
root object of a multipart/related message. For a Cost Map resource, the
`media-type` in the IRD entry is `multipart/related` with the parameter
`type=application/alto-costmap+json`; for an Endpoint Cost Service, the
parameter is `type=application/alto-endpointcost+json`.

### References to Part Messages {#ref-partmsg-design}

As the response of a Path Vector resource is a multipart message with two
different parts, it is important that each part can be uniquely identified.
Following the designs of {{RFC8895}}, this extension requires that an ALTO
server assigns a unique identifier to each part of the `multipart/related`
response message. This identifier, referred to as a Part Resource ID (See
{{part-rid-spec}} for details), is present in the part message's `Content-ID`
header. By concatenating the Part Resource ID to the identifier of the Path
Vector request, an ALTO server/client can uniquely identify the Path Vector Part
or the Property Map part.
