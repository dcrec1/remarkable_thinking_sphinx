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

      # The design of this was taken directly from Remarkable's HaveScopeMatcher:
      #  http://github.com/carlosbrando/remarkable/blob/7049b3339da0b6d3ec0fe0d3720d4eac755fad10/remarkable_activerecord/lib/remarkable_activerecord/matchers/have_scope_matcher.rb
      class HaveSphinxScopeMatcher < Remarkable::ActiveRecord::Base
        arguments :scope_name
        assertions :is_scope?, :options_match?

        optionals :args, :splat => true
        optionals :conditions, :with, :with_all, :order, :sort_mode, :field_weights,
                  :group_by, :group_function, :group_clause, :page, :per_page, :classes,
                  :match_mode, :rank_mode

        protected

        def is_scope?
          @scope_object = if @options.key?(:args)
            @options[:args] = [ @options[:args] ] unless Array === @options[:args]
            subject_class.send(@scope_name, *@options[:args])
          else
            subject_class.send(@scope_name)
          end

          @scope_object.class == ::ThinkingSphinx::Search
        rescue NoMethodError
          # the sphinx scope does not exist...
          false
        end

        def expected_options
          @options.except(:args)
        end

        def actual_options
          @scope_object ? @scope_object.options.except(:classes, :raise_on_stale, :limit) : {}
        end

        def options_match?
          actual_options == expected_options
        end

        def interpolation_options
          {
            :options => expected_options.inspect,
            :actual  => actual_options.inspect
          }
        end
      end

      def index(*args)
        IndexMatcher.new(*args).spec(self)
      end
      
      def have_index_attribute(*args)
        HaveIndexAttributeMatcher.new(*args).spec(self)
      end

      def have_sphinx_scope(*args, &block)
        HaveSphinxScopeMatcher.new(*args, &block).spec(self)
      end

    end
  end
end
