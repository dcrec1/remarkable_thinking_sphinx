module Remarkable
  module ThinkingSphinx
    module Matchers
      class IndexMatcher < Remarkable::ActiveRecord::Base
        arguments :attribute
        
        assertion :indexes?
        
        def indexes?
          fields = @subject.sphinx_indexes.first.fields
          columns = fields.map { |field| field.columns }.flatten
          columns.map do |column|
            stack = column.__stack.first
            name = column.__name.to_s
            stack.nil? ? name : "#{stack}.#{name}"
          end.include?(@attribute)
        end
      end

      def index(attribute)
        IndexMatcher.new(attribute).spec(self)
      end

    end
  end
end
