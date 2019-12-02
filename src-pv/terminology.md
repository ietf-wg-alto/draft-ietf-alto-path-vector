# Terminology # {#term}

This document extends the ALTO base protocol [](#RFC7285) and the Unified
Property Map extension [](#I-D.ietf-alto-unified-props-new). In addition to
the ones defined in these documents, this document also uses the following
additional terms:

- Abstract network element (ANE): An abstract network element is an abstraction
  of network components. It can be a link, a middlebox, a virtualized network
  function (VNF), etc., or their aggregations. An abstract network element can
  be constructed either statically in advance or on demand based on the
  requested information. In a response, each abstract network element is
  represented by a unique ANE identifier. Note that an ALTO client MUST NOT
  assume ANEs in different responses but with the same identifier refer to the
  same aggregation of network components.

- Path vector: A path vector is an array of ANE identifiers. It presents an
  abstract network path between source/destination points such as PIDs or
  endpoints.

- Path vector resource: A path vector resource refers to an ALTO resource which
  supports the extension defined in this document.

- Path vector query/request: A path vector query or request refers to the POST
  message sent to an ALTO path vector resource, requesting for path vectors of
  different source/destination pairs and associated properties.

- Path vector response: A path vector response refers to the multipart/related
  message returned by a path vector resource. It consists of a path vector part,
  i.e., the (endpoint) cost map part which contains the path vector information,
  and a property map part.
