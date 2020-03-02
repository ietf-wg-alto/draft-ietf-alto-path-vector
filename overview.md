# Overview {#Overview}

This section gives a top-down overview of approaches adopted by the Path Vector
extension, with discussions to fully explore the design space. It is assumed
that readers are familiar with both the base protocol {{RFC7285}} and the
Unified Property Map extension {{I-D.ietf-alto-unified-props-new}}.

## Workflow {#design-workflow}

The workflow of the base ALTO protocol consists of one round of communication:
An ALTO client sends a request to an ALTO server, and the ALTO server returns a
response, as shown in {{fig-workflow}}. Each response contains only one type of ALTO
resources, e.g., network maps, cost maps, or property maps.

~~~~~~~~~~ drawing
+-------------+                          +-------------+
| ALTO Client |                          | ALTO Server |
+-------------+                          +-------------+
       |               Request                  |
       |--------------------------------------->|
       |                                        |
       |               Response                 |
       |<---------------------------------------|
       |                                        |
       .                   .                    .
       .                   .                    .
       .                   .                    .
       |              PV Request                |
       |--------------------------------------->|
       |                                        |
       |       PV Response (Cost Map Part)      |
       |<---------------------------------------|
       |                                        |
       |      PV Response (Property Map Part)   |
       |<---------------------------------------|
       |                                        |
~~~~~~~~~~
{: #fig-workflow artwork-align="center" title="Information Exchange Process of the base ALTO Protocol and the Path Vector Extension"}

The Path Vector extension, on the other hand, involves two types of information
resources. First, Path Vectors, which represent the correlations of network
paths for all <source, destination> pairs in the request, are encoded as an
(endpoint) cost map with an extended cost type. Second, properties associated
with the ANEs are encoded as a property map.

Instead of making two consecutive queries, however, the Path Vector extension
adopts a workflow which also consists of only one round of communication, based
on the following reasons:

1. ANE Computation Flexibility. For better scalability, flexibility and privacy,
   Abstract Network Elements MAY be constructed on demand, and potentially based
   on the properties (See {{design-ane}} for more details). If sources and
   destinations are not in the same request as the properties, an ALTO server
   either CANNOT construct ANEs on-demand, or MUST wait until both requests are
   received.

2. Server Scalability. As ANEs are constructed on demand, mappings of each ANE
   to its underlying network devices and resources CAN be different in different
   queries. In order to respond to the second request correctly, an ALTO server
   MUST store the mapping of each Path Vector request until the client fully
   retrieves the property information. The "stateful" behavior CAN substantially
   harm the server scalability and potentially lead to Denial-of-Service
   attacks.

Thus, the Path Vector extension encapsulates all essential information in one
request, and returns both Path Vectors and properties associated with the ANEs
in a single response. See {{design-msg}} for more details.

## Abstract Network Element {#design-ane}

A key design in the Path Vector extension is abstract network element. Abstract
network elements can be statically generated, for example, based on
geo-locations, OSPF areas, or simply the raw network topology. They CAN also be
generated on demand based on a client's request. This on-demand ANE
generation allows for better scalability, flexibility and privacy enhancement.

Consider an extreme case where the client only queries the bandwidth between one
source and one destination in the topology shown in {{fig-ane-tp}}. Without knowing
in advance the desired property, an ALTO server MAY need to include all network
components on the paths for high accuracy. However, with the prior knowledge
that the client only asks for the bandwidth information, an ALTO server CAN
either 1) selectively pick the link with the smallest available bandwidth, or 2)
dynamically generate a new ANE whose available bandwidth is the smallest value
of the links' on the path. Thus, an ALTO server can provide accurate information
with very little leak of its internal network topology. For more general cases,
ANEs MAY be constructed based on algebraic aggregations, please see {{TON2019}}
for more details.

~~~~~~~~~~ drawing
      +-----+  +-----+       +-----+
eh1 --| sw1 |--| sw2 |--...--| swN |-- eh2
      +-----+  +-----+       +-----+
