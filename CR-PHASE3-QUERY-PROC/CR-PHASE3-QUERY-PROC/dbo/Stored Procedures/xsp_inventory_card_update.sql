CREATE PROCEDURE dbo.xsp_inventory_card_update
(
	 @p_id						bigint
	,@p_company_code			nvarchar(50)
	,@p_branch_code				nvarchar(50)
	,@p_branch_name				nvarchar(250)
	,@p_transaction_code		nvarchar(50)
	,@p_transaction_type		nvarchar(5)
	,@p_transaction_period		nvarchar(10)
	,@p_item_code				nvarchar(50)
	,@p_item_name				nvarchar(250)
	,@p_warehouse_code			nvarchar(50)
	,@p_plus_or_minus			nvarchar(1)
	,@p_quantity				int
	,@p_on_hand_quantity		int
		--
	,@p_mod_date				datetime
	,@p_mod_by					nvarchar(15)
	,@p_mod_ip_address			nvarchar(15)
)
as
begin
	declare @msg nvarchar(max) ;
	
	if @p_plus_or_minus = 'T'
		set @p_plus_or_minus = '1' ;
	else if @p_plus_or_minus = '1'
		set @p_plus_or_minus = '1' ;
	else if @p_plus_or_minus = '0'
		set @p_plus_or_minus = '0' ;
	else
		set @p_plus_or_minus = '0' ;


	begin try
	 update inventory_card
	set
		 company_code		= @p_company_code
		,branch_code		= @p_branch_code
		,branch_name		= @p_branch_name
		,transaction_code	= @p_transaction_code
		,transaction_type	= @p_transaction_type
		,transaction_period	= @p_transaction_period
		,item_code			= @p_item_code
		,item_name			= @p_item_name
		,warehouse_code		= @p_warehouse_code
		,plus_or_minus		= @p_plus_or_minus
		,quantity			= @p_quantity
		,on_hand_quantity	= @p_on_hand_quantity
			--
		,mod_date			= @p_mod_date
		,mod_by				= @p_mod_by
		,mod_ip_address		= @p_mod_ip_address
	where		id	= @p_id

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
end
