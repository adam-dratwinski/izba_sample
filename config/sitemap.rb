# Set the host name for URL creation
SitemapGenerator::Sitemap.default_host = "http://www.izbaprzyjec.pl"

SitemapGenerator::Sitemap.create do

  add signup_path
  add login_path

  PagePart.all.each do |page_part|
    add page_part_path page_part
  end

  Office.all.each do |office|
    add office_path office, :lastmod => office.updated_at
  end

  Departament.all.each do |departament|
    add departament_path(departament), :lastmod => departament.updated_at
  end

  Clinic.all.each do |clinic|
    add clinic_path(clinic), :lastmod => clinic.updated_at
  end

#  add departaments_path tego nie ma
  add clinics_path

  SearchClinic.all.each do |search_clinic|
    add search_clinic_path search_clinic
  end

  State.all.each do |state|
    add state_clinics_path state

    State.first.cities_with_clinics.limit(10).each do |city|
      add city_clinics_path city
    end
  end

  # Put links creation logic here
  #
  # The root path '/' and sitemap index file are added automatically for you.
  # Links are added to the Sitemap in the order they are specified.
  #
  # Usage: add(path, options={})
  #        (default options are used if you don't specify)
  #
  # Defaults: :priority => 0.5, :changefreq => 'weekly',
  #           :lastmod => Time.now, :host => default_host
  #
  # Examples:
  #
  # Add '/articles'
  #
  #   add articles_path, :priority => 0.7, :changefreq => 'daily'
  #
  # Add all articles:
  #
  #   Article.find_each do |article|
  #     add article_path(article), :lastmod => article.updated_at
  #   end
end
