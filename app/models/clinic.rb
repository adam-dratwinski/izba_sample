# encoding: UTF-8
class Clinic < ActiveRecord::Base
  geocoded_by :full_address_with_poland, :latitude => :lat, :longitude => :lng

  attr_accessible :name, :nip, :state_id, :city_id, :street, :description, :city_name

  has_friendly_id :friendly_name, :use_slug => true, :cache_column => 'cached_slug', :approximate_ascii =>true

  belongs_to :departament
  belongs_to :city, :counter_cache => true, :touch => true
  belongs_to :state
  has_many :offices
  has_many :offices_with_specialisations, :class_name => "Office", :include => :specialisations
  has_many :offices_with_diseases, :class_name => "Office", :include => :diseases
  has_many :offices_with_both, :class_name => "Office", :include => [ :diseases, :specialisations ]

  attr_accessor :city_name

  validates :state, :presence => true
  validates :city, :presence => true
  validates :street, :presence => true
  validates :name, :presence => true
  validates :departament, :presence => true

  validate :validate_city_belongs_to_state

  before_save :set_tags, :update_cities_counter

  acts_as_taggable

  def full_address_with_poland
    self.full_address + " Poland"
  end

  def friendly_name
    "#{name}-#{full_address}"
  end

  def city_name=(value)
    unless self.city_id?
      city = City.where(:name.eq => value, :state_id.eq => self.state_id).first
      self.city = city
    end
  end

  def city_name
    city.name if city
  end

  define_index do
    indexes :name
    indexes :description
    indexes :street

    indexes city.name, :as => :city_name
    indexes state.name, :as => :state_name

    indexes offices.name, :as => :office_name, :facet => true
    indexes offices.specialisations.name, :as => :specialisation_name
    indexes offices.diseases.name, :as => :disease_name
    indexes offices.city.name, :as => :office_city_name
    indexes offices.state.name, :as => :office_state_name
    indexes offices.street, :as => :office_street
    
    indexes departament.name, :as => :departament_name
    indexes departament.city.name, :as => :departament_city_name
    indexes departament.state.name, :as => :departament_state_name
    indexes departament.street, :as => :departament_street

    has :city_id
    has :state_id

    has 'RADIANS(`clinics`.`lat`)', :as => "latitude", :type => :float
    has 'RADIANS(`clinics`.`lng`)', :as => "longitude", :type => :float

    set_property :latitude_attr => "latitude"
    set_property :longitude_attr => "longitude"

    set_property :enable_star => 1
    set_property :min_infix_len => 3

  end

  def specialisations
    self.offices_with_specialisations.map do |o|
      o.specialisations
    end.flatten.uniq
  end

  def address
    "#{self.street}, #{self.city.name}"
  end

  def set_geolocation
    street = Street.where("`street` = ? AND `city_id` = ?", self.street, self.city_id).first
    unless street
      street = Street.new
      street.city = self.city
      street.street = self.street

      geocode = Geocoding::Base.new street.street + ", " + street.city.name

      if location = geocode.get_location
        street.lat = location["lat"]
        street.lng = location["lng"]
        street.save
        self.lat = street.lat
        self.lng = street.lng
        self.save
      end
    end
  end

  def to_json
    {
      :id => self.id,
      :name => self.name,
      :street => self.street,
      :lat => self.lat,
      :lng => self.lng
    }.to_json
  end

  def search_distance
    if self.sphinx_attributes
      self.sphinx_attributes["@geodist"]
    end
  end

  private

  def validate_city_belongs_to_state
    if self.city && self.state && self.city.state != self.state
      errors.add(:city_name, I18n.t("clinics.errors.city_belongs_to_state")) 
    end
  end

  def set_tags
    cached_offices = self.offices_with_both
    self.tag_list =  cached_offices.map(&:specialisations).flatten.map(&:name)
    self.tag_list += cached_offices.map(&:diseases).flatten.map(&:name)
    self.tag_list += [self.name]
  end

  def update_cities_counter
    if self.city_id_changed?
      City.find(self.city_id_was).decrement! :clinics_count
      City.find(self.city_id).increment! :clinics_count
    end
  end
end
