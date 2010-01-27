module Remarkable
  module ThinkingSphinx
  
    class Base < Remarkable::ActiveRecord::Base
      def exists?(map)
        if [nil, []].include?(@subject.sphinx_indexes) && @subject.class.respond_to?(:define_indexes)
          @subject.class.define_indexes
        end

        key, value = map.keys.first.to_s, map.values.first
        as = @options[:as]
        values = if @subject.sphinx_indexes.nil? || @subject.sphinx_indexes.size == 0
          []
        else
          @subject.sphinx_indexes.first.send key.pluralize
        end
        columns = values.map do |v|
          if as.nil? or as.eql? v.alias
            v.columns
          else
            nil
          end
        end.flatten.compact
        columns.map do |column|
          stack = column.__stack.inject { |a, b| a.to_s + "." + b.to_s }
          name = column.__name.to_s
          stack.nil? ? name : "#{stack}.#{name}"
        end.include?(value.to_s)
      end    
    end
    
    module Matchers
    
      class IndexMatcher < ThinkingSphinx::Base
        arguments :field
        
        optional :as
        
        assertion :indexes?
        
        def indexes?
          exists?(:field => @field)
        end
      end
      
      class HaveIndexAttributeMatcher < ThinkingSphinx::Base
        arguments :attribute
        
        optional :as
        
        assertion :has_index_attribute?
        
        def has_index_attribute?
          exists?(:attribute => @attribute)
        end
      end

      def index(*args)
        IndexMatcher.new(*args).spec(self)
      end
      
      def have_index_attribute(*args)
        HaveIndexAttributeMatcher.new(*args).spec(self)
      end

    end
  end
end
