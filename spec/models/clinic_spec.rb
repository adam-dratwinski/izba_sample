require File.dirname(__FILE__) + '/../spec_helper'

describe Clinic do
  it "should be valid" do
    Factory.build(:clinic).should be_valid
  end

  it "should require city" do
    Factory.build(:clinic, :city => nil).should have(1).error_on(:city)
  end

  it "should require state" do
    Factory.build(:clinic, :state => nil).should have(1).error_on(:state)
  end

  it "should parse address" do
    city = Factory.build(:city, :name => "Gorzow")
    street = "Walczaka 57/6"
    clinic = Factory.build(:clinic, :street => street, :city => city)
    clinic.address.should == "Walczaka 57/6, Gorzow"
  end

  it "should require city belongs to state" do
    Factory.build(:user_without_city, :state => Factory.build(:state), :city => Factory.build(:city)).should have(1).error_on(:city)
  end
end
