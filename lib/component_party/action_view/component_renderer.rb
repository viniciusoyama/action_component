module ComponentParty
  # Renders a given component
  module ActionView
    class ComponentRenderer < ::ActionView::TemplateRenderer
      attr_reader :caller_component_path
      attr_reader :lookup_context

      def initialize(lookup_context, caller_component_path)
        lookup_context.view_paths.push(Rails.root.join(ComponentParty.configuration.components_path))
        @caller_component_path = caller_component_path
        super(lookup_context)
      end

      def render(context, options)
        options[:file] = template_path_from_component_path(options[:component])
        options[:locals] = { vm: ComponentParty::ViewModel.new(options[:view_model_data] || {}) }
        options[:locals][:caller_component_path] = options[:caller_component_path] if options[:caller_component_path].present?
        super(context, options)
      end

      def render_template(template, layout_name = nil, locals = nil) #:nodoc:
        super(decorate_template(template), layout_name, locals)
      end

      def decorate_template(template)
        template
      end

      def create_view_model( options)

        # vm_class = find_custom_vm_class
        vm_class ||= ComponentParty::Component::ViewModel

        vm_class.new(view_model_data)
      end

      def template_path_from_component_path(component_path, template_file_name: ComponentParty.configuration.template_file_name)
        Pathname.new(component_path).join(template_file_name).to_s
      end
    end
  end
end