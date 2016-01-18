require 'csv'

namespace :import do
  def import_files
    Dir.glob("#{Rails.root}/imports/dw_materials_*.csv")
  end

  def spreadsheet_id
    "1LgMaX9n6Yp8DQKq-u-eF1HH2xQ-_aUgSfSJna6mTuLs"
  end

  def sheets
    [
      {name: "log",     gid: 0},
      {name: "surveys", gid: 574066838},
      {name: "worlds",  gid: 728822980}
    ]
  end

  def log(message, level=:info)
    Rails.logger.send(level, message)
    puts message
  end

  desc "Import Distant Worlds prospector spreadsheet"
  task :spreadsheet => :environment do
    Rake::Task["import:dw_spreadsheet:download"].invoke
    Rake::Task["import:dw_spreadsheet:update_db"].invoke
    Rake::Task["import:dw_spreadsheet:clean_up"].invoke
  end

  namespace :dw_spreadsheet do

    def clean_up
      import_files.each { |f| FileUtils.rm_f(f) }
    end

    def spreadsheet_url(gid)
      "https://docs.google.com/spreadsheets/d/#{
        spreadsheet_id}/export?format=csv&gid=#{gid}&id=#{spreadsheet_id}"
    end

    def read_csv_data()
      @worlds_arr =  CSV.read("#{Rails.root}/imports/dw_materials_worlds.csv", headers: true)
      @surveys_arr = CSV.read("#{Rails.root}/imports/dw_materials_surveys.csv", headers: true)
      @logs_arr =    CSV.read("#{Rails.root}/imports/dw_materials_log.csv", headers: true)
    end

    def build_worlds_dict
      @worlds_arr.inject({}) do |acc, system|
        full_system = system["World Name"].to_s.upcase.strip
        acc[full_system] = system.to_h if full_system.present?
        acc
      end
    end

    def insert_key_fields
      @surveys_arr.each do |survey|
        full_system = survey["World"].to_s.upcase
        world_data = @worlds_dict[full_system]

        system    = world_data["System Name"] if world_data
        world     = world_data["Body"] if world_data
        commander = survey["Surveyed By"]

        if system && world && commander
          ws = WorldSurvey.where("UPPER(TRIM(system)) = :system AND
                                  UPPER(TRIM(world)) = :world AND
                                  UPPER(TRIM(commander)) = :commander",
                                  { system:    system.upcase.strip,
                                    world:     world.upcase.strip,
                                    commander: commander.upcase.strip })
          prefix = "Inserting #{full_system}:"
          if ws.blank?
            log "#{prefix} creating..."
            ws.create(system: system.titleize, world: world, commander: commander)
          else
            log "#{prefix} already exists"
          end
        else
          log "Unable to find key fields for #{full_system} (#{system}, #{world}, #{commander})"
        end
      end
    end

    def update_world_data
      @worlds_arr.each do |data|
        system = data["System Name"].to_s.upcase.strip
        world = data["Body"].to_s.upcase.strip
        if system.present? && world.present?
          log "Updating world data for #{system} #{world}..."
          attributes = { world_type: data["World Type"],
                         radius: data["Radius [km]"],
                         gravity: data["Gravity [km]"],
                         vulcanism_type: data["Volcanism"],
                         arrival_point: data["Arrival Point"] }
          unless attributes.values.all?(&:blank?)
            WorldSurvey.where("UPPER(TRIM(system)) = :system AND
                               UPPER(TRIM(world)) = :world",
                               { system: system, world: world }).
                        update_all(world_type: data["World Type"],
                                   radius: data["Radius [km]"],
                                   gravity: data["Gravity [km]"],
                                   vulcanism_type: data["Volcanism"],
                                   arrival_point: data["Arrival Point"])
          else
            log "Nothing to update"
          end
        end
      end
    end

    task :download => :environment do
      log "Downloading Distant Worlds Spreadsheet..."
      clean_up
      begin
        sheets.each do |sheet|
          open("#{Rails.root}/imports/dw_materials_#{sheet[:name]}.csv", 'wb') do |file|
            url = spreadsheet_url(sheet[:gid])
            file << open(url).read
          end
        end
      rescue OpenSSL::SSL::SSLError
        log ""
        STDERR.log "SSL problems. Probably a certs issue with this flavor of ruby. Instructions on how to fix it can be found here: https://gist.github.com/mislav/5026283"
        raise
      end
      log "Done!"
    end

    task :update_db => :environment do
      log "Updating Database with DW Spreadsheet data..."
      # Taking advantage of the CSVs being small. This will of course not to
      # be refined if the sitation changes
      @start_time = Time.now()

      read_csv_data()
      @worlds_dict = build_worlds_dict()
      insert_key_fields
      update_world_data
      log "Done!"
    end

    task :clean_up => :environment do
      log "Cleaning up..."
      clean_up
      log "Done!"
    end
  end
end
