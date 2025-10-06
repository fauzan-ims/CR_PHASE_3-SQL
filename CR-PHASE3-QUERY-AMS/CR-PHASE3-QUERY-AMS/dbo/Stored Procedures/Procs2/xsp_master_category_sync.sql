CREATE procedure xsp_master_category_sync
(
	@p_cre_date		   datetime
	,@p_cre_by		   nvarchar(15)
	,@p_cre_ip_address nvarchar(15)
	,@p_mod_date	   datetime
	,@p_mod_by		   nvarchar(15)
	,@p_mod_ip_address nvarchar(15)
)
as
begin
	declare @msg			  nvarchar(max)
			,@code			  nvarchar(50)
			,@description	  nvarchar(250)
			,@asset_type_code nvarchar(20)
			,@company_code  nvarchar(50) ;

	begin try
		--declare cursor dari bam
		declare c_asset_category cursor for
		select	code
				,description
				,asset_type_code
				,company_code
		from	ifinbam.dbo.master_category ;

		--open cursor
		open c_asset_category ;

		--fetch cursor
		fetch c_asset_category
		into @code
			 ,@description
			 ,@asset_type_code
			 ,@company_code ;

		while @@fetch_status = 0
		begin
			if exists
			(
				select	1
				from	dbo.master_category
				where	code = @code
			)
			begin
				update	dbo.master_category
				set		description = @description
						,asset_type_code = @asset_type_code 
				where	code = @code
				and		company_code = @company_code

			end ;
			else
			begin
				insert into dbo.master_category
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
				(	@code
					,@company_code
					,@description
					,@asset_type_code
					,N'' 
					,N'' 
					,N'' 
					,N'' 
					,N'' 
					,N'' 
					,N'' 
					,N'' 
					,N'' 
					,N'' 
					,N'' 
					,N'' 
					,N'' 
					,N'' 
					,'' 
					,0 
					,0 
					,0 
					,0 
					,0 
					,N'' 
					,0 
					,N'1' 
					--
					,@p_cre_date		  
					,@p_cre_by		  
					,@p_cre_ip_address
					,@p_mod_date	  
					,@p_mod_by		  
					,@p_mod_ip_address
				) ;
			end ;

			--fetch cursor selanjutnya
			fetch c_asset_category
			into @code
				 ,@description
				 ,@asset_type_code 
				 ,@company_code;
		end ;

		--close & deallocate cursor
		close c_asset_category ;
		deallocate c_asset_category ;
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
			set @msg = 'v' + ';' + @msg ;
		end ;
		else
		begin
			if (
				   error_message() like '%v;%'
				   or	error_message() like '%e;%'
			   )
			begin
				set @msg = error_message() ;
			end ;
			else
			begin
				set @msg = 'e;' + dbo.xfn_get_msg_err_generic() + ';' + error_message() ;
			end ;
		end ;

		raiserror(@msg, 16, -1) ;

		return ;
	end catch ;
end ;
