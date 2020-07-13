# Specification: Basic Data Types {#Basic}

## ANE Name {#ane-name-spec}

An ANE Name is encoded as a JSON string with the same format as that of the type
PIDName (Section 10.1 of {{RFC7285}}).

The type ANEName is used in this document to indicate a string of this
format.

## ANE Domain {#ane-domain-spec}

The ANE domain associates property values with the Abstract Network Elements in
a Property Map. Accordingly, the ANE domain always depends on a Property Map.

### Entity Domain Type ## {#domain-type}

ane

### Domain-Specific Entity Identifier ## {#entity-address}

The entity identifiers are the ANE Names in the associated Property Map.

### Hierarchy and Inheritance

There is no hierarchy or inheritance for properties associated with ANEs.

### Media Type of Defining Resource {#domain-defining}

When resource specific domains are defined with entities of domain type `ane`,
the defining resource for entity domain type `pid` MUST be a Property Map. The
media type of defining resources for the `ane` domain is:

    application/alto-propmap+json

Specifically, the defining resource of ephemeral ANEs is the Property Map part
of the multipart response. The defining resource of persistent ANEs is the
Property Map on which standalone queries for properties of persistent ANEs are
made.

## ANE Property Name {#ane-prop-name-spec}

An ANE Property Name is encoded as a JSON string with the same format as that of
Entity Property Name (Section 5.2.2 of {{I-D.ietf-alto-unified-props-new}}).

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
              | |   MEC1    | |         |          |
              | +-----------+ |   +-----+          |
       PID2   |               |   |     +----------+
2.3.4.0/24+---+               |   |         NET3
              |               |   | 15 Gbps
              |               |   |        \
              +---------------+   |         -------- L2
                    NET1          |
                           +---------------+
                           | +-----------+ |   PID4
                           | |   MEC2    | +---+4.5.6.0/24
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

Identifier:
: `max-reservable-bandwidth`

Intended Semantics:
: The maximum reservable bandwidth property stands for the maximum bandwidth
  that can be reserved for all the traffic that traverses an ANE. The value MUST
  be encoded as a non-negative numerical cost value as defined in Section
  6.1.2.1 of {{RFC7285}} and the unit is bit per second. If this property is
  requested but not present in an ANE, it MUST be interpreted as that the ANE
  does not support bandwidth reservation.

Security Considerations:
: ALTO entity properties expose information to ALTO clients. ALTO service
  providers should be made aware of the security ramifications related to the
  exposure of an entity property.

To illustrate the use of `max-reservable-bandwidth`, consider the network in
{{fig-pe}}. An ALTO server can create an ANE for each interconnection link,
where the initial value for `max-reservable-bandwidth` is the link capacity.

### New ANE Property Type: Persistent Entity ID {#persistent-entity-id}

Identifier:
: `persistent-entity-id`

Intended Semantics:
: The persistent entity ID property is the entity identifier of the persistent
  ANE associated with an ephemeral ANE. The value of this property is encoded
  with the format defined in Section 5.1.3 of
  {{I-D.ietf-alto-unified-props-new}}.

  In this format, the entity ID combines:

  - a defining information resource for the ANE on which a
    "persistent-entity-id" is queried, which is the property map defining the
    ANE as a persistent entity, together with the properties

  - the persistent name of the ANE in this property map

  With this format, the client has all the needed information for further
  standalone query properties on the persistent ANE.

Security Considerations:
: ALTO entity properties expose information to ALTO clients. ALTO service
  providers should be made aware of the security ramifications related to the
  exposure of an entity property.

To illustrate the use of `persistent-entity-id`, consider the network in
{{fig-pe}}. Assume the ALTO server has a Property Map resource called
"mec-props" that defines persistent ANEs "MEC1" and "MEC2" that represent the
corresponding mobile edge computing (MEC) clusters. The `persistent-entity-id`
of the ephemeral ANE that is associated with MEC1 has the value
`mec-props.ane:MEC1`.

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
