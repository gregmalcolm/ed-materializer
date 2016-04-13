require 'zip'
require 'digest/md5'

namespace :export do
  desc "Create zipped snapshot of all data"
  task :snapshots => :environment do
    log "Building snapshots"
    Rake::Task["export:snapshot:stars"].invoke
    Rake::Task["export:snapshot:worlds"].invoke
    Rake::Task["export:snapshot:world_surveys"].invoke
    Rake::Task["export:snapshot:basecamps"].invoke
    Rake::Task["export:snapshot:surveys"].invoke
    Rake::Task["export:snapshot:systems"].invoke
    
    log "Done!" 
  end

  namespace :snapshot do
    def make_snapshot(model_name)
      models = model_name.constantize.all
      serializer = "#{model_name}Serializer".constantize
      array_serializer = ActiveModel::Serializer::ArraySerializer.new(models, serializer: serializer)
      adapter = ActiveModel::Serializer::Adapter.create(array_serializer)
      
      filename = "#{model_name.underscore.dasherize}s.json"
      full_filename = "#{Rails.root}/exports/snapshots/#{filename}"
      zip_filename = "#{full_filename}.zip"
      md5_filename = "#{full_filename}.md5"
      tmp_filename = "#{Rails.root}/tmp/#{filename}"

      FileUtils.rm_f zip_filename
      FileUtils.rm_f md5_filename

      File.write(tmp_filename, adapter.to_json)
      Zip::File.open(zip_filename, Zip::File::CREATE) do |zip|
        zip.add filename, tmp_filename
      end

      File.write(md5_filename, Digest::MD5.hexdigest(File.read(zip_filename)))

      FileUtils.rm_f tmp_filename
    end

    task :stars => :environment do
      log "Stars..."
      make_snapshot("Star")
    end
    
    task :worlds => :environment do
      log "Worlds..."
      make_snapshot("World")
    end
    
    task :world_surveys => :environment do
      log "World Surveys..."
      make_snapshot("WorldSurvey")
    end
    
    task :basecamps => :environment do
      log "Basecamps..."
      make_snapshot("Basecamp")
    end
    
    task :surveys => :environment do
      log "Surveys..."
      make_snapshot("Survey")
    end
    
    task :systems => :environment do
      log "Systems..."
      make_snapshot("System")
    end
  end
end
