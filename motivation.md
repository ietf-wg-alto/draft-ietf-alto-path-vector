# Use Case

## Capacity Region for Co-Flow Scheduling # {#SecMF}

<!-- Consider the case that routing is given. Then what application-layer traffic optimization will focus on is traffic scheduling among application-layer paths. -->

<!-- Done: Revise the first paragraph. -->
<!--Once routing has been configured in the network, application-layer traffic optimization may want to schedule traffic among application-layer paths. Specifically, assume that an application has control over a set of flows F = {f_1, f_2, ..., f_|F|}. If routing is given, what the application can control is x_1, x_2, ..., x_|F|, where x_i is the amount of traffic for flow i. Let x = [x_1, ..., x_|F|] be the vector of the flow traffic amounts. Due to shared links, feasible values of x where link capacities are not exceeded can be a complex polytype.-->

Assume that an application has control over a set of flows, which may go through
shared links or switches and share a bottleneck. The application hopes to
schedule the traffic among multiple flows to get better performance. The
capacity region information for those flows will benefit the scheduling.
However, existing cost maps cannot reveal such information.

Specifically, consider a network as shown in [](#MFUseCase). The network has 7
switches (sw1 to sw7) forming a dumb-bell topology. Switches sw1/sw3 provide
access on one side, sw2/sw4 provide access on the other side, and sw5-sw7 form
the backbone. Endhosts eh1 to eh4 are connected to access switches sw1 to sw4
respectively. Assume that the bandwidth all links are 100 Mbps.

```
                            +------+
                            |      |
                          --+ sw6  +--
                        /   |      |  \
  PID1 +-----+         /    +------+   \          +-----+  PID2
  eh1__|     |_       /                 \     ____|     |__eh2
       | sw1 | \   +--|---+         +---|--+ /    | sw2 |
       +-----+  \  |      |         |      |/     +-----+
                 \_| sw5  +---------+ sw7  |
  PID3 +-----+   / |      |         |      |\     +-----+  PID4
  eh3__|     |__/  +------+         +------+ \____|     |__eh4
       | sw3 |                                    | sw4 |
       +-----+                                    +-----+

```
^[MFUseCase::Raw Network Topology.]

The single-node ALTO topology abstraction of the network is shown in [](#SingleNodeAbs).

```
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
```
^[SingleNodeAbs::Base Single-Node Topology Abstraction.]

Consider an application overlay (e.g., a large data analysis system) which wants
to schedule the traffic among a set of end host source-destination pairs, say
eh1 -> eh2 and eh3 -> eh4. The application can request a cost map providing
end-to-end available bandwidth, using 'availbw' as cost-metric and 'numerical'
as cost-mode.

The application will receive from ALTO server that the bandwidth of eh1 -> eh2
and eh3 -> eh4 are both 100 Mbps. But this information is not enough. Consider
the following two cases:

- Case 1: If eh1 -> eh2 uses the path eh1 -> sw1 -> sw5 -> sw6 -> sw7 -> sw2 ->
  eh2 and eh3 -> eh4 uses path eh3 -> sw3 -> sw5 -> sw7 -> sw4 -> eh4, then the
  application will obtain 200 Mbps.
- Case 2: If eh1 -> eh2 uses the path eh1 -> sw1 -> sw5 -> sw7 -> sw2 -> eh2 and
  eh3 -> eh4 uses the path eh3 -> sw3 -> sw5 -> sw7 -> sw4 -> eh4, then the
  application will obtain only 100 Mbps due to the shared link from sw5 to sw7.

To allow applications to distinguish the two aforementioned cases, the network
needs to provide more details. In particular:
<!-- , it needs to provide the following new capabilities: -->

- The network needs to expose more detailed routing information to show the
  shared bottlenecks;
- The network needs to provide the necessary abstraction to hide the real
  topology information while providing enough information to applications.
<!-- as possible. -->

<!-- The path-vector extension defined in this document will satisfy all the requirements. -->
The path vector extension defined in this document provides a solution to address
the preceding issue.

See [](#I-D.bernstein-alto-topo) for a more comprehensive survey of use cases
where extended network topology information is needed.

## In-Network Caching

Consider a network as shown in [](#INC). Two clients (C1/eh2 and C2/eh3) are
downloading data from a server (S/eh1) and the network provides an HTTP proxy
which can cache results. The clients and the server are controlled by an ALTO
client.

```
                            +---------+
                            | Caching |
                           -+ Proxy   |
                          / |         |
S      +-------+         /  +---------+
  eh1__| sub   |_       /
       | net 1 | \   +--|---+         +----------+
       +-------+  ---|      |         |          |     C2
                     | Gate +---------+ Internet |__eh3
C1     +-------+   --| way  |         |          |
  eh2__| sub   |__/  +------+         +----------+
       | net 2 |
       +-------+
```
^[INC::Raw Topology for the In-Network Caching Use Case.]

Without the traffic correlation information, the ALTO client cannot know whether
or how the traffic goes through the proxy. For example, if subnet1 and subnet2
are directly connected and the traffic from eh1 to eh2 bypasses the gateway, the
in-network cache can only be used for traffic from C2 to S and is less
effective.
