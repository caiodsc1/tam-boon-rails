# frozen_string_literal: true

class DonationService
  attr_reader :token

  def initialize(charity_id: nil, amount: 0, omise_token: nil)
    @charity     = charity_id.eql?('random') ? Charity.random_charity : Charity.find_by(id: charity_id)
    @amount      = amount.to_d # allow subunits
    @omise_token = omise_token
  end

  def process
    unless @omise_token && @amount > 20 && @charity
      @token = retrieve_token
      return false
    end

    @charge = create_charge

    @charity.credit_amount(@charge.amount) if @charge.paid

    @charge.paid # true or false
  end

  private

  def create_charge
    if Rails.env.test?
      OpenStruct.new(
        amount: @amount * 100,
        paid: (@amount != 999)
      )
    else
      Omise::Charge.create(
        amount: @amount * 100,
        currency: 'THB',
        card: @omise_token,
        description: "Donation to #{@charity.name} [#{@charity.id}]"
      )
    end
  end

  def retrieve_token
    return nil unless @omise_token

    if Rails.env.test?
      OpenStruct.new(id: 'tokn_X',
                     card: OpenStruct.new(
                       name: 'J DOE',
                       last_digits: '4242',
                       expiration_month: 10,
                       expiration_year: 2020,
                       security_code_check: false
                     ))
    else
      Omise::Token.retrieve(@omise_token)
    end
  end
end
