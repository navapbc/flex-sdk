---
applyTo: "app/models/**/*.rb"
---

# Data Modeling Guidelines

The Flex SDK uses domain-driven design (DDD) principles. These guidelines explain key ideas in plain language, with examples, so developers can apply them consistently.

## ActiveRecord vs Repository Pattern

DDD often recommends the repository pattern as a layer that separates domain logic from data persistence. To align with common Rails practice, the Flex SDK skips this extra layer. Instead, the model class itself acts as the repository.

### What this means for you

- Always run database queries through a single method on the ActiveRecord model or through model scopes. This centralizes query logic.
- When you need a custom query, write a scope. Don’t sprinkle `where`, `order`, or other query builder calls around your controllers or services. Instead, define named [scopes](https://guides.rubyonrails.org/active_record_querying.html#scopes) on the model. This makes queries easier to reuse and review, and it ensures all query logic lives in one place for easier maintenance.

## Aggregates vs Non-Aggregate Entities

DDD distinguishes between three main kinds of objects:

- **Value objects**: These describe something in the domain but don’t have an identity. Example: a Money value (amount and currency) or a date range.
- **Entities**: These have an identity that persists over time. Example: a specific user account — the same person even if they change their name.
- **Aggregates**: These are groups of entities and value objects that you treat as a single unit. Each aggregate has a root entity (the “aggregate root”) that controls how you work with it.

Aggregates enforce consistency boundaries. You make changes to an aggregate through its root. This way, you can check rules (invariants) before saving, and you know changes stay consistent.

### Why it matters

If you update entities directly, you risk skipping important checks or breaking consistency. Always work through the aggregate root.

**Bad:** (updates entity directly)

```ruby
LeavePeriod.find(id).update(start:, end:)
```

**Good:** (routes change through aggregate root)

```ruby
PaidLeave.find(id).update_leave_period(leave_period_id, start:, end:)
```

Here, the `PaidLeave` aggregate root can enforce rules and wrap changes in a transaction. For example,

```ruby
class PaidLeave < ApplicationRecord
  has_many :leave_periods

  def update_leave_period(leave_period_id, start:, end:)
    with_lock do
      leave_period = leave_periods.find { |lp| lp.id == leave_period_id }
      other_leave_periods = leave_periods.reject { |lp| lp.id == leave_period_id }
      leave_period.attributes = { start:, end: }
      # Check if new [start, end] period overlaps with any of the other leave periods
      if other_leave_periods.any? { |lp| lp.overlaps?(leave_period) }
        # Raise validation error
      else
        leave_period.save!
      end
    end
  end
end
```

### Rules of thumb

- Don’t create Rails associations between entities in different aggregates. Cross-aggregate associations often hide database calls that trigger N+1 query problems. They also make it harder to enforce consistency. Avoiding these associations also makes it more feasible to split the application into microservices later, since there are no database-level dependencies between bounded contexts. If you must connect aggregates, use IDs instead of `has_many` or `belongs_to`.
- Load aggregates as a whole. Use `includes` or `preload` when fetching so the aggregate root and its related entities come in one query. This avoids hidden queries and keeps the aggregate consistent. For example.

  ```ruby
  class PaidLeave < ApplicationRecord
    has_many :leave_periods
    default_scope { preload(:leave_periods) }
  end
  ```

- Size aggregates carefully based on the number of related entities they contain. An oversized aggregate (one that groups too many entities together) makes saves slow and complicated because more data needs to be loaded and validated together. A tiny aggregate (containing just a single entity) might make it hard to enforce business rules across related entities. Start with fewer entities per aggregate and merge them later if needed. Splitting an aggregate with many entities after the fact is harder.
- Favor aggregates with fewer entities. They usually perform better and scale more easily since they reduce the amount of data that needs to be loaded and validated together. For example, if you have `Case`, `Document`, and `Note` entities, you might start with each as its own aggregate rather than automatically grouping them all under `Case`.
- Be open to eventual consistency. Not every rule has to be enforced immediately. Some business processes can handle checks that run asynchronously, especially when strict consistency would slow things down too much.

By following these rules, you’ll build models that are both reliable and maintainable—even if you’re new to DDD.
