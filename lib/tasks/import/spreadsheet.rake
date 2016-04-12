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

  def number(val)
    val.to_s.delete(",")
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

    def update_systems
      @systems_arr.each do |data|
        system = data["System Name"] if data
        if system
          item = System.by_system(system).first_or_initialize
          prefix = item.id ? "Updating " : "Inserting"
          prefix << " System record for #{system}"
          if item.updater && item.updater != updater_tag 
            log "#{prefix}: has been changed outside of the spreadsheet, ignoring"
          else
            item.system = system
            item.updater = updater_tag
            item.x = data["X"]
            item.y = data["Y"]
            item.z = data["Z"]
            item.tags = [data["DWE/POI Location"]] if data["DWE/POI Location"]
            item.notes = data["Notes"]

            if item.save
              log "#{prefix}: Success"  
            else
              log "#{prefix}: Failed"  
            end
          end
        else
          log "System missing: #{data.inspect}"
        end
      end
    end
    
    def insert_primary_stars
      @worlds_arr.each do |world|
        system_name = world["System name"] if world
        star = ""
        if world["Body"].to_s.strip.downcase =~ /^[a-z]/
          star = "A"
        end

        if system_name
          item = Star.by_system(system_name)
          prefix = "Inserting Primary Star for #{system_name}:"
          if item.blank?
            log "#{prefix} creating..."
            Star.create(system_name: system_name, star: star, updater: updater_tag)
          else
            log "#{prefix} already has a star"
          end
        else
          log "Unable to find key fields for #{system_name} #{star}"
        end
      end
    end

    def update_star_data
      @systems_arr.each do |data|
        system_name = data["System Name"].to_s.upcase.strip
        if system_name.present?
          prefix =  "Updating star data for #{system_name}:"
          attributes = { spectral_class: data["Spectral Class"],
                         spectral_subclass: (data["Spectral Subclass"].to_i if data["Spectral Subclass"].present?),
                         solar_mass: number(data["Mass [Sol M]"]),
                         solar_radius: number(data["Radius [Sol R]"]),
                         star_age: (number(data["Star Age [My]"]).to_i * 1_000_000 if data["Star Age [My]"].present?),
                         orbit_period: number(data[""]),
                         arrival_point: number(data[""]),
                         luminosity: data["Star Luminosity"],
                         notes: data["Notes"],
                         surface_temp: number(data["Surf. T [K]"])
                       }
          item = Star.by_system(system_name).first
          if item.present?
            if item.updater == updater_tag
              log "#{prefix} Updating"
              item.update(attributes)
            else
              log "#{prefix} has been changed outside of the spreadsheet, ignoring"
            end
          else
            log "Nothing to update"
          end
        end
      end
    end
    
    def insert_worlds
      @worlds_arr.each do |data|
        system_name = data["System name"] if data
        world  = data["Body"] if data

        if system_name && world
          item = World.where("UPPER(TRIM(system_name)) = :system_name AND
                             UPPER(TRIM(world)) = :world",
                             { system_name:  system_name.upcase.strip,
                               world:   world.upcase.strip }).first
          prefix = "World #{system_name} #{world}:"
          attributes = { system_name: system_name, 
                         world: world, 
                         updater: updater_tag,
                         world_type: data["World Type"],
                         mass: number(data["Mass [Earth M]"]),
                         radius: number(data["Radius [km]"]),
                         gravity: number(data["Gravity [km]"]),
                         surface_temp: number(data["Surf. Temp. [K]"]),
                         surface_pressure: number(data["Surf. P [atm]"]),
                         orbit_period: number(data["Orb. Per. [D]"]),
                         rotation_period: number(data["Rot. Per. [D]"]),
                         semi_major_axis: number(data["Semi Maj. Axis [AU]"]),
                         vulcanism_type: data["Volcanism"],
                         rock_pct: data["Rock %"],
                         metal_pct: data["Metal %"],
                         ice_pct: data["Ice %"],
                         reserve: data["Reserves"],
                         arrival_point: (number(data["Arrival Point [Ls]"]).to_f if data["Arrival Point [Ls]"]),
                         notes: data["Notes"]
                     }
          if item.blank?
            log "#{prefix} Inserting"
            World.create(attributes)
          else
            if item.updater == updater_tag
              log "#{prefix} Updating"
              item.update(attributes)
            else
              log "#{prefix} has been changed outside of the spreadsheet, ignoring"
            end
          end
        else
          log "Unable to find key fields for #{system_name} #{world}"
        end
      end
    end

    def insert_basecamps_data
      @surveys_arr.each do |data|
        world = World.where("UPPER(system_name || ' ' || world) = ?", data["World"].to_s.upcase)
                     .first
        if world
          prefix = "Inserting Basecamp for #{ data['World']} at #{
            data['Landing Zone Latitude']},#{data['Landing Zone Longitude']}:"
          item = Basecamp.where(world_id: world.id)
                         .where(landing_zone_lat: data["Landing Zone Latitude"])
                         .where(landing_zone_lon: data["Landing Zone Longitude"]).first
          attributes = { world_id: world.id,
                         updater: updater_tag,
                         name: "Camp #{data['Surveyed By']} #{data['Date']}",
                         landing_zone_terrain: data["Landing Zone Terrain"],
                         terrain_hue_1: color_lookup(data["Terrain Hue 1"]),
                         terrain_hue_2: color_lookup(data["Terrain Hue 2"]),
                         terrain_hue_3: color_lookup(data["Terrain Hue 3"]),
                         landing_zone_lat: number(data["Landing Zone Latitude"]),
                         landing_zone_lon: number(data["Landing Zone Longitude"]),
                         notes: data["Notes"]
                       }
          if item.blank?
            log "#{prefix} creating..."
            Basecamp.create(attributes)
          else
            if item.updater == updater_tag
              log "#{prefix} Updating"
              item.update(attributes)
            else
              log "#{prefix} has been changed outside of the spreadsheet, ignoring"
            end
          end
        else
          log "Unable to update Basecamp record for #{data['World']}"
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
          
          world = World.where("upper(system_name || ' ' || world) = ?", full_system.to_s.upcase)
                       .first
          bc = Basecamp.by_world_id(world.try(:id))
                       .where("landing_zone_lat": survey["Landing Zone Latitude"])
                       .where("landing_zone_lon": survey["Landing Zone Longitude"])
                       .first
          ss = SiteSurvey.by_basecamp_id(bc.try(:id))
                         .by_commander(commander)
                         .by_resource(resource)
                         .first_or_initialize
          prefix = ss.id ? "Updating " : "Inserting "
          prefix << " SiteSurvey record for #{full_system} (bc:#{bc.try(:id)} cmdr:#{commander} res:#{resource.to_s}):"
          ss.assign_attributes(basecamp_id: bc.try(:id),
                               commander: commander,
                               resource: resource,
                               surveyed_by: [commander],
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
          prefix = ws.id ? "Updating " : "Inserting"
          prefix << " WorldSurvey record for #{data["World Name"]}"
          if ws.updater && ws.updater != updater_tag 
            log "#{prefix}: has been changed outside of the spreadsheet, ignoring"
          else
            ws.updater = updater_tag
            ss= world.site_surveys
            ss.each do |survey|
              materials.each do |m|
                ws[m] = true if survey[m].to_i > 0
              end
              if survey.commander
                ws.surveyed_by = survey.surveyed_by
                ws.updaters = [survey.commander] 
              end
            end
            if ws.save
              log "#{prefix}: Success"  
            else
              log "#{prefix}: Failed"  
            end
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
      Rake::Task["import:dw_spreadsheet:update:systems"].invoke
      Rake::Task["import:dw_spreadsheet:update:stars"].invoke
      Rake::Task["import:dw_spreadsheet:update:worlds"].invoke
      Rake::Task["import:dw_spreadsheet:update:basecamps"].invoke
      Rake::Task["import:dw_spreadsheet:update:site_surveys"].invoke
      Rake::Task["import:dw_spreadsheet:update:world_surveys"].invoke
      log "Done!"
    end

    namespace :update do
      task :systems => "import:dw_spreadsheet:prepare" do
        log "Updating Systems table"
      
        update_systems
      
        log "Done! Systems count is now at #{System.count}"
      end
      
      task :stars => "import:dw_spreadsheet:prepare" do
        log "Updating Stars table"
      
        insert_primary_stars
        update_star_data
      
        log "Done! Star count is now at #{Star.count}"
      end
      
      task :worlds => "import:dw_spreadsheet:prepare" do
        log "Updating Worlds table"

        insert_worlds
      
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
