class Charity < ActiveRecord::Base
  validates :name, presence: true

  def credit_amount(amount)
    with_lock { update_column :total, total + amount }
  end

  def self.random_charity
    find(pluck(:id).sample) # Faster than order("RANDOM()").first even for 100K+ records
  end
end
