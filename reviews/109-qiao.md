Presentation and clarity of the draft:

1. In Abstract: "on particular network components or elements", it looks like
   the word element is no longer used in the remaining of the draft, hence
   should be removed. DONE

2. What is network component? The draft did not give a clear definition. In
   Abstract, it says "Examples of such abstracted components are networks, data
   centers or links.", and later in Section 3, it says "An Abstract Network
   Element is a representation of network components. It can be a link, a
   middlebox, a virtualized network function (VNF), etc., or their
   aggregations." I would suggest a clear definition about network component in
   Section 3. DONE

3. Mixed use of "network component" and "intermediate network component". For
example, in Section 3, it says "An Abstract Network Element is a representation
of network components.", but in Section 5, it says "introduces Abstract Network
Element (ANE) as the abstraction of intermediate network components". There are
a couple of more spots of this mixed use throughout the draft. DONE

4. In Abstract: "Each ANE is defined by a set of properties.", but in Section 3:
   "In a response, each ANE is represented by a unique ANE Name." Which one is
   the intended definition? My understanding is that the one in Section 3 seems
   more appropriate. DONE

5. In the example in Section 4.1, eh3 does not seem to be used anywhere. I would
   suggest removing it to make things simple and clean. DONE


Design issues:

The first two issues I have are the questions I asked previously in the mailing
list under the thread "[alto] Comments on the Path-Vector draft during IETF 102"
in August, 2018
(https://mailarchive.ietf.org/arch/msg/alto/rt0t_K-PuWcTiIlEn6XuTdpGL48/). I did
not see these two comments appropriately addressed/discussed in the current
draft:

  6. The semantics of "array of ANEs". In particular, in Section 3, it says
"(The path vector) conveys the information that the path between a source and a
destination traverses the ANEs in the same order as they appear in the Path
Vector." Must we require this traversal order in the response? Taking the
maximal bandwidth example we have always been using, does the user need the
traversal order of ANEs? Would enforcing such an order increase the
implementation complexity of the PV extension? In a response email from Jensen
in the same thread, he said we may add strong use cases to motivate the
necessity of "array" semantics, but it does not seem to be added in this draft.

  7. Handle multipath (and potentially multicast). In my previous email, I give
a proposal to address this issue in PV, which is motivated by RFC7911
("Advertisement of Multiple Paths in BGP"). Jensen replied that it may be better
to consider handling multipath in a separate document, but I want to use this
review opportunity to ask the opinion of all WG members about this issue.

Next, in Section 11 (security consideration), I have two more comments.

  8. For the measures to mitigate the risk of exposing fine-grained internal
     network structure, in some earlier papers by our WG members [1, 2, 3, 4],
     we already proposed certain mechanisms to mitigate this risk, i.e., a
     minimal-feasible region compression algorithm [1, 2] and a feasible-region
     obfuscation protocol. I would suggest the draft adding these references.
     DONE

  9. for the discussion on the availability of ALTO services, I disagree with
     the sentence "It is known that the computation of Path Vectors is unlikely
     to be cacheable, in that the results will depend on the particular requests
     (e.g., where the flows are distributed)." In [3, 4], we already proposed a
     precomputation-and-projection mechanism to improve the scalability and
     availability of the PV service. As such, I feel this issue is not
     introduced by PV, but rather an inherent issue of the ATLO protocol.
     DONE


[1] Kai Gao, Qiao Xiang, Xin Wang, Yang Richard Yang, Jun Bi: NOVA: Towards
on-demand equivalent network view abstraction for network optimization. IWQoS
2017: 1-10
[2] Kai Gao, Qiao Xiang, Xin Wang, Yang Richard Yang, Jun Bi: An
Objective-Driven On-Demand Network Abstraction for Adaptive Applications.
IEEE/ACM Trans. Netw. 27(2): 805-818 (2019)
[3] Qiao Xiang, J. Jensen Zhang, X. Tony Wang, Y. Jace Liu, Chin Guok, Franck
Le, John MacAuley, Harvey Newman, Yang Richard Yang: Fine-grained, multi-domain
network resource abstraction as a fundamental primitive to enable
high-performance, collaborative data sciences. SC 2018: 5:1-5:13
[4] Qiao Xiang, Jingxuan Jensen Zhang, Xin Tony Wang, Yang Jace Liu, Chin Guok,
Franck Le, John MacAuley, Harvey Newman, Yang Richard Yang: Toward Fine-Grained,
Privacy-Preserving, Efficient Multi-Domain Network Resource Discovery. IEEE J.
Sel. Areas Commun. 37(8): 1924-1940 (2019)
