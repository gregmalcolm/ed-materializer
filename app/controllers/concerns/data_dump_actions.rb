module DataDumpActions
  def download
    @model_name = controller_name.classify
    send_file("#{Rails.root}/exports/snapshots/#{filename_base}.json.zip")
  end

  def md5
    md5 = File.read("#{Rails.root}/exports/snapshots/#{filename_base}.json.md5")
    render json: {md5sum: md5} 
  end

  private

  def filename_base
    controller_name.dasherize
  end
end
