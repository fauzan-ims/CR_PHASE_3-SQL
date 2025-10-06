--created by, Rian at 17/02/2023 

CREATE procedure dbo.xsp_master_category_insert
(
	@p_code								nvarchar(50)
	,@p_company_code					nvarchar(50)
	,@p_description						nvarchar(250)
	,@p_asset_type_code					nvarchar(20)
	,@p_transaction_depre_code			nvarchar(50)	= ''
	,@p_transaction_depre_name			nvarchar(250)	= ''
	,@p_transaction_accum_depre_code	nvarchar(50)	= ''
	,@p_transaction_accum_depre_name	nvarchar(250)	= ''
	,@p_transaction_gain_loss_code		nvarchar(50)	= ''
	,@p_transaction_gain_loss_name		nvarchar(250)	= ''
	,@p_transaction_profit_sell_code	nvarchar(50)	= ''
	,@p_transaction_profit_sell_name	nvarchar(250)	= ''
	,@p_transaction_loss_sell_code		nvarchar(50)	= ''
	,@p_transaction_loss_sell_name		nvarchar(250)	= ''
	,@p_depre_cat_fiscal_code			nvarchar(50)	= ''
	,@p_depre_cat_fiscal_name			nvarchar(250)	= ''
	,@p_depre_cat_commercial_code		nvarchar(50)	= ''
	,@p_depre_cat_commercial_name		nvarchar(250)	= ''
	,@p_last_depre_date					datetime		= ''
	,@p_asset_amount_threshold			decimal(18, 2) = 0
	,@p_depre_amount_threshold			decimal(18, 2) = 0
	,@p_total_net_book_value_amount		decimal(18, 2) = 0
	,@p_total_accum_depre_amount		decimal(18, 2) = 0
	,@p_total_asset_value				decimal(18, 2) = 0
	,@p_value_type						nvarchar(50) = ''
	,@p_nde								decimal(18, 2) = 0
	,@p_is_active						nvarchar(1)
	--
	,@p_cre_date						datetime
	,@p_cre_by							nvarchar(15)
	,@p_cre_ip_address					nvarchar(15)
	,@p_mod_date						datetime
	,@p_mod_by							nvarchar(15)
	,@p_mod_ip_address					nvarchar(15)
)
as
begin
	declare @msg nvarchar(max) ;

	if @p_is_active = 'T'
		set @p_is_active = '1' ;
	else
		set @p_is_active = '0' ;

	begin try
		if exists
		(
			select	1
			from	dbo.master_category
			where	code			 = @p_code
					and company_code = @p_company_code
		)
		begin
			set @msg = 'Code already exist' ;
			raiserror(@msg, 16, -1) ;
		end ;

		if exists
		(
			select	1
			from	dbo.master_category
			where	description		 = @p_description
					and company_code = @p_company_code
		)
		begin
			set @msg = 'Description already exist' ;
			raiserror(@msg, 16, -1) ;
		end ;

		insert into master_category
		(
			code
			,company_code
			,description
			,asset_type_code
			,transaction_depre_code
			,transaction_depre_name
			,transaction_accum_depre_code
			,transaction_accum_depre_name
			,transaction_gain_loss_code
			,transaction_gain_loss_name
			,transaction_profit_sell_code
			,transaction_profit_sell_name
			,transaction_loss_sell_code
			,transaction_loss_sell_name
			,depre_cat_fiscal_code
			,depre_cat_fiscal_name
			,depre_cat_commercial_code
			,depre_cat_commercial_name
			,last_depre_date
			,asset_amount_threshold
			,depre_amount_threshold
			,total_net_book_value_amount
			,total_accum_depre_amount
			,total_asset_value
			,value_type
			,nde
			,is_active
			--
			,cre_date
			,cre_by
			,cre_ip_address
			,mod_date
			,mod_by
			,mod_ip_address
		)
		values
		(	upper(@p_code)
			,@p_company_code
			,upper(@p_description)
			,@p_asset_type_code
			,@p_transaction_depre_code
			,@p_transaction_depre_name
			,@p_transaction_accum_depre_code
			,@p_transaction_accum_depre_name
			,@p_transaction_gain_loss_code
			,@p_transaction_gain_loss_name
			,@p_transaction_profit_sell_code	
			,@p_transaction_profit_sell_name	
			,@p_transaction_loss_sell_code		
			,@p_transaction_loss_sell_name		
			,@p_depre_cat_fiscal_code
			,@p_depre_cat_fiscal_name
			,@p_depre_cat_commercial_code
			,@p_depre_cat_commercial_name
			,@p_last_depre_date
			,@p_asset_amount_threshold
			,@p_depre_amount_threshold
			,@p_total_net_book_value_amount
			,@p_total_accum_depre_amount
			,@p_total_asset_value
			,@p_value_type
			,@p_nde
			,@p_is_active
			--
			,@p_cre_date
			,@p_cre_by
			,@p_cre_ip_address
			,@p_mod_date
			,@p_mod_by
			,@p_mod_ip_address
		) ;
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
