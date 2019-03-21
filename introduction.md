# Introduction #

The base ALTO protocol [](#RFC7285) is designed to expose network information
through services such as cost maps and endpoint cost service. These services use
an extreme `single-node` network abstraction, which represents a whole
network as a single node, and hosts as `endpoint groups` directly connected
to the node.

Although the `single-node` abstraction works well in many settings,
it lacks the ability to support emerging use cases, such as
co-flow scheduling for large-scale data analytics. For such a use case, applications 
require a more powerful network view abstraction beyond the `single-node` abstraction.

To support capabilities like co-flow scheduling, this document uses a `path
vector` abstraction to represent more detailed network graph information like
capacity regions. The path vector abstraction uses path vectors with abstract
network elements to provide network graph view for applications. A path vector
consists of a sequence of abstract network elements (ANEs) that end-to-end
traffic goes through. Example ANEs include links, switches, middleboxes, and their
aggregations. An ANE can have properties such as `bandwidth`, and `delay`. Providing 
such information can help both applications to achieve better
application performance and networks to avoid network congestion.
<!--to provide information on the shared bottlenecks of multiple flows.-->

Providing path vector abstraction using ALTO introduces the following additional
requirements (ARs):

AR-1:
~ The path vector abstraction requires the encoding of array-like cost
values rather than scalar cost values in cost maps or endpoint cost maps.
~ Specifically, the path vector abstraction requires the specification of the 
sequence of ANEs between sources and destinations. Such a sequence, however,
cannot be encoded by the scalar types (numerical or ordinal) which
the base ALTO protocol supports. 

<!--A path vector exposes the abstract network elements (e.g., links, switches, middleboxes and their aggregations) that end-to-end traffic goes through, allowing applications to discover the correlations of traffic with different source/destination endpoints. The properties can be `bandwidth` for links and `delay` between neighboring switches. These information may help the application avoid network congestion, achieving better application performance.-->

AR-2:
~ The path vector abstraction requires the encoding of the properties of aforementioned ANEs.
~ Specifically, only the sequences of ANEs are not enough for existing use cases. Properties 
of ANEs such as `bandwidth` and `delay` are needed by
applications to properly construct network constraints or states.

<!-- ~ Unified property map [](#I-D.ietf-alto-unified-props-new) defines an extensible schema to provide properties of general entities; it cannot -->
<!-- convey properties of abstract network elements. A new ALTO domain needs to be -->
<!-- registered so that unified property map can encode properties of abstract -->
<!-- network elements. -->

AR-3:
~ The path vector abstraction requires consistent encoding of path vectors (AR-1) and the 
properties of the ANEs in a path vector (AR-2).
~ Specifically, path vectors and the properties of ANEs in the vectors are dependent. A mechanism to query both of them consistently is necessary.

<!-- - Encapsulating multiple map messages in a single response: Sending multiple queries to get path vectors and properties of abstract network elements introduce additional communication overhead.  A mechanism to provide multiple map messages in a single session is necessary. -->

This document proposes the path vector extension to the ALTO protocol to satisfy these
additional requirements . 

Specifically, the extension encodes the array (AR-1) of ANEs over an end-to-end path 
using a new cost type, and conveys the properties of ANEs (AR-2) using unified property map
[](#I-D.ietf-alto-unified-props-new). The path vector and ANE properties are conveyed in a
single message encoded as a multipart/related message to satisfy AR-3. 

<!--
We also provide an optional solution to
query separated path vectors and properties of ANEs in a consistent way. But
querying general separated resources consistently is not the scope in this
document.
-->

<!--To replace: This document introduces a new cost type to encode abstract network elements along an end-to-end path and optionally conveys their properties.-->

<!-- specifies how to encode the shared bottlenecks in a network for a given set of flows with many design details driven by effectiveness, performance and backward compatibility considerations. -->

<!-- The second functionality for simple cost types, such as those introduced in the base protocol, is already addressed in a recent extension, e.g. [](#RFC8189). However, the path-vector extension in this document has introduced a new cost type which complicates the situation. Thus, the multiple cost encapsulation SHOULD still be taken into consideration. -->

<!-- The key changes are: the new cost type, with associated metric and mode and the kind of values provided for this metric (ii)the possibility of receiving responses with composite information on path costs, insight on abstracted path elements and their properties. -->

<!-- TODO: Don't forget to update the organization -->

The rest of this document is organized as follows. [](#SecMF) gives an example
of co-flow scheduling and illustrates the limitations of the base ALTO protocol
in such a use case. [](#SecOverview) gives an overview of the path vector
extension. [](#SecCostType) introduces a new cost type. [](#SecANEDomain)
registers a new domain in Domain Registry. [](#SecMultiFCM) and [](#SecMultiECS)
define new ALTO resources to support Path Vector query by using the request
format of Filtered Cost Map and Endpoint Cost Service. [](#SecExample) presents
several examples. [](#SecComp) and [](#SecDisc) discusses compatibility issues
with other existing ALTO extensions and design decisions. [](#SecSCons) and
[](#SecIANA) review the security and IANA considerations.

<!-- [](#SecMultiService) defines a new service to encode multiple map messages
in a single response. -->
