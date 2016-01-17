#require 'open-uri'
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

  desc "Import Distant Horizons prospector spreadsheet"
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

    task :download => :environment do
      print "Downloading Distant Horizons Spreadsheet..."
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

    end

    task :clean_up => :environment do
      print "Cleaning up..."
      clean_up
      puts " Done!"
    end
  end
end
