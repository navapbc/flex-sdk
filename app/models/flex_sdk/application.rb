class EligibilityEngine
  def initialize(rules)
    @rules = MinimumWagesRuls
  end

  def evaluate(employee, claim)
    @rules.all? { |rule| rule.ned.evaluate(employee, claim)}
  end
end