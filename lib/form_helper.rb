module ActionView
  module Helpers
    module FormHelper
      def autocomplete_field(object_name, method, source, autocomplete_options = {}, options = {})
        options['data-autocomplete'] = source
        inputs = []
        if autocomplete_options.has_key? :id_holder 
          options['data-autocomplete-id-holder'], options['data-autocomplete-required'] = autocomplete_options[:id_holder]
          inputs.push hidden_field(object_name, options['data-autocomplete-id-holder'], {:id => "autocomplete_holder_"+options['data-autocomplete-id-holder'].to_s})
        end
        if autocomplete_options.has_key? :dependent_on
          options['data-autocomplete-dependent-on'], options['data-autocomplete-dependent-name'], options['data-autocomplete-dependent-message']  = autocomplete_options[:dependent_on]
        end
        inputs.push text_field(object_name, method, options)
        inputs.join.html_safe
      end

      def autocomplete_collection_select(object_name, method, collection, display_key, display_value, prompt = {}, options = {})
        options['data-autocomplete'] = true
        collection_select(object_name, method, collection, display_key, display_value, prompt, options)
      end
    end
  end
end

class ActionView::Helpers::FormBuilder
  def autocomplete_field(method, source, autocomplete_options = {}, options = {})
    @template.autocomplete_field(@object_name, method, source, autocomplete_options, objectify_options(options))
  end

  def autocomplete_collection_select(method, collection, display_key, display_value, prompt = {}, options = {})
    @template.autocomplete_collection_select(@object_name, method, collection, display_key, display_value, prompt, options) 
  end
end

def custom_form_for(object, options = {}, &block)
  options[:builder] = CustomFormBuilder
  simple_form_for(object, options, &block)
end

class CustomFormBuilder < SimpleForm::FormBuilder
  def autocomplete(attribute_name, source, autocomplete_options, input_options = {}, &block)
    inputs = []
    html_options = {}
    html_options['data-autocomplete'] = source

    if autocomplete_options.has_key? :name
      html_options['data-autocomplete-name'] = autocomplete_options[:name]
    else
      html_options['data-autocomplete-name'] = attribute_name.to_s+"_starts_with"
    end
    if autocomplete_options.has_key? :id_holder 
      html_options['data-autocomplete-id-holder'], html_options['data-autocomplete-required'] = autocomplete_options[:id_holder]
      inputs.push hidden_field(html_options['data-autocomplete-id-holder'], {:id => "autocomplete_holder_"+html_options['data-autocomplete-id-holder'].to_s})
    end

    if autocomplete_options.has_key? :dependent_on
      html_options['data-autocomplete-dependent-on'], html_options['data-autocomplete-dependent-name'], html_options['data-autocomplete-dependent-message']  = autocomplete_options[:dependent_on]
    end

    input_options.merge!({:input_html => html_options})

    inputs.push input(attribute_name, input_options, &block)
    inputs.join.html_safe
  end

  def autocomplete_collection(attribute_name, collection, options, &block)
    options[:collection] = collection
    options[:input_html] = {'data-autocomplete' => true}
    input(attribute_name, options, &block)
  end

  def input(attribute_name, options = {}, &block)
    if options.has_key? :placeholder
      options.merge!(:input_html => { 'data-placeholder' => options.delete(:placeholder) })
    end
    super(attribute_name, options, &block)
  end

  def button(type, options = {}) 
    options[:label] ||= I18n.t("forms.labels.#{type}")
    value = options[:value] || type
    
    template.content_tag(:button, :class => [type, 'button'], :type => type, :value => value) do
      template.content_tag(:span, " ").safe_concat(options[:label].to_s)
    end
  end
end
