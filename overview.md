# Path Vector Extension: Overview {#Overview}

This section gives a non-normative overview of the Path Vector extension. It is
assumed that readers are familiar with both the base protocol {{RFC7285}} and
the Unified Property Map extension {{I-D.ietf-alto-unified-props-new}}.

To satisfies the additional requirements, this extension:

1. introduces Abstract Network Element (ANE) as the abstraction of intermediate
   network components,

2. extends the Cost Map and Endpoint Cost Service to convey the intermediate
   network components traversed by the path of a <source, destination> pair as
   Path Vectors,

3. uses the Unified Property Map to convey the association between the
   intermediate network components and their properties.

Thus, an ALTO client can learn about the intermediate network components that
are critical to the QoE of a <source, destination> pair by investigating the
corresponding Path Vector value (AR1), identify common network components if an
ANE appears in the Path Vectors of multiple <source, destination> pairs (AR2),
and retrieve the properties of the network components by searching the Unified
Property Map (AR3).

Besides the additional requirements, this extension also adopts several design
choices to address practical issues. Specifically, this document uses the
following designs:

1. This extension conveys the routing information in the abstract network in an
   ALTO Cost Map or Endpoint Cost Map which accepts a Path Vector, i.e., a JSON
   array of ANEs traversed by the path between a source and a destination, as
   the cost value. With the Path Vectors, an ALTO client can simultaneously
   reconstruct the structure of the abstract network and the routing
   for the paths between endpoints.

2. This extension uses the ALTO Unified Property Map to convey the properties
   associated with the ANEs, which offers more fine-grained abstract
   network state for overlay applications.

3. This extension uses the multipart message {{RFC2387}} to include
   both information resources in the same Path Vector response.

## Abstract Network Element {#ane-design}

This extension introduces Abstract Network Element (ANE) as an indirect and
network-agnostic way to specify an aggregation of intermediate network
components between a source and a destination.


### ANE Name

Each ANE is uniquely identified by a string of type ANEName as specified in
{{ane-name-spec}}. An important observation is that for different requests, an
ALTO server may selectively apply different methods to create the abstract
network state based on confidentiality and performance considerations. Thus, the
ANEs inside the abstract network may be constructed on demand. This indicates
that the scope of an ANEName is limited to the Path Vector response.

Since each ANE is also an entity in the Unified Property Map, the ANE Name MUST
conform to the encoding of an Entity Identifier. Thus, this document also
specifies a new EntityDomainName following the instructions in
{{I-D.ietf-alto-unified-props-new}}.

### ANE Properties

In this extension, the associations between ANE and the properties are conveyed
in a Unified Property Map. Thus, they MUST follow the mechanisms specified in
the {{I-D.ietf-alto-unified-props-new}} with some additional considerations.

1. As a property may not exist in every ANE, it must be interpreted in the same
   way by the ALTO server and the ALTO client. Thus, for an ANE property type,
   its intended semantics MUST specify how to interpret the case that a
   requested property does not exist in an ANE.

2. As each ANE is an aggregation of multiple network components, its properties
   are the aggregated results of the components' properties. For different ALTO
   server implementations, different properties MAY have different rules when
   they are aggregated into a single ANE. For example, if an ANE is the
   aggregation of two networks where each network contains a CDN, an ALTO server
   may selectively expose one CDN, expose none, or expose both in the ANE,
   according to its own aggregation policies.

   However, it is common that an ALTO client needs to compute the aggregated
   property value of some ANEs, e.g., to infer the end-to-end property for a
   <source, destination> pair. It is RECOMMENDED that the intended
   semantics of an ANE property specifies how to compute the aggregated value
   without loss of information. Thus, the information is interpreted by the ALTO
   server and the ALTO client in the same way. For example, properties with
   algebraic properties can be aggregated following the algebraic rules
   {{TON2019}}.

   NOTE: The aggregation rule ONLY specifies how to compute the aggregated
   property for a Path Vector, NOT how the ANEs can be aggregated in the Path
   Vector response. This is because the change of Path Vectors may change the
   routing information and the abstract network topology, leading to inaccurate
   results.

3. An ALTO Path Vector resource MAY only support a set of ANE properties.
   Meanwhile, an ALTO client MAY only require a subset of the available
   properties. Thus, a property negotiation process is required.

   This document uses a similar approach as the negotiation process of cost
   types: the available properties for a given resource are announced in the
   Information Resource Directory as a new capability called
   `ane-property-names`; the selected properties SHOULD be specified in a new
   filter called `ane-property-names` in the request body; the response MUST
   return and only return the selected properties for the ANEs in the response.

