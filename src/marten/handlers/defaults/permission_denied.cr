module Marten
  module Handlers
    module Defaults
      class PermissionDenied < Template
        template_name DEFAULT_TEMPLATE_NAME

        def dispatch
          render_to_response(status: 403)
        rescue ex : Marten::Template::Errors::TemplateNotFound
          raise ex if self.class.template_name != DEFAULT_TEMPLATE_NAME
          HTTP::Response::Forbidden.new(content: "403 Forbidden", content_type: "text/plain")
        end

        private DEFAULT_TEMPLATE_NAME = "403.html"
      end
    end
  end
end
