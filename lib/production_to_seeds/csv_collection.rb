module ProductionToSeeds
  class CsvCollection
    attr_reader :object

    def initialize(dump_filename)
      @dump_filename = dump_filename
      @dir           = File.join File.dirname(@dump_filename), File.basename(@dump_filename, '.tar.gz')
      FileUtils.mkdir_p @dir

      @collection = Hash.new
    end

    def csv_for(klass, headers)
      @collection[klass] ||= open_csv_for(klass, headers)
    end

    def close_all
      @collection.each do |klass, csv|
        csv.close
      end
    end

    def compress
      Archive.compress @dump_filename, @dir, type: :tar, compression: :gzip
      # FileUtils.rm_rf @dir
    end

    def fetch(klass, **options, &block)
      ProductionToSeeds::Generator.new self, klass, options, &block
    end

    def fetch!(klass, **options, &block)
      fetch(klass, options, &block).generate
    end

    protected
    def open_csv_for(klass, headers)
      CSV.open "#{File.join @dir, klass.table_name}.csv", 'w', write_headers: true, headers: headers
    end
  end
end
