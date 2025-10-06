CREATE PROCEDURE dbo.xsp_adjustment_detail_update_sum
(
	@p_adjustment_code				nvarchar(50)
	--
	,@p_mod_date					datetime
	,@p_mod_by						nvarchar(15)
	,@p_mod_ip_address				nvarchar(15)
)
as
begin
	declare @msg nvarchar(max) 
			,@net_book_value_comm	decimal(18,2)
			,@net_book_value_fiscal	decimal(18,2)
			,@total_fiscal			decimal(18,2)
			,@total_comm			decimal(18,2)
			,@amount				decimal(18,2)
			,@adjust_type			nvarchar(50)
			,@purchase_price		decimal(18,2)
			,@old_nbv_comm			decimal(18,2)
			,@old_nbv_fiscal		decimal(18,2)
			,@new_nbv_comm			decimal(18,2)
			,@new_nbv_fiscal		decimal(18,2)

	select @net_book_value_fiscal	= isnull(ass.net_book_value_fiscal,0)
			,@net_book_value_comm	= isnull(ass.net_book_value_comm,0) 
			,@adjust_type			= adj.adjustment_type
			,@purchase_price		= ass.purchase_price
			,@old_nbv_comm			= adj.old_netbook_value_comm
			,@old_nbv_fiscal		= adj.old_netbook_value_fiscal
	from dbo.adjustment adj
	inner join dbo.asset ass on (ass.code = adj.asset_code)
	where adj.code = @p_adjustment_code

	select @amount = sum(isnull(amount,0)) 
	from dbo.adjustment_detail
	where adjustment_code = @p_adjustment_code

	--select	@purchase_price = case @net_book_value_comm when 0 then 0 else @purchase_price end
	select	@new_nbv_comm = case @old_nbv_comm when 0 then 0 else @old_nbv_comm end
	select	@new_nbv_fiscal = case @old_nbv_fiscal when 0 then 0 else @old_nbv_fiscal end

	begin try

		update	dbo.adjustment
		set		new_netbook_value_fiscal	= @amount + @new_nbv_fiscal
				,new_netbook_value_comm		= @amount + @new_nbv_comm
				,total_adjustment			= @amount
				--
				,mod_date					= @p_mod_date
				,mod_by						= @p_mod_by
				,mod_ip_address				= @p_mod_ip_address
		where	code = @p_adjustment_code
 
		-- update	dbo.adjustment
		--set		new_netbook_value_fiscal	= @purchase_price + @amount
		--		,new_netbook_value_comm		= @purchase_price + @amount
		--		--
		--		,mod_date					= @p_mod_date
		--		,mod_by						= @p_mod_by
		--		,mod_ip_address				= @p_mod_ip_address
		--where	code = @p_adjustment_code
 

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