## Path Vector Cost Type {#path-vector-design}

For an ALTO client to correctly interpret the Path Vector, this extension
specifies a new cost type called the Path Vector cost type, which MUST be
included both in the Information Resource Directory and the ALTO Cost Map or
Endpoint Cost Map so that an ALTO client can correct interpret the cost values.

The Path Vector cost type MUST convey both the interpretation and semantics in
the "cost-mode" and "cost-metric" respectively. Unfortunately, a single
"cost-mode" value cannot fully specify the interpretation of a Path Vector,
which is a compound data type. For example, in programming languages such as
Java, a Path Vector will have the type of JSONArray[ANEName].

Instead of extending the "type system" of ALTO, this document takes a simple
and backward compatible approach. Specifically, the "cost-mode" of the Path
Vector cost type is "array", which indicates the value is a JSON array. Then, an
ATLO client MUST check the value of the "cost-metric". If the value is
"ane-path", meaning the JSON array should be further interpreted as a path of
ANENames.

The Path Vector cost type is specified in {{cost-type-spec}}.

## Multipart Path Vector Response

For a basic ALTO information resource, a response contains only one type of
ALTO resources, e.g., Network Map, Cost Map, or Property Map. Thus, only one
round of communication is required: An ALTO client sends a request to an ALTO
server, and the ALTO server returns a response, as shown in {{fig-alto}}.

~~~~~~~~~~ drawing
  ALTO Client                              ALTO Server
       |-------------- Request ---------------->|
       |<------------- Response ----------------|
~~~~~~~~~~
{: #fig-alto artwork-align="center" title="A Typical ALTO Request and Response"}

The Path Vector extension, on the other hand, involves two types of information
resources: Path Vectors conveyed in a Cost Map or an Endpoint Cost Map, and ANE
properties conveyed in a Unified Property Map. Instead of two consecutive
message exchanges, the Path Vector extension enforces one round of
communication. Specifically, the Path Vector extension requires the ALTO client
to include the source and destination pairs and the requested ANE properties in
a single request, and encapsulates both Path Vectors and properties associated
with the ANEs in a single response, as shown in {{fig-pv}}.


~~~~~~~~~~ drawing
  ALTO Client                              ALTO Server
       |------------- PV Request -------------->|
       |<----- PV Response (Cost Map Part) -----|
       |<--- PV Response (Property Map Part) ---|
~~~~~~~~~~
{: #fig-pv artwork-align="center" title="The Path Vector Extension Request and Response"}

This design is based on the following considerations:

1. Since ANEs MAY be constructed on demand, and potentially based on the
   requested properties (See {{ane-design}} for more details). If sources and
   destinations are not in the same request as the properties, an ALTO server
   either cannot construct ANEs on-demand, or must wait until both requests are
   received.

2. As ANEs MAY be constructed on demand, mappings of each ANE to its underlying
   network devices and resources can be specific to the request. In order
   to respond to the Property Map request correctly, an ALTO server MUST store
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
`media-type` in the IRD entry MUST be `multipart/related` with the parameter
`type=application/alto-costmap+json`; for an Endpoint Cost Service, the
parameter MUST be `type=application/alto-endpointcost+json`.

### References to Part Messages {#ref-partmsg-design}

The ALTO SSE extension (see {{I-D.ietf-alto-incr-update-sse}}) uses
`client-id` to demultiplex push updates. However, `client-id` is provided
for each request, which introduces ambiguity when applying SSE to a Path Vector
resource.

To address this issue, an ALTO server MUST assign a unique identifier to each
part of the `multipart/related` response message. This identifier, referred to
as a Part Resource ID (See {{part-rid-spec}} for details), MUST be present in
the part message's `Resource-Id` header. The MIME part header MUST also contain
the `Content-Type` header, whose value is the media type of the part (e.g.,
`application/alto-costmap+json`, `application/alto-endpointcost+json`, or
`application/alto-propmap+json`).

If an ALTO server provides incremental updates for this Path Vector resource, it
MUST generate incremental updates for each part separately. The client-id MUST
have the following format:

~~~~~~~~~~
   pv-client-id '.' part-resource-id
~~~~~~~~~~

where pv-client-id is the client-id assigned to the Path Vector request, and
part-resource-id is the `Resource-Id` header value of the part. The media-type
MUST match the `Content-Type` of the part.

The same problem applies to the part messages as well. The two parts MUST
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
