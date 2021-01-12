# Introduction

<!-- ALTO can improve QoE of overlay applications. -->
Network performance metrics are crucial to the Quality of Experience (QoE) of
today's applications. The ALTO protocol allows Internet Service Providers (ISPs)
to provide guidance, such as topological distance between different end
hosts, to overlay applications. Thus, the overlay applications can potentially
improve the QoE by better orchestrating their traffic to utilize the resources
in the underlying network infrastructure.

<!-- ALTO supports only cost information of end-to-end paths. -->
Existing ALTO Cost Map and Endpoint Cost Service provide only cost information
on an end-to-end path defined by its <source, destination> endpoints: The base
protocol {{RFC7285}} allows the services to expose the topological distances of
end-to-end paths, while various extensions have been proposed to extend the
capability of these services, e.g., to express other performance metrics
{{I-D.ietf-alto-performance-metrics}}, to query multiple costs simultaneously
{{RFC8189}}, and to obtain the time-varying values
{{RFC8896}}.

<!-- However, the QoE also depends on ANEs. -->
While the existing extensions are sufficient for many overlay applications,
however, the QoE of some overlay applications depends not only on the cost
information of end-to-end paths, but also on particular components of a network
on the paths and their properties. For example, job completion time, which is an
important QoE metric for a large-scale data analytics application, is impacted
by shared bottleneck links inside the carrier network. We refer to such
components of a network as Abstract Network Elements (ANE).

Predicting such information can be very complex without the help of the ISP
{{AAAI2019}}. With proper guidance from the ISP, an overlay application may be
able to schedule its traffic for better QoE. In the meantime, it may be helpful
as well for ISPs if applications could avoid using bottlenecks or challenging
the network with poorly scheduled traffic.

Despite the benefits, ISPs are not likely to expose details on their
network paths: first for the sake of confidentiality, second because it may
result in a huge volume and overhead, and last because it is difficult for ISPs
to figure out what information and what details an application needs. Likewise,
applications do not necessarily need all the network path details and are likely
not able to understand them.

Therefore, it is beneficial for both parties if an ALTO server provides ALTO
clients with an "abstract network state" that provides the necessary details to
applications, while hiding the network complexity and confidential information.
An "abstract network state" is a selected set of abstract representations of
Abstract Network Elements traversed by the paths between <source, destination>
pairs combined with properties of these Abstract Network Elements that are
relevant to the overlay applications' QoE. Both an application via its ALTO
client and the ISP via the ALTO server can achieve better confidentiality and
resource utilization by appropriately abstracting relevant Abstract Network
Elements. The pressure on the server scalability can also be reduced by
combining Abstract Network Elements and their properties in a single response.

This document extends {{RFC7285}} to allow an ALTO server convey "abstract
network state", for paths defined by their <source, destination> pairs. To this
end, it introduces a new cost type called "Path Vector". A Path Vector is an
array of identifiers that each identifies an Abstract Network Element, which can
be associated with various properties. The associations between ANEs and their
properties are encoded in an ALTO information resource called Unified Property
Map, which is specified in {{I-D.ietf-alto-unified-props-new}}.

For better confidentiality, this document aims to minimize information exposure.
In particular, this document enables and recommends that first ANEs are
constructed on demand, and second an ANE is only associated with properties that
are requested by an ALTO client. A Path Vector response involves two ALTO Maps:
the Cost Map that contains the Path Vector results and the up-to-date Unified
Property Map that contains the properties requested for these ANEs. To enforce
consistency and improve server scalability, this document uses the
`multipart/related` message defined in {{RFC2387}} to return the two maps in a
single response.

The rest of the document is organized as follows. {{term}} introduces the extra
terminologies that are used in this document. {{probstat}} uses an illustrative
example to introduce the additional requirements of the ALTO framework, and
discusses potential use cases. {{Overview}} gives an overview of the protocol
design. {{Basic}} and {{Services}} specify the Path Vector extension to the ALTO
IRD and the information resources, with some concrete examples presented in
{{Examples}}. {{Compatibility}} discusses the backward compatibility with the
base protocol and existing extensions. Security and IANA considerations are
discussed in {{Security}} and {{IANA}} respectively.


# Requirements Languages

The key words "MUST", "MUST NOT", "REQUIRED", "SHALL", "SHALL NOT", "SHOULD",
"SHOULD NOT", "RECOMMENDED", "NOT RECOMMENDED", "MAY", and "OPTIONAL" in this
document are to be interpreted as described in BCP 14 {{RFC2119}} {{RFC8174}}
when, and only when, they appear in all capitals, as shown here.

When the words appear in lower case, they are to be interpreted with their
natural language meanings.

# Terminology {#term}

