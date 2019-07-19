# Overview {#SecOverview}

This section gives a top-down overview of approaches adopted by the path vector
extension. It is assumed that readers are familiar with both the base protocol
[](#RFC7285) and the Unified Property Map extension
[](#I-D.ietf-alto-unified-props-new).

## Workflow {#design-workflow}

The workflow of the base ALTO protocol consists of one round of communication:
An ALTO Client sends a request to an ALTO Server, and the ALTO Server returns a
response, as shown in [](#WF). Each response contains only one type of ALTO
resources, e.g., Network Map, Cost Map, or Property Map.

```
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
       |       PV Response (Cost Map part)      |
       |<---------------------------------------|
       |                                        |
       |      PV Response (Property Map part)   |
       |<---------------------------------------|
       |                                        |
```
^[WF::Information Exchange Process of the base ALTO Protocol and the Path Vector Extension]

The path vector extension, on the other hand, CAN be decomposed to two types of
information resources. First, path vectors, which represent the correlations of
network paths for all <source, destination> pairs in the requst, CAN be encoded
as an (Endpoint) Cost Map with an extended cost type. Second, properties
associated with the ANEs CAN be encoded as a Unified Property Map.

Instead of making two consecutive queries, however, the path vector extension
adopts a workflow which also consists of only one round of communication, based
on the following reasons:

1. ANE Computation Flexibility. For better scalability, flexibility and privacy,
   Abstract Network Elements MAY be constructed on demand, and potentially based
   on the properties (See [](#design-ane) for more details). If sources and
   destinations are not in the same request as the properties, an ALTO server
   either CANNOT construct ANEs on-demand, or MUST wait until both requests are
   received.

2. Server Scalability. As ANEs are constructed on demand, mappings of each ANE
   to its underlying network devices and resources CAN be different in different
   queries. In order to respond to the second request correctly, an ALTO server
   MUST store the mapping of each path vector request until the client fully
   retrieves the property information, which CAN substantially harm the server
   scalability and potentially lead to Denial-of-Service attacks.

Thus, the path vector extension encapsulates all essential information in one
request, and returns both path vectors and properties associated with the ANEs
in a single response. See [](#design-msg) for more details.

## Abstract Network Element {#design-ane}

A key design in the path vector extension is abstract network element. Abstract
network elements can be statically generated, for example, based on
geo-locations, OSPF areas, or simply the raw network topology. They CAN also be
generated dynamically, based on a client's request. This on-demand ANE
generation allows for better scalability, flexibility and privacy enhancement.

Consider an extreme case where the client only queries the bandwidth between one
source and one destination in the topology shown in [](#ANETP). Without knowing
in prior the desired property, an ALTO server MAY need to include all network
components on the paths for high accuracy. However, with the prior knowledge
that the client only asks for the bandwidth information, an ALTO server CAN
either 1) selectively pick the link with the smallest available bandwidth, or 2)
dynamically generate a new ANE whose available bandwidth is the smallest value
of the links' on the path. Thus, an ALTO server can provide accurate information
with very little leak of its internal network topology.

```
      +-----+  +-----+       +-----+
eh1 --| sw1 |--| sw2 |--...--| swN |-- eh2
      +-----+  +-----+       +-----+
```
^[ANETP::Topology for Dynamic ANE Example.]

Since ANEs CAN be generated dynamically, an ALTO client MUST NOT assume that
ANEs with the same identifier but from different queries refer to the same
aggregation of network components. This approach simplifies the management of
ANE identifiers at ALTO servers, and increases the difficulty to infer the real
network topology with cross queries. It is RECOMMENDED that the identifiers of
statically generated ANEs be anonymized in the path vector response, for
example, by shuffling the ANEs and shrinking their identifier space to 1, 2, 3,
etc.

## Message Encoding {#design-msg}

[](#design-workflow) has well articulated the reasons to complete the
information exchange in a single round of communication. This section introduces
the three major extensions to the base ALTO protocol and the Unified Property
Map extension.

### Path Vector Cost Type

Existing cost modes defined in [](#RFC7285) allow only scalar cost values.
However, the path vector extension MUST convey vector format information. To
fulfill this requirement, this document defines a new cost mode named `array`,
which indicates that the cost value MUST be interpreted as an array of
JSONValue. This document also introduces a new cost metric `ane-path` to convey
an array of ANE identifiers.

The combination of the `array` cost mode and the `ane-path` cost metric also
complies best with the ALTO base protocol, where cost mode specifies the
interpretation of a cost value, and cost metric conveys the meaning.

### Property Negotiation

Similar to cost types, an ALTO server MAY only support a given set of ANE
properties in a path vector information resource. Meanwhile, an ALTO client MAY
only require a subset of the available properties. Thus, a property negotiation
process is required.

This document uses a similar approach as the negotiation process of cost types:
the available properties for a given resource are announced in the Information
Resource Directory and more specifically, in a new capability called
`ane-properties`; the selected properties SHOULD be specified in a new filter
called `ane-properties` in the request body; the response MUST return and only
return the selected properties for the ANEs in the response, if applicable.

### Multipart/Related Message

Path vectors and the property map containing the ANEs are two different types
of objects, but they require strong consistency. One approach to achieving
strong consistency is to define a new media type to contain both objects, but
this violates modular design.

This document uses standard-conforming usage of `multipart/related` media type
defined in [](#RFC2387) to elegantly encode the objects. Specifically, using
`multipart/related` needs to address two issues:

- ALTO uses media type to indicate the type of an entry in the information
  resource directory (IRD) (e.g., `application/alto-costmap+json` for cost map
  and `application/alto-endpointcostmap+json` for endpoint cost map). Simply
  putting `multipart/related` as the media type, however, makes it impossible
  for an ALTO client to identify the type of service provided by related
  entries.

- The ALTO SSE extension (see [](#I-D.ietf-alto-incr-update-sse)) depends on
  resource-id to identify push updates, but resource-id is provided only in IRD
  and hence each entry in the IRD has only one resource-id.

This design addresses the two issues as follows:

- To address the first issue, the multipart/related media type includes the type
  parameter to allow type indication of the root object. For a
  cost map service, the `media-type` will be `multipart/related` with the
  parameter `type=application/alto-costmap+json`; for an endpoint cost
  map service, the parameter will be
  `type=application/alto-endpointcostmap+json`. This design is highly
  extensible. The entries can still use `application/alto-costmapfilter+json` or
  `application/alto-endpointcostparams+json` as the accept input parameters, and
  hence an ALTO client still sends the filtered cost map request or endpoint
  cost service request. The ALTO server sends the response as a
  `multipart/related` message. The body of the response includes two parts: the
  first one is of the media type specified by the `type` parameter; the second one
  is a property map associated to the first map.
- To address the second issue, each part of the `multipart/related` response
  message has the MIME part header information including `Content-Type` and
  `Resource-Id`. An ALTO server MAY generate incremental updates (see
  [](#I-D.ietf-alto-incr-update-sse)) for each part separately using the
  `Resource-Id` header.

By applying the design above, for each path vector query, an ALTO server
returns the path vectors and the associated property map modularly and
consistently. An ALTO server can reuse the data models of the existing
information resources. And an ALTO client can subscribe to the incremental
updates for the dynamic generated information resources without any changes, if
the ALTO server provides incremental updates for them.
