module Remarkable
  module ThinkingSphinx
  
    class Base < Remarkable::ActiveRecord::Base
      def exists?(map)
        key, value = map.keys.first.to_s, map.values.first
        values = @subject.sphinx_indexes.first.send key.pluralize
        columns = values.map { |field| field.columns }.flatten
        columns.map do |column|
          stack = column.__stack.first
          name = column.__name.to_s
          stack.nil? ? name : "#{stack}.#{name}"
        end.include?(value)
      end    
    end
    
    module Matchers
    
      class IndexMatcher < ThinkingSphinx::Base
        arguments :field
        
        assertion :indexes?
        
        def indexes?
          exists?(:field => @field)
        end
      end
      
      class HaveIndexAttributeMatcher < ThinkingSphinx::Base
        arguments :attribute
        
        assertion :has_index_attribute?
        
        def has_index_attribute?
          exists?(:attribute => @attribute)
        end
      end

      def index(field)
        IndexMatcher.new(field).spec(self)
      end
      
      def have_index_attribute(attribute)
        HaveIndexAttributeMatcher.new(attribute).spec(self)
      end

    end
  end
end
