# Use Case: Capacity Region for Multi-Flow Scheduling # {#SecMF}

Consider the case that routing is given. Then what application-layer traffic optimization will focus on is traffic scheduling among application-layer paths. Specifically, assume that an application has control over a set of flows F = {f_1, f_2, ..., f_|F|}. If routing is given, what the application can control is x_1, x_2, ..., x_|F|, where x_i is the amount of traffic for flow i. Let x = [x_1, ..., x_|F|] be the vector of the flow traffic amounts. Due to shared links, feasible values of x where link capacities are not exceeded can be a complex polytype.

Specifically, consider a network as shown in [](#MFUseCase). The network has 7 switches (sw1 to sw7) forming a dumb-bell topology. Switches sw1/sw3 provide access on one side, sw2/sw4 provide access on the other side, and sw5-sw7 form the backbone. End hosts eh1 to eh4 are connected to access switches sw1 to sw4 respectively. Assume that the bandwidth of each link is 100 Mbps.

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

Consider an application overlay (e.g., a large data analysis system) which needs to schedule the traffic among a set of end host source-destination pairs, say eh1 -> eh2, and eh3 -> eh4. The application can request a cost map providing end-to-end available bandwidth, using 'availbw' as cost-metric  and 'numerical' as cost-mode.

Assume that the application receives from the ALTO server that the bandwidth of eh1 -> eh2 and eh3 ->eh4 are both 100 Mbps. It cannot determine that if it schedules the two flows together, whether it will obtain a total of 100 Mbps or 200 Mbps. This depends on whether the routing paths of the two flows share a bottleneck in the underlying topology:

- Case 1: If eh1 -> eh2 and eh3 -> eh4 use different paths, for example, when the first uses sw1 -> sw5 -> sw7 -> sw2, and the second uses sw3 -> sw5 -> sw6 -> sw7 -> sw4. Then the application will obtain 200 Mbps.
- Case 2: If eh1 -> eh2 and eh3 -> eh4 share a bottleneck, for example, when both use the direct link sw5 -> sw7, then the application will obtain only 100 Mbps.

To allow applications to distinguish the two aforementioned cases, the network needs to provide more details. In particular, it needs to provide the following new capabilities:

- The network needs to expose more detailed routing information to show the shared bottlenecks.
- The network needs to provide the necessary abstraction to hide the real topology information as possible.

The path-vector extension defined in this document will satisfy all the requirements.

See [](#I-D.bernstein-alto-topo) for a survey of use-cases where extended network topology information is needed.