NOTE: This document depends on the Unified Property Map extension
{{I-D.ietf-alto-unified-props-new}} and should be processed after the Unified
Property Map document.

This document extends the ALTO base protocol {{RFC7285}} and the Unified
Property Map extension {{I-D.ietf-alto-unified-props-new}}. In addition to
the terms defined in these documents, this document also uses the following
additional terms:

- Abstract Network Element (ANE): An Abstract Network Element is an abstract
  representation for a component in a network that handle data packets and whose
  properties can potentially have an impact on the end-to-end performance of
  traffic. An ANE can be a physical device such as a router, a link or an
  interface, or an aggregation of devices such as a subnetwork, or a data
  center.

  The definition of Abstract Network Element is similar to Network Element
  defined in {{RFC2216}} in the sense that they both provide an abstract
  representation of particular components of a network. However, they have
  different criteria on how these particular components are selected.
  Specifically, Network Element requires the components to be potentially
  capable of exercising QoS control, while Abstract Network Element only
  requires the components to have an impact on the end-to-end performance.

- ANE Name: An ANE can be constructed either statically in advance or on demand
  based on the requested information. Thus, different ANEs may only be valid
  within a particular scope, either ephemeral or persistent. Within each scope,
  an ANE is uniquely identified by an ANE Name, as defined in {{ane-name-spec}}.
  Note that an ALTO client must not assume ANEs in different scopes but with
  the same ANE Name refer to the same component(s) of the network.

- Path Vector: A Path Vector, or an ANE Path Vector, is a JSON array of ANE
  Names. It is a generalization of BGP path vector. While standard BGP path
  vector specifies a sequence of autonomous systems for a destination IP prefix,
  the Path Vector defined in this extension specifies a sequence of ANEs either
  for a source PID and a destination PID as in a cost map or for a source
  endpoint and a destination endpoint as in an endpoint cost map.

- Path Vector resource: A Path Vector resource refers to an ALTO resource which
  supports the extension defined in this document.

- Path Vector cost type: The Path Vector cost type is a special cost type, which
  is specified in {{cost-type-spec}}. When this cost type is present in an IRD
  entry, it indicates that the information resource is a Path Vector resource.
  When this cost type is present in a Cost Map or an Endpoint Cost Map, it
  indicates each cost value must be interpreted as a Path Vector.

- Path Vector request: A Path Vector request refers to the POST message sent to
  an ALTO Path Vector resource.

- Path Vector response: A Path Vector response refers to the multipart/related
  message returned by a Path Vector resource.

# Problem Statement {#probstat}

## Design Requirements

This section gives an illustrative example of how an overlay application can
benefit from the Path Vector extension.

Assume that an application has control over a set of flows, which may go through
shared links or switches and share a bottleneck. The application hopes to
schedule the traffic among multiple flows to get better performance. The
capacity region information for those flows will benefit the scheduling.
However, existing cost maps can not reveal such information.

Specifically, consider a network as shown in {{fig-dumbbell}}. The network has 7
switches (sw1 to sw7) forming a dumb-bell topology. Switches sw1/sw3 provide
access on one side, sw2/sw4 provide access on the other side, and sw5-sw7 form
the backbone. Endhosts eh1 to eh4 are connected to access switches sw1 to sw4
respectively. Assume that the bandwidth of link eh1 -> sw1 and link sw1 -> sw5
are 150 Mbps, and the bandwidth of the rest links are 100 Mbps.

~~~~ drawing
                              +-----+
                              |     |
                            --+ sw6 +--
                           /  |     |  \
     PID1 +-----+         /   +-----+   \          +-----+  PID2
     eh1__|     |_       /               \     ____|     |__eh2
192.0.2.2 | sw1 | \   +--|--+         +--|--+ /    | sw2 | 192.0.2.3
          +-----+  \  |     |         |     |/     +-----+
                    \_| sw5 +---------+ sw7 |
     PID3 +-----+   / |     |         |     |\     +-----+  PID4
     eh3__|     |__/  +-----+         +-----+ \____|     |__eh4
192.0.2.4 | sw3 |                                  | sw4 | 192.0.2.5
          +-----+                                  +-----+
