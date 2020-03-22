class WebsiteController < ApplicationController
  def index
    @token = nil
  end

  def donate
    donation = DonationService.new(charity_id: params[:charity],
                                   amount: params[:amount],
                                   omise_token: params[:omise_token])

    if donation.process
      flash.notice = t(".success")
      redirect_to root_path
    else
      @token = donation.retrieve_token
      flash.now.alert = t(".failure")
      render :index
    end
  end
end
