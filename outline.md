The Outline of the Draft
========================

<!-- **Abstract** -->

> COMMENT: Abstract is not a part of the content.

> COMMENT: Abstract should always be written in the last.

# Introduction #

# Terminology #

# Use Case #

# Overview of Approach #

- Introduce new cost-mode and cost-metric
    - cost-mode=path-vector, cost-metric=ne, ane...
    - cost-mode=nep, cost-metric=availbw, delay...
- Introduce new property service (nep-map)
    - Use unified property service
    - Register network element domains
    - Register properties for network elements
 - Augment the query schema
    - pids vs. pid-flows
    - endpoints vs. endpoint-flows
- Augment the grammar of filter constraints
    - testable-cost-types
    - filter constraints
- Extend Response of (Filtered) Cost Map and Endpoint Cost Map
- Define the error conditions and which error code (in RFC7285) to be returned.
aints
- Define the error conditions and which error code (in RFC7285) to be returned.

# Changes Since Version -04 #

# Motivation #

# Filtered Property Map #

No need to define the schema, but we need to introduce new domains and entities and extend the shceme of ReqFilteredPropertyMap.

# Protocol Extensions #

## Cost Map Extensions ##

### Uses ###

### Response ###

## Filtered Cost Map Extensions ##

### Accept Input parameters ###

### Uses ###

### Capabilities ###

### Response ###

## Endpoint Cost Service Extensions ##

### Accept Input Parameters ###

### Uses ###

### Capabilities ###

### Response ###

# Examples #

## IRD ##

## Filtered Property Map Example ##

Query filtered property map (ne, availbw, delay).

## Filtered Cost Map ##

(pv, ne, constraints)

## Endpoint Cost Map Example #1 ##

(pv, ne, constraints)

## Endpoint Cost Map Example #2 ##

(pv, ane, link-constraints)

# Compatibility #

## Compatibility with Multi-Cost Extensions ##

## Compatibility with Cost Calendar ##

## Compatibility with Incremental Update ##

# Miscellaneous Considerations #

## Error Handling ##

<!-- TODO: Should be in the specification -->

## Fine-Grained Routing ##

# Security Considerations #

# IANA Considerations #

# Acknowledgments #
