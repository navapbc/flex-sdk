require_relative 'eligibility/rules/base_eligibility_rule'
require_relative 'eligibility/rules/minimum_wages_rule'

module FlexSdk
  class EligibilityEngine
    @rules = [Eligibility::Rules::MinimumWagesRule]

    CONFIG_PATH = 'config/pfml_rules.yml'

    def self.load_rules_from_config
      puts "HERE"
      unless File.exist?(CONFIG_PATH)
        raise "Configuration file not found at #{CONFIG_PATH}. Please create one."
      end

      config = YAML.load_file(CONFIG_PATH)
      @rules = config['rules'].map do |rule_config|
        puts "here2"
        type = rule_config['type']
        params = rule_config['params'] || {}
        puts type
        puts params
        # Dynamically instantiate the rule class with parameters
        Object.const_get("Eligibility::Rules::#{type}").new(params)
      end

      puts @rules.inspect
    end

    def self.debug_rules
      puts "Rules: #{@rules.inspect}"
    end

    def self.evaluate(employee, claim)
      load_rules_from_config
      puts "Evaluating with rules: #{@rules.inspect}"
      passes = @rules.all? { |rule| rule.evaluate(employee, claim) }
    end

    # Placeholder method
    def self.check(data)
      data.each { |key, value| puts "#{key}: #{value}" }
      "Yup"
    end
  end
end
