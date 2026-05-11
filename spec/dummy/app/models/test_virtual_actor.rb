# frozen_string_literal: true

# Test-only virtual actor used by audit-log specs and factories. Mirrors how a
# host app would mark a non-ActiveRecord actor class.
class TestVirtualActor
  include Strata::VirtualActor
end
