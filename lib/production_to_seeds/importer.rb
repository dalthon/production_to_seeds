module ProductionToSeeds
  class Importer
    def initialize(dump_filename)
      @dump_filename = dump_filename
    end

    def import
      extract_files

      Dir[File.join(dump_path, basename, '*.csv')].each do |csv_filename|
        import_from_csv csv_filename
      end

      # clean
    end

    protected
    def import_from_csv(csv_filename)
      CSV.open csv_filename do |csv|
        columns = csv.readline
        values  = csv.readlines.uniq
        model_for(csv_filename).import columns, values, validate: false
      end
    end

    def dump_path
      @dump_path ||= File.join File.dirname(@dump_filename)
    end

    def basename
      File.basename @dump_filename, '.tar.gz'
    end

    def model_for(csv_filename)
      File.basename(csv_filename, '.csv').singularize.camelize.constantize
    end

    def extract_files
      Archive.extract @dump_filename
    end

    def clean
      FileUtils.rm_rf dump_path
    end
  end
end
