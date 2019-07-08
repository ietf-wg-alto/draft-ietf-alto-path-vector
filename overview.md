# Overview {#SecOverview}

This section presents an overview of approaches adopted by the path vector
extension. It assumes that the readers are familiar with cost map and endpoint cost
service defined in [](#RFC7285). The path vector extension also requires the
support of Filtered Property Map defined in
[](#I-D.ietf-alto-unified-props-new).

The path vector extension is composed of three building blocks: (1) a new cost
mode to encode path vectors in a cost map or an endpoint cost map; (2) a new
ALTO entity domain to enable ANE property encoding using the unified property
extension [](#I-D.ietf-alto-unified-props-new); and (3) a generic mechanism to
put multiple ALTO information objects in a single response to enforce
consistency, to preserve modularity and to avoid complex linking of multiple
responses.
<!-- (3) an extension to the cost map and endpoint cost resource to provide path -->
<!-- vectors and properties of ANEs in a single response. -->

## New Cost Mode to Encode Path Vectors ## {#ALTO.PV.CostType}

Existing cost modes defined in [](#RFC7285) allow only scalar cost values.
However, the "path vector" abstraction requires to convey vector format
information (AR-1). To fulfill this requirement, this document defines a new
`cost-mode` named path vector to indicate that the cost value is an array of ANEs.
A path vector abstraction should be computed for a specific performance metric,
and this is achieved using the existing `cost-metric` component of cost type.
The details of the new `cost-mode` is given in [](#SecCostType).


<!-- ### New Cost Metric: ane-path ### {#ALTO.PV.CostMetric}

To represent an abstract network path, this document introduces a new cost metric named "ane-path". A cost value in this metric is a list containing the names of the ALTO ANEs that the ALTO Server has specified as describing the network path elements. The ANE names array is organized as a sequence beginning at the source of the path and ending at its destination.

### New Cost Mode: array ### {#ALTO.PV.CostMode}

A cost mode as defined in Section 6.1.2 of [](#RFC7285), a cost mode is either "numerical" or "ordinal" and none of these can be used to present a list of ANE names. Therefore, this document specifies a new cost mode named "array" for the cost metric "ane-path". The new cost mode "array" means each cost value in the cost maps is a list. -->

## New ALTO Entity Domain for ANE Properties ## {#nep-map}

A path vector of ANEs contains only the abstracted routing elements between a
source and a destination. Hence, an application can find shared ANEs of
different source-destination pairs but cannot know the shared ANEs' properties.
For the capacity region use case in [](#SecMF), knowing that eh1->eh2 and
eh3->eh4 share ANEs but not the available bandwidth of the shared ANEs, is not
enough.

To encode ANE properties like the available bandwidth in a path vector
query response, this document uses the unified property extension defined in
[](#I-D.ietf-alto-unified-props-new). Specifically, for each path vector query,
the ALTO server generates a property map associated to the (endpoint) cost map
as follows:

- a dynamic entity domain of an entity domain type `ane` is generated to contain
  the generated ANEs. Each ANE has the same unique identifier in the path
  vectors and in the dynamic entity domain;
- each entity in this dynamic entity domain has the properties specified by the
  client.

Detailed information and specifications are given in [](#SecANEDomain).

<!--
CHECKME: This design uses the unified property extension defined in
[](#I-D.ietf-alto-unified-props-new) to provide the properties of the ANEs. Specifically,
for each path vector query, a dynamic entity domain of an entity domain type `ane` is
generated to contain the generated ANEs. Each ANE has the same identifier in the path vectors and
in the dynamic entity domain; each entity in the entity domain has a property which is the
`cost-metric` that generated the ANEs, providing the required information.
Detailed information and specifications are given in [](#SecANEDomain).
-->

<!--
Given the new cost type introduced by [](#ALTO.PV.CostType), Cost Map and
Endpoint Cost Service can provide the ANE names along a flow path. However, only
providing the ANE names without properties is not enough for many use cases (see
[](#SecMF)). For example, to detect shared bottlenecks, ALTO clients may expect
information on specific ANE properties such as link capacity or delay.

This document adopts the property map defined in
[](#I-D.ietf-alto-unified-props-new) to encode the properties of abstract
network elements. A new entity domain `ane` is registered for the property map.
Each entity in the `ane` domain has an identifier of an ANE. An ANE identifier
is the ANE name used in the values of the `ane-path` metric defined in the
present draft. ANE properties are provided in information resources called
`Property Map Resource` and `Filtered Property Map Resource`. The `Filtered
Property Map` resource which supports the `ane` domain is used to encode the
properties of ane entities, and it is called an ANE Property Map in this
document.
-->

<!--
## Extended Cost Map/Endpoint Cost Service for Compound Resources ## {#ext-cm-ecs}

Providing path vectors and ANE properties in
separated resources has several benefits: (1) it can be better compatible
with the base ALTO protocol; (2) it allows different property map resources to reuse
the same cost map or endpoint cost resource. However, it introduces two issues:

- Efficiency: Two separate resources may lead to the ALTO client invoking
  multiple requests/responses to collect all needed information. This may increase
  communication overhead.
- Consistency: Path vectors and properties of ANEs are correlated, and
  querying them separately may lead to consistency issues.

To solve these issues, this document introduces an extension to cost map and
endpoint cost service, which allows the ALTO server to attach a property map in
the data entry of a cost map or an endpoint cost service response.

These issues may exist in all general cases for querying separated ALTO
information resources. But solving this general problem is not in the scope of
this document.
-->

<!-- Decouple the multipart service with path vector -->

<!-- ## [](#RFC2378) media type for path vector: multipart/related ## -->
## Multipart/Related Resource for Consistency##

Path vectors and the property map containing the ANEs are two different types
of objects, but they require strong consistency. One approach to achieving
strong consistency is to define a new media type to contain both objects, but
this violates modular design.

Another approach is to provide the objects in two different information resources.
Thus, an ALTO client needs to make separate queries to get the information of
related services. This may cause a data synchronization problem between two
queries. Also, as the generation of ANE is dynamic, an ALTO server must cache
the results of a query before a client fully retrieves all related resources,
which hurts the scalability and security of an ALTO server.

This document uses standard-conforming usage of `multipart/related` media type
defined in [](#RFC2387) to elegantly solve the problem.

Specifically, using `multipart/related` needs to address two issues:

- ALTO uses media type to indicate the type of an entry in the information
  resource directory (IRD) (e.g., `application/alto-costmap+json` for cost map
  and `application/alto-endpointcostmap+json` for endpoint cost map). Simply
  putting `multipart/related` as the media type, however, makes it impossible
  for an ALTO client to identify the type of service provided by related
  entries.

- The ALTO SSE extension (see [](#I-D.ietf-alto-incr-update-sse)) depends on
  resource-id to identify push updates, but resource-id is provided only in IRD
  and hence each entry in the IRD has only one resource-id.


<!--
- The path vector extension requires the ALTO server to provide two separated
  ALTO resources, the (endpoint) cost map and the property map, consistently. In
  the base ALTO protocol, ALTO servers use media types in the HTTP header to
  indicate the type of the response. Typically one response only contains a
  single JSON object specified by the media type, such as
  `application/alto-costmap+json` or `application/alto-propmap+json`. So the
  base ALTO protocol limits the capability of ALTO servers to return multiple
  map messages in the same response. Thus, an ALTO client needs to make separate
  queries to get the information of related services. This may cause a data
  synchronization issue and break the consistency between the (endpoint) cost
  map and the property map.
- The ANE property map associated to the path vector (endpoint) cost map is a
  dynamic resource. Without the (endpoint) cost map, the ALTO client cannot
  retrieve it individually.
-->

<!--
Thus, an ALTO client needs to make separate queries to get the information of
related services. This may cause a data synchronization problem between
dependent ALTO services. Because when making the second query, the result for
the first query may have already changed. The same problem can happen to Network
Map and Cost Map resources. However, unlike Network Map and Cost Map which are
considered more stable, Path Vectors and the dependent ANE Property Maps might
change more frequently.
-->

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
th ALTO server provides incremental updates for them.

<!--
In this way, for each  the ALTO server can reuse the  a response can contain both the path vectors in a filtered cost map
(or endpoint cost map) and the associated ANE Property Map. The media types of
the cost map and the property map can still be retrieved from the response. The
interpretation of each media type in the `multipart/related` response is
consistent with the base ALTO protocol.
-->

<!--## Applicable ALTO services for Path Vector costs ##-->

<!--This document defines Filtered Cost Map and Endpoint Cost Map are applicable for path vector costs. Although the new cost type for path vector can also be used in the GET-mode Cost Map service from [](#RFC7285), the behaviours of the ALTO server and client for such a GET-mode service is not defined. So it is not recommended to apply path vector costs to the GET-mode Cost Map service.-->

<!-- Cost Map, Filtered Cost Map and Endpoint Cost Map are all applicable for path vector costs, -->

<!--## Impact of backwards compatibility on the PV design ##-->

<!--The path vector extension on Filtered Cost Map and Endpoint Cost Service is backward compatible with the base ALTO protocol. If the ALTO server provides path vector extended Filtered Cost Map or Endpoint Cost Service, but the client is a base ALTO client, then the client will ignore the path vector cost type without conducting any incompatibility. If the client sents a request with path vector cost type, but the server is a base ALTO server, the server will return an `E_INVALID_FIELD_VALUE` error.-->

<!-- For backward compatibility, this extension also allows ALTO clients to make multiple queries instead of encapsulating abstract network element property map along with the path vector. Thus, each Cost Map or Endpoint Cost Service with this extension MUST include a "prop-map" in their capabilities to indicate where to retrieve the network element properties. An additional field "query-id" MUST also be added to the "vtag" field to uniquely identify a path vector query session. -->

<!--## Requirements for PV on Clients and Servers ##-->

<!--A path vector extended ALTO server MUST implement the base ALTO protocol specified in [](#RFC7285) with the following additional requirements:-->

<!--
If an ALTO server supports path vector extension, it MUST support the Unified Property Map defined in [](#I-D.ietf-alto-unified-props-new).
If an ALTO server supports path vector extended Filtered Cost Map or Endpoint Cost Service, the server MUST provide the associated Property Map simultaneously.
If an ALTO server provides "multipart/related" media type for path vector, the server MUST provide the associated Filtered Cost Map or Endpoint Cost Service and the Property Map simultaneously.
-->

<!--An ALTO client supported path vector extension MUST be able to interpret Unified Property Map correctly. If the ALTO client wants to interpret "multipart/related" path vector response, the client MUST implement the path vector extension on Filtered Cost Map or Endpoint Cost Service at first.-->
