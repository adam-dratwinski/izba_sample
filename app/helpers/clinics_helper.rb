module ClinicsHelper
  def render_offices_links offices
    offices_links = []
    offices.each do |office|
      offices_links.push link_to office.name, office
    end
    offices_links.join(', ').html_safe
  end

  def distance_indicator distance, scale
    offset = distance / scale < 1 ? distance / scale : 1
    offset = offset * 100
    content_tag :div, " ", :style => "background-position: #{offset}% 0", :class => "distance-indicator" 
  end
end
