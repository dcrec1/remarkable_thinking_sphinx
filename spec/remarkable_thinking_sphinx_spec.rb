require File.join(File.dirname(__FILE__), "spec_helper.rb")

create_table "people" do end
create_table "blog_posts" do end
class BlogPost < ActiveRecord::Base; end

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
    indexes taggings.tag.name, :as => :tag
    
    has created_at, role_id
    has posts(:id), :as => :post_ids
    has active
  end

  sphinx_scope(:latest_first) { { :order => 'created_at DESC' } }
  sphinx_scope(:with_role) { |role_id| { :with => { :role_id => role_id } } }
end

describe Remarkable::ThinkingSphinx, 'for a model that does not have a defined index' do
  subject { BlogPost.new }

  context "index" do
    it "should validate a field is not being indexed" do
      index(:title).matches?(subject).should be_false
    end
  end

  context "have_index_attribute" do
    it "should validate a field is not being indexed" do
      have_index_attribute(:date).matches?(subject).should be_false
    end
  end

  context 'have_sphinx_scope' do
    it "should fail since no sphinx scopes are defined" do
      have_sphinx_scope(:date).matches?(subject).should be_false
    end
  end
end

describe Remarkable::ThinkingSphinx, 'for a model that has a defined index' do
  before :each do
    @model = Person.new
  end

  context "index" do
    it "should validate a field is being indexed" do
      index(:email).matches?(@model).should be_true
    end
    
    it "should validate a field is not being indexed" do
      index('name').matches?(@model).should be_false
    end
    
    it "should validate a field has an alias" do
      index("taggings.tag.name", :as => :tag).matches?(@model).should be_true
    end
    
    it "should validate a field doesn't has an alias" do
      index("taggings.tag.name", :as => :thundercat).matches?(@model).should be_false
    end
  end
  
  context "have_index_attribute" do
    it "should validate a index has an attribute" do
      have_index_attribute("active").matches?(@model).should be_true
    end
    
    it "should validate a index doesn't has an attribute" do
      have_index_attribute("pasive").matches?(@model).should be_false
    end
    
    it "should validate an index attribute has an alias" do
      have_index_attribute("posts.id", :as => :post_ids).matches?(@model).should be_true
    end
    
    it "should validate an index attribute doesn't has an alias" do
      have_index_attribute("posts.id", :as => :posts_names).matches?(@model).should be_false
    end
  end

  context 'have_sphinx_scope' do
    it 'should not match if the scope does not exist' do
      have_sphinx_scope(:not_a_scope).matches?(@model).should be_false
    end

    it 'should not match if the scope options are wrong' do
      have_sphinx_scope(:latest_first, :order => 'created_at ASC').matches?(@model).should be_false
    end

    it 'should match if the scope exists and the options are right' do
      have_sphinx_scope(:latest_first, :order => 'created_at DESC').matches?(@model).should be_true
    end

    it 'should handle lambda scopes' do
      have_sphinx_scope(:with_role, :args => 6, :with => { :role_id => 5 }).matches?(@model).should be_false
      have_sphinx_scope(:with_role, :args => 5, :with => { :role_id => 5 }).matches?(@model).should be_true
    end
  end
end
