module PurchaseContractsHelper
  include ActionView::Helpers::NumberHelper

  def index_formatter(pc)
    result = []
    result << pc.certification_symbol if !pc.certification_symbol.blank?
    result << pc.average_score.round(1) if pc.average_score
    result << number_to_currency(pc.ssp, locale: :en) if pc.ssp
    result.join(" | ")
  end
end