# Specification: Basic Data Types {#Basic}

## ANE Name {#ane-name-spec}

An ANE Name is encoded as a JSON string, which has the same format as
EntityIdentifer (Section 3.1.3 of [I-D.ietf-alto-unified-props-new]) and the
EntityDomainName MUST be "ane", indicating that this entity belongs to the "ane"
Entity Domain.

The type ANEName is used in this document to indicate a string of this
format.

## ANE Domain {#ane-domain-spec}

The ANE domain associates property values with the Abstract Network Elements
contained in a Path Vector response, which can either be a Cost Map
({{pvcm-spec}}) or an Endpoint Cost Service ({{pvecs-spec}}). Thus, the ANE
domain always depends on a Cost Map or an Endpoint Cost Map.

### Entity Domain Type ##

ane

### Domain-Specific Entity Identifier ## {#entity-address}

The entity identifiers are the ANE names contained in a Path Vector response.

### Hierarchy and Inheritance

There is no hierarchy or inheritance for properties associated with ANEs.

## ANE Property Name {#ane-prop-name-spec}

An ANE Property Name is encoded as an Entity Property Name (Section 3.2.2 of
{{I-D.ietf-alto-unified-props-new}}) where

- the ResourceID part of an ANE Property Name MUST be empty;

- the EntityPropertyType part MUST be a valid property of an ANE entity, i.e.,
  the mapping of the ANE domain type and the Entity Property Type MUST be
  registered to the ALTO Resource Entity Property Mapping Registries as
  instructed by Section 11.5 of {{I-D.ietf-alto-unified-props-new}}.

In this document, two initial ANE properties are specified, see {{maxresbw}} and
{{persistent-entities}} for details.

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
the Path Vector. For example, assume a Path Vector response contains three ANEs
with the following maxresbw values:

| ANEName | maxresbw |
|---------|----------|
| ane:1   | 100 Gbps |
| ane:2   |  10 Gbps |
| ane:3   |  20 Gbps |

The aggregated `maxresbw` for ["ane:1", "ane:2", "ane:3"] is calculated as follows:

~~~
  maxresbw(["ane:1", "ane:2", "ane:3"])
= min(maxresbw("ane:1"), maxresbw("ane:2"), maxresbw("ane:3"))
= min(100 Gbps, 10 Gbps, 20 Gbps) = 10 Gbps
~~~

### ANE Property: Persistent Entities {#persistent-entities}

The persistent entities property conveys the physical or logical network entities
(e.g., links, in-network caching service) that are contained by an ANE. It is
indicated by the property name `persistent-entities`. The value is encoded as a
JSON array of entity identifiers ({{I-D.ietf-alto-unified-props-new}}). These
entity identifiers are persistent so that a client CAN further query their
properties for future use.

If this property is requested but is missing for a given ANE, it MUST be
interpreted as an empty array which indicates that no such entities exist in
this ANE.

The aggregated value for the `persistent-entities` property of a Path Vector
is the concatenation of the values of all the ANEs in the Path Vector. For
example, assume a Path Vector response contains three ANEs with the following
persistent-entities values:

| ANEName | persistent-entities |
|---------|---------------------|
| ane:1   | ["dc:A", "dc:B"]    |
| ane:2   | []                  |
| ane:3   | ["dc:C"]            |

The aggregated `persistent-entities` for ["ane:1", "ane:2", "ane:3"] is calculated
as follows (for better readability, the `persistent-entities` property is
abbreviated as PE):

~~~
  PE(["ane:1", "ane:2", "ane:3"])
= concat(PE("ane:1"), PE("ane:2"), PE("ane:3"))
= concat(["dc:A", "dc:B"], [], ["dc:C"])
= ["dc:A", "dc:B", "dc:C"]
~~~

## Path Vector Cost Type {#cost-type-spec}

This document defines a new cost type, which is referred to as the `Path Vector`
cost type. An ALTO server MUST offer this cost type if it supports the Path
Vector extension.

### Cost Metric: ane-path {#metric-spec}

The cost metric "ane-path" indicates the value of such a cost type conveys an
array of ANE names, where each ANE name uniquely represents an ANE traversed by
traffic from a source to a destination.

### Cost Mode: array {#mode-spec}

The cost mode "array" indicates that every cost value in a Cost Map or an
Endpoint Cost Map MUST be interpreted as a JSON array object.

Note that this cost mode only requires the cost value to be a JSON array of
JSONValue. However, an ALTO server that enables this extension MUST return a
JSON array of ANEName ({{ane-name-spec}}) when the cost metric is
"ane-path".

## Part Resource ID {#part-rid-spec}

A Part Resource ID is encoded as a JSON string with the same format as that of the
Resource ID (Section 10.2 of {{RFC7285}}).

NOTE: Even though the client-id assigned to a Path Vector request and the
Part Resource ID MAY contain up to 64 characters by their own definition. Their
concatenation (see {{ref-partmsg-design}}) MUST also conform to the same length
constraint. The same requirement applies to the resource ID of the Path Vector
resource, too. Thus, it is RECOMMENDED to limit the length of resource ID and
client ID related to a Path Vector resource to 31 characters.
