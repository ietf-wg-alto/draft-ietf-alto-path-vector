# Compatibility with Other ALTO Extensions {#Compatibility}

## Compatibility with Legacy ALTO Clients/Servers

The multipart filtered cost map resource and the multipart endpoint cost
resource has no backward compatibility issue with legacy ALTO clients and
servers. Although these two types of resources reuse the media types defined in
the base ALTO protocol for the accept input parameters, they have different
media types for responses. If the ALTO server provides these two types of
resources, but the ALTO client does not support them, the ALTO client will
ignore the resources without incurring any incompatibility problem.

<!--
The path vector extension on Filtered Cost Map and Endpoint Cost Service is
backward compatible with the base ALTO protocol:

- If the ALTO server provides extended capabilities `dependent-property-map` and
  `allow-compound-response` for Filtered Cost Map or Endpoint Cost Service, but
  the client only supports the base ALTO protocol, then the client will ignore
  those capabilities without conducting any incompatibility.
- If the client sends a request with the input parameter `properties`, but the
  server only supports the base ALTO protocol, the server will ignore this
  field.
-->

## Compatibility with Multi-Cost Extension ##

<!-- FIXME: path-vector cannot be used in multi-cost, also no reason -->

The extension defined in this document is NOT compatible with the multi-cost
extension {{RFC8189}}. The reason is that if a resource supports both the
extension defined in this document and the multi-cost extension, the media type
of this resource depends on the selection of cost types: if the path vector cost
type is selected, the media type of the response is either `multipart/related;
type=application/alto-costmap+json` or `multipart/related;
type=application/alto-endpointcost+json`; if the path vector cost type is not
selected, the media type of the response is either
`application/alto-costmap+json` or `application/alto-endpointcost+json`.

Note that this problem may happen when an ALTO information resource supports
multiple cost types, even if it does not enable the multi-cost extension. Thus,
{{pvcm-cap}} has specified that if an ALTO information resource enables the
extension defined in this document, the path vector cost type MUST be the only
cost type in the `cost-type-names` capability of this resource.