~~~~~~~~~~
{:center #fig-ane-tp title="Topology for Dynamic ANE Example."}

An ANE is uniquely identified by an ANE identifier (see {{ane-id}}) in the
same response. However, since ANEs CAN be generated dynamically, an ALTO client
MUST NOT assume that ANEs with the same identifier but from different queries
refer to the same aggregation of network components. This approach simplifies
the management of ANE identifiers at ALTO servers, and increases the difficulty
to infer the real network topology with cross queries. It is RECOMMENDED that
the identifiers of statically generated ANEs be anonymized in the Path Vector
response, for example, by shuffling the ANEs and shrinking their identifier
space to \[1, N\], where N is the number of ANEs etc.

## Protocol Extensions {#design-msg}

{{design-workflow}} has well articulated the reasons to complete the
information exchange in a single round of communication. This section introduces
the three major extended components to the base ALTO protocol and the Unified
Property Map extension, as shown in {{tab-ext}}.

| Component             | IRD | Request | Response |
|-----------------------|-----|---------|----------|
| Path Vector Cost Type | Yes | Yes     | Yes      |
| Property Negotiation  | Yes | Yes     | Yes      |
| Multipart Message     | Yes | No      | Yes      |
{:center #tab-ext title="Extended Components and Where They Apply."}

### Path Vector Cost Type

Existing cost modes defined in {{RFC7285}} allow only scalar cost values.
However, the Path Vector extension MUST convey vector format information. To
fulfill this requirement, this document defines a new cost mode named `array`,
which indicates that the cost value MUST be interpreted as an array of
JSONValue. This document also introduces a new cost metric `ane-path` to convey
an array of ANE identifiers.

The combination of the `array` cost mode and the `ane-path` cost metric also
complies best with the ALTO base protocol, where cost mode specifies the
interpretation of a cost value, and cost metric conveys the meaning.

### Property Negotiation

Similar to cost types, an ALTO server MAY only support a given set of ANE
properties in a Path Vector information resource. Meanwhile, an ALTO client MAY
only require a subset of the available properties. Thus, a property negotiation
process is required.

This document uses a similar approach as the negotiation process of cost types:
the available properties for a given resource are announced in the Information
Resource Directory and more specifically, in a new capability called
`ane-properties`; the selected properties SHOULD be specified in a new filter
called `ane-properties` in the request body; the response MUST return and only
return the selected properties for the ANEs in the response, if applicable.

### Multipart/Related Message

Path Vectors and the property map containing the ANEs are two different types
of objects, but they need to be encoded in one message. One approach is to
define a new media type to contain both objects, but this violates modular
design.

This document uses standard-conforming usage of `multipart/related` media type
defined in {{RFC2387}} to elegantly combine the objects. Path Vectors are
encoded as a cost map or an endpoint cost map, and the property map is encoded
as a Unified Propert Map. They are encapsulated as parts of a multipart message.
The modular composition allows ALTO servers and clients to reuse the data models
of the existing information resources. Specifically, this document addresses the
following practical issues using `multipart/related`.

#### Identifying the Media Type of the Root Object

ALTO uses media type to indicate the type of an entry in the Information
Resource Directory (IRD) (e.g., `application/alto-costmap+json` for cost map
and `application/alto-endpointcost+json` for endpoint cost map). Simply
putting `multipart/related` as the media type, however, makes it impossible
for an ALTO client to identify the type of service provided by related
entries.

To address this issue, this document uses the `type` parameter to indicate the
root object of a multipart/related message. For a cost map resource, the
`media-type` in the IRD entry MUST be `multipart/related` with the parameter
`type=application/alto-costmap+json`; for an Endpoint Cost Service, the
parameter MUST be `type=application/alto-endpointcost+json`.

#### References to Part Messages {#design-rpm}

The ALTO SSE extension (see {{I-D.ietf-alto-incr-update-sse}}) uses
`client-id` to demultiplex push updates. However, `client-id` is provided
for each request, which introduces ambiguity when applying SSE to a Path Vector
resource.

To address this issue, an ALTO server MUST assign a unique identifier to each
part of the `multipart/related` response message. This identifier, referred to
as a Part Resource ID (See {{mpri}} for details), MUST be present in the part
message's `Resource-Id` header. The MIME part header MUST also contain the
`Content-Type` header, whose value is the media type of the part (e.g.,
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

The same problem happens inside the part messages as well. The two parts MUST
contain a version tag, which SHOULD contain a unique Resource ID. This document
requires the resource-id in a Version Tag to have the following format:

~~~~~~~~~~
   pv-resource-id '.' part-resource-id
~~~~~~~~~~

where pv-resource-id is the resource ID of the Path Vector resource in the IRD
entry, and the part-resource-id has the same value as the `Resource-Id` header
of the part.

#### Order of Part Messages

According to RFC 2387 {{RFC2387}}, the Path Vector part, whose media type is
the same as the `type` parameter of the multipart response message, is the root
object. Thus, it is the element the application processes first. Even though the
`start` parameter allows it to be placed anywhere in the part sequence, it is
RECOMMENDED that the parts arrive in the same order as they are processed, i.e.,
the Path Vector part is always put as the first part, followed by the property
map part. It is also RECOMMENDED that when doing so, an ALTO server SHOULD NOT
set the `start` parameter, which implies the first part is the root object.
