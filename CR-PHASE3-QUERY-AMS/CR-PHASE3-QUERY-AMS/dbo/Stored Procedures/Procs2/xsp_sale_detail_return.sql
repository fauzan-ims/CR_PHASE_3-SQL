CREATE PROCEDURE [dbo].[xsp_sale_detail_return]
(
	@p_id				bigint
	--
	,@p_mod_date	    datetime
	,@p_mod_by		    nvarchar(15)
	,@p_mod_ip_address  nvarchar(15)
)
as
begin
	declare @msg								nvarchar(max)
			,@status							nvarchar(20)
			,@asset_code						nvarchar(50)
			,@reason_type						nvarchar(50)
			,@is_valid							int 
			,@max_day							int
			,@disposal_date						datetime
			,@company_code						nvarchar(50)
			,@interface_remarks					nvarchar(4000)
			,@req_date							datetime
			,@item_name							nvarchar(250)
			,@reff_approval_category_code		nvarchar(50)
			,@request_code						nvarchar(50)
			,@net_book_value					decimal(18,2)
			,@branch_code						nvarchar(50)
			,@branch_name						nvarchar(250)
			,@approval_code						nvarchar(50)
			,@reff_dimension_code				nvarchar(50)
			,@reff_dimension_name				nvarchar(250)
			,@dimension_code					nvarchar(50)
			,@table_name						nvarchar(50)
			,@primary_column					nvarchar(50)
			,@dim_value							nvarchar(50)
			,@sell_amount						decimal(18,2)
			,@sell_code							nvarchar(50)
			,@sell_req_date						datetime

	begin try -- 
	if exists(select 1 from dbo.sale_detail where id = @p_id and sale_detail_status = 'ON PROCESS')
	begin
			select	@branch_code	= sl.branch_code
					,@branch_name	= sl.branch_name
					,@req_date		= sd.sale_date
					,@sell_amount	= sd.sold_amount
					,@sell_code		= sl.code
					,@sell_req_date	= sl.sale_date
					,@asset_code	= sd.asset_code
					,@item_name		= ass.item_name
			from dbo.sale_detail sd
			left join dbo.sale sl on (sl.code = sd.sale_code)
			left join dbo.asset ass on (sd.asset_code = ass.code)
			where id = @p_id
			
			update	dbo.sale_detail
			set		sale_detail_status	= 'HOLD'
					--
					,mod_date			= @p_mod_date
					,mod_by				= @p_mod_by
					,mod_ip_address		= @p_mod_ip_address
			where	id					= @p_id ;
	end
	else
	begin
		set @msg = 'Data already proceed.';
		raiserror(@msg ,16,-1);
	end

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
