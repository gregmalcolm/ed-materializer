#require 'open-uri'
namespace :import do
  def output_path
    "#{Rails.root}/tmp/dh_materials.xlsx"
  end

  def spreadsheet_id
    "1LgMaX9n6Yp8DQKq-u-eF1HH2xQ-_aUgSfSJna6mTuLs"
  end

  desc "Import Distant Horizons prospector spreadsheet"
  task :spreadsheet => :environment do
    Rake::Task["import:dh_spreadsheet:download"].invoke
    Rake::Task["import:dh_spreadsheet:update_db"].invoke
    Rake::Task["import:dh_spreadsheet:clean_up"].invoke
  end

  namespace :dh_spreadsheet do

    def clean_up
      FileUtils.rm_f output_path
    end

    task :download => :environment do
      print "Downloading Distant Horizons Spreadsheet..."
      clean_up
      open("#{Rails.root}/tmp/dh_materials.xlsx", 'wb') do |file|
        file << open("https://docs.google.com/spreadsheets/d/#{
          spreadsheet_id}/export?format=xlsx&id=#{spreadsheet_id}").read
      end
      puts " Done!"
    end

    task :update_db => :environment do

    end

    task :clean_up => :environment do
      print "Cleaning up..."
      clean_up
      puts " Done!"
    end
  end
end
