---
title: "ALTO Extension: Path Vector"
abbrev: ALTO-PV
docname: draft-ietf-alto-path-vector-latest
date: {DATE}
category: std
ipr: trust200902
area: Application
workgroup: ALTO

stand_alone: yes
pi: [toc, sortrefs, symrefs, docmapping]

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

informative:

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

  SENSE:
    title: "Services - SENSE"
    target: http://sense.es.net/services
    date: 2019

--- abstract

{::include src-pv/abstract.md}

--- middle

{::include src-pv/introduction.md}

{::include src-pv/terminology.md}

{::include src-pv/motivation.md}

{::include src-pv/overview.md}

{::include src-pv/specification.md}

{::include src-pv/examples.md}

{::include src-pv/others.md}

--- back

{::include src-pv/changes.md}
