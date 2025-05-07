module Flex
  class Presenter
    protected attr_reader :view_context, :i18n_path

    def initialize(view_context)
      @view_context = view_context
      @i18n_path = view_context.controller_path.gsub("/", ".")
    end

    def t(subpath)
      view_context.t("#{i18n_path}.#{subpath}")
    end
  end
end
