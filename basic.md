# Basic Data Types {#Basic}

## ANE Identifier {#ane-id}

An ANE identifier is encoded as a JSON string. The string MUST be no more than
64 characters, and it MUST NOT contain characters other than US-ASCII
alphanumeric characters (U+0030-U+0039, U+0041-U+005A, and U+0061-U+007A), the
hyphen (`-`, U+002D), the colon (`:`, U+003A), the at sign (`@`, code point
U+0040), the low line (`_`, U+005F), or the `.` separator (U+002E). The `.`
separator is reserved for future use and MUST NOT be used unless specifically
indicated in this document, or an extension document.

The type ANEIdentifier is used in this document to indicate a string of this
format.

## Path Vector Cost Type {#cost-type}

This document defines a new cost type, which is referred to as the `path vector`
cost type. An ALTO server MUST offer this cost type if it supports the path
vector extension.

### Cost Metric: ane-path{#metric-spec}

This cost metric conveys an array of ANE identifiers, where each identifier
uniquely represents an ANE traversed by traffic from a source to a destination.

### Cost Mode: array {#mode-spec}

This cost mode indicates that every cost value in a cost map or an endpoint cost
map MUST be interpreted as a JSON array object.

Note that this cost mode only requires the cost value to be a JSON array of
JSONValue. However, an ALTO server that enables this extension MUST return a
JSON array of ANEIdentifier ({{ane-id}}) when the cost metric is "ane-path".

## ANE Domain {#SecANEDomain}

This document specifies a new ALTO entity domain called `ane` in addition to the
ones in {{I-D.ietf-alto-unified-props-new}}. The ANE domain associates property
values with the ANEs in a network. The entity in ANE domain is often used in the
path vector by cost maps or endpoint cost resources. Accordingly, the ANE domain
always depends on a cost map or an endpoint cost map.

### Entity Domain Type ##

ane

### Domain-Specific Entity Identifier ## {#entity-address}

The entity identifier of ANE domain uses the same encoding as ANEIdentifier
({{ane-id}}).

### Hierarchy and Inheritance

There is no hierarchy or inheritance for properties associated with ANEs.

## New Resource-Specific Entity Domain Exports

### ANE Domain of Cost Map Resource {#costmap-ede}

If an ALTO cost map resource supports `ane-path` cost metric, it can export an
`ane` typed entity domain defined by the union of all sets of ANE names, where
each set of ANE names are an `ane-path` metric cost value in this ALTO cost map
resource.

### ANE Domain of Endpoint Cost Resource {#ec-ede}

If an ALTO endpoint cost resource supports `ane-path` cost metric, it can export
an `ane` typed entity domain defined by the union of all sets of ANE names,
where each set of ANE names are an `ane-path` metric cost value in this ALTO
endpoint cost resource.

## ANE Properties {#SecANEProp}

### ANE Property: Maximum Reservable Bandwidth {#maxresbw}

The maximum reservable bandwidth property conveys the maximum bandwidth that can
be reserved for traffic from a source to a destination and is indicated by the
property name "maxresbw". The value MUST be encoded as a numerical cost value as
defined in Section 6.1.2.1 of {{RFC7285}} and the unit is bit per second.

If this property is requested but is missing for a given ANE, it MUST be
interpreted as that the ANE does not support bandwidth reservation but have
sufficiently large bandwidth for all traffic that traverses it.

### ANE Property: Persistent Entity

The persistent entity property conveys the physical or logical network entities
(e.g., links, in-network caching service) that are contained by an abstract
network element. It is indicated by the property name `persistent-entity`. The
value is encoded as a JSON array of entity identifiers
({{I-D.ietf-alto-unified-props-new}}). These entity identifiers are persistent
so that a client CAN further query their properties for future use.

If this property is requested but is missing for a given ANE, it MUST be
interpreted as that no such entities exist in this ANE.

## Part Resource ID {#mpri}

A Part Resource ID is encoded as a JSON string with the same format as that of the
Resource ID (Section 10.2 of {{RFC7285}}).

WARNING: Even though the client-id assigned to a path vector request and the
Part Resource ID MAY contain up to 64 characters by their own definition. Their
concatenation (see {{design-rpm}}) MUST also conform to the same length
constraint. The same requirement applies to the resource ID of the path vector
resource, too. Thus, it is RECOMMENDED to limit the length of resource ID and
client ID related to a path vector resource to 31 characters.
