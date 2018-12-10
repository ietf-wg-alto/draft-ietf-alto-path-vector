# Terminology # {#term}

Besides the terms defined in [](#RFC7285) and
[](#I-D.ietf-alto-unified-props-new), this document also uses the following
additional terms: Abstract Network Element, Path Vector.

<!-- FIXME: Do we really need so many terms? A lot of terms are useless actually -->

<!-- TODO: What are the real necessary terms we need? -->

- Abstract Network Element (ANE): An abstract network element is an abstraction
  of network components; it can be an aggregation of links, middle boxes,
  virtualized network function (VNF), etc. An abstract network element has two
  types of attributes: a name and a set of properties.
- Path Vector: A path vector is an array of ANEs. It presents an abstract
  network path between source/destination points such as PIDs or endpoints.

<!-- FIXED: Can we use ANE address here? Because it is actually the address of
the entity in ANE domain, if based on the term in unified props. -->

<!--
- Abstract Network Element Name (ANE Name): An abstract network element name is
  an identifier that uniquely identifies an abstract network element.
-->

<!-- FIXED: We don't need this term. Because it is actually the "property of
ANE" and can be explained very clearly. And we never use any special meaning of
this term in the whole document. -->

<!--
- Abstract Network Element Property (ANE Property): An abstract network element
  property is a network-related property of an abstract network element, such as
  `bandwidth` for links, `delay` between two switches, etc.
-->

<!--An abstract network element can have a set of properties.-->

<!-- FIXED: It is tricky to use `ane` domain before we define it in the spec.
Actually it's just an abbr and already mentioned. Maybe we can remove it. -->

<!--
- Abstract Network Element Property Map (ANE Property Map): We use the term abstract network
  element property map is a Filtered Property Map defined in
  [](#I-D.ietf-alto-unified-props-new) which supports the `ane` domain in its
  `domain-types` capability.
-->

<!-- - Path Vector (PV): A path vector is an array of abstract network elements, representing an abstract path between entities (PIDs or endpoints). -->

<!-- An ANE represents a selected part of an end-to-end path that the ALTO Server considers worth exposing. -->
