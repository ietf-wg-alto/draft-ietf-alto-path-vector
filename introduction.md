# Introduction

Network performance metrics are crucial to the Quality of Experience (QoE) of
today's applications. The ALTO protocol allows Internet Service Providers (ISPs)
to provide guidance, such as topological distance between different end
hosts, to overlay applications. Thus, the overlay applications can potentially
improve the QoE by better orchestrating their traffic to utilize the resources
in the underlying network infrastructure.

The base protocol {{RFC7285}} defines Cost Map and Endpoint Cost Service that
expose the topological distances of a set of <source, destination> pairs.
Various extensions have been proposed extend the capability of these services to
express other performance metrics {{I-D.ietf-alto-performance-metrics}}, to
query multiple costs simultaneously {{RFC8189}}, and to obtain the time-varying
values {{I-D.ietf-alto-cost-calendar}}.

However, existing ATLO services provide only scalar network performance metrics
for each <source, destination> communicating pair. While this approach has many
benefits such as confidentiality and simplicity, the scalar cost values are not
sufficient for several overlay applications that are becoming widely deployed in
today's Internet. For example, a large scale data analytics application must
predict the potential bottlenecks to optimize the job completion time, which can
be very complex without the visibility of the internal network structure
{{AAAI2019}}. In particular, to infer the desired information, the overlay
application may make multiple ALTO queries, which in return compromises the
confidentiality of the ISP and service capability of the ALTO server.

Thus, it is beneficial for both parties that the ISP proactively provide more
fine-grained but abstract internal network state to authorized overlay
applications. The overlay applications (i.e., ALTO clients) can save the efforts
to infer the desired information and potentially get more accurate results. The
ISP (i.e., the ALTO server) can potentially achieve better confidentiality and
resource utilization by appropriately guiding the applications' traffic
distribution. Also, the pressure on the server scalability can also be reduced
as multiple potential queries are packed into a single query.

This document extends {{RFC7285}} to allow an ALTO server expose abstract
internal network states, as path vectors, for a set of <source, destination>
pairs. Each element in the path vector is referred to as an Abstract Network
Element (ANE). An ANE represents an abstract component of the physical network,
and can be associated with various attributes. The associations between ANEs and
their properties are encoded in a Unified Property Map
{{I-D.ietf-alto-unified-props-new}}.

For better confidentiality, this document aims to minimize information exposure.
In particular, this document enables and recommends that 1) ANEs are constructed
on demand, and 2) an ANE is only associated with attributes that are requested
by an ALTO client. Thus, the two maps involved with a single Path Vector query,
i.e., the (Endpoint) Cost Map that contains the Path Vector results and the
Unified Property Map that contains the association between ANEs and their
properties, are tightly coupled. To enforce consistency and improve server
scalability, this document uses the [TBD-ID-MULTIPART]() extension to return
the two maps in a single response.

The rest of the document are organized as follows. {{Overview}} gives an
overview of the protocol design. {{Basic}} and {{Services}} specify the Path
Vector extension to the ALTO IRD and the information resources, with some
concrete examples presented in {{Examples}}. {{Compatibility}} discusses the
backward compatibility with the base protocol and existing extensions. Security
and IANA considerations are discussed in {{Security}} and {{IANA}} respectively.

## Recent Use Cases {#usecases}

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

It is sometimes important to know how the capabilities of various network
components between two end hosts. With the Path Vector extension, an ALTO client
may query the "network context" information, i.e., whether the two hosts are
connected to the access network through a wireless link or a wire, and the
capabilities of the access network. Thus, the client may use different data
transfer mechanisms, or even deploy different 5G User Plane Functions (UPF)
{{I-D.ietf-dmm-5g-uplane-analysis}} to optimize the data transfer.

### CDN and Service Edge

A growing trend in today's applications is to bring storage and computation
closer to the end user for better QoE, such as Content Delivery Network (CDN),
AR/VR, and cloud gaming, as reported in various recent documents
({{I-D.contreras-alto-service-edge}},
{{I-D.huang-alto-mowie-for-network-aware-app}}, and
{{I-D.yang-alto-deliver-functions-over-networks}}).

With the Path Vector extension, an ALTO server can selectively reveal the CDNs
and service edges that reside along the paths between different end hosts,
together with their properties such as available Service Level Agreement (SLA)
plans. Otherwise, the ALTO client may have to make multiple queries and
potentially with the complete list of CDNs and/or service edges. While both
approaches offer the same information, making multiple queries introduce larger
delay and more overhead on both the ALTO server and the ALTO client.

### Multi-domain Resource Discovery

Another potential use case is to use ALTO for multi-domain resource discovery,
as reported in a recent document [TBD-ALTO-MULTIDOMAIN](). In such a scenario,
the Path Vector extension is essential. Consider the scenario in
{{fig-multidomain}} and assume only Network D can provide 100 GB in-network
storage. If the ALTO server in Network A discovers in-network storage
capabilities from Network B and Network C, with only scalar values, it may
mistakenly think there are 200 GB in-network storage available. What is worse,
when it broadcasts the 200 GB storage to its neighbors, Network B and
Network C may again mistakenly update their own information, which results in an
infinite loop.

With the Path Vector extension, the ALTO server in Network A receives two Path
Vectors from Network B and C respectively, which both contains an entry of
Network D. Thus, the ALTO server in Network A can correctly conclude the total
available in-network storage is 100 GB.

~~~~~~~~ drawing
                       +-----------+
                /------| Network B |------\
        +-----------+  +-----------+  +-----------+
src ----| Network A |                 | Network D |---- dst
        +-----------+  +-----------+  +-----------+
                \------| Network C |------/
                       +-----------+
~~~~~~~~
{: #fig-multidomain title="An Example Topology" artwork-align="center"}


## Terminology # {#term}

This document extends the ALTO base protocol [](#RFC7285) and the Unified
Property Map extension [](#I-D.ietf-alto-unified-props-new). In addition to
the terms defined in these documents, this document also uses the following
additional terms:

- Abstract Network Element (ANE): An Abstract Network Element is an abstraction
  representation of network components. It can be a link, a middlebox, a
  virtualized network function (VNF), etc., or their aggregations. An ANE can be
  constructed either statically in advance or on demand based on the requested
  information. In a response, each ANE is represented by a unique ANE
  Name. Note that an ALTO client MUST NOT assume ANEs in different
  responses but with the same ANE Name refer to the same aggregation of
  network components.

- Path Vector: A Path Vector, or an ANE Path Vector, is a JSON array of ANE
  Names. It conveys the information that the traffic between a source and a
  destination traverses the ANEs in the same order as they appear in the Path
  Vector.

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
