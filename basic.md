# Specification: Basic Data Types {#Basic}

## ANE Name {#ane-name-spec}

An ANE Name is encoded as a JSON string with the same format as that of the type
PIDName (Section 10.1 of {{RFC7285}}).

The type ANEName is used in this document to indicate a string of this
format.

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

### Media Type of Defining Resource

The media type of defining resources for the `ane` domain is
`application/alto-propmap+json`.

The defining resource of ephemeral ANEs is the Property Map part of the
multipart response. The defining resource of persistent ANEs is the Property Map
on which standalone queries for properties of persistent ANEs are made.

Similarly to entities of the PID domain, ANE domains are intrinsically resource
specific. The reason is that, just like PIDs, ANEs Identifiers are arbitrarily
defined and do not have a standardized format, unlike routable IPv4 or IPv6
addresses. A name such as examples `Link10`, `DataCenterEU33.ServerFarm.AppNN`
can be defined in several property maps, with different meanings.

### Security Considerations

In some usage scenarios, ANE addresses carried in ALTO Protocol messages may
reveal information about an ALTO client or an ALTO service provider.
Applications and ALTO service providers using addresses of ANEs will be made
aware of how (or if) the addressing scheme relates to private information and
network proximity, in further iterations of this document.

## ANE Property Name {#ane-prop-name-spec}

An ANE Property Name is encoded as a JSON string with the same format as that of
Entity Property Name (Section TBD of {{I-D.ietf-alto-unified-props-new}}).

## Initial ANE Property Types

In this document, two initial ANE property types are specified,
`max-reservable-bandwidth` and `persistent-entity-id`.

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

### New ANE Property Type: Maximum Reservable Bandwidth {#maxresbw}

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

### New ANE Property Type: Persistent Entities {#persistent-entity-id}

Property `persistent-entity-id` can be queried by a client together with the
“path-vector” metric. It defines the persistent entity ID for those ANEs in the
path vector response for which the server defines one.

The value of this property is encoded with the format defined in the UP draft
for an entity ID. (Section nb TBC, once UP dartf becomes an RFC)

In this format, the entity ID combines:

- a defining information resource for the ANE on which a "persistent-entity-id"
  is queried, which is the property map defining the ANE as a persistent entity,
  together with the properties

- the persistent name of the ANE in this property map

With this format, the client has all the needed information for further
standalone query properties on the ANE, without the need to query a path vector
for it.


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
