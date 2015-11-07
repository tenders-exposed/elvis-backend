class ImportData < Thor
  require 'smarter_csv'
  require_relative '../float_converter'

  require File.expand_path('config/environment.rb')

  desc "import_ted_csv FILE", "Import data from the TED csvs"
  def import_ted_csv(filename)
    opts= { :chunk_size => 50, :row_sep => "\n"}
    SmarterCSV.process(filename, opts) do |chunk|
      initialize_arrays
      chunk.each do |row|
        doc =  Document.new(
                document_id: row[:document_doc_no],
                additionalIdentifiers: row[:contract_file_reference],
                awardCriteria: row[:document_award_criteria_code],
                procurementMethod: row[:document_procedure_code],
                x_CPV: row[:document_cpvs],
                x_euProject: row[:contract_relates_to_eu_project],
                x_NUTS: row[:contract_location_nuts],
                x_url: row[:document_doc_url],
                numberOfTenderers: row[:contract_offers_received_num],
                x_additionalInformation: row[:contract_additional_information]
        )
        @documents << doc
        @awards << Award.new(
                      date: {
                        x_year:  row[:contract_contract_award_year],
                        x_month: row[:contract_contract_award_month],
                        x_day:   row[:contract_contract_award_day]
                      },
                      initialValue: {
                          amount: row[:contract_initial_value_cost].to_f,
              			      currency: row[:contract_initial_value_currency],
                          x_vat: row[:contract_initial_value_vat_rate].to_f
                      },
                      x_initialValue: {
                        x_amountEur: row[:contract_initial_value_cost_eur],
                        x_vatbool: row[:contract_initial_value_vat_included]
                      },
                      value: {
                        amount:   row[:contract_contract_value_cost].to_f,
                        x_amountEur:    row[:contract_contract_value_cost_eur].to_f,
                        currency: row[:contract_contract_value_currency],
                        x_vatbool: row[:contract_contract_value_vat_included]
                      },
                      minValue: {
                        amount: row[:contract_contract_value_low].to_f,
                        x_amountEur: row[:contract_contract_value_low_eur].to_f
                      },
                      title: row[:contract_contract_award_title],
                      description: row[:contract_contract_description],
                      document_id: doc.id
                  )
        entity =  ProcuringEntity.new(
                    name: row[:contract_authority_official_name],
                    x_slug: row[:contract_authority_slug],
                    contractPoint: {name: row[:contract_authority_attention]},
                    document_id: doc.id
                  )
        @entities << entity
        @addresses << Address.new(
                        countryName: row[:contract_authority_country],
                        locality: row[:contract_authority_town],
                        streetAddress: row[:contract_authority_address],
                        postalCode: row[:contract_authority_postal_code],
                        email: row[:contract_authority_email],
                        telephone: row[:contract_authority_phone],
                        x_url: row[:contract_authority_url],
                        addressable_type: entity.class.to_s,
                        addressable_id: entity.id
                      )
        @tenders << Tender.new(
                      value: {
                        amount: row[:contract_total_value_cost].to_f,
                        x_amountEur: row[:contract_total_value_cost_eur].to_f,
                        x_vatbool: row[:contract_total_value_vat_included],
                        currency: row[:contract_total_value_currency],
                        x_vat: row[:contract_total_value_vat_rate].to_f
                      },
                      document_id: doc.id
                    )
        supplier =  Supplier.new(
                      name: row[:contract_operator_official_name],
                      x_slug: row[:contract_operator_slug],
                      document_id: doc.id
                    )
        @suppliers << supplier
        @addresses << Address.new(
                        countryName: row[:contract_operator_country_code],
                        locality: row[:contract_operator_town],
                        streetAddress: row[:contract_operator_address],
                        postalCode: row[:contract_operator_postal_code],
                        email: row[:contract_operator_email],
                        telephone: row[:contract_operator_phone],
                        x_url: row[:contract_operator_url],
                        addressable_type: supplier.class.to_s,
                        addressable_id: supplier.id
                      )
      end
      batch_insert
    end
  end

  desc "import_ted_csv FILE", "Import data from the TED csvs"
  def import_2011_csv(filename)
    opts= { :chunk_size => 50}
    SmarterCSV.process(filename, opts) do |chunk|
      initialize_arrays
      chunk.each do |row|
        doc = Document.new(
                document_id: row[:doc_number],
                additionalIdentifiers: row[:contract_number],
                awardCriteria: row[:award_criteria_type],
                procurementMethod: row[:proc_type],
                x_CPV: row[:cpv],
                x_euProject: row[:eu_project],
                x_framework: row[:framework],
                x_NUTS: row[:NUTS],
                x_url: row[:url],
                x_lot: row[:lot],
                numberOfTenderers: row[:nr_bids],
                x_additionalInformation: row[:additional_info]
              )
        @documents << doc
        @awards <<  Award.new(
                      date: {
                        x_year:  row[:contract_award_year],
                        x_month: row[:contract_award_month],
                        x_day:   row[:contract_award_day]
                      },
                      value: {
                        amount:   row[:contract_value].to_f,
                        x_amountEur: row[:contract_value_eur].to_f,
                        x_vatbool: row[:contract_value_vat],
                        currency: row[:contract_currency],
                        x_vat: row[:initial_value_vat_percent].to_f
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
                      award_id: row[:contract_id],
                      document_id: doc.id
                    )
        entity =  ProcuringEntity.new(
                    name: row[:authority_name],
                    x_slug: row[:authority_name_slug],
                    x_type: row[:auth_type],
                    contractPoint: {name: row[:authority_contact_person]},
                    document_id: doc.id
                  )
        @entities << entity
        @addresses << Address.new(
                        countryName: row[:authority_country],
                        locality: row[:authority_town],
                        streetAddress: row[:authority_address],
                        postalCode: row[:authority_postal_code],
                        x_url: row[:authority_www],
                        addressable_type: entity.class.to_s,
                        addressable_id: entity.id
                      )
        @tenders << Tender.new(
                      value: {
                        amount: row[:tender_value].to_f,
                        currency: row[:tender_currency],
                        x_amountEur: row[:tender_value_eur],
                        x_vatbool: row[:tender_value_vat],
                        x_vat: row[:tender_value_vat_percent].to_f
                      },
                      document_id: doc.id
                    )
        supplier =  Supplier.new(
                      name: row[:company_name],
                      x_slug: row[:company_name_slug],
                      document_id: doc.id
                    )
        @suppliers << supplier
        @addresses << Address.new(
                        countryName: row[:company_country],
                        locality: row[:company_town],
                        streetAddress: row[:company_address],
                        postalCode: row[:company_postal_code],
                        addressable_type: supplier.class.to_s,
                        addressable_id: supplier.id
                      )
      end
      batch_insert
    end
  end

no_commands{

  def initialize_arrays
    @documents, @awards, @entities , @tenders, @suppliers, @addresses = [], [], [], [], [], []
  end

  def batch_insert
    Document.with(ordered: false).collection.insert_many(@documents.map(&:as_document))
    Award.with(ordered: false).collection.insert_many(@awards.map(&:as_document))
    ProcuringEntity.with(ordered: false).collection.insert_many(@entities.map(&:as_document))
    Tender.with(ordered: false).collection.insert_many(@tenders.map(&:as_document))
    Supplier.with(ordered: false).collection.insert_many(@suppliers.map(&:as_document))
    Address.with(ordered: false).collection.insert_many(@addresses.map(&:as_document))
  end

}
end
