module Flex
  # ApplicationRecord is the base class for all Active Record models in the Flex SDK.
  # It provides a common ancestor for all Flex models to inherit from.
  #
  # This is an abstract class that is not meant to be instantiated directly.
  #
  class ApplicationRecord < ActiveRecord::Base
    self.abstract_class = true
  end
end
