# Use Cases {#use-cases}

This section describes typical use cases of the path vector extension. For each
example, we demonstrate that it is beyond the capabilities of the current ALTO
framework and thus provides a new usage scenario. In this first two example, we
also demonstrate the benefits of constructing abstract network elements on demand.

## Shared Risk Resource Group {#uc-srrg}

Consider an application which controls 4 end hosts (eh1, eh2, eh3 and eh4),
which are connected by an ISP network with 5 switches (sw1, sw2, sw3, sw4 and
sw5) and 5 links (l1, l2, l3, l4 and l5), as shown in [](#UCTP). Assume the end
hosts are running data storage services and some analytics tasks, which requires
high data availability. In order to determine the replica placement, the
application must know how the end hosts will be partitioned if certain network
failures happen.

For that purpose, the application uses an ALTO client, which communicates with
an ALTO server provided by the ISP network. Since the Endpoint Cost Service with
only scalar cost values cannot provide essential information for the
application, thus, both the client and the server have the path vector extension
enabled.

Assume the ISP uses shortest path routing. For simplicity, consider the data
availability on eh4. The network components on the paths from all other end
hosts to eh4 are as follows:

    eh1->eh4: sw1, l1, sw3, l4, sw5
    eh2->eh4: sw2, l2, sw3, l4, sw5
    eh3->eh4: sw4, l5, sw5

While an ALTO server can simply return the information above to the client, it
can benefit from on-demand aggregation of network components.

```
                 +-----------------+
   ------------->|                 |<---------
  /   ---------->|   ALTO Client   |<------   \
 /   /           +-----------------+       \   \
|   |                    ^                  |   |
|   |                    |                  |   |
|   |                    v                  |   |
|   |            +-----------------+        |   |
|   |  ..........|                 |......  |   |
|   |  .         |   ALTO Server   |     .  |   |
|   |  .         +-----------------+     .  |   |
|   |  .                                 .  |   |
|   v  . +-----+                 +-----+ .  v   |
|  eh1 --|     |-         l3.   -|     |-- eh3  |
|      . | sw1 | \..l1       ../ | sw4 | .      |
|      . +-----+  \  +-----+  /  +-----+ .      |
|      .           --|     |--      |    .      |
|      .             | sw3 |    l5..|    .      |
|      .           --|     |--      |    .      |
|      . +-----+  /  +-----+  \  +-----+ .      |
|      . |     | /..l2     l4..\ |     | .      |
-->eh2 --| sw2 |-               -| sw5 |-- eh4<--
       . +-----+                 +-----+ .
       ...................................
```
^[UCTP::Topology for the Shared Risk Resource Group and the Capacity Region Use Cases]

These network components can be categorized into 5 categories:

1. Failure will only disconnect eh1 to eh4: sw1, l1.
2. Failure will only disconnect eh2 to eh4: sw2, l2.
3. Failure will only disconnect eh3 to eh4: sw4, l5.
4. Failure will only disconnect eh1 and eh2 to eh4: sw3, l4.
5. Failure will disconnect eh1, eh2 and eh3 to eh4: sw5.

The ALTO server can then aggregate sw1 and l1 as an abstract network element,
ane1. By applying the aggregation to the categories, the response may be as
follows:

    eh1->eh4: ane1, ane4, ane5
    eh2->eh4: ane2, ane4, ane5
    eh3->eh4: ane3, ane5

Thus, the application can still derive the potential network partitions for all
possible network failures without knowing the exact network topology, which
protects the privacy of the ISP. Note this aggregation is specific to the query,
i.e., the response is constructed on demand. If we change a source or a
destination in the query, for example exchange the role of eh3 and eh4, we get
the same failure categories but each category has a different set of links and
switches.


## Capacity Region {#uc-cr}

This use case uses the same topology and application settings as
in [](#uc-srrg) as shown in [](#UCTP). Assume the capacity of each link is 10
Gbps, except l5 whose capacity is 5 Gbps. Assume the application is running a
map-reduce task, where the optimal traffic scheduling is usually referred to the
co-flow scheduling problem. Consider a simplified co-flow scheduling problem,
e.g., the first stage of a map-reduce task which needs to transfer data from two
data nodes (eh1 and eh3) to the mappers (eh2 and eh4). In order to optimize the
job completion time, the application needs to determine the bottleneck of the
transfers.

If the ALTO server encodes the routing cost as bandwidth of the path, the client
will obtain the following information:

    eh1->eh2: 10 Gbps,
    eh1->eh4: 10 Gbps,
    eh3->eh2: 10 Gbps,
    eh3->eh4:  5 Gbps.

However, it does not provide sufficient information to determine the bottleneck.
With the path vector extension, the ALTO server will first return the
correlations of network paths between eh1, eh3 and eh2, eh4, as follows:

    eh1->eh2: ane1 (l1), ane2 (l2),
    eh1->eh4: ane1 (l1), ane4 (l4),
    eh3->eh2: ane3 (l3), ane2 (l2),
    eh3->eh3: ane5 (l5).

Meanwhile, the ALTO server also returns the capacity of each ANE:

    ane1.capacity = 10 Gbps,
    ane2.capacity = 10 Gbps,
    ane3.capacity = 10 Gbps,
    ane4.capacity = 10 Gbps,
    ane5.capacity =  5 Gbps.

With the correlation of network paths and the link capacity property, the client
is able to derive the capacity region of data transfer rates. Let x1 denote the
transfer rate of eh1->eh2, x2 denote the rate of eh1->eh4, x3 denote the rate of
eh3->eh2, and x4 denote the rate of eh3->eh4. The application can derive the
following information from the responses:

```
      eh1->eh2  eh1->eh4  eh3->eh2  eh3->eh4      capaity
ane1     1         1         0         0      |   10 Gbps
ane2     1         0         1         0      |   10 Gbps
ane3     0         0         1         0      |   10 Gbps
ane4     0         1         0         0      |   10 Gbps
ane5     0         0         0         1      |    5 Gbps
```

Specifically, the coefficient matrix on the left hand side is the transposition
of the matrix directly derived from the path vector part, and the
right-hand-side vector is directly derived from the property map part. Thus, the
bandwidth constraints of the data transfers are as follows:

    x1 + x2 <= 10 Gbps (ane1),
    x1 + x3 <= 10 Gbps (ane2),
    x3      <= 10 Gbps (ane3),
    x2      <= 10 Gbps (ane4),
    x4      <=  5 Gbps (ane5).

Now we demonstrate how the property can lead to better on-demand aggregation.
For the capacity region use case, we can easily conclude that each abstract
network element refers to a linear constraint. For the example, we can see that
the constraints of ane3 and ane4 are redundant, i.e., they can be removed
without affecting the final capacity region. Thus, an ALTO server can return the
following information:

    eh1->eh2: ane1 (l1), ane2 (l2),
    eh1->eh4: ane1 (l1),
    eh3->eh2: ane2 (l2),
    eh3->eh3: ane5 (l5),

and

    ane1.capacity = 10 Gbps,
    ane2.capacity = 10 Gbps,
    ane5.capacity =  5 Gbps.

## In-Network Caching {#uc-inc}

Consider an application which controls 3 end hosts (eh1, eh2 and eh3), which are
connected by an ISP network and the Internet, as shown in [](#INCTP). Assume two
clients at end hosts eh2 and eh3 are downloading the same data from a data
server at eh1. Meanwhile, the network provider offers an in-network caching
service at the gateway.

```
                +-------------+
        ------->|             |<-----------------------
       /  ----->| ALTO Client |<-------                \
      /  /      +-------------+       |                 \
     /  /                             v                  |
    /  /                          +-------------+        |
   /  /   ........................| ALTO Server |......  |
  /  /    .                       +-------------+     .  |
 /  /     .                     +---------+           .  |
|  |      .                    -+ Caching |           .  |
|  |      .                   / | Proxy   |           .  |
|  |S     .+-------+         /  +---------+           .  |
|  -->eh1--| sub   |_       |                         .  |
|         .| net 1 | \   +------+         +----------+.  |
|         .+-------+  ---|      |         |          |.  v C2
|         .              | Gate +---------+ Internet |--eh3
|   C1    .+-------+   --| way  |         |          |.
----->eh2--| sub   |__/  +------+         +----------+.
          .| net 2 |                                  .
          .+-------+                                  .
          .............................................
```
^[INCTP::Topology for the In-Network Caching Use Case.]

With the path vector extension enabled, the ALTO server can expose two types of information

Without the traffic correlation information, the ALTO client cannot know whether
or how the traffic goes through the proxy. For example, if subnet1 and subnet2
are directly connected and the traffic from eh1 to eh2 bypasses the gateway, the
in-network cache can only be used for traffic from C2 to S and is less
effective.
