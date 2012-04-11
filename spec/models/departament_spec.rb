require File.dirname(__FILE__) + '/../spec_helper'

describe Departament do
  it "should be valid" do
    Factory.build(:departament).should be_valid
  end

  it "should require name" do
    Factory.build(:departament, :name => '').should have(1).error_on(:name)
  end

  it "should require state" do
    Factory.build(:departament, :name => '').should have(1).error_on(:name)
  end

  it "should require city" do
    Factory.build(:departament, :name => '').should have(1).error_on(:name)
  end

  it "should require street" do
    Factory.build(:departament, :name => '').should have(1).error_on(:name)
  end

  it "should require city belongs to state" do
    Factory.build(:departament_without_city, :state => Factory.build(:state), :city => Factory.build(:city)).should have(1).error_on(:city_name)
  end

  it "should connect departament with a city if city name matches" do
    state = Factory.create(:state, :name => "Pomorskie")
    city = Factory.create(:city, :name => "Szczecin", :state => state)
    Factory.create(:departament_without_city, :state => state, :city_name => "Szczecin").city.id == city.id
  end

  it "should require city if city name doesnt connected with state" do
    state = Factory.create(:state, :name => "Pomorskie")
    Factory.build(:departament_without_city, :state => state, :city_name => "Szczecin").should have(1).error_on(:city)
  end

  it "should assign user if user_id provided" do
    user = Factory.create(:user)
    departament = Factory.create(:departament, :user_id => user.id)
    user.departament_id = departament.id
  end
end
