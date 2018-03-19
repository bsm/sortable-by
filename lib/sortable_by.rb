require 'active_record'
require 'active_support/concern'
require 'set'

module ActiveRecord # :nodoc:
  module SortableByHelper # :nodoc:
    extend ActiveSupport::Concern

    included do
      class_attribute :_sortable_by_scope_options, instance_accessor: false
      sortable_by
    end

    def self.validate_custom_scope!(custom, original = custom)
      case custom
      when true, Arel::Nodes::Node, String, Symbol
        nil # OK
      when Array
        custom.each do |v|
          validate_custom_scope!(v, original)
        end
      else
        raise ArgumentError, "Option #{original.inspect} contains unexpected values."
      end
    end

    def self.order_clause(name, rank, value)
      case value
      when true
        { name => rank }
      when String, Symbol
        { value => rank }
      when Arel::Nodes::Node
        value.send(rank)
      when Array
        value.map { |v| order_clause(name, rank, v) }
      end
    end

    module ClassMethods # :nodoc:
      # Copy _sortable_by_scope_options on inheritance.
      def inherited(base) #:nodoc:
        base._sortable_by_scope_options = _sortable_by_scope_options.deep_dup
        super
      end

      # Provide a whitelist and options for sorted_by
      def sortable_by(*whitelist)
        self._sortable_by_scope_options ||= { scopes: {}, default: { id: :asc } }

        opts = whitelist.extract_options!
        default = opts.delete(:default)
        self._sortable_by_scope_options[:default] = default if default

        whitelist.each do |attr|
          self._sortable_by_scope_options[:scopes][attr.to_s] = true
        end
        opts.each do |attr, custom|
          SortableByHelper.validate_custom_scope!(custom)
          self._sortable_by_scope_options[:scopes][attr.to_s] = custom
        end
      end

      # @param [String] expr the sort expr
      # @return [ActiveRecord::Relation] the scoped relation
      def sorted_by(expr)
        relation = self
        matches = expr.to_s.split(',').count do |name|
          name.strip!

          rank = :asc
          if name[0] == '-'
            rank = :desc
            name = name[1..-1]
          end

          value  = self._sortable_by_scope_options[:scopes][name]
          clause = SortableByHelper.order_clause(name, rank, value)
          relation = relation.order(clause) if clause
          clause
        end

        if matches.zero?
          default  = self._sortable_by_scope_options[:default]
          relation = relation.order(default)
        end

        relation
      end
    end
  end

  class Base # :nodoc:
    include SortableByHelper
  end
end
