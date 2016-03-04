require 'csv'

namespace :import do
  def csv_files
    Dir.glob("#{imports_dir}/dw_materials_*.csv")
  end

  def import_files
    sheets.map { |s| "#{imports_dir}/dw_materials_#{s[:name]}.csv" }
  end

  def spreadsheet_id
    "1LgMaX9n6Yp8DQKq-u-eF1HH2xQ-_aUgSfSJna6mTuLs"
  end

  def imports_dir
    ENV["IMPORT_DIR"] || "#{Rails.root}/imports"
  end

  def updater_tag
    "DW Spreadsheet"
  end

  def materials
    %w[carbon
       iron
       nickel
       phosphorus
       sulphur
       arsenic
       chromium
       germanium
       manganese
       selenium
       vanadium
       zinc
       zirconium
       cadmium
       mercury
       molybdenum
       niobium
       tin
       tungsten
       antimony
       polonium
       ruthenium
       technetium
       tellurium
       yttrium]
  end
  def color_lookup(color_name)
    color_name = color_name.to_s
                           .downcase.gsub("ice","white")
    color = Color::CSS[color_name]
    color.hex.to_i(16) if color
  end

  def sheets
    [
      {name: "log",     gid: 0},
      {name: "surveys", gid: 574066838},
      {name: "worlds",  gid: 728822980},
      {name: "systems", gid: 2126209210}
    ]
  end

  def log(message, level=:info)
    Rails.logger.send(level, message)
    puts message
  end

  desc "Import Distant Worlds prospector spreadsheet"
  task :spreadsheet => :environment do
    Rake::Task["import:dw_spreadsheet:download"].invoke
    Rake::Task["import:dw_spreadsheet:update_db_v1"].invoke
    Rake::Task["import:dw_spreadsheet:update"].invoke
    Rake::Task["import:dw_spreadsheet:clean_up"].invoke
  end

  namespace :dw_spreadsheet do

    def clean_up
      csv_files.each { |f| FileUtils.rm_f(f) }
    end

    def spreadsheet_url(gid)
      "https://docs.google.com/spreadsheets/d/#{
        spreadsheet_id}/export?format=csv&gid=#{gid}&id=#{spreadsheet_id}"
    end

    def fix_csvs
      import_files.each { |filename| fix_header(filename) }
    end

    def fix_header(filename)
      fixed_file = filename[0..-5] << "_fixed.csv"
      FileUtils.rm_f(fixed_file)
      File.open(fixed_file, 'w') do |file|
        data = File.read(filename)

        # Count lines until we encounter a double comma
        num_header_lines = data[0,(data =~ /(,,,)|(,\d*\.\d*,)/)].split("\n").size - 2

        # CSV doesn't like carriage returns in headers
        num_header_lines.times { data = data.sub("\n", "") }
        file.write data
      end
    end

    def read_csv_data()
      @worlds_arr =      CSV.read("#{imports_dir}/dw_materials_worlds_fixed.csv", headers: true)
      @systems_arr =     CSV.read("#{imports_dir}/dw_materials_systems_fixed.csv", headers: true)
      @surveys_arr =     CSV.read("#{imports_dir}/dw_materials_surveys_fixed.csv", headers: true)
      @survey_logs_arr = CSV.read("#{imports_dir}/dw_materials_log_fixed.csv", headers: true)
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

    def insert_key_world_survey_v1_fields
      @surveys_arr.each do |survey|
        full_system = survey["World"].to_s.upcase
        world_data = @worlds_dict[full_system]

        system    = world_data["System Name"] if world_data
        commander = survey["Surveyed By"]

        world     = world_data["Body"] if world_data

        if system && world && commander
          ws = WorldSurveyV1.where("UPPER(TRIM(system)) = :system AND
                                    UPPER(TRIM(world)) = :world AND
                                    UPPER(TRIM(commander)) = :commander",
                                  { system:    system.upcase.strip,
                                    world:     world.upcase.strip,
                                    commander: commander.upcase.strip })
          prefix = "Inserting World Survey #{full_system}:"
          if ws.blank?
            log "#{prefix} creating..."
            ws.create(system: system, world: world, commander: commander)
          else
            log "#{prefix} already exists"
          end
        else
          log "Unable to find key fields for #{full_system} (#{system} #{world}, #{commander})"
        end
      end
    end

    def update_world_survey_v1_data
      @worlds_arr.each do |data|
        system = data["System name"].to_s.upcase.strip
        world = data["Body"].to_s.upcase.strip
        if system.present? && world.present?
          log "Updating world data for #{system} #{world}..."
          attributes = { world_type: data["World Type"],
                         radius: data["Radius [km]"],
                         gravity: data["Gravity [g]"],
                         vulcanism_type: data["Volcanism"],
                         arrival_point: (data["Arrival Point [Ls]"].to_f if data["Arrival Point [Ls]"]),
                         reserve: data["Reserves"],
                         mass: data["Mass [Earth M]"],
                         surface_temp: data["Surf. Temp. [K]"],
                         surface_pressure: data["Surf. P [atm]"],
                         orbit_period: data["Orb. Per. [D]"],
                         rotation_period: data["Rot. Per. [D]"],
                         semi_major_axis: data["Semi Maj. Axis [AU]"],
                         rock_pct: data["Rock %"],
                         metal_pct: data["Metal %"],
                         ice_pct: data["Ice %"]
                       }
          unless attributes.values.all?(&:blank?)
            WorldSurveyV1.where("UPPER(TRIM(system)) = :system AND
                                 UPPER(TRIM(world)) = :world AND
                                 world_type IS NULL AND
                                 radius IS NULL AND
                                 gravity IS NULL AND
                                 vulcanism_type IS NULL AND
                                 arrival_point IS NULL AND
                                 reserve IS NULL AND
                                 mass IS NULL AND
                                 surface_temp IS NULL AND
                                 surface_pressure IS NULL AND
                                 orbit_period IS NULL AND
                                 rotation_period IS NULL AND
                                 semi_major_axis IS NULL AND
                                 rock_pct IS NULL AND
                                 metal_pct IS NULL AND
                                 ice_pct IS NULL",
                                 { system: system, world: world })
                       .update_all(attributes)
          else
            log "Nothing to update"
          end
        end
      end
    end

    def update_world_survey_v1_materials_data
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
            WorldSurveyV1.where("UPPER(TRIM(system)) = :system AND
                                 UPPER(TRIM(world)) = :world AND
                                 UPPER(TRIM(commander)) = :commander AND
                                 carbon IS NULL AND
                                 iron IS NULL AND
                                 nickel IS NULL AND
                                 phosphorus IS NULL AND
                                 sulphur IS NULL AND
                                 arsenic IS NULL AND
                                 chromium IS NULL AND
                                 germanium IS NULL AND
                                 manganese IS NULL AND
                                 selenium IS NULL AND
                                 vanadium IS NULL AND
                                 zinc IS NULL AND
                                 zirconium IS NULL AND
                                 cadmium IS NULL AND
                                 mercury IS NULL AND
                                 molybdenum IS NULL AND
                                 niobium IS NULL AND
                                 tin IS NULL AND
                                 tungsten IS NULL AND
                                 antimony IS NULL AND
                                 polonium IS NULL AND
                                 ruthenium IS NULL AND
                                 technetium IS NULL AND
                                 tellurium IS NULL AND
                                 yttrium IS NULL AND
                                 notes IS NULL",
                                 { system: system,
                                   world: world,
                                   commander: commander})
                       .update_all(attributes)
          else
            log "Nothing to update"
          end
        end
      end
    end

    def insert_primary_stars
      @surveys_arr.each do |survey|
        full_system = survey["World"].to_s.upcase
        world_data = @worlds_dict[full_system]

        system    = world_data["System Name"] if world_data
        commander = survey["Surveyed By"]

        star = ""
        if world_data && world_data["Body"].to_s.strip.downcase =~ /^[a-z]/
          star = "A"
        end

        if system && commander
          ss = StarSurvey.where("UPPER(TRIM(system)) = :system AND
                                 UPPER(TRIM(star)) = :star AND
                                 UPPER(TRIM(commander)) = :commander",
                                 { system:    system.upcase.strip,
                                   star:      star.upcase.strip,
                                   commander: commander.upcase.strip })
          prefix = "Inserting Star Survey #{system} #{star}:"
          if ss.blank?
            log "#{prefix} creating..."
            ss.create(system: system, star: star, commander: commander)
          else
            log "#{prefix} already exists"
          end
        else
          log "Unable to find key fields for #{full_system} (#{system} #{star}, #{commander})"
        end
      end
    end

    def update_star_data
      @systems_arr.each do |data|
        system = data["System Name"].to_s.upcase.strip
        if system.present?
          log "Updating star data for #{system}..."
          attributes = { star_type: data["Spectral Class"],
                         solar_mass: data["Mass [Sol M]"],
                         solar_radius: data["Radius [Sol R]"],
                         star_age: (data["Star Age [My]"].to_i * 1_000_000 if data["Star Age [My]"].present?),
                         orbit_period: data[""],
                         arrival_point: data[""],
                         luminosity: data["Star Luminosity"],
                         note: data["Notes"],
                         surface_temp: data["Surf. T [K]"]
                       }
          unless attributes.values.all?(&:blank?)
            StarSurvey.where("UPPER(TRIM(system)) = :system AND
                              star in ('', 'A') AND
                              star_type IS NULL AND
                              solar_mass IS NULL AND
                              solar_radius IS NULL AND
                              star_age IS NULL AND
                              orbit_period IS NULL AND
                              arrival_point IS NULL AND
                              luminosity IS NULL AND
                              note IS NULL AND
                              surface_temp IS NULL",
                              { system: system })
                      .update_all(attributes)
          else
            log "Nothing to update"
          end
        end
      end
    end

    def insert_primary_stars_v2
      @worlds_arr.each do |world|
        system    = world["System name"] if world
        star = ""
        if world["Body"].to_s.strip.downcase =~ /^[a-z]/
          star = "A"
        end

        if system
          item = Star.where("UPPER(TRIM(system)) = :system AND
                             COALESCE(UPPER(TRIM(star)),'') = :star",
                             { system:  system.upcase.strip,
                               star:    star.upcase.strip,
                               updater: updater_tag })
          prefix = "Inserting Star #{system} #{star}:"
          if item.blank?
            log "#{prefix} creating..."
            item.create(system: system, star: star, updater: updater_tag)
          else
            log "#{prefix} already exists"
          end
        else
          log "Unable to find key fields for #{system} #{star}"
        end
      end
    end

    def update_star_data_v2
      @systems_arr.each do |data|
        system = data["System Name"].to_s.upcase.strip
        if system.present?
          log "Updating star data for #{system}..."
          attributes = { spectral_class: data["Spectral Class"],
                         spectral_subclass: (data["Spectral Subclass"].to_i if data["Spectral Subclass"].present?),
                         solar_mass: data["Mass [Sol M]"],
                         solar_radius: data["Radius [Sol R]"],
                         star_age: (data["Star Age [My]"].to_i * 1_000_000 if data["Star Age [My]"].present?),
                         orbit_period: data[""],
                         arrival_point: data[""],
                         luminosity: data["Star Luminosity"],
                         notes: data["Notes"],
                         surface_temp: data["Surf. T [K]"]
                       }
          unless attributes.values.all?(&:blank?)
            Star.where("UPPER(TRIM(system)) = :system AND
                        COALESCE(star,'') in ('', 'A') AND
                        updater = :updater",
                        { system: system, updater: updater_tag })
                 .update_all(attributes)
          else
            log "Nothing to update"
          end
        end
      end
    end
    
    def insert_worlds_v2
      @worlds_arr.each do |data|
        system = data["System name"] if data
        world  = data["Body"] if data

        if system && world
          item = World.where("UPPER(TRIM(system)) = :system AND
                             UPPER(TRIM(world)) = :world",
                             { system:  system.upcase.strip,
                               world:   world.upcase.strip,
                               updater: updater_tag })
          prefix = "Inserting World #{system} #{world}:"
          if item.blank?
            attributes = { system: system, 
                           world: world, 
                           updater: updater_tag,
                           world_type: data["World Type"],
                           mass: data["Mass [Earth M]"],
                           radius: data["Radius [km]"],
                           gravity: data["Gravity [km]"],
                           surface_temp: data["Surf. Temp. [K]"],
                           surface_pressure: data["Surf. P [atm]"],
                           orbit_period: data["Orb. Per. [D]"],
                           rotation_period: data["Rot. Per. [D]"],
                           semi_major_axis: data["Semi Maj. Axis [AU]"],
                           vulcanism_type: data["Volcanism"],
                           rock_pct: data["Rock %"],
                           metal_pct: data["Metal %"],
                           ice_pct: data["Ice %"],
                           reserve: data["Reserves"],
                           arrival_point: (data["Arrival Point [Ls]"].to_f if data["Arrival Point [Ls]"]),
                           notes: data["Notes"]
                       }
            log "#{prefix} creating..."
            item.create(attributes)
          else
            log "#{prefix} already exists"
          end
        else
          log "Unable to find key fields for #{system} #{world}"
        end
      end
    end

    def insert_basecamps_data
      @surveys_arr.each do |data|
        world = World.where("UPPER(system || ' ' || world) = ?", data["World"].to_s.upcase)
                     .first
        if world
          prefix = "Inserting Basecamp for #{ data['World']} at #{
            data['Landing Zone Latitude']},#{data['Landing Zone Longitude']}:"
          bc = Basecamp.where(world_id: world.id)
                       .where(landing_zone_lat: data["Landing Zone Latitude"])
                       .where(landing_zone_lon: data["Landing Zone Longitude"])
          if bc.blank?
            log "#{prefix} creating..."
            Basecamp.create(world_id: world.id,
                            updater: updater_tag,
                            name: "Camp #{data['Surveyed By']} #{data['Date']}",
                            landing_zone_terrain: data["Landing Zone Terrain"],
                            terrain_hue_1: color_lookup(data["Terrain Hue 1"]),
                            terrain_hue_2: color_lookup(data["Terrain Hue 2"]),
                            terrain_hue_3: color_lookup(data["Terrain Hue 3"]),
                            landing_zone_lat: data["Landing Zone Latitude"],
                            landing_zone_lon: data["Landing Zone Longitude"],
                            notes: data["Notes"])
          else
            log "#{prefix} already exists"
          end
        else
          log "Unable to pdate Basecamp record for #{data['World']}"
        end
      end
    end

    def insert_site_surveys_data
      @survey_logs_arr.each do |data|
        survey = @surveys_dict[data["Survey / World"]]
        if survey
          full_system = survey["World"]
          commander = survey["Surveyed By"]
          resource = data["Resource"] || "AGGREGATED"
          
          world = World.where("upper(system || ' ' || world) = ?", full_system.to_s.upcase)
                       .first
          bc = Basecamp.by_world_id(world.try(:id))
                       .where("landing_zone_lat": survey["Landing Zone Latitude"])
                       .where("landing_zone_lon": survey["Landing Zone Longitude"])
                       .first
          ss = SiteSurvey.by_basecamp_id(bc.try(:id))
                         .by_commander(commander)
                         .by_resource(resource)
                         .first_or_initialize
          prefix = ss.id ? "Inserting " : "Updating "
          prefix << " SiteSurvey record for #{full_system} (bc:#{bc.try(:id)} cmdr:#{commander} res:#{resource.to_s}):"
          ss.assign_attributes(basecamp_id: bc.try(:id),
                               commander: commander,
                               resource: resource,
                               carbon: data["C"],
                               iron: data["Fe"],
                               nickel: data["Ni"],
                               phosphorus: data["P"],
                               sulphur: data["S"],
                               arsenic: data["As"],
                               chromium: data["Cr"],
                               germanium: data["Ge"],
                               manganese: data["Mn"],
                               selenium: data["Se"],
                               vanadium: data["V"],
                               zinc: data["Zn"],
                               zirconium: data["Zr"],
                               cadmium: data["Cd"],
                               mercury: data["Hg"],
                               molybdenum: data["Mo"],
                               niobium: data["Nb"],
                               tin: data["Sn"],
                               tungsten: data["W"],
                               antimony: data["Sb"],
                               polonium: data["Po"],
                               ruthenium: data["Ru"],
                               technetium: data["Tc"],
                               tellurium: data["Te"],
                               yttrium: data["Y"])
          if ss.save
            log "#{prefix}: Success"  
          else
            log "#{prefix}: Failed"  
          end
        end
      end
    end
    
    def insert_world_surveys_data
      @worlds_arr.each do |data|
        world = World.by_system(data["System name"])
                     .by_world(data["Body"])
                     .first
        if world
          ws = WorldSurvey.by_world_id(world.id).first_or_initialize
          ws.updater = updater_tag
          ss= world.site_surveys
          ss.each do |survey|
            materials.each do |m|
              ws[m] = true if survey[m].to_i > 0
            end
          end
          prefix = ws.id ? "Inserting " : "Updating "
          prefix << " WorldSurvey record for #{data["World Name"]}"
          if ws.save
            log "#{prefix}: Success"  
          else
            log "#{prefix}: Failed"  
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
      fix_csvs
      log "Done!"
    end

    task :update_db_v1 => :environment do
      log "Updating Database V1 with DW Spreadsheet data..."
      # Taking advantage of the CSVs being small. This will of course not to
      # be refined if the sitation changes
      @start_time = Time.now()

      read_csv_data
      build_worlds_dict
      build_surveys_dict
      insert_primary_stars
      update_star_data
      insert_key_world_survey_v1_fields
      update_world_survey_v1_data
      update_world_survey_v1_materials_data
      log "Done!"
    end

    task :prepare => :environment do
      @start_time = Time.now()

      read_csv_data
      build_worlds_dict
      build_surveys_dict
    end

    task :update => :prepare do
      log "Updating Database V2 with DW Spreadsheet data..."
      # Taking advantage of the CSVs being small. This will of course not to
      # be refined if the sitation changes
      Rake::Task["import:dw_spreadsheet:update:stars"].invoke
      Rake::Task["import:dw_spreadsheet:update:worlds"].invoke
      Rake::Task["import:dw_spreadsheet:update:basecamps"].invoke
      Rake::Task["import:dw_spreadsheet:update:site_surveys"].invoke
      Rake::Task["import:dw_spreadsheet:update:world_surveys"].invoke
      log "Done!"
    end

    namespace :update do
      task :stars => "import:dw_spreadsheet:prepare" do
        log "Updating Stars table"
      
        insert_primary_stars_v2
        update_star_data_v2
      
        log "Done! Star count is now at #{Star.count}"
      end
      
      task :worlds => "import:dw_spreadsheet:prepare" do
        log "Updating Worlds table"

        insert_worlds_v2
      
        log "Done! World count is now at #{World.count}"
      end
      
      task :basecamps => "import:dw_spreadsheet:prepare" do
        log "Updating Basecamps table"
      
        insert_basecamps_data
      
        log "Done! Basecamp count is now at #{Basecamp.count}"
      end
      
      task :site_surveys => "import:dw_spreadsheet:prepare" do
        log "Updating Site Surveys table"
      
        insert_site_surveys_data
      
        log "Done! SiteSurvey count is now at #{SiteSurvey.count}"
      end
      
      task :world_surveys => "import:dw_spreadsheet:prepare" do
        log "Updating World Surveys table"
      
        insert_world_surveys_data
      
        log "Done! WorldSurvey count is now at #{WorldSurvey.count}"
      end
    end


    task :clean_up => :environment do
      log "Cleaning up..."
      clean_up
      log "Done!"
    end
  end
end
