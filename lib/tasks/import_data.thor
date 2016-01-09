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
                additionalIdentifiers: row[:file_reference],
                awardCriteria: row[:award_criteria_code],
                procurementMethod: row[:procedure_code],
                x_CPV: row[:cpv_code].to_s.split(';'),
                x_euProject: row[:relates_to_eu_project],
                x_NUTS: row[:location_nuts],
                x_url: row[:doc_url],
                x_lot: row[:lot_number],
                numberOfTenderers: row[:offers_received_num],
                number: row[:contract_number],
                x_additionalInformation: row[:additional_information]
        )
        @contracts << doc
        @awards << doc.build_award(
                      date: {
                        x_year:  row[:contract_award_year].to_i,
                        x_month: row[:contract_award_month].to_i,
                        x_day:   row[:contract_award_day].to_i
                      },
                      initialValue: {
                          amount: row[:initial_value_cost].to_f,
              			      currency: row[:initial_value_currency],
                          x_vat: row[:initial_value_vat_rate].to_f
                      },
                      x_initialValue: {
                        x_amountEur: row[:initial_value_cost_eur].to_f,
                        x_vatbool: row[:initial_value_vat_included]
                      },
                      value: {
                        amount:   row[:contract_value_cost].to_f,
                        x_amountEur:    row[:contract_value_cost_eur].to_f,
                        currency: row[:contract_value_currency],
                        x_vatbool: row[:contract_value_vat_included]
                      },
                      minValue: {
                        amount: row[:contract_value_low].to_f,
                        x_amountEur: row[:contract_value_low_eur].to_f
                      },
                      title: row[:contract_award_title],
                      description: row[:contract_description]
                  )
        entity =  doc.build_procuring_entity(
                    name: row[:authority_official_name],
                    x_slug: row[:authority_slug],
                    contractPoint: {name: row[:authority_attention]}
                  )
        @procuring_entities << entity
        @addresses << entity.build_address(
                        countryName: row[:authority_country],
                        locality: row[:authority_town],
                        streetAddress: row[:authority_address],
                        postalCode: row[:authority_postal_code],
                        email: row[:authority_email],
                        telephone: row[:authority_phone],
                        x_url: row[:authority_url]
                      )
        @tenders << doc.build_tender(
                      value: {
                        amount: row[:total_value_cost].to_f,
                        x_amountEur: row[:total_value_cost_eur].to_f,
                        x_vatbool: row[:total_value_vat_included],
                        currency: row[:total_value_currency],
                        x_vat: row[:total_value_vat_rate].to_f
                      }
                    )
        supplier =  doc.suppliers.build(
                      name: row[:operator_official_name],
                      x_slug: row[:operator_slug],
                      same_city: ((row[:operator_town] == row[:authority_town]) && row[:operator_town]) ? 1 : 0
                    )
        @suppliers << supplier
        @addresses << supplier.build_address(
                        countryName: row[:operator_country_code],
                        locality: row[:operator_town],
                        streetAddress: row[:operator_address],
                        postalCode: row[:operator_postal_code],
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
                additionalIdentifiers: row[:contract_number],
                awardCriteria: row[:award_criteria_type],
                procurementMethod: row[:proc_type],
                contract_number: row[:contract_number],
                x_CPV: row[:cpv].to_s.split(';'),
                x_euProject: row[:eu_project],
                x_framework: row[:framework],
                x_NUTS: row[:NUTS],
                x_url: row[:url],
                x_lot: row[:lot],
                numberOfTenderers: row[:nr_bids],
                x_additionalInformation: row[:additional_info]
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
                        x_amountEur: row[:contract_value_eur].to_f,
                        x_vatbool: row[:contract_value_vat],
                        currency: row[:contract_currency],
                        x_vat: row[:contract_value_vat_percent].to_f
                      },
                      initialValue: {
                        amount: row[:initial_value].to_f,
                        currency: row[:contract_currency],
                        x_vat: row[:initial_value_vat_percent].to_f
                      },
                      x_initialValue: {
                        x_amountEur: row[:initial_value_eur].to_f,
                        x_vatbool: row[:initial_value_vat]
                      },
                      title: row[:title_contract],
                      description: row[:short_contract_description],
                      award_id: row[:contract_id]
                    )
        entity =  doc.build_procuring_entity(
                    name: row[:authority_name],
                    x_slug: row[:authority_name_slug],
                    x_type: row[:auth_type],
                    contractPoint: {name: row[:authority_contact_person]}
                  )
        @procuring_entities << entity
        @addresses << entity.build_address(
                        countryName: row[:authority_country],
                        locality: row[:authority_town],
                        streetAddress: row[:authority_address],
                        postalCode: row[:authority_postal_code],
                        x_url: row[:authority_www],
                        country: country_full_name(row[:authority_country])
                      )
        @tenders << doc.build_tender(
                      value: {
                        amount: row[:tender_value].to_f,
                        currency: row[:tender_currency],
                        x_amountEur: row[:tender_value_eur].to_f,
                        x_vatbool: row[:tender_value_vat],
                        x_vat: row[:tender_value_vat_percent].to_f
                      }
                    )
        supplier =  doc.suppliers.build(
                      name: row[:company_name],
                      x_slug: row[:company_name_slug],
                      same_city: ((row[:authority_town] == row[:company_town]) && row[:company_town] ? 1 : 0
                      )
                    )
        @suppliers << supplier
        @addresses << supplier.build_address(
                        countryName: row[:company_country],
                        locality: row[:company_town],
                        streetAddress: row[:company_address],
                        postalCode: row[:company_postal_code],
                        country: country_full_name(row[:company_country])
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

  def country_full_name(iso)
    store = Redis::HashKey.new('countries')
    country = store.get(iso)
  end

}
end
