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
    title: "TON 2019"
    date: {DATE}

  SENSE:
    title: "SENSE"
    date: {DATE}

--- abstract

{::include abstract.md}

--- middle

{::include introduction.md}


# Changes since -08

This revision

- fixes a few spelling errors
- emphasizes that abstract network elements can be generated on demand in both
  introduction and motivating use cases

{::include motivation.md}

{::include overview.md}

{::include specification.md}

{::include examples.md}

{::include others.md}
