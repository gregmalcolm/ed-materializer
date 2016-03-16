module DataDumpActions
  def download
    ensure_download_exists
    send_file("#{full_json_filename}.zip")
  end

  def md5
    ensure_download_exists
    md5 = File.read("#{full_json_filename}.md5")
    render json: { controller_name => { md5: md5 }}
  end

  private

  def full_json_filename
    "#{Rails.root}/exports/snapshots/#{filename_base}.json"
  end
  
  def filename_base
    controller_name.dasherize
  end

  def ensure_download_exists
    zipfile = "#{full_json_filename}.zip"
    if !File.exists?(zipfile) || expired?
      `rake export:snapshot:#{controller_name}`
    end
  end

  def expired?
    file_date = File.mtime("#{full_json_filename}.zip").to_date
    file_date != Date.today
  end
end
