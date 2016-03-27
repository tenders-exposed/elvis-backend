class UpdateNullSlugsWorker
  include Sidekiq::Worker
  sidekiq_options queue: 'critical', retry: 10, :backtrace => true

  def perform(type, contract_id, actor_ids, id)
    if type == 'supplier'
      actor_ids.each_with_index do |supplier_id, index|
        contract = Contract.find(contract_id)
        contract.update_attributes!(suppliers_attributes:  {"#{index}" => {id: supplier_id, x_slug_id: id}})
        id +=1
      end
    else
      contract = Contract.find(contract_id)
      contract.update_attributes!(procuring_entity_attributes: {id: actor_ids.first, x_slug_id: id})
    end
  end
end
