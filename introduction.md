# Introduction #

The base ALTO protocol [](#RFC7285) is designed to expose network information
through services such as cost map and endpoint cost service. These services use
an extreme `single-node` network view abstraction, which represents the whole
network with a single node and hosts with `endpoint groups` directly connected
to the node.

Although the `single-node` network view abstraction works well in many settings,
it lacks the ability to support emerging use cases, such as applications
requiring large bandwidth or latency sensitivity [](#I-D.bernstein-alto-topo),
and inter-datacenter data transfers [](#I-D.lee-alto-app-net-info-exchange). For
these use cases, applications require a more powerful network view abstraction
beyond the `single-node` abstraction to support application capabilities, in
particular, the ability multi-flow scheduling.

<!-- FIXED: [I-D.yang-alto-topology] only propose the "node-link schema" which is
distinguished from "path vector" representation. Need to fix the description.
-->

To support capabilities like multi-flow scheduling, this document uses a `path
vector` abstraction to represent more detailed network graph information like
capacity regions. The path vector abstraction uses path vectors with abstract
network elements to provide network graph view for applications. A path vector
consists of a sequence of abstract network elements (ANEs) that end-to-end
traffic goes through. ANEs can be links, switches, middleboxes, their
aggregations, etc.; they have properties like `bandwidth`, `delay`, etc. These
information may help the application avoid network congestion and achieve better
application performance.
<!--to provide information on the shared bottlenecks of multiple flows.-->

Providing path vector abstraction using ALTO introduces the following additional
requirements (ARs):

AR-1:
~ The ALTO protocol SHOULD include the support for encoding array-like cost
values rather than scalar cost values in cost maps or endpoint cost maps.
~ The ALTO server providing path vector abstraction SHOULD convey sequences of
ANEs between sources and destinations the ALTO client requests. Theses
information cannot be encoded by the scalar types (numerical or ordinal) which
the base ALTO protocol supports. A new cost type is required to encode path
vectors as costs.

<!--A path vector exposes the abstract network elements (e.g., links, switches, middleboxes and their aggregations) that end-to-end traffic goes through, allowing applications to discover the correlations of traffic with different source/destination endpoints. The properties can be `bandwidth` for links and `delay` between neighboring switches. These information may help the application avoid network congestion, achieving better application performance.-->

AR-2:
~ The ALTO protocol SHOULD include the support for encoding properties of ANEs.
~ Only the sequences of ANEs are not enough for most use cases mentioned
previously. The properties of ANEs like `bandwidth` and `delay` are required by
applications to build the capacity region or realize the latency sensitivity.

<!-- ~ Unified property map [](#I-D.ietf-alto-unified-props-new) defines an extensible schema to provide properties of general entities; it cannot -->
<!-- convey properties of abstract network elements. A new ALTO domain needs to be -->
<!-- registered so that unified property map can encode properties of abstract -->
<!-- network elements. -->

AR-3:
~ The ALTO server SHOULD allow the ALTO client to query path vectors and the
properties of abstract network elements consistently.
~ Path vectors and the properties of abstract network elements are correlated
information, but can be separated into different ALTO information resources. A
mechanism to query both of them consistently is necessary.

<!-- - Encapsulating multiple map messages in a single response: Sending multiple queries to get path vectors and properties of abstract network elements introduce additional communication overhead.  A mechanism to provide multiple map messages in a single session is necessary. -->

This document proposes the path vector extension which satisfies these
additional requirements to the ALTO protocol. Specifically, the ALTO protocol
encodes the array of ANEs over an end-to-end path using a new cost type, and
conveys the properties of ANEs using unified property map
[](#I-D.ietf-alto-unified-props-new). We also provide an optional solution to
query separated path vectors and properties of ANEs in a consistent way. But
querying general separated resources consistently is not the scope in this
document.

<!--To replace: This document introduces a new cost type to encode abstract network elements along an end-to-end path and optionally conveys their properties.-->

<!-- specifies how to encode the shared bottlenecks in a network for a given set of flows with many design details driven by effectiveness, performance and backward compatibility considerations. -->

<!-- The second functionality for simple cost types, such as those introduced in the base protocol, is already addressed in a recent extension, e.g. [](#RFC8189). However, the path-vector extension in this document has introduced a new cost type which complicates the situation. Thus, the multiple cost encapsulation SHOULD still be taken into consideration. -->

<!-- The key changes are: the new cost type, with associated metric and mode and the kind of values provided for this metric (ii)the possibility of receiving responses with composite information on path costs, insight on abstracted path elements and their properties. -->

<!-- TODO: Don't forget to update the organization -->

The rest of this document is organized as follows. [](#SecMF) gives an example
of multi-flow scheduling and illustrates the limitations of the base ALTO
protocol in such a use case. [](#SecOverview) gives an overview of the path
vector extension. [](#SecCostType) introduces a new cost type.
[](#SecANEDomain) registers a new domain in Domain Registry. [](#SecProtoExt)
extends Filtered Cost Map and Endpoint Cost Service to support the compound
resource query. [](#SecExample) presents several examples. [](#SecComp) and
[](#SecDisc) discusses compatibility issues with other existing ALTO extensions
and design decisions. [](#SecSCons) and [](#SecIANA) review the security and
IANA considerations.

<!-- [](#SecMultiService) defines a new service to encode multiple map messages
in a single response. -->
