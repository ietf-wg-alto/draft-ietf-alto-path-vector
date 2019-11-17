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
