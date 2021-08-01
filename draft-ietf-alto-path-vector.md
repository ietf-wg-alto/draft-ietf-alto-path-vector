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
    country: South Korea
    org: Samsung
    email: younglee.tx@gmail.com

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
  RFC2119:
  RFC7285:
  RFC2387:
  RFC8174:
  RFC8189:
  RFC8895:
  RFC8896:
  I-D.ietf-alto-unified-props-new:

informative:
  RFC2216:
  RFC7540:
  I-D.ietf-quic-http:
  I-D.ietf-alto-performance-metrics:
  I-D.ietf-dmm-5g-uplane-analysis:
  I-D.contreras-alto-service-edge:
  I-D.yang-alto-deliver-functions-over-networks:
  I-D.huang-alto-mowie-for-network-aware-app:
  XQuery:
    title: "XQuery 3.1: An XML Query Language"
    target: https://www.w3.org/TR/xquery-31/
    date: 2017

  JSONiq:
    title: "The JSON Query language"
    target: https://www.jsoniq.org/
    date: 2020

  JSAC2019:
    title: "Toward Fine-Grained, Privacy-Preserving, Efficient Multi-Domain Network Resource Discovery"
    author:
      -
        ins: Q. Xiang
        name: Qiao Xiang
        org: Yale University
      -
        ins: J. Zhang
        name: Jingxuan Zhang
        org: Tongji University
      -
        ins: X. Wang
        name: Xin Wang
        org: Tongji University
      -
        ins: Y. Liu
        name: Yang Liu
        org: Tongji University
      -
        ins: C. Guok
        name: Chin Guok
        org: ESNet
      -
        ins: F. Le
        name: Franck Le
        org: IBM T.J. Watson Research Center
      -
        ins: J. MacAuley
        name: John MacAuley
        org: ESNet
      -
        ins: H. Newman
        name: Harvey Newman
        org: Caltech
      -
        ins: Y. R. Yang
        name: Yang Richard Yang
        org: Yale University
    date: 2019
    seriesinfo:
      IEEE/ACM: "IEEE Journal on Selected Areas of Communication 37(8): 1924-1940"

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

  SC2018:
    title: "Fine-grained, multi-domain network resource abstraction as a fundamental primitive to enable high-performance, collaborative data sciences"
    author:
      -
        ins: Q. Xiang
        name: Qiao Xiang
        org: Yale University
      -
        ins: J. Zhang
        name: Jingxuan Zhang
        org: Tongji University
      -
        ins: X. Wang
        name: Xin Wang
        org: Tongji University
      -
        ins: Y. Liu
        name: Yang Liu
        org: Tongji University
      -
        ins: C. Guok
        name: Chin Guok
        org: ESNet
      -
        ins: F. Le
        name: Franck Le
        org: IBM T.J. Watson Research Center
      -
        ins: J. MacAuley
        name: John MacAuley
        org: ESNet
      -
        ins: H. Newman
        name: Harvey Newman
        org: Caltech
      -
        ins: Y. R. Yang
        name: Yang Richard Yang
        org: Yale University
    date: 2019
    seriesinfo:
      "Proceedings of the Super Computing 2018, 5:1-5:13"

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
    seriesinfo:
      "Proceedings of the AAAI Conference on Artificial Intelligence 33, 1674-1681"

  SENSE:
    title: "Services - SENSE"
    target: http://sense.es.net/services
    date: 2019

  LHC:
    title: "CERN - LHC"
    target: https://atlas.cern/tags/lhc
    date: 2019

--- abstract

This document is an extension to the base Application-Layer Traffic Optimization
(ALTO) protocol. It extends the ALTO Cost Map service and ALTO Property Map
service so that the application can decide which endpoint(s) to connect based on
not only numerical/ordinal cost values but also details of the paths. This is
useful for applications whose performance is impacted by specified components of
a network on the end-to-end paths, e.g., they may infer that several paths share
common links and prevent traffic bottlenecks by avoiding such paths. This
extension introduces a new abstraction called Abstract Network Element (ANE) to
represent these components and encodes a network path as a vector of ANEs. Thus,
it provides a more complete but still abstract graph representation of the
underlying network(s) for informed traffic optimization among endpoints.

--- middle

{::include introduction.md}

{::include overview.md}

{::include basic.md}

{::include services.md}

{::include examples.md}

{::include others.md}

--- back

# Changes since -14

Revision -15

- fixes the IDNits warnings,
- addresses the comments in the AD review.

# Changes since -13

Revision -14

- addresses the comments in the chair review,
- fixes most issues raised by IDNits.

# Changes since -12

Revision -13

- changes the abstract based on the chairs' reviews
- integrates Richard's responds to WGLC reviews

# Changes since -11

Revision -12

- clarifies the definition of ANEs in a similar way as how Network Elements is
  defined in {{RFC2216}}
- restructures several paragraphs that are not clear (Sec 3, Path Vector bullet, Sec 4.2, Sec 5.1.3, Sec 6.2.4, Sec 6.4.2, Sec 9.3)
- uses `ALTO Entity Domain Type Registry`

# Changes since -10

Revision -11

- replaces "part"  with "components" in the abstract;
- identifies additional requirements (AR) derived from the flow scheduling
  example, and introduces how the extension addresses the additional
  requirements
- fixes the inconsistent use of "start" parameter in multipart responses;
- specifies explicitly how to handle "cost-constraints";
- uses the latest IANA registration mechanism defined in
  {{I-D.ietf-alto-unified-props-new}};
- renames `persistent-entities` to `persistent-entity-id`;
- makes `application/alto-propmap+json` as the media type of defining resources
  for the `ane` domain;
- updates the examples;
- adds the discussion on ephemeral and persistent ANEs.


# Changes since -09

Revision -10

- revises the introduction which
  - extends the scope where the PV extension can be applied beyond the "path
    correlation" information
- brings back the capacity region use case to better illustrate the problem
- revises the overview to explain and defend the concepts and decision choices
- fixes inconsistent terms, typos

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
