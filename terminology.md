# Terminology # {#term}

This document extends the ALTO base protocol [](#RFC7285) and the Unified
Property Map extension [](#I-D.ietf-alto-unified-props-new). In additional to
the ones defined in these documents, this document also uses the following
additional terms: Abstract Network Element and Path Vector.

- Abstract Network Element (ANE): An abstract network element is an abstraction
  of network components. It can be an aggregation of links, middleboxes,
  virtualized network function (VNF), etc. An abstract network element has two
  types of attributes: a name and a set of properties.

- Path Vector: A path vector is an array of ANEs. It presents an abstract
  network path between source/destination points such as PIDs or endpoints.
