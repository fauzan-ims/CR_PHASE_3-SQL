CREATE PROCEDURE dbo.xsp_sale_detail_delete
(
	@p_id bigint
)
as
begin
	declare @msg			nvarchar(max)
			,@asset_code	nvarchar(50)
			,@sale_code		nvarchar(50)
			,@buy_type		nvarchar(50);

	begin try
	--select	@asset_code = asset_code
	--		,@sale_code	= sale_code
	--from dbo.sale_detail
	--where id = @p_id

	--select @buy_type = buy_type 
	--from dbo.sale_bidding
	--where sale_code = @sale_code

	--if(@buy_type = 'By Batch')
	--begin
	--	set @msg = 'The No Asset you have chosen has been registered in the bidding.';
	--	raiserror(@msg ,16,-1);	
	--end
	--else if(@buy_type = 'By Unit')
	--begin
	--	if exists(select 1 from dbo.sale_bidding_detail where asset_code = @asset_code)
	--	begin
	--		set @msg = 'The No Asset you have chosen has been registered in the bidding.';
	--		raiserror(@msg ,16,-1);	
	--	end
	--end
	--else
	begin
		delete sale_detail
		where	id = @p_id ;
	end

		
	end try
	begin catch
		declare @error int ;

		set @error = @@error ;

		if (@error = 2627)
		begin
			set @msg = dbo.xfn_get_msg_err_code_already_exist() ;
		end ;
		else if (@error = 547)
		begin
			set @msg = dbo.xfn_get_msg_err_code_already_used() ;
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
