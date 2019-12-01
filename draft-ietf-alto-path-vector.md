---
title: ALTO Extension: Path Vector
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
    org: Sichuan University
    email: kaigao@scu.edu.cn
-
    ins: Y. Lee
    name: Young Lee

-
    ins: S. Randriamasy
    name: Sabine Randriamasy
    org: Nokia Bell Labs
    email: sabine.randriamasy@nokia-bell-labs.com

-
    ins:  Y. R. Yang
    name: Yang Richard Yang
    org: Yale University
    email: yry@cs.yale.edu

-
    ins: J. Zhang
    name: Jingxuan Jensen Zhang
    org: Tongji University
    email: jingxuan.n.zhang@gmail.com


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
