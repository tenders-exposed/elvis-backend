class IdXslugs < Thor

  desc "id per slug", "Give each x_slug an id"
  def id_per_slug
    update_suppliers
    update_procurers
  end

  no_commands{

    def update_suppliers
      all =  Contract.collection.aggregate( [ { "$project": { "suppliers.x_slug": 1 }}])
      unique = all.to_a.map{|obj| obj["suppliers"].first["x_slug"]}.uniq.compact
      slug_ids = Hash[unique.map.with_index(1).to_a]
      slug_ids.each do |slug, id|
        Contract.where("suppliers.x_slug": slug).update_all("$set" => {"suppliers.$.slug_id" => id})
      end
    end

    def update_procurers
      all = Contract.collection.aggregate( [ { "$project": { "procuring_entity.x_slug": 1 }}])
      unique = all.to_a.map{|obj| obj["procuring_entity"]["x_slug"]}.uniq.compact
      slug_ids = Hash[unique.map.with_index(1).to_a]
      slug_ids.each do |slug, id|
        contracts = Contract.where("procuring_entity.x_slug": slug)
        contracts_ids = contracts.map{|c| c.id}
        Contract.any_in(id: contracts_ids).update_all("procuring_entity.slug_id": id)
      end
    end

  }

end
