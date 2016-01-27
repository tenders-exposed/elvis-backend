class ImportData < Thor
  require 'smarter_csv'
  require 'active_support/core_ext/object/try'

  require File.expand_path('config/environment.rb')

  desc "import_ted_csv FILE", "Import data from the TED csvs"
  def import_ted_csv(filename)
    opts= { :chunk_size => 100, :row_sep => "\n"}
    SmarterCSV.process(filename, opts) do |chunk|
      initialize_arrays
      chunk.each do |row|
        row.each{ |key,val| row[key] = val.is_a?(String) ? val.try(:erase_html) : val }
        doc =  Contract.new(
                contract_id: row[:doc_no].try(:erase_html),
                additional_identifiers: row[:file_reference],
                award_criteria: row[:award_criteria_code],
                procurement_method: row[:procedure_code],
                x_CPV: row[:cpv_code].to_s.split(';'),
                x_eu_project: row[:relates_to_eu_project],
                x_NUTS: row[:location_nuts],
                x_url: row[:doc_url],
                x_lot: row[:lot_number],
                number_of_tenderers: row[:offers_received_num],
                contract_number: row[:contract_number],
                x_additional_information: row[:additional_information]
        )
        @contracts << doc
        @awards << doc.build_award(
                      date: {
                        x_year:  row[:contract_award_year].to_i,
                        x_month: row[:contract_award_month].to_i,
                        x_day:   row[:contract_award_day].to_i
                      },
                      x_initial_value: {
                        x_amount_eur: row[:initial_value_cost_eur].to_f,
                        x_vatbool: row[:initial_value_vat_included],
                        amount: row[:initial_value_cost].to_f,
                        currency: row[:initial_value_currency],
                        x_vat: row[:initial_value_vat_rate].to_f
                      },
                      value: {
                        amount:   row[:contract_value_cost].to_f,
                        x_amount_eur:    row[:contract_value_cost_eur].to_f,
                        currency: row[:contract_value_currency],
                        x_vatbool: row[:contract_value_vat_included]
                      },
                      min_value: {
                        amount: row[:contract_value_low].to_f,
                        x_amount_eur: row[:contract_value_low_eur].to_f
                      },
                      title: row[:contract_award_title],
                      description: row[:contract_description]
                  )
        entity =  doc.build_procuring_entity(
                    name: row[:authority_official_name],
                    x_slug: row[:authority_slug],
                    contract_point: {name: row[:authority_attention]}
                  )
        @procuring_entities << entity
        @addresses << entity.build_address(
                        country_name: row[:authority_country],
                        locality: row[:authority_town],
                        street_address: row[:authority_address],
                        postal_code: row[:authority_postal_code],
                        email: row[:authority_email],
                        telephone: row[:authority_phone],
                        x_url: row[:authority_url]
                      )
        @tenders << doc.build_tender(
                      value: {
                        amount: row[:total_value_cost].to_f,
                        x_amount_eur: row[:total_value_cost_eur].to_f,
                        x_vatbool: row[:total_value_vat_included],
                        currency: row[:total_value_currency],
                        x_vat: row[:total_value_vat_rate].to_f
                      }
                    )
        supplier =  doc.suppliers.build(
                      name: row[:operator_official_name],
                      x_slug: row[:operator_slug],
                      x_same_city: ((row[:operator_town] == row[:authority_town]) && row[:operator_town]) ? 1 : 0
                    )
        @suppliers << supplier
        @addresses << supplier.build_address(
                        country_name: row[:operator_country],
                        locality: row[:operator_town],
                        street_address: row[:operator_address],
                        postal_code: row[:operator_postal_code],
                        email: row[:operator_email],
                        telephone: row[:operator_phone],
                        x_url: row[:operator_url]
                      )
      end
      batch_insert
    end
  end

  desc "import_2011_csv FILE", "Import data from the TED csvs"
  def import_2011_csv(filename)
    opts= { :chunk_size => 50, :row_sep => "\n"}
    SmarterCSV.process(filename, opts) do |chunk|
      initialize_arrays
      chunk.each do |row|
        row.values.map!{|val| val.is_a?(String) ? val.try(:erase_html) : val }
        doc = Contract.new(
                contract_id: row[:doc_number],
                additional_identifiers: row[:contract_number],
                award_criteria: row[:award_criteria_type],
                procurement_method: row[:proc_type],
                contract_number: row[:contract_number],
                x_CPV: row[:cpv].to_s.split(';'),
                x_eu_project: row[:eu_project],
                x_framework: row[:framework],
                x_NUTS: row[:NUTS],
                x_url: row[:url],
                x_lot: row[:lot],
                number_of_tenderers: row[:nr_bids],
                x_additional_information: row[:additional_info]
              )
        @contracts << doc
        @awards <<  doc.build_award(
                      date: {
                        x_year:  row[:contract_award_year].to_i,
                        x_month: row[:contract_award_month].to_i,
                        x_day:   row[:contract_award_day].to_i
                      },
                      value: {
                        amount:   row[:contract_value].to_f,
                        x_amount_eur: row[:contract_value_eur].to_f,
                        x_vatbool: row[:contract_value_vat],
                        currency: row[:contract_currency],
                        x_vat: row[:contract_value_vat_percent].to_f
                      },
                      x_initial_value: {
                        x_amount_eur: row[:initial_value_eur].to_f,
                        x_vatbool: row[:initial_value_vat],
                        amount: row[:initial_value].to_f,
                        currency: row[:contract_currency],
                        x_vat: row[:initial_value_vat_percent].to_f
                      },
                      title: row[:title_contract],
                      description: row[:short_contract_description],
                      award_id: row[:contract_id]
                    )
        entity =  doc.build_procuring_entity(
                    name: row[:authority_name],
                    x_slug: row[:authority_name_slug],
                    x_type: row[:auth_type],
                    contract_point: {name: row[:authority_contact_person]}
                  )
        @procuring_entities << entity
        @addresses << entity.build_address(
                        country_name: row[:authority_country],
                        locality: row[:authority_town],
                        street_address: row[:authority_address],
                        postal_code: row[:authority_postal_code],
                        x_url: row[:authority_www]
                      )
        @tenders << doc.build_tender(
                      value: {
                        amount: row[:tender_value].to_f,
                        currency: row[:tender_currency],
                        x_amount_eur: row[:tender_value_eur].to_f,
                        x_vatbool: row[:tender_value_vat],
                        x_vat: row[:tender_value_vat_percent].to_f
                      }
                    )
        supplier =  doc.suppliers.build(
                      name: row[:company_name],
                      x_slug: row[:company_name_slug],
                      x_same_city: ((row[:authority_town] == row[:company_town]) && row[:company_town] ? 1 : 0
                      )
                    )
        @suppliers << supplier
        @addresses << supplier.build_address(
                        country_name: row[:company_country],
                        locality: row[:company_town],
                        street_address: row[:company_address],
                        postal_code: row[:company_postal_code]
                      )
      end
      batch_insert
    end
  end

  desc "import_2008_csv FILE", "Import data from the TED csvs"
  def import_2008_csv(filename)
    opts= { :chunk_size => 50, :row_sep => "\n"}
    SmarterCSV.process(filename, opts) do |chunk|
      initialize_arrays
      chunk.each do |row|
        row.values.map!{|val| val.is_a?(String) ? val.try(:erase_html) : val }
        doc = Contract.new(
                contract_id: row[:id],
                additional_identifiers: row[:additionalidentifiers],
                award_criteria: row[:awardcriteria],
                procurement_method: row[:procurementmethod],
                x_CPV: row[:x_cpv].to_s.split(';'),
                x_subcontracted: row[:x_subcontracted],
                x_framework: row[:x_framework],
                x_NUTS: row[:x_nuts],
                number_of_tenderers: row[:numberoftenderers],
                x_additional_information: row[:x_additionalinformation]
              )
        @contracts << doc
        @awards <<  doc.build_award(
                      date: {
                        x_year:  row[:"award.date/x_year"].to_i,
                        x_month: row[:"award.date/x_month"].to_i,
                        x_day:   row[:"award.date/x_day"].to_i
                      },
                      value: {
                        amount:   row[:"award.value/amount"].to_f,
                        x_amount_eur: row[:"award.value/x_amounteur"].to_f,
                        x_vatbool: row[:"award.value/x_vatbool"],
                        currency: row[:"award.value/currency"],
                        x_vat: row[:"award.value/x_vat"].to_f
                      },
                      x_initial_value: {
                        x_amount_eur: row[:"award.x_initialvalue/x_amounteur"].to_f,
                        x_vatbool: row[:"award.x_initialvalue/x_vatbool"],
                        amount: row[:"award.initialvalue/amount"].to_f,
                        currency: row[:"award.initialvalue/currency"],
                        x_vat: row[:"award.initialvalue/x_vat"].to_f
                      },
                      title: row[:"award.title"],
                      description: row[:"award.description"]
                    )
        entity =  doc.build_procuring_entity(
                    name: row[:"procuringentity/name"],
                    x_slug: row[:"procuringentity/x_slug"],
                    x_type: row[:"procuringentity/x_type"],
                    contract_point: {name: row[:"procuringentity/contactpoint/name"]}
                  )
        @procuring_entities << entity
        @addresses << entity.build_address(
                        country_name: row[:"procuringentity/address/countryname"],
                        locality: row[:"procuringentity/address/locality"],
                        street_address: row[:"procuringentity/address/streetaddress"],
                        postal_code: row[:"procuringentity/address/postalcode"],
                        email: row[:"procuringentity/address/email"],
                        telephone: row[:"procuringentity/address/telephone"],
                        x_url: row[:"procuringentity/address/x_url"]
                      )
        @tenders << doc.build_tender(
                      value: {
                        amount: row[:"tender.value/amount"].to_f,
                        currency: row[:"tender.value/currency"],
                        x_amount_eur: row[:"tender.value/amount/x_amounteur"].to_f,
                        x_vatbool: row[:"tender.value/x_vatbool"],
                        x_vat: row[:"tender.value/x_vat"].to_f
                      }
                    )
        supplier =  doc.suppliers.build(
                      name: row[:"suppliers/name"],
                      x_slug: row[:"suppliers/x_slug"],
                      x_same_city: ((row[:"procuringentity/address/locality"] == row[:"suppliers/address/locality"]) && row[:"suppliers/address/locality"] ? 1 : 0)
                    )
        @suppliers << supplier
        @addresses << supplier.build_address(
                        country_name: row[:"suppliers/address/countryname"],
                        locality: row[:"suppliers/address/locality"],
                        street_address: row[:"suppliers/address/streetaddress"],
                        postal_code: row[:"suppliers/address/postalcode"],
                        email: row[:"suppliers/address/email"],
                        telephone: row[:"suppliers/address/telephone"],
                        x_url: row[:"suppliers/address/x_url"]
                      )
      end
      batch_insert
    end
  end

no_commands{

  def initialize_arrays
    @contracts, @awards, @procuring_entities , @tenders, @suppliers, @addresses = [], [], [], [], [], []
  end

  def batch_insert
    Contract.with(ordered: false).collection.insert_many(@contracts.map(&:as_document))
    Award.with(ordered: false).collection.insert_many(@awards.map(&:as_document))
    ProcuringEntity.with(ordered: false).collection.insert_many(@procuring_entities.map(&:as_document))
    Tender.with(ordered: false).collection.insert_many(@tenders.map(&:as_document))
    Supplier.with(ordered: false).collection.insert_many(@suppliers.map(&:as_document))
    Address.with(ordered: false).collection.insert_many(@addresses.map(&:as_document))
  end

}
end