~~~~~
{: #fig-dumbbell title="Raw Network Topology"}

The single-node ALTO topology abstraction of the network is shown in
{{fig-base}}.

~~~~ drawing
                          +----------------------+
                 {eh1}    |                      |     {eh2}
                 PID1     |                      |     PID2
                   +------+                      +------+
                          |                      |
                          |                      |
                 {eh3}    |                      |     {eh4}
                 PID3     |                      |     PID4
                   +------+                      +------+
                          |                      |
                          +----------------------+
~~~~
{: #fig-base title="Base Single-Node Topology Abstraction"}

Consider an application overlay (e.g., a large-scale data analytics system)
which wants to optimize the total throughput of the traffic among a set of end
host <source, destination> pairs, say eh1 -> eh2 and eh1 -> eh4. The application
can request a cost map providing end-to-end available bandwidth, using "availbw"
as cost-metric and "numerical" as cost-mode.

The application will receive from the ALTO server that the bandwidth of eh1 ->
eh2 and eh1 -> eh4 are both 100 Mbps. But this information is not enough to
determine the optimal total throughput. Consider the following two cases:

- Case 1: If eh1 -> eh2 uses the path eh1 -> sw1 -> sw5 -> sw6 ->
  sw7 -> sw2 -> eh2 and eh1 -> eh4 uses path eh1 -> sw1 -> sw5 ->
  sw7 -> sw4 -> eh4, then the application will obtain 150 Mbps at
  most.

- Case 2: If eh1 -> eh2 uses the path eh1 -> sw1 -> sw5 -> sw7 ->
  sw2 -> eh2 and eh1 -> eh4 uses the path eh1 -> sw1 -> sw5 -> sw7
  -> sw4 -> eh4, then the application will obtain only 100 Mbps at
  most.

To allow applications to distinguish the two aforementioned cases,
the network needs to provide more details.  In particular:

- For eh1 -> eh2, the ALTO server must give more details which is critical for
  the overlay application to distinguish between Case 1 and Case 2 and to
  compute the optimal total throughput accordingly.

- The ALTO server must allow the client to distinguish the common ANE shared by
  eh1 -> eh2 and eh1 -> eh4, e.g., eh1 - sw1 and sw1 - sw5 in Case 1.

- The ALTO server must give details on the properties of the ANEs used by eh1 ->
  eh2 and eh1 -> eh4, e.g., the available bandwidth between eh1 - sw1, sw1 -
  sw5, sw5 - sw7, sw5 - sw6, sw6 - sw7, sw7 - sw2, sw7 - sw4, sw2 - eh2, sw4 -
  eh4 in Case 1.

In general, we can conclude that to support the multiple flow scheduling
use case, the ALTO framework must be extended to satisfy the following
additional requirements:

AR1:
: An ALTO server must provide essential information on ANEs on the
  path of a <source, destination> pair that are critical to the QoE of the
  overlay application.

AR2:
: An ALTO server must provide essential information on how the paths of
  different <source, destination> pairs share a common ANE.

AR3:
: An ALTO server must provide essential information on the properties associated
  to the ANEs.

The Path Vector extension defined in this document propose a solution to provide
these details.

## Use Cases

While the multiple flow scheduling problem is used to help identify the
additional requirements, the Path Vector extension can be applied to a wide
range of applications. This section highlights some real use cases that are
reported.

### Large-scale Data Analytics

One potential use case of the Path Vector extension is for large-scale data
analytics such as {{SENSE}} and {{LHC}}, where data of Gigabytes, Terabytes and
even Petabytes are transferred. For these applications, the QoE is usually
measured as the job completion time, which is related to the completion time of
the slowest data transfer. With the Path Vector extension, an ALTO client can
identify bottlenecks inside the network. Therefore, the overlay application can
make optimal traffic distribution or resource reservation (i.e., proportional to
the size of the transferred data), leading to optimal job completion time and
network resource utilization.

### Context-aware Data Transfer

It is getting important to know the capabilities of various ANEs between two end
hosts, especially in the mobile environment. With the Path Vector extension, an
ALTO client may query the "network context" information, i.e., whether the two
hosts are connected to the access network through a wireless link or a wire, and
the capabilities of the access network. Thus, the client may use different data
transfer mechanisms, or even deploy different 5G User Plane Functions (UPF)
{{I-D.ietf-dmm-5g-uplane-analysis}} to optimize the data transfer.

### CDN and Service Edge

A growing trend in today's applications is to bring storage and computation
closer to the end user for better QoE, such as Content Delivery Network (CDN),
AR/VR, and cloud gaming, as reported in various documents
({{I-D.contreras-alto-service-edge}},
{{I-D.huang-alto-mowie-for-network-aware-app}}, and
{{I-D.yang-alto-deliver-functions-over-networks}}).

With the Path Vector extension, an ALTO server can selectively reveal the CDNs
and service edges that reside along the paths between different end hosts,
together with their properties such as available Service Level Agreement (SLA)
plans. Otherwise, the ALTO client may have to make multiple queries and
potentially with the complete list of CDNs and/or service edges. While both
approaches offer the same information, making multiple queries introduces larger
delay and more overhead on both the ALTO server and the ALTO client.
