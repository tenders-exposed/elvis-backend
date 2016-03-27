class UpdateSlugIdWorker
  include Sidekiq::Worker
  sidekiq_options queue: 'critical', retry: 10, :backtrace => true

  def perform(type, slug, slug_id)
    if type == 'supplier'
      Contract.where("suppliers.x_slug": slug).update_all("$set" => {"suppliers.$.x_slug_id" => slug_id})
    else
      contracts = Contract.where("procuring_entity.x_slug": slug)
      contracts_ids = contracts.map{|contract| contract.id}
      Contract.any_in(id: contracts_ids).update_all("procuring_entity.x_slug_id": slug_id)
    end
  end
end
