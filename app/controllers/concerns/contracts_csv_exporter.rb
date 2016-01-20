module ContractsCsvExporter
  extend ActiveSupport::Concern

  def render_csv
    set_file_headers
    set_streaming_headers
    response.status = 200
    self.response_body = csv_lines
  end

  def set_file_headers
    headers['Content-Type'] = 'text/csv; charset=UTF-16LE'
    headers['Content-disposition'] = 'attachment;'
    headers['Content-disposition'] += " filename=\"#{file_name}.csv\""
  end

  def set_streaming_headers
    headers['X-Accel-Buffering'] = 'no'
    headers["Cache-Control"] ||= "no-cache"
    headers.delete("Content-Length")
  end

  def file_name
    "#{Time.now.strftime("%v")}"
  end

  def csv_lines
    CsvExportGenerator.new(query)
  end

end
