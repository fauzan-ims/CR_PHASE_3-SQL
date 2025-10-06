CREATE PROCEDURE dbo.xsp_master_insurance_fee_insert
(
	@p_id					  bigint = 0 output
	,@p_insurance_code		  nvarchar(50)
	,@p_currency_code		  nvarchar(3)
	,@p_eff_date			  datetime
	,@p_admin_fee_buy_amount  decimal(18,2)
	,@p_admin_fee_sell_amount decimal(18,2)
	,@p_stamp_fee_amount	  decimal(18,2)
	--
	,@p_cre_date			  datetime
	,@p_cre_by				  nvarchar(15)
	,@p_cre_ip_address		  nvarchar(15)
	,@p_mod_date			  datetime
	,@p_mod_by				  nvarchar(15)
	,@p_mod_ip_address		  nvarchar(15)
)
as
begin
	declare @msg nvarchar(max) ;

	begin try 
		if exists (select 1 from master_insurance_fee where insurance_code = @p_insurance_code AND CAST(eff_date AS DATE) =CAST(@p_eff_date AS DATE)   )
		begin
			SET @msg = 'Effective Date already exist';
			raiserror(@msg, 16, -1) ;
		END 
		if (@p_eff_date < dbo.xfn_get_system_date() )
		begin
			SET @msg = 'Effective Date must be greater and equal than System Date';
			raiserror(@msg, 16, -1) ;
		END
        
		if (@p_admin_fee_buy_amount > @p_admin_fee_sell_amount)
		begin
			set @msg = 'Buy Amount must be greater than Sell Amount';
			raiserror(@msg, 16, -1) ;
		end
		insert into master_insurance_fee
		(
			insurance_code
			,eff_date
			,currency_code
			,admin_fee_buy_amount
			,admin_fee_sell_amount
			,stamp_fee_amount
			--
			,cre_date
			,cre_by
			,cre_ip_address
			,mod_date
			,mod_by
			,mod_ip_address
		)
		values
		(	@p_insurance_code
			,@p_eff_date
			,@p_currency_code
			,@p_admin_fee_buy_amount
			,@p_admin_fee_sell_amount
			,@p_stamp_fee_amount
			--
			,@p_cre_date
			,@p_cre_by
			,@p_cre_ip_address
			,@p_mod_date
			,@p_mod_by
			,@p_mod_ip_address
		) ;

		EXEC dbo.xsp_master_insurance_update_invalid @p_code			= @p_insurance_code                   
		                                             ,@p_mod_date		= @p_mod_date
		                                             ,@p_mod_by			= @p_mod_by 
		                                             ,@p_mod_ip_address	= @p_mod_ip_address

		set @p_id = @@identity ;
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




