require_relative 'eligibility/rules/base_eligibility_rule'
require_relative 'eligibility/rules/minimum_wages_rule'
require_relative 'eligibility/rules/custom_rule'

module FlexSdk
  class EligibilityEngine
    @rules = [Eligibility::Rules::MinimumWagesRule]

    # This should live elsewhere
    CONFIG_PATH = 'config/pfml_rules.yml'
    def self.load_rules_from_config
      unless File.exist?(CONFIG_PATH)
        raise "Configuration file not found at #{CONFIG_PATH}. Please create one."
      end

      config = YAML.load_file(CONFIG_PATH)
      @rules = config['rules'].flat_map do |rule_config|
        type = rule_config['type']
        params = rule_config['params'] || {}

        next if params['exclude']

        if type == 'CustomRules'
          # Create a CustomRule for each definition under CustomRules
          sub_rules = params['rules'] || []
          sub_rules.map { |custom_rule_def| Eligibility::Rules::CustomRule.new(custom_rule_def) }
        else
          # Dynamically instantiate other rules
          Object.const_get("Eligibility::Rules::#{type}").new(params)
        end
      end.compact # Remove nil values from array
    end

    def self.debug_rules
      puts "Rules: #{@rules.inspect}"
    end

    def self.evaluate(employee, claim)
      load_rules_from_config
      puts "Evaluating with rules: #{@rules.inspect}"
      passes = @rules.all? { |rule| rule.evaluate(employee, claim) }
    end

  end
end
