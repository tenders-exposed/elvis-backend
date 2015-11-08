class String
  require 'nokogiri'

  def erase_html
    Nokogiri::HTML(self).text unless self.blank? 
  end
end
