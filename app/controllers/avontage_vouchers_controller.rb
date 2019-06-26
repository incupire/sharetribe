class AvontageVouchersController < ApplicationController

	def voucher_show
		@transaction = Transaction.last
	end

end
