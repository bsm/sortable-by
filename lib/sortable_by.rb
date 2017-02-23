require 'active_record'
require 'active_support/concern'
require 'set'

module ActiveRecord
  module SortableByHelper
    extend ActiveSupport::Concern

    included do
      class_attribute :_sortable_by_scope_options, instance_accessor: false
      sortable_by
    end

    module ClassMethods

      def sortable_by(*whitelist)
        opts = whitelist.extract_options!
        opts[:default] ||= {id: :asc}
        self._sortable_by_scope_options = opts.merge(whitelist: whitelist.map(&:to_s).to_set)
      end

      # @param [String] expr the sort expr
      # @return [ActiveRecord::Relation] the scoped relation
      def sorted_by(expr)
        options = {}
        expr.to_s.split(',').each do |name|
          name.strip!
          rank = :asc
          rank, name = :desc, name[1..-1] if name[0] == '-'
          options[name.to_sym] = rank if self._sortable_by_scope_options[:whitelist].include?(name)
        end
        options = self._sortable_by_scope_options[:default] if options.empty?
        order(options)
      end

    end
  end

  class Base
    include SortableByHelper
  end
end
