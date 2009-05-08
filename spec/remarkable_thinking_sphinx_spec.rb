require File.join(File.dirname(__FILE__), "spec_helper.rb")

create_table "people" do end

require 'thinking_sphinx'

class Person < ActiveRecord::Base

  define_index do
    indexes [:first_name, :last_name], :as => :name, :sortable => true
    indexes login, :sortable => :true
    indexes email
    indexes role.name, :as => :role
    indexes [
      address.street_address, address.city,
      address.state, address.country, address.postcode
    ], :as => :address
    indexes posts.subject, :as => :post_subjects
    indexes posts.content, :as => :post_contents
    
    has created_at, role_id
    has posts(:id), :as => :post_ids
    has active
  end

end

describe Remarkable::ThinkingSphinx do
  context "index" do
    it "should validate a field is being indexed" do
      index('email').matches?(Person.new).should be_true
    end
    
    it "should validate a field is not being indexed" do
      index('name').matches?(Person.new).should be_false
    end
  end
  
  context "" do
  end
end
