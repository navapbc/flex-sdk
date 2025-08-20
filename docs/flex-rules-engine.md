# Flex Rules Engine

The Flex Rules Engine allows developers to implement and maintain policy rules as code. The same rules can be used for both internal eligibility determination logic as well as public facing unauthenticated calculators.

> [!NOTE]  
> The Flex Rules Engine is still a work in progress, and detailed documentation will be provided as the feature matures.

## Key features

- **Readable rule definitions**—Rules are defined to be readable, making it easy for developers to write and for both developers and non-developers to read.
- **Facts can be derived from different source facts**—Intermediate facts can be computed or set directly. For example, a fact like "is over 18" can be derived from a "birth date" fact based on source of truth data tied to an authenticated user with a verified identity, or it can be set directly from a public facing calculator that does not collect personal information.
- **Lazy evaluation**—Facts are only evaluated when needed. This allows for facts that can be computed in more than one way to leverage the most efficient path based on available data. For example, if there are multiple systems that can be used to determine a fact, some of the systems can be reserved as fallbacks if the primary system doesn't have the available data.
- **Extensible, and customizable rules**—Rulesets can be based off of existing rulesets to extend existing rules that are common to multiple programs. Rules can also be overridden and customized. For example, if one state defines income differently than others, it can override the default income rule to use its own definition.
- **Explanability of evaluated facts**—Evaluated facts include a reasons tree for how the fact was derived, enabling the development of user interfaces that explain how a particular determination was made. This can be useful for both the applicant applying for a program and for the staff adjudicating a program leveraging a preliminary eligibility calculation. If a fact is unknown, the derivation path shows which facts are necessary to compute the fact.
- **Collection type support**—Rules can be defined for fact collections, which represents a fact about a collection of entities. For example, "individual gross income" could be a fact that applies to each member of a household on an application, and "monthly income amount" could be a fact that applies to each income source for each individual member of a household.
- **Versioned rules**—Rules are versioned, allowing for re-executing rules with different versions of the ruleset. This allows use cases of re-evaluating facts if an earlier implementation of a ruleset was incorrect, or re-evaluating facts using an earlier version of a ruleset if something needs to be decided retroactively.

## Key concepts

### Rule Graph Architecture

The rules engine models business logic as a directed acyclic graph (DAG), where:

- Each **node** represents a rule that computes a fact
- Each **edge** represents a dependency between rules
- The **direction** of edges follows the flow of computation

For example, determining if someone is eligible for a program might involve this chain of rules:

```mermaid
birth_date → age → is_adult → meets_age_requirement → is_eligible
```

### Fact Computation and Management

Facts in the system can be:

1. **Directly Set**: Raw input values like birth dates or income amounts
2. **Computed**: Derived from other facts through rules (e.g., age from birth date)
3. **Unknown**: When required dependent facts are missing

The DAG structure enables several key capabilities:

- **Lazy Evaluation**: Facts are only computed when requested, following the most efficient path through the graph
- **Multiple Computation Paths**: A fact can be computed through different rules depending on available data
- **Versioning**: Rules and their relationships are versioned, allowing historical computations

### Collections and Aggregation

The rules engine handles collections of facts through:

- **Fact Collections**: Rules that operate on groups of related facts (e.g., household members)
- **Aggregation Rules**: Special rules that combine facts from collections (e.g., total household income)
- **Collection Dependencies**: Rules that depend on both individual and aggregated facts

### Probabilistic Reasoning

When facts are unknown, the system can:

- Track which facts are needed to make a determination
- (Future) Calculate probability distributions for facts based on available data
- (Future) Make statistical inferences for scenarios like:
  - Preliminary eligibility assessments
  - Fraud detection
  - Risk evaluation
