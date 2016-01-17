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
      {name: "worlds",  gid: 728822980},
      {name: "systems", gid: 2126209210}
    ]
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
      #@systems_arr = CSV.read("#{Rails.root}/imports/dw_materials_systems.csv", headers: true)
      @worlds_arr =  CSV.read("#{Rails.root}/imports/dw_materials_worlds.csv", headers: true)
      @surveys_arr = CSV.read("#{Rails.root}/imports/dw_materials_surveys.csv", headers: true)
      @logs_arr =    CSV.read("#{Rails.root}/imports/dw_materials_log.csv", headers: true)
    end

    def build_systems_dict
      @worlds_arr.inject({}) do |acc, system|
        acc[system["World Name"]] = system.to_h
        acc
      end
    end

    def insert_key_fields
      #@surveys_arr.each do |survey|
      #end
    end

    task :download => :environment do
      print "Downloading Distant Worlds Spreadsheet..."
      clean_up
      begin
        sheets.each do |sheet|
          open("#{Rails.root}/imports/dw_materials_#{sheet[:name]}.csv", 'wb') do |file|
            url = spreadsheet_url(sheet[:gid])
            file << open(url).read
          end
        end
      rescue OpenSSL::SSL::SSLError
        puts ""
        STDERR.puts "SSL problems. Probably a certs issue with this flavor of ruby. Instructions on how to fix it can be found here: https://gist.github.com/mislav/5026283"
        raise
      end
      puts " Done!"
    end

    task :update_db => :environment do
      print "Updating Database with DW Spreadsheet data..."
      # Taking advantage of the CSVs being small. This will of course not to
      # be refined if the sitation changes
      @start_time = Time.now()

      read_csv_data()
      @systems_dict = build_systems_dict()
      #@systems_dict["Achenar 3"]["Body"]
      #@systems_dict["Achenar 3"]["System Name"]
      insert_key_fields

      puts " Done!"
    end

    task :clean_up => :environment do
      print "Cleaning up..."
      clean_up
      puts " Done!"
    end
  end
end
