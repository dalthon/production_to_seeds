module ProductionToSeeds
  class Generator
    attr_reader :object

    def initialize(csv_collection, object, **options, &block)
      @csv_collection, @object, @options = csv_collection, object, options
      @scrambled_attributes = Hash.new

      yield(self) if block_given?
    end

    def scope(value = nil, &block)
      if block_given?
        @options[:scope] = block
      else
        @options[:scope] = value
      end
    end

    def columns(*names)
      @column_names = names.map(&:to_sym)
    end

    def except_columns(*names)
      names = names.map &:to_sym
      column_names.delete_if{ |name| names.include? name }
    end

    def limit(value)
      @options[:limit] = value
    end

    def attribute(name, value = nil, &block)
      if block_given?
        @scrambled_attributes[name] = block
      else
        @scrambled_attributes[name] = value
      end
    end

    def generate(&block)
      return if @object.nil?

      csv = @csv_collection.csv_for model_class, column_names
      fetch_instances do |instance|
        csv << attributes_for(instance)
        yield(instance) if block_given?
      end
    end

    protected
    def model_class
      if @object.is_a? Class
        @object
      else
        if @object.is_a?(ActiveRecord::Associations::CollectionProxy) || @object.is_a?(ActiveRecord::AssociationRelation)
          @object.model
        else
          @object.class
        end
      end
    end

    def column_names
      @column_names ||= model_class.column_names.map(&:to_sym) rescue binding.pry
    end

    def fetch_instances(&block)
      return yield(@object) if @object.is_a? ActiveRecord::Base

      relation = case @options[:scope]
      when Symbol
        @object.public_send @options[:scope]
      when Proc
        @options[:scope].call @object
      when NilClass
        @object
      end

      if @options[:limit].present?
        relation.limit(@options[:limit]).each &block
      else
        relation.find_each &block
      end
    end

    def attributes_for(instance)
      attributes = Hash.new

      column_names.each do |column|
        attributes[column] = instance.read_attribute column
      end

      @scrambled_attributes.each do |key, value_or_proc|
        if value_or_proc.is_a? Proc
          attributes[key] = value_or_proc.call attributes[key]
        else
          attributes[key] = value_or_proc
        end
      end

      attributes
    end

  end
end
