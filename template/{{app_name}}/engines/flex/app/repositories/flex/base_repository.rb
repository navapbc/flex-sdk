module Flex
  class BaseRepository
    def initialize(model_class)
      @model_class = model_class
    end

    def find(id)
      @model_class.find(id)
    end

    def create(params)
      model = form_type.create(params)
      model.id
    end

    def update(id, params)
      record = find(id)
      record.update(params)
    end

    def find_fields(id, fields)
      @model_class.select(fields).find(id)
    end
  end
end
