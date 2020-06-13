# Specification: Basic Data Types {#Basic}

## ANE Domain {#ane-domain-spec}

The ANE domain associates property values with the Abstract Network Elements
contained in a Path Vector response, which can either be a Cost Map
({{pvcm-spec}}) or an Endpoint Cost Service ({{pvecs-spec}}). Thus, the ANE
domain always depends on a Cost Map or an Endpoint Cost Map.

### Entity Domain Type ##

ane

### Entity Identifier ## {#entity-address}

An ANE Name is encoded as a JSON string with the same format as that of the type
EntityIdentifer (Section 3.1.3 of [I-D.ietf-alto-unified-props-new]) where the
EntityDomainName MUST be "ane", indicating that this entity belongs to the "ane"
Entity Domain.

The type ANEName is used in this document to indicate a string of this
format.

The entity identifiers are the ANE names contained in a Path Vector response.

### Hierarchy and Inheritance

There is no hierarchy or inheritance for properties associated with ANEs.

### Originating Information Resource

The ANE domain has two originating information resources:

- Cost Map
- Endpoint Cost Map

For each Path Vector request to an originating information resource, the `ane`
domain is defined by the ANE names contained in the corresponding Path Vector
response.

## ANE Property Name {#ane-prop-name-spec}

An ANE Property Name is encoded as a JSON string with the same format as that of
Entity Property Name (Section TBD of {{I-D.ietf-alto-unified-props-new}}).

## Initial ANE Property Types

In this document, two initial ANE property types are specified,
`max-reservable-bandwidth` and `persistent-entities`.

Note that the two property types defined in this document do not depend on any
information resource, so their ResourceID part must be empty.

~~~~~~~~~~ drawing
                                    ----- L1
                                   /
       PID1   +---------------+ 10 Gbps +----------+    PID3
1.2.3.0/24+---+ +-----------+ +---------+          +---+3.4.5.0/24
              | | WebCache1 | |         |          |
              | +-----------+ |   +-----+          |
       PID2   |               |   |     +----------+
2.3.4.0/24+---+ +-----------+ |   |         NET3
              | | WebCache2 | |   | 15 Gbps
              | +-----------+ |   |        \
              +---------------+   |         -------- L2
                    NET1          |
                           +---------------+
                           | +-----------+ |   PID4
                           | | WebCache3 | +---+4.5.6.0/24
                           | +-----------+ |
                           +---------------+
                                 NET2
~~~~~~~~~~
{: #fig-pe artwork-align="center" title="Examples of ANE Properties"}

In this document, {{fig-pe}} is used to illustrate the use of the two initial
ANE property types. There are 3 sub-networks (NET1, NET2 and NET3) and two
interconnection links (L1 and L2). It is assumed that each sub-network has
sufficiently large bandwidth to be reserved.

### ANE Property Type: Maximum Reservable Bandwidth {#maxresbw}

The `maximum reservable bandwidth` property stands for the maximum bandwidth that
can be reserved for all the traffic that traverses an ANE. The Entity Property
Type of the maximum reservable bandwidth is "max-reservable-bandwidth", and the
value MUST be encoded as a non-negative numerical cost value as defined in
Section 6.1.2.1 of {{RFC7285}} and the unit is bit per second.

To illustrate the use of `max-reservable-bandwidth`, consider the network in
{{fig-pe}}. An ALTO server can create an ANE for each interconnection link,
where the initial value for `max-reservable-bandwidth` is the link capacity.

If this property is requested but not present in an ANE, it MUST be interpreted
as that the ANE does not support bandwidth reservation.

The aggregated value of a Path Vector is the minimum value of all the ANEs in
the Path Vector. For example, assume a Path Vector response contains three ANEs
with the following maxresbw values:

| ANEName | max-reservabe-bandwidth |
|---------|----------|
| ane:1   | 100 Gbps |
| ane:2   |  10 Gbps |
| ane:3   |  20 Gbps |

The aggregated `max-reservable-bandwidth` (abbreviated as MRB) for ["ane:1", "ane:2", "ane:3"] is
calculated as follows:

~~~
  MRB(["ane:1", "ane:2", "ane:3"])
= min(MRB("ane:1"), MRB("ane:2"), MRB("ane:3"))
= min(100 Gbps, 10 Gbps, 20 Gbps) = 10 Gbps
~~~

### ANE Property Type: Persistent Entities {#persistent-entities}

The `persistent entities` property stands for the physical or logical network
entities (e.g., links, in-network services) that are contained by an ANE. It is
indicated by the property name `persistent-entities`. The value is encoded as a
JSON array of JSON strings that have the same format as that of the type
EntityIdentifiers. These EntityIdentifiers are persistent so that a client can
further query their properties for future use.

To illustrate the use of persistent entities, consider the network in
{{fig-pe}}. An ALTO server can create an ANE for each sub-network. Assume the
ALTO server wants to expose web caches deployed in the network to users to allow
faster data access and to save its inbound traffic. Thus, WebCache1 and
WebCache2 are announced as `persistent-entities` in ANE1, and WebCache3 is
announced as `persistent-entities` in ANE2. The clients can use the entity
identifiers of these web caches to query the detailed information in another
Unified Property Map.

If this property is requested but is missing for a an ANE entity, it MUST be
interpreted as an empty array which indicates that no persistent entities are
defined within the scope of this ANE.

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
type ResourceID (Section 10.2 of {{RFC7285}}).

NOTE: Even though the client-id assigned to a Path Vector request and the
Part Resource ID MAY contain up to 64 characters by their own definition, their
concatenation (see {{ref-partmsg-design}}) MUST also conform to the same length
constraint. The same requirement applies to the resource ID of the Path Vector
resource, too. Thus, it is RECOMMENDED to limit the length of resource ID and
client ID related to a Path Vector resource to 31 characters.
