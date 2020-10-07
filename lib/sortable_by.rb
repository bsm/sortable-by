require 'active_record'

module ActiveRecord # :nodoc:
  module SortableBy # :nodoc:
    class Config # :nodoc:
      attr_reader :_fields, :_default

      def initialize
        @_fields  = {}
        @_default = nil
      end

      def dup
        duplicate = self.class.new
        duplicate.instance_variable_set :@_fields, _fields.deep_dup
        duplicate.instance_variable_set :@_default, _default.deep_dup
        duplicate
      end

      def field(name, **opts)
        name = name.to_s
        @_fields[name] = Field.new(name, **opts)
        @_default ||= name
      end

      def default(expr)
        # legacy support
        if expr.is_a?(Hash)
          expr = expr.map do |field, dir|
            [(dir == :desc ? '-' : ''), field].join
          end.join(',')
        end

        @_default = expr.to_s
      end

      protected

      def order(relation, expr, fallback: true)
        matched = false
        expr.to_s.split(',').each do |name|
          name.strip!

          rank = :asc
          if name[0] == '-'
            rank = :desc
            name = name[1..-1]
          end

          field = _fields[name]
          next unless field

          matched = true
          relation = field.order(relation, rank)
        end

        relation = order(relation, _default, fallback: false) if fallback && !matched && _default
        relation
      end
    end

    class Field # :nodoc:
      def initialize(name, as: nil, scope: nil, eager_load: nil, case_sensitive: false)
        @cols = Array.wrap(as)
        @eager_load = Array.wrap(eager_load).presence
        @case_sensitive = case_sensitive == true

        # validate custom_scope
        @custom_scope = scope
        raise ArgumentError, "Invalid sortable-by field '#{name}': scope must be a Proc." if @custom_scope && !@custom_scope.is_a?(Proc)

        # normalize cols
        @cols.push name if @cols.empty?
        @cols.each do |col|
          case col
          when String, Symbol, Arel::Attributes::Attribute, Arel::Nodes::Node
            next
          when Proc
            raise ArgumentError, "Invalid sortable-by field '#{name}': proc must accept 2 arguments." unless col.arity == 2
          else
            raise ArgumentError, "Invalid sortable-by field '#{name}': invalid type #{col.class}."
          end
        end
      end

      def order(relation, rank)
        @cols.each do |col|
          case col
          when String, Symbol
            type = relation.columns_hash[col.to_s].type
            col  = relation.arel_table[col]
            col  = col.lower if (type == :string || type == :text) && !@case_sensitive
            relation = relation.order(col.send(rank))
          when Arel::Nodes::Node, Arel::Attributes::Attribute
            relation = relation.order(col.send(rank))
          when Proc
            relation = col.call(relation, rank)
          end
        end

        relation = relation.eager_load(*@eager_load) if @eager_load
        relation = relation.instance_eval(&@custom_scope) if @custom_scope
        relation
      end
    end

    def self.extended(base) # :nodoc:
      base.class_attribute :_sortable_by_config, instance_accessor: false, instance_predicate: false
      base._sortable_by_config = Config.new
    end

    def inherited(base) # :nodoc:
      base._sortable_by_config = _sortable_by_config.deep_dup
      super
    end

    # Declare sortable attributes and scopes. Examples:
    #
    #   # Simple
    #   class Post < ActiveRecord::Base
    #     sortable_by :title, :id
    #   end
    #
    #   # Case-sensitive
    #   class Post < ActiveRecord::Base
    #     sortable_by do |x|
    #       x.field :title, case_sensitive: true
    #       x.field :id
    #     end
    #   end
    #
    #   # With default
    #   class Post < ActiveRecord::Base
    #     sortable_by :id, :topic, :created_at,
    #       default: 'topic,-created_at'
    #   end
    #
    #   # Composition
    #   class App < ActiveRecord::Base
    #     sortable_by :name, default: '-version' do |x|
    #       x.field :version, as: %i[major minor patch]]
    #     end
    #   end
    #
    #   # Associations (eager load)
    #   class Product < ActiveRecord::Base
    #     belongs_to :shop
    #
    #     sortable_by do |x|
    #       x.field :name
    #       x.field :shop, as: Shop.arel_table[:name], eager_load: :shop
    #       x.default 'shop,name'
    #     end
    #   end
    #
    #   # Associations (custom scope)
    #   class Product < ActiveRecord::Base
    #     belongs_to :shop
    #
    #     sortable_by do |x|
    #       x.field :shop, as: Shop.arel_table[:name], scope: -> { joins(:shop) }
    #     end
    #   end
    #
    def sortable_by(*attributes, **opts)
      config  = _sortable_by_config
      default = opts.delete(:default)

      attributes.each do |name|
        config.field(name, **opts)
      end
      config.default(default) if default
      yield config if block_given?
      config
    end

    # @param [String] expr the sort expr
    # @return [ActiveRecord::Relation] the scoped relation
    def sorted_by(expr)
      _sortable_by_config.send :order, self, expr
    end
  end

  class Base # :nodoc:
    extend SortableBy
  end
end
