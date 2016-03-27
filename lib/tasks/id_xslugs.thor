class IdXslugs < Thor

  desc "id_per_slug", "Give each x_slug an id"
  def id_per_slug
    update_procurers
    update_suppliers
  end

  no_commands{

    def update_suppliers
      all =  Contract.collection.aggregate( [ { "$project": { "suppliers.x_slug": 1 }}])
      unique_suppliers = all.to_a.map{|obj| obj["suppliers"].map{|s| s["x_slug"]}}.flatten.uniq.compact
      x_slug_ids = unique_suppliers.map.with_index(Contract.count()+1).to_a
      x_slug_ids.each do |slug, id|
        UpdateSlugIdWorker.perform_async('supplier',slug, id)
      end
      nil_contracts = Contract.where("suppliers.x_slug": nil)
      next_index = x_slug_ids.size + 1
      unless nil_contracts.empty?
        contract_and_suppliers = nil_contracts.map{|contract| [contract.id, contract.suppliers.map{|s| s.id}]}
        contract_and_suppliers.each do |contract_id, supplier_ids|
          UpdateNullSlugsWorker.perform_async('supplier', contract_id, supplier_ids, next_index)
          next_index += 1
        end
      end
    end

    def update_procurers
      all = Contract.collection.aggregate( [ { "$project": { "procuring_entity.x_slug": 1 }}])
      unique = all.to_a.map{|obj| obj["procuring_entity"]["x_slug"]}.uniq.compact
      x_slug_ids = unique.map.with_index(1).to_a
      x_slug_ids.each do |slug, id|
        UpdateSlugIdWorker.perform_async('procuring_entity',slug, id)
      end
      nil_contracts = Contract.where("procuring_entity.x_slug": nil).to_a
      next_index = x_slug_ids.size + 1
      unless nil_contracts.empty?
        contract_and_procurer = nil_contracts.map{|contract| [contract.id, contract.procuring_entity.id]}
        contract_and_procurer.each do |contract_id, procurer_id|
          UpdateNullSlugsWorker.perform_async('procuring_entity', contract_id, [procurer_id], next_index)
          next_index += 1
        end
      end
    end

  }

end
