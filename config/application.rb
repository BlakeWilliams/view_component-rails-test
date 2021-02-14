require_relative "boot"

require "rails/all"

module ActionViewRenderablePartialPatch
  class RenderedComponent
    attr_reader :body

    def initialize(body)
      @body = body
    end
  end

  def render(partial, context, block)
    renderable = find_renderable(partial, template_keys(partial))

    if renderable
      body = renderable.new(**@locals).render_in(context, &block)
      RenderedComponent.new(body)
    else
      super
    end
  end

  def find_renderable(path, locals)
    prefixes = path.include?(?/) ? [] : @lookup_context.prefixes

    if prefixes
      constant_name = path.camelize
      return constant_name.constantize if Object.const_defined?(constant_name)
    else
      prefixes.each do
        constant_name = File.join(prefixes, path).camelize
        return constant_name.constantize if Object.const_defined?(constant_name)
      end
    end

    nil
  end
end

ActionView::PartialRenderer.prepend(ActionViewRenderablePartialPatch)

module ActionViewRenderableTemplatePatch
  def determine_template(options)
    if options.key?(:template) && !options[:template].respond_to?(:render)
      renderable = find_renderable(options[:template], options[:prefixes])

      if renderable
        renderable_instance = renderable.new(**options.except(:template, :layout))
        ActionView::Template::Renderable.new(renderable_instance)
      else
        super
      end
    else
      super
    end
  end

  def find_renderable(path, prefixes)
    if prefixes
      prefixes.each do
        constant_name = File.join(prefixes, path).camelize
        return constant_name.constantize if Object.const_defined?(constant_name)
      end
    else
      constant_name = path.camelize
      return constant_name.constantize if Object.const_defined?(constant_name)
    end

    nil
  end
end

ActionView::TemplateRenderer.prepend(ActionViewRenderableTemplatePatch)

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module ViewComponentTest
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 6.1

    config.autoload_paths << Rails.root.join("app/views")

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")
  end
end
