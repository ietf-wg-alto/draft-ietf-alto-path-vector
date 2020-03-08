# Basic Data Types {#Basic}

## ANE Name {#ane-name-spec}

An ANE Name is encoded as a JSON string, which has the same format as
EntityIdentifer (Section 3.1.3 of [I-D.ietf-alto-unified-props-new]) and the
EntityDomainName MUST be "ane", indicating that this entity belongs to the "ane"
Entity Domain.

The type ANEName is used in this document to indicate a string of this
format.

## ANE Domain {#ane-domain-spec}

This document specifies a new ALTO entity domain called `ane` in addition to the
ones in {{I-D.ietf-alto-unified-props-new}}. The ANE domain associates property
values with the ANEs in a network. The entity in ANE domain is often used in the
Path Vector by Cost Map or Endpoint Cost Service resources. Accordingly, the ANE
domain always depends on a Cost Map or an Endpoint Cost Map.

### Entity Domain Type ##

ane

### Domain-Specific Entity Identifier ## {#entity-address}

The entity identifier of ANE domain uses the same encoding as ANEName
({{ane-name-spec}}).

### Hierarchy and Inheritance

There is no hierarchy or inheritance for properties associated with ANEs.

## New Resource-Specific Entity Domain Exports

### ANE Domain of Cost Map Resource {#costmap-ede}

If an ALTO Cost Map resource supports the Path Vector cost type, it can export an
`ane` typed entity domain defined by the union of all sets of ANE names, where
each set of ANE names are an `ane-path` metric cost value in this ALTO Cost Map
resource.

### ANE Domain of Endpoint Cost Service Resource {#ec-ede}

If an ALTO Endpoint Cost Service resource supports the Path Vector cost type, it
can export an `ane` typed entity domain defined by the union of all sets of ANE
names, where each set of ANE names are an `ane-path` metric cost value in this
ALTO Endpoint Cost Service resource.

## ANE Property Name {#ane-prop-name-spec}

An ANE Property Name is encoded as an Entity Property Name (Section 3.2.2 of
{{I-D.ietf-alto-unified-props-new}}) where

- the ResourceID part of an ANE Property Name MUST be empty;

- the EntityPropertyType part MUST be a valid property of an ANE entity, i.e.,
  the mapping of the ANE domain type and the Entity Property Type MUST be
  registered to the ALTO Resource Entity Property Mapping Registries (Section
  11.5 in {{I-D.ietf-alto-unified-props-new}}).

### ANE Property: Maximum Reservable Bandwidth {#maxresbw}

The maximum reservable bandwidth property conveys the maximum bandwidth that can
be reserved for all the traffic that traverses an ANE. The Entity Property Type
of the maximum reservable bandwidth is "maxresbw", and the value MUST be encoded
as a non-negative numerical cost value as defined in Section 6.1.2.1 of
{{RFC7285}} and the unit is bit per second.

If this property is requested but not present in an ANE, it MUST be interpreted
as that the ANE has sufficiently large bandwidth to be reserved. If the ANE does
not support bandwidth reservation, the value MUST be present and be set to 0.

The aggregated value of a Path Vector is the minimum value of all the ANEs in
the Path Vector.

### ANE Property: Persistent Entities {#persistent-entities}

The persistent entities property conveys the physical or logical network entities
(e.g., links, in-network caching service) that are contained by an ANE. It is
indicated by the property name `persistent-entities`. The value is encoded as a
JSON array of entity identifiers ({{I-D.ietf-alto-unified-props-new}}). These
entity identifiers are persistent so that a client CAN further query their
properties for future use.

If this property is requested but is missing for a given ANE, it MUST be
interpreted as that no such entities exist in this ANE.

## Path Vector Cost Type {#cost-type-spec}

This document defines a new cost type, which is referred to as the `Path Vector`
cost type. An ALTO server MUST offer this cost type if it supports the Path
Vector extension.

### Cost Metric: ane-path {#metric-spec}

This cost metric conveys an array of ANE names, where each ANE name uniquely
represents an ANE traversed by traffic from a source to a destination.

### Cost Mode: array {#mode-spec}

This cost mode indicates that every cost value in a Cost Map or an Endpoint Cost
Map MUST be interpreted as a JSON array object.

Note that this cost mode only requires the cost value to be a JSON array of
JSONValue. However, an ALTO server that enables this extension MUST return a
JSON array of ANEName ({{ane-name-spec}}) when the cost metric is
"ane-path".

## Part Resource ID {#part-rid-spec}

A Part Resource ID is encoded as a JSON string with the same format as that of the
Resource ID (Section 10.2 of {{RFC7285}}).

WARNING: Even though the client-id assigned to a Path Vector request and the
Part Resource ID MAY contain up to 64 characters by their own definition. Their
concatenation (see {{ref-partmsg-design}}) MUST also conform to the same length
constraint. The same requirement applies to the resource ID of the Path Vector
resource, too. Thus, it is RECOMMENDED to limit the length of resource ID and
client ID related to a Path Vector resource to 31 characters.
