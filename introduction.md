# Introduction #

The ALTO protocol is aimed to provide applications with knowledge of the
underlying network topologies from the point of views of ISPs. The base
protocol [](#RFC7285) defines cost maps and endpoint cost services that expose
the preferences of network paths for a set of source and destination pairs.

While the preferences of network paths are already sufficient for a wide range
of applications, new application traffic patterns and new network technologies
are emerging that are well beyond the domain for which existing ALTO maps are
engineered, including but not limited to:

Very-high-speed data transfers:
~ Applications, such as Content Distribution Network (CDN) overlays,
  geo-distributed data centers and large-scale data analytics, are foundations
  of many Internet services today and have very large traffic between a source
  and a destination. Thus, the interference between traffic of different source
  and destination pairs cannot be omitted, which cannot be provided by or
  inferred from existing ALTO base protocol and extensions.

In-network storage and computation:
~ Emerging networking technologies such as network function virtualization and
  mobile edge computing provide storage and computation inside the network.
  Applications can leverage these resources to further improve their
  performance, for example, using in-network caching to reduce latency and
  bandwidth from a given source to multiple clients. However, existing ALTO
  extensions provide no map resources to discover available in-network services,
  nor any information to help ALTO clients determine how to effectively and
  efficiently use these services.

This document specifies a new extension to incorporate these newly emerged
scenarios into the ALTO framework. The essence of this extension is that an ALTO
server exposes correlations of network paths in additional to preferences of
network paths.

The correlations of network paths are represented by path vectors. Each element
in a path vector, which is referred to as an abstract network element (ANE), is
the aggregation of network components on the path, such as routers, switches,
links and clusters of in-network servers. If an abstract network element appears
in multiple network paths, the traffic along these paths will join at this
abstract network element and are subject to the corresponding resource
constraints.

The availability of the path correlations by itself can help ALTO clients
conduct better traffic scheduling. For example, an ALTO client can use the
path correlations to conduct more intelligent end-to-end measurement and
identify traffic bottlenecks.

By augmenting these abstract network elements with different properties, an ALTO
server can provide a more fine-grained view of the network. ALTO clients can use
this view to derive information such as shared risk resource groups, capacity
regions and available in-network cache locations, which can be used to improve
the robustness and performance of the application traffic.
