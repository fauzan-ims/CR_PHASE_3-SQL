CREATE PROCEDURE dbo.xsp_application_asset_financing_portion_pct_update
(
	@p_application_no  nvarchar(50)
	--
	,@p_mod_date	   datetime
	,@p_mod_by		   nvarchar(15)
	,@p_mod_ip_address nvarchar(15)
)
as
begin
	declare @msg					 nvarchar(max)
			,@total_financing_amount decimal(18, 2)
			,@financing_portion_pct	 decimal(9, 6)
			,@asset_no				 nvarchar(50)
			,@financing_amount		 decimal(18, 2) ;

	begin try 

		declare cursor_name cursor fast_forward read_only for
		select	asset_no
				,0--asset_value
		from	dbo.application_asset
		where	application_no = @p_application_no ;

		open cursor_name ;

		fetch next from cursor_name
		into @asset_no
			 ,@financing_amount ;

		while @@fetch_status = 0
		begin
			set @financing_portion_pct = (isnull(@financing_amount, 0) / (isnull(@total_financing_amount, 0))) * 100 ;
 
			fetch next from cursor_name
			into @asset_no
				 ,@financing_amount ;
		end ;

		close cursor_name ;
		deallocate cursor_name ;
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


