require 'csv'

namespace :import do
  def import_files
    Dir.glob("#{imports_dir}/dw_materials_*.csv")
  end

  def spreadsheet_id
    "1LgMaX9n6Yp8DQKq-u-eF1HH2xQ-_aUgSfSJna6mTuLs"
  end

  def imports_dir
    ENV["IMPORT_DIR"] || "#{Rails.root}/imports"
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

    def fix_world_file
      worlds_orig_file =  "#{imports_dir}/dw_materials_worlds.csv"
      worlds_file = "#{imports_dir}/dw_materials_worlds2.csv"
      FileUtils.rm_f(worlds_file)
      File.open(worlds_file, 'w') do |file|
        data = File.read(worlds_orig_file)
        # CSV doesn't like carriage returns in headers
        2.times { data = data.sub("\n", "") }
        file.write data
      end
    end

    def read_csv_data()
      @worlds_arr =      CSV.read("#{imports_dir}/dw_materials_worlds2.csv", headers: true)
      @surveys_arr =     CSV.read("#{imports_dir}/dw_materials_surveys.csv", headers: true)
      @survey_logs_arr = CSV.read("#{imports_dir}/dw_materials_log.csv", headers: true)
    end

    def build_worlds_dict
      @worlds_dict = @worlds_arr.inject({}) do |acc, system|
        full_system = system["World Name"].to_s.upcase.strip
        acc[full_system] = system.to_h if full_system.present?
        acc
      end
    end

    def build_surveys_dict
      @surveys_dict = @surveys_arr.inject({}) do |acc, survey|
        survey_id = survey["Survey ID"]
        acc[survey_id] = survey.to_h if survey_id
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
            ws.create(system: system, world: world, commander: commander)
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

    def update_materials_data
      @survey_logs_arr.each do |data|
        survey = @surveys_dict[data["Survey / World"]]
        full_system = @worlds_dict[survey["World"].to_s.upcase.strip] if survey.present?
        system = full_system["System Name"].to_s.upcase.strip if full_system.present?
        world = full_system["Body"].to_s.upcase.strip if full_system.present?
        commander = survey["Surveyed By"].to_s.upcase.strip if survey.present?
        if system.present? && world.present? && commander.present?
          log "Updating materials data for #{system} #{world} by #{commander}..."
          attributes = { carbon: data["C"].to_i > 0,
                         iron: data["Fe"].to_i > 0,
                         nickel: data["Ni"].to_i > 0,
                         phosphorus: data["P"].to_i > 0,
                         sulphur: data["S"].to_i > 0,
                         arsenic: data["As"].to_i > 0,
                         chromium: data["Cr"].to_i > 0,
                         germanium: data["Ge"].to_i > 0,
                         manganese: data["Mn"].to_i > 0,
                         selenium: data["Se"].to_i > 0,
                         vanadium: data["V"].to_i > 0,
                         zinc: data["Zn"].to_i > 0,
                         zirconium: data["Zr"].to_i > 0,
                         cadmium: data["Cd"].to_i > 0,
                         mercury: data["Hg"].to_i > 0,
                         molybdenum: data["Mo"].to_i > 0,
                         niobium: data["Nb"].to_i > 0,
                         tin: data["Sn"].to_i > 0,
                         tungsten: data["W"].to_i > 0,
                         antimony: data["Sb"].to_i > 0,
                         polonium: data["Po"].to_i > 0,
                         ruthenium: data["Ru"].to_i > 0,
                         technetium: data["Tc"].to_i > 0,
                         tellurium: data["Te"].to_i > 0,
                         yttrium: data["Y"].to_i > 0,
                         notes: survey["Notes"] }

          unless attributes.values.all?(&:blank?)
            WorldSurvey.where("UPPER(TRIM(system)) = :system AND
                               UPPER(TRIM(world)) = :world AND
                               UPPER(TRIM(commander)) = :commander",
                               { system: system,
                                 world: world,
                                 commander: commander}).
                        update_all(attributes)
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
          open("#{imports_dir}/dw_materials_#{sheet[:name]}.csv", 'wb') do |file|
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

      fix_world_file
      read_csv_data
      build_worlds_dict
      build_surveys_dict
      insert_key_fields
      update_world_data
      update_materials_data
      log "Done!"
    end

    task :clean_up => :environment do
      log "Cleaning up..."
      clean_up
      log "Done!"
    end
  end
end