<!--
As [](#fcm-cap) mentions, the syntax and semantics of whether `constraints` or
`or-constraints` field for the `array` cost mode is not specified in this
document. So if an ALTO server provides a resource with the `array` cost mode
and the capability `cost-constraints` or `testable-cost-types-names`, the ALTO
client MAY ignore the capability `cost-constraints` or
`testable-cost-types-names` unless the implementation or future documents
specify the behavior.
-->

<!--
Cost type path-vector is not a testable cost type. Any format of constraints
SHOULD NOT be applied to cost type path-vector in order for multi-cost to
support the path-vector extension. Specifically,

- Cost type path-vector MUST NOT be included in `testable-cost-types-names` or
  `testable-cost-types`.
- When `testable-cost-types-names` is omitted in the `capabilities` and
  `testable-cost-types` is omitted in the input parameters, `constraints` or
  `or-constraints` SHOULD NOT add any format of constraints on cost type
  path-vector.
-->

## Compatibility with Incremental Update ##

<!-- FIXME: using resource-id header in MIME part -->

ALTO clients and servers MUST follow the specifications given in Section 5.2 of
{{RFC8895} to support incremental updates for a Path Vector resource.

## Compatibility with Cost Calendar

The extension specified in this document is compatible with the Cost Calendar
extension {{RFC8896}}. When used together with the Cost Calendar extension, the
cost value between a source and a destination is an array of path vectors, where
the k-th path vector refers to the abstract network paths traversed in the k-th
time interval by traffic from the source to the destination.

When used with time-varying properties, e.g., maximum reservable bandwidth
(maxresbw), a property of a single ANE may also have different values in
different time intervals. In this case, if such an ANE has different property
values in two time intervals, it MUST be treated as two different ANEs, i.e.,
with different entity identifiers. However, if it has the same property values
in two time intervals, it MAY use the same identifier.

This rule allows the Path Vector extension to represent both changes of ANEs and
changes of the ANEs' properties in a uniform way. The Path Vector part is
calendared in a compatible way, and the Property Map part is not affected by the
calendar extension.

The two extensions combined together can provide the historical network
correlation information for a set of source and destination pairs. A network
broker or client may use this information to derive other resource requirements
such as Time-Block-Maximum Bandwidth, Bandwidth-Sliding-Window, and
Time-Bandwidth-Product (TBP) (See {{SENSE}} for details).

# General Discussions {#SecDisc}

<!--
Cost Calendar is proposed as a useful ALTO extension to provide the historical
cost values for Filtered Cost Map Service and Endpoint Cost Service. Since path
vector is an extension to these services, it SHOULD be compatible with Cost
Calendar extension.

However, the calendar of a path-vector (Endpoint) Cost Map is insufficient for
the application which requires the historical data of routing state information.
The (Endpoint) Cost Map can only provide the changes of the paths. But more
useful information is the history of network element properties which are
recorded in the dependent Network Element Property Map.

Before the Unified Property Map is introduced as an ALTO extension, Filtered
Cost Map Service and Endpoint Cost Service are the only resources which require
the calendar supported. Because other resources don't have to be updated
frequently. But Network Element Property Map as a use case of Unified Property
Map will collect the real-time information of the network. It SHOULD be updated
as soon as possible once the metrics of network elements change.

So the requirement is to provide a general calendar extension which not only
meets the Filtered Cost Map and Endpoint Cost Service but also applies to the
Property Map Service.
-->

## Constraint Tests for General Cost Types ##

The constraint test is a simple approach to query the data. It allows users to
filter the query result by specifying some boolean tests. This approach is
already used in the ALTO protocol. {{RFC7285}} and {{RFC8189}} allow ALTO
clients to specify the `constraints` and `or-constraints` tests to better
filter the result.

However, the current syntax can only be used to test scalar cost types, and
cannot easily express constraints on complex cost types, e.g., the Path Vector
cost type defined in this document.

In practice, developing a bespoke language for general-purpose boolean tests can
be a complex undertaking, and it is conceivable that there are some existing
implementations already (the authors have not done an exhaustive search to
determine whether there are such implementations). One avenue to develop such a
language may be to explore extending current query languages like XQuery
{{XQuery}} or JSONiq {{JSONiq}} and integrating these with ALTO.

Filtering the Path Vector results or developing a more sophisticated filtering
mechanism is beyond the scope of this document.

## General Multi-Resource Query ##

Querying multiple ALTO information resources continuously is a general
requirement. Enabling such a capability, however, must address the general
issues like efficiency and consistency. The incremental update extension
{{RFC8895}} supports submitting multiple queries in a single request, and allows
flexible control over the queries. However, it does not cover the case
introduced in this document where multiple resources are needed for a single
request.

This extension gives an example of using a multipart message to encode two
specific ALTO information resources: a filtered cost map or an endpoint cost
map, and a property map. By packing multiple resources in a single response, the
implication is that servers may proactively push related information resources to
clients.

Thus, it is worth looking into the direction of extending the SSE mechanism as
used in the incremental update extension {{RFC8895}}, or upgrading to HTTP/2
{{RFC7540}} and HTTP/3 {{I-D.ietf-quic-http}}, which provides the ability to
multiplex queries and to allow servers proactively send related information
resources.

Defining a general multi-resource query mechanism is out of the scope of this
document.

# Security Considerations {#Security}

This document is an extension of the base ALTO protocol, so the Security
Considerations {{RFC7285}} of the base ALTO protocol fully apply when this
extension is provided by an ALTO server.

<!-- Additional security considerations -->

<!-- ## Privacy Concerns { #pricon } -->

The Path Vector extension requires additional scrutiny on two security
considerations discussed in the base protocol: confidentiality of ALTO
information (Section 15.3 of {{RFC7285}}) and availability of ALTO service
(Section 15.5 of {{RFC7285}}).

For confidentiality of ALTO information, a network operator should be aware of
that this extension may introduce a new risk: the Path Vector information may
make network attacks easier. For example, as the Path Vector information may
reveal more fine-grained internal network structures than the base protocol, an
ALTO client may detect the bottleneck link and start a distributed
denial-of-service (DDoS) attack involving minimal flows to conduct the
in-network congestion.

To mitigate this risk, the ALTO server should consider protection mechanisms to
reduce information exposure or obfuscate the real information, in particular,
in settings where the network and the application do not belong to the same
trust domain. But the implementation of Path Vector extension involving
reduction or obfuscation should guarantee the requested properties are still
accurate, for example, by using minimal feasible region compression algorithms
{{TON2019}} or obfuscation protocols {{SC2018}}{{JSAC2019}}.

<!--
On the other hand, in a setting of the same trust domain, a key benefit
of the path-vector abstraction is to reduce information transferred from the network
to the application.
-->

For availability of ALTO service, an ALTO server should be cognizant that using
Path Vector extension might have a new risk: frequent requesting for Path
Vectors might conduct intolerable increment of the server-side computation and
storage, which can break the ALTO server. For example, if an ALTO server
implementation dynamically computes the Path Vectors for each requests, the
service providing Path Vectors may become an entry point for denial-of-service
attacks on the availability of an ALTO server.

To mitigate this risk, an ALTO server may consider using optimizations such as
precomputation-and-projection mechanisms {{JSAC2019}} to reduce the overhead for
processing each query. Also, an ALTO server may also protect itself from
malicious clients by monitoring the behaviors of clients and stopping serving
clients with suspicious behaviors (e.g., sending requests at a high frequency).

# IANA Considerations # {#IANA}

## ALTO Entity Domain Type Registry ##

This document registers a new entry to the ALTO Domain Entity Type Registry, as
instructed by Section 12.2 of {{I-D.ietf-alto-unified-props-new}}. The new entry
is as shown below in {{tbl-entity-domain}}.



| Identifier | Entity Address Encoding | Hierarchy & Inheritance |
|------------|-------------------------|-------------------------|
| ane | See {{entity-address}} | None |
{: #tbl-entity-domain title="ALTO Entity Domain Type Registry"}

Identifier:
: See {{domain-type}}.

Entity Identifier Encoding:
: See {{entity-address}}.

Hierarchy:
: None

Inheritance:
: None

Media Type of Defining Resource:
: See {{domain-defining}}.

Security Considerations:
: In some usage scenarios, ANE addresses carried in ALTO Protocol messages may
  reveal information about an ALTO client or an ALTO service provider.
  Applications and ALTO service providers using addresses of ANEs will be made
  aware of how (or if) the addressing scheme relates to private information and
  network proximity, in further iterations of this document.

## ALTO Entity Property Type Registry ##

Two initial entries are registered to the ALTO Domain `ane` in the `ALTO Entity
Property Type Registry`, as instructed by Section 12.3 of
{{I-D.ietf-alto-unified-props-new}}. The two new entries are shown below in
{{tbl-prop-type-reg}}.

| Identifier              | Intended Semantics          |
|-------------------------|-----------------------------|
| max-reservable-bandwidth | See {{maxresbw}}            |
| persistent-entity-id     | See {{persistent-entity-id}} |
{: #tbl-prop-type-reg title="Initial Entries for ane Domain in the ALTO Entity Property Types Registry"}

# Acknowledgments #

The authors would like to thank discussions with Andreas
Voellmy, Erran Li, Haibin Song, Haizhou Du, Jiayuan Hu, Qiao Xiang, Tianyuan Liu,
Xiao Shi, Xin Wang, and Yan Luo. The authors thank Greg Bernstein (Grotto Networks),
Dawn Chen (Tongji University), Wendy Roome, and Michael Scharf for
their contributions to earlier drafts.
