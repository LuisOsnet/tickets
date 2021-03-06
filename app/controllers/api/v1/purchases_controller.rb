class Api::V1::PurchasesController < Api::V1::BaseController
  before_action :find_event, only: %i[create]

  def create
    purchase = Purchase.create(purchases_params)
    buy = purchase.update(total: total_with_commission)
    response_success
  end

  private

  def purchases_params
    params.require(:purchase).permit(
      :number_of_tickets,
      :commission_type,
      :event_id,
      :user_id
    )
  end

  def total_without_commission
    @event.pricing_by_ticket * purchases_params[:number_of_tickets].to_i
  end

  def total_with_commission
    if price_by_commission.commission_type.eql?("money")
      total_without_commission + (purchases_params[:number_of_tickets].to_i *
        price_by_commission.commission_amount
      )
    elsif price_by_commission.commission_type.eql?("percentage")
      total_without_commission + (purchases_params[:number_of_tickets].to_i * (
        price_by_commission.commission_amount / 10)
      )
    end
  end

  def price_by_commission
    @event.commissions.find_by(
      commission_type: purchases_params[:commission_type]
    )
  end

  def find_event
    @event = Event.find(purchases_params[:event_id])
  end
end
