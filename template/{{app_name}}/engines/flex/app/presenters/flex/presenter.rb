module Flex
  class Presenter
    protected attr_reader :view_context, :i18n_scope

    def initialize(view_context)
      @view_context = view_context
      @i18n_scope = view_context.controller_path.gsub("/", ".")
    end

    def t_scoped(subpath)
      view_context.t(subpath, scope: i18n_scope)
    end
  end
end
