# ADR-001: Remove Strata Agent Rule Generators

## Status

Accepted

## Date

2026-04-29

## Context

The `strata:rules` generator was introduced to generate path-scoped agent rule
files (for Claude, Cursor, Copilot) that embed current SDK source code. The
goal was to reduce the time and cost an AI agent spends when building features
on top of the Strata SDK by providing pre-baked, curated context.

In testing, rules did shorten the time an agent spent on a given subject.
However, they did not improve cost and performance by a large enough factor to
validate the approach given its maintenance overhead.

The core problem: for agent rules to outperform giving the agent direct access
to the full SDK, the rule set would need to be dramatically more comprehensive.
For example, an application form does not stand alone — it connects to a
business process, which connects to case management. Each relationship requires
its own rule coverage. Scaling this to even a small feature area requires
generating and maintaining a large number of rule files.

A further problem is that agent rule files are not maintained one-to-one with
the code. Even when rules dynamically reference source at generation time, the
recipe for building a feature (the "how the pieces fit together" knowledge)
must be iterated continuously and is not captured by source excerpts alone.

## Decision

Remove the `strata:rules` generator and its associated spec files. Do not
invest further in expanding the rule set.

Instead, the recommended approach for any project using the Strata SDK is to
clone this repository into a temporary directory and configure skills or agents
to reference it directly when building features. In testing, this approach
produced feature output that was more aligned with intent, at roughly 2x the
API cost and agent duration compared to the rule-based approach. That tradeoff
is acceptable given the improvement in output quality and the elimination of
rule maintenance burden.

## Consequences

- The `strata:rules` generator and its documentation are removed.
- Downstream projects cannot auto-generate agent rules from this SDK.
- Projects wanting AI assistance with Strata features should clone the SDK
  repo locally and point their agent/skill at the cloned directory.
- No ongoing maintenance is required to keep rule files in sync with code.
