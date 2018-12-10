# Protocol Extensions # {#SecPE}

This section formally specifies the path-vector extension which includes the following components: a new cost type, a new entity domain, extensions of (Filtered) Cost Map and Endpoint Cost Map. Below we specify each component in details.

## Cost Type ## {#cost-type-def}

The path-vector extension defined in this document enriches the cost types defined in Section 6.1 of [](#RFC7285).

### Cost Metric ### {#metric-spec}

This document specifies a new cost metric: "ane". It is of type CostMetric as defined in Section 10.6 of [](#RFC7285). The cost metric "ane" MUST NOT be used when the cost mode is not "path-vector" unless it is explicitly specified in a future extension. Meanwhile, an ALTO server with path-vector extension MUST support the cost metric "ane".

Cost metric "ane":
~ This cost metric MUST be encoded as the JSONString "ane". When cost metric is "ane", Network Element Names contained in the path vectors MUST be query-specific.
<!--In this case, different path-vector queries to the same (Filtered) Cost Map or Endpoint Cost Service MAY have different Filtered Network Element Property Maps. -->

### Cost Mode: Path Vector ###

This document specifies a new cost mode: "path-vector". The path-vector cost mode is of type CostMode as defined in Section 6.1.2 of [](#RFC7285) and is encoded as the JSONString "path-vector".

A (Filtered) Cost Map resource or Endpoint Cost Service, when queried with this cost mode, MUST return a CostMapData or EndpointCostMapData whose cost value is a JSONArray of type NetworkElementName as specified in [](#nen).

This cost mode MUST be used with the cost metric "ane" unless it is explicitly specified by a future extension.

## Version Tag ##  {#vtag}

To support the concept of query specific, a new field named "query-id" is introduced to correlate the query information between the (Filtered) Cost Map/Endpoint Cost Service response and the corresponding property map query. The object VersionTag as defined in Section 10.3 of [](#RFC7285) is extended as follows:

```
  object {
    ResourceID   resource-id;
    JSONString   tag;
    [JSONString  query-id;]
  } VersionTag;
```

resource-id, tag:
~ As defined in Section 10.3 of [](#RFC7285).

query-id:
~ A string used to uniquely identify the abstract network elements in the property map.

## Network Element Name ## {#nen}

This document also extends [](#RFC7285) with a new basic data type: NetworkElementName. A NetworkElementName is of type EntityAddr as defined in Section 2.3 of [](#I-D.roome-alto-unified-props) and is encoded as a JSONString. A NetworkElementName MUST be an EntityAddr of the ANE domain.

## ANE Domain ##

This document specifies a new domain in addition to the ones in [](#I-D.roome-alto-unified-props).

### Domain Name ###

ane

### Domain-Specific Entity Addresses ### {#entity-ane-spec}

The entity address of ane domain is encoded as a JSON string.  The string MUST be no more
than 64 characters, and it MUST NOT contain characters other than US-ASCII alphanumeric characters (U+0030-U+0039, U+0041-U+005A, and U+0061-U+007A), the hyphen (’-’, U+002D), the colon (’:’, U+003A), the at sign (’@’, code point U+0040), the low line (’\_’, U+005F), or the ’.’ separator (U+002E).  The ’.’ separator is reserved for future use and MUST NOT be used unless specifically indicated in this document, or an extension document.

## Filtered Network Element Property Map ## {#SecNEPMap}

A Filtered Network Element Property Map MUST be a Filtered Property Map as defined in Section 5 of [](#I-D.roome-alto-unified-props).

### Accept Input Parameters

This document extends ReqFilteredPropertyMap defined in Section 5.3 of [](#I-D.roome-alto-unified-props) by introducing an optional field named "query-id". The ReqFilteredPropertyMap is extended as follows:

```
  object {
    EntityAddr     entities<1..*>
    PropertyName   properties<1..*>;
    [JSONString    query-id;]
  } ReqFilteredPropertyMap;
```

entities, properties:
~ The same as defined in Section 5.3 of [](#I-D.roome-alto-unified-props).

query-id:
~ Like the "query-id" defined in [](#vtag), the "query-id" here is also a string used to uniquely identify the abstract network elements in the property map.

### Capabilities ###

A Network Element Property Map MUST have capabilities "domain-types" and "prop-types" as defined in Section 4.4 of [](#I-D.roome-alto-unified-props). The "domain-types" capability MUST contain domain "ane". And the "prop-types" capability MUST be a subset of property types which are registered with the "ALTO Network Element Property Type Registry" defined in [](#id-nep-type-reg) of this document.

<!-- Whether the prop-types is a global idea or not-->

### Response ###

The response is the same as for the Property Map, as defined in Section 4.6 of [](#I-D.roome-alto-unified-props), except that only the requested entities and properties are returned for Filtered Network Element Map. Examples can be found in [](#id-example-nepmap-availbw) and [](#id-example-nepmap-delay).

## IRD Extensions ##

This document extends IRDResourceEntry defined in Section 9.2.2 of [](#RFC7285) by introducing a new entry named "propertymap". The IRDResourceEntry object is extended as follows:

```
  object {
    JSONString uri;
    JSONString media-type;
    [JSONString accepts;]
    [Capabilities capabilities;]
    [ResourceID uses<0..*>;]
    [ResourceID propertymap<0..*>;]
  } IRDResourceEntry;
```

uri, media-type, accepts, capabilities, uses:
~ The same as defined in Section 9.2.2 of [](#RFC7285).

propertymap:
~ A list of resource IDs, defined in the same IRD, that indicates where the specific properties of the returned abstract network elements can be retrieved.

## Cost Map Extensions ##

This document extends Cost Map defined in Section 11.2.3 of [](#RFC7285) by returning JSONArray instead of JSONNumber as the cost value, including "vtag" in "meta" field in the response, and adding a new field referencing to the Network Element Property Map.

The media type, HTTP method, capabilities, accept input parameter and uses specifications are unchanged.

### Propertymap ###

If the Cost Map supports the path-vector extension, the field "propertymap" provides a list of resource ids of Network Element Property Map. Each network element property map resource provides properties for the dynamically generated abstract network elements.

### Response ### {#id-cm-response}

The response is the same as defined in Section 11.2.3.6 of [](#RFC7285) except the follows:

- If the cost mode is "path-vector", the cost is a JSONArray of Network Element Names.

- If the query sent by the client includes cost type path vector, the "vtag" filed defined in [](#vtag) has to be included in the response. And the "query-id" information in "vtag" MUST be provided to clients.

## Filtered Cost Map Extensions ##

This document extends the Filtered Cost Map defined in Section 4.1 of [](#I-D.ietf-alto-multi-cost) by specifying details on capabilities, returning JSONArray instead of JSONNumber as the cost value, including "vtag" in "meta" field in the response, and adding a new field referencing to the Network Element Property Map.

The media type, HTTP method and uses specifications are unchanged.

### Capabilities ###  { #id-fcm-capabilities }

The FilteredCostMapCapabilities object is the same as defined in Section 4.1.1 of [](#I-D.ietf-alto-multi-cost) expect the follow:

<!-- ```
  object {
    JSONString cost-type-names<1..*>;
    [JSONBool cost-constraints;]
    [JSONNumber max-cost-types;]
    [JSONString testable-cost-type-names<1..*>;]
  } FilteredCostMapCapabilities;
``` -->

testable-cost-type-names:
~ Cost type "path-vector" MUST NOT appear in the "testable-cost-type-names" field.

### Accept Input Parameters ### {#fcm-input}

The ReqFilteredCostMap defined in Section 4.1.2 of [](#I-D.ietf-alto-multi-cost) is extended, the meanings and the constraints of some fields are also extended.

```
  object {
    [CostType cost-type;]
    [CostType multi-cost-types<1..*>;]
    [CostType testable-cost-types<1..*>;]
    [JSONString constraints<0..*>;]
    [JSONString or-constraints<1..*><1..*>;]
    [PIDFilter pids;]
    [PIDFlowFilter pid-flows<1..*>;]
  } ReqFilteredCostMap;

  object {
    PIDName src;
    PIDName dst;
  } PIDFlowFilter;
```

cost-type:
~ If the cost type is path-vector and neither the "testable-cost-type-names" field is provided by the server nor the "testable-cost-types" field is provided by the client, the "constraints" field and the "or-constraints" field SHOULD NOT appear. If not, the ALTO server MUST return an error with error code E_INVALID_FIELD_VALUE. The server MAY include an optional field named "field" in the "meta" field of the response, the value of "field" is "constraints" or "or-constraints". The server MAY also include an optional field named "value" in the "meta" field, the value of "value" is "path-vector". If the "value" field is specified, the "field" field MUST be specified.

multi-cost-types:
~ If "multi-cost-types" includes cost type path-vector, meanwhile, neither the "testable-cost-type-names" field is provided by the server nor the "testable-cost-types" field is provided by the client, the cost type index of path-vector MUST NOT appear in the "constraints" field or the "or-constraints" field. If not, the ALTO server MUST return an error with error code E_INVALID_FIELD_VALUE. The server MAY include an optional field named "field" in the "meta" field of the response, the value of "field" is "constraints" or "or-constraints". The server MAY also include an optional field named "value" in the "meta" field, the value of "value" is "path-vector". If the "value" field is specified, the "field" field MUST be specified.  <!-- The value of "value" may need to be refined -->

testable-cost-types:
~ "testable-cost-types" SHOULD NOT include path-vector cost type. If "testable-cost-types" contains path-vector cost type, the ALTO server MUST return an error with error code E_INVALID_FIELD_VALUE. The server MAY include an optional field named "field" in the "meta" field of the response, the value of "filed" is "testable-cost-types/cost-mode". The server MAY also include an optional field named "value" in the "meta" field, the value of "value" is "path-vector". If the "value" field is specified, the "field" field MUST be specified.

pid-flows:
~ A list of PID src to PID dst for which path costs are to be returned.

Additional requirement is that the Client MUST specify either "pids" or "pid-flows", but MUST NOT specify both.

### Propertymap ###

If the Filtered Cost Map supports the path-vector extension, the field "propertymap" provides a list of resource ids of Network Element Property Map. Each network element property map resource provides properties for the dynamically generated abstract network elements.

### Response ###

The response is the same as defined in Section 4.1.3 of [](#I-D.ietf-alto-multi-cost) except the follows:

- Whether the "cost-type" field or the "multi-cost-types" field includes cost type path-vector, the cost is a JSONArray of Network Element Names.

- If the query sent by the client includes cost type path vector, the "vtag" filed defined in [](#vtag) has to be included in the response. And the "query-id" information in "vtag" MUST be provided to clients.

## Endpoint Cost Service Extensions ##

This document extends the Endpoint Cost Service defined in Section 4.2 in [](#I-D.ietf-alto-multi-cost) by specifying details on capabilities, returning JSONArray instead of JSONNumber as the cost value, including "vtag" in "meta" field in the response, and adding a new field referencing to the Network Element Property Map.

The media type, HTTP method and uses specifications are unchanged.

### Capabilities ###

The same as defined in [](#id-fcm-capabilities).

### Accept Input Parameters ###

<!-- The schema is the same -->

The ReqFilteredCostMap defined in Section 4.1.2 of [](#I-D.ietf-alto-multi-cost) is extended, the meanings and the constraints of some fields are also extended.

 ```
  object {
    [CostType cost-type;]
    [CostType multi-cost-types<1..*>;]
    [CostType testable-cost-types<1..*>;]
    [JSONString constraints<0..*>;]
    [JSONString or-constraints<1..*><1..*>;]
    [EndpointFilter endpoints;]
    [EndpointFlowFilter endpoint-flows<1..*>;]
  } ReqEndpointCostMap;

  object {
    TypedEndpointAddr src;
    TypedEndpointAddr dst;
  } EndpointFlowFilter;
```

cost-type:
~ If the cost type is path-vector and neither the "testable-cost-type-names" field is provided by the server nor the "testable-cost-types" field is provided by the client, the "constraints" field and the "or-constraints" field SHOULD NOT appear. If not, the ALTO server MUST return an error with error code E_INVALID_FIELD_VALUE. The server MAY include an optional field named "field" in the "meta" field of the response, the value of "field" is "constraints" or "or-constraints". The server MAY also include an optional field named "value" in the "meta" field, the value of "value" is "path-vector". If the "value" field is specified, the "field" field MUST be specified.

multi-cost-types:
~ If "multi-cost-types" includes cost type path-vector, meanwhile, neither the "testable-cost-type-names" field is provided by the server nor the "testable-cost-types" field is provided by the client, the cost type index of path-vector MUST NOT appear in the "constraints" field or the "or-constraints" field. If not, the ALTO server MUST return an error with error code E_INVALID_FIELD_VALUE. The server MAY include an optional field named "field" in the "meta" field of the response, the value of "field" is "constraints" or "or-constraints". The server MAY also include an optional field named "value" in the "meta" field, the value of "value" is "path-vector". If the "value" field is specified, the "field" field MUST be specified.     <!-- The value of "value" may need to be refined -->

testable-cost-types:
~ "testable-cost-types" SHOULD NOT include path-vector cost type. If "testable-cost-types" contains path-vector cost type, the ALTO server MUST return an error with error code E_INVALID_FIELD_VALUE. The server MAY include an optional field named "field" in the "meta" field of the response, the value of "filed" is "testable-cost-types/cost-mode". The server MAY also include an optional field named "value" in the "meta" field, the value of "value" is "path-vector". If the "value" field is specified, the "field" field MUST be specified.

endpoint-flows:
~ A list of endpoint src to endpoint dst for which path costs are to be returned.

Additional requirement is that the Client MUST specify either "endpoints" or "endpoint-flows", but MUST NOT specify both.

### Propertymap ###

If the Endpoint Cost Service supports the path-vector extension, the field "propertymap" provides a list of resource ids of Network Element Property Map. Each network element property map resource provides properties for the dynamically generated abstract network elements.

### Response ###

The response is the same as defined in Section 4.2.3 of [](#I-D.ietf-alto-multi-cost) except the follows:

- Whether the "cost-type" field or the "multi-cost-types" field includes cost type path-vector, the cost is a JSONArray of Network Element Names.

- If the query sent by the client includes cost type path vector, the "vtag" filed defined in [](#vtag) has to be included in the response. And the "query-id" information in "vtag" MUST be provided to clients.
