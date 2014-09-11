lib = File.expand_path '..', __FILE__
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

# stdlib
require 'csv'
require 'fileutils'

# dependencies
require 'archive'

# library files
require 'production_to_seeds/version'

require 'production_to_seeds/generator'
require 'production_to_seeds/csv_collection'
require 'production_to_seeds/importer'

module ProductionToSeeds
  def self.collection(dump_filename)
    collection = ProductionToSeeds::CsvCollection.new dump_filename
    yield collection
    collection.close_all
    collection.compress
  end

  def self.populate(dump_filename)
    ProductionToSeeds::Importer.new(dump_filename).import
  end
end
