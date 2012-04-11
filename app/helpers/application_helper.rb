require "grid_helper"
module ApplicationHelper
  def custom_form_button(type, options = {})
    type = type.to_s
    options[:label] ||= type
    label = t("forms.labels." + type.to_s)
    content_tag(:button, :class => [type, 'button'], :type => type) do
      content_tag(:span, " ").safe_concat(label.to_s)
    end
  end

  def json_for_autocomplete(items, method)
    items.collect { |item| { "id" => item.id, "label" => item.send(method), "value" => item.send(method) } }.to_json
  end

  def get_autocomplete_limit(options)
    options[:limit] ||= 10
  end

  def grid_for(model, search = nil, &block)
    grid = GridBuilder.new(model, search)
    block.call(grid)
    render "shared/grid/table", :grid => grid
  end

  # Generates a column sort link for a given attribute of a MetaSearch::Builder object.
  # The link maintains existing options for the sort as parameters in the URL, and
  # sets a meta_sort parameter as well. If the first parameter after the attribute name
  # is not a hash, it will be used as a string for alternate link text. If a hash is
  # supplied, it will be passed to link_to as an html_options hash. The link will
  # be assigned two css classes: sort_link and one of "asc" or "desc", depending on
  # the current sort order. Any class supplied in the options hash will be appended.
  #
  # Sample usage:
  #
  # <%= sort_link @search, :name %>
  # <%= sort_link @search, :name, 'Company Name' %>
  # <%= sort_link @search, :name, :class => 'name_sort' %>
  # <%= sort_link @search, :name, 'Company Name', :class => 'company_name_sort' %>
  def grid_sort_link(builder, attribute, *args)
    raise ArgumentError, "Need a MetaSearch::Builder search object as first param!" unless builder.is_a?(MetaSearch::Builder)
    attr_name = attribute.to_s
    name = (args.size > 0 && !args.first.is_a?(Hash)) ? args.shift.to_s : builder.base.human_attribute_name(attr_name)
    prev_attr, prev_order = builder.search_attributes['meta_sort'].to_s.split('.')
    current_order = prev_attr == attr_name ? prev_order : nil
    new_order = current_order == 'asc' ? 'desc' : 'asc'
    options = args.first.is_a?(Hash) ? args.shift : {}
    html_options = args.first.is_a?(Hash) ? args.shift : {}
    css = ['sort_link', current_order].compact.join(' ')
    html_options[:class] = [css, html_options[:class]].compact.join(' ')
    options.merge!(
      builder.search_key => builder.search_attributes.merge(
        'meta_sort' => [attr_name, new_order].join('.')
      )
    )

    link_to [ERB::Util.h(name), order_indicator_for(current_order)].compact.join(' ').html_safe,
            url_for(options).gsub(/.+\?/, request.env['PATH_INFO']+"?"), #hack zeby dzialaly linki dla aktualnej strony - zagniezdzonek resourca
            html_options
  end

  def display_geolocation_hint?
    ! (cookies[:city_id] || cookies[:hgh])
  end

  private

  def order_indicator_for(order)
    if order == 'asc'
      '&#9650;'
    elsif order == 'desc'
      '&#9660;'
    else
      nil
    end
  end

  def new_if_valid(object)
    if object.valid?
      object.class.new
    else 
      object
    end
  end

  def number_to_distance number, precision
    number = number.to_i

    unit = "m"

    if number > 1000
      number = number / 1000.0
      unit = "km"
    end

    number = number.round(2)

    "#{number} #{unit}"
  end

  def add_breadcrumb(item, path) 
    @breadcrumbs ||= []
    @breadcrumbs.push :item => item, :path => path
  end

  def breadcrumb_link b
    if b[:item].is_a?(Symbol) 
      label = I18n.t('breadcrumbs.'+b[:item].to_s) 
    else 
      label = b[:item]
    end
    link_to label.truncate(45), b[:path], "data-hint" => label
  end

  def truncated_link_to label, path, options = {}
    length = options.delete(:length) || 45
    highlight_phrase = options.delete(:highlight) || nil
    options.reverse_merge!({"data-hint" => label})

    label = label.truncate(length) 
    label = highlight(label, highlight_phrase) if highlight_phrase 

    link_to label, path, options
  end

  def search_menu_link_if condition, label, path, options = {}
    if condition
      link_to label, path, options
    else
      content_tag :strong, label, options
    end
  end

  def search_menu_link_unless condition, label, link, options = {}
    search_menu_link_if !condition, label, link, options
  end

  def search_by_states? state
    ((clinics_path != request.path) && params[:id].blank?) || state
  end

  def search_option_link link, params_hash
    params_hash.stringify_keys!
    query_array = CGI::parse(request.query_string)
    query = query_array.merge params_hash
    query.select! {|k,v| v != nil}
    params_hash = {}
    query.each {|k,v| params_hash.merge!(k => v.is_a?(Array) ? v.first : v)}
    link + "?" + params_hash.to_query
  end

  def debugger_once
    unless @debugged
      debugger
    end

    @debugged = true
  end

end
