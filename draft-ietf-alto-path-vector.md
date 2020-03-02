---
docname: draft-ietf-alto-path-vector-latest
title: "ALTO Extension: Path Vector"
abbrev: ALTO-PV
category: std
date: {DATE}

ipr: trust200902
area: Application
workgroup: ALTO

stand_alone: yes
pi:
  strict: yes
  comments: yes
  inline: yes
  editing: no
  toc: yes
  tocompact: yes
  tocdepth: 3
  iprnotified: no
  sortrefs: yes
  symrefs: yes
  compact: yes
  subcompact: no

author:
  -
    ins: K. Gao
    name: Kai Gao
    street: "No.24 South Section 1, Yihuan Road"
    city: Chengdu
    code: 610000
    country: China
    org: Sichuan University
    email: kaigao@scu.edu.cn
  -
    ins: Y. Lee
    name: Young Lee

  -
    ins: S. Randriamasy
    name: Sabine Randriamasy
    street: Route de Villejust
    city: Nozay
    code: 91460
    country: France
    org: Nokia Bell Labs
    email: sabine.randriamasy@nokia-bell-labs.com

  -
    ins:  Y. R. Yang
    name: Yang Richard Yang
    street: 51 Prospect Street
    city: New Haven
    code: CT
    country: USA
    org: Yale University
    email: yry@cs.yale.edu

  -
    ins: J. Zhang
    name: Jingxuan Jensen Zhang
    street: 4800 Caoan Road
    city: Shanghai
    code: 201804
    country: China
    org: Tongji University
    email: jingxuan.n.zhang@gmail.com

normative:
  RFC7285:
  RFC2387:
  RFC8189:
  I-D.ietf-alto-cost-calendar:
  I-D.ietf-alto-unified-props-new:
  I-D.ietf-alto-incr-update-sse:
  I-D.ietf-alto-performance-metrics:

informative:

  I-D.ietf-dmm-5g-uplane-analysis:
  I-D.contreras-alto-service-edge:
  I-D.yang-alto-deliver-functions-over-networks:

  TON2019:
    title: "An objective-driven on-demand network abstraction for adaptive applications"
    author:
      -
        ins: K. Gao
        name: Kai Gao
        org: Sichuan University
      -
        ins: Q. Xiang
        name: Qiao Xiang
        org: Yale University
      -
        ins: X. Wang
        name: Xin Wang
        org: Tongji University
      -
        ins: Y. R. Yang
        name: Yang Richard Yang
        org: Yale University
      -
        ins: J. Bi
        name: Jun Bi
        org: Tsinghua University
    date: 2019
    seriesinfo:
      IEEE/ACM: "Transactions on Networking (TON) Vol 27, no. 2 (2019): 805-818."

  AAAI2019:
    title: "Optimizing in the dark: Learning an optimal solution through a simple request interface"
    author:
      -
        ins: Q. Xiang
        name: Qiao Xiang
        org: Yale University
      -
        ins: H. Yu
        name: Haitao Yu
        org: Tongji University
      -
        ins: J. Aspnes
        name: James Aspnes
        org: Yale University
      -
        ins: F. Le
        name: Franck Le
        org: IBM T.J. Watson Research Center
      -
        ins: L. Kong
        name: Linghe Kong
        org: Shanghai Jiao Tong University
      -
        ins: Y. R. Yang
        name: Yang Richard Yang
        org: Yale University
    date: 2019
    seriesinfo: "Proceedings of the AAAI Conference on Artificial Intelligence 33, 1674-1681"

  SENSE:
    title: "Services - SENSE"
    target: http://sense.es.net/services
    date: 2019

  LHC:
    title: "CERN - LHC"
    target: https://atlas.cern/tags/lhc
    date: 2019

--- abstract

This document defines an ALTO extension that allows an ALTO information resource
to provide not only preferences but also correlations of the paths between
different PIDs or endpoints. The extended information, including aggregations of
network components on the paths and their properties, can be used to improve the
robustness and performance for applications in some new usage scenarios, such as
high-speed data transfers and traffic optimization using in-network storage and
computation.

This document reuses the mechanisms of the ALTO base protocol and the Unified
Property extension, such as Information Resource Directory (IRD) capabilities
and entity domains, to negotiate and exchange path correlation information.
Meanwhile, it uses an extended compound message to fully represent the path
correlation information, for better server scalability and message modularity.
Specifically, the extension 1) introduces abstract network element (ANE) as an
abstraction for an aggregation of network components and encodes a network path
as a "path vector", i.e., an array of ANEs traversed from the source to the
destination, 2) encodes properties of abstract network elements in a unified
property map, and 3) encapsulates the two types of information in a multipart
message.

--- middle

{::include introduction.md}

{::include overview.md}

{::include basic.md}

{::include services.md}

{::include examples.md}

{::include others.md}

--- back

# Changes since -08

This revision

- fixes a few spelling errors
- emphasizes that abstract network elements can be generated on demand in both
  introduction and motivating use cases

# Changes Since Version -06 #

- We emphasize the importance of the path vector extension in two aspects:

  1. It expands the problem space that can be solved by ALTO, from preferences
     of network paths to correlations of network paths.
  2. It is motivated by new usage scenarios from both application's and
     network's perspectives.

- More use cases are included, in addition to the original capacity region use
  case.

- We add more discussions to fully explore the design space of the path vector
  extension and justify our design decisions, including the concept of abstract
  network element, cost type (reverted to -05), newer capabilities and the
  multipart message.

- Fix the incremental update process to be compatible with SSE -16 draft, which
  uses client-id instead of resource-id to demultiplex updates.

- Register an additional ANE property (i.e., persistent-entities) to cover all
  use cases mentioned in the draft.
