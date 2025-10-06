CREATE PROCEDURE dbo.xsp_deposit_revenue_update
(
	@p_code				nvarchar(50)
	,@p_branch_code		nvarchar(50)
	,@p_branch_name		nvarchar(250)
	,@p_revenue_status	nvarchar(10)
	,@p_revenue_date	datetime
	,@p_revenue_amount	decimal(18, 2)
	,@p_revenue_remarks nvarchar(4000)
	,@p_agreement_no	nvarchar(50)
	,@p_currency_code	nvarchar(3)
	,@p_exch_rate		decimal(18,6)
	--
	,@p_mod_date		datetime
	,@p_mod_by			nvarchar(15)
	,@p_mod_ip_address	nvarchar(15)
)
as
begin
	declare @msg nvarchar(max) ;

	begin try

		if (@p_revenue_date > dbo.xfn_get_system_date()) 
				begin
					set @msg = dbo.xfn_get_msg_err_must_be_lower_or_equal_than('Date','System Date');
					raiserror(@msg ,16,-1)
				end

		update	deposit_revenue
		set		branch_code			= @p_branch_code
				,branch_name		= @p_branch_name
				,revenue_status		= @p_revenue_status
				,revenue_date		= @p_revenue_date
				,revenue_amount		= @p_revenue_amount
				,revenue_remarks	= @p_revenue_remarks
				,agreement_no		= @p_agreement_no
				,currency_code		= @p_currency_code
				,exch_rate			= @p_exch_rate
				--
				,mod_date			= @p_mod_date
				,mod_by				= @p_mod_by
				,mod_ip_address		= @p_mod_ip_address
		where	code				= @p_code ;
	end try
	begin catch
		declare @error int ;

		set @error = @@error ;

		if (@error = 2627)
		begin
			set @msg = dbo.xfn_get_msg_err_code_already_exist() ;
		end ;

		if (len(@msg) <> 0)
		begin
			set @msg = 'V' + ';' + @msg ;
		end ;
		else
		begin
			if (error_message() like '%V;%' or error_message() like '%E;%')
			begin
				set @msg = error_message() ;
			end
			else 
			begin
				set @msg = 'E;' + dbo.xfn_get_msg_err_generic() + ';' + error_message() ;
			end
		end ;

		raiserror(@msg, 16, -1) ;

		return ;
	end catch ;
end ;
