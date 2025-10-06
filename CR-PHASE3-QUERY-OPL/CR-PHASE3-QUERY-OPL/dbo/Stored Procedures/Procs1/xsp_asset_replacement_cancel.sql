CREATE PROCEDURE dbo.xsp_asset_replacement_cancel
(
	@p_code			   nvarchar(50)
	--
	,@p_mod_date	   datetime
	,@p_mod_by		   nvarchar(15)
	,@p_mod_ip_address nvarchar(15)
)
as
begin
	
	declare @msg					 nvarchar(max);

	begin try
		
		if exists
		(
			select	1
			from	dbo.asset_replacement
			where	code = @p_code
			and		status = 'HOLD'
		)
		begin
			
			update	dbo.asset_replacement
			set		status			= 'CANCEL'
					--
					,mod_date		= @p_mod_date		
					,mod_by			= @p_mod_by			
					,mod_ip_address	= @p_mod_ip_address
			where	code			= @p_code ;
			
			if exists (select 1 from dbo.asset_replacement_detail where replacement_code = @p_code and isnull(new_fa_code, '')<>'')
			begin
				--for update fixe asset status to Reserved when asset condition is USED
				declare @asset_no				 nvarchar(50)
						,@fa_code				 nvarchar(50)

				declare currapplicationasset cursor fast_forward read_only for
				select	old_asset_no
						,new_fa_code
				from	dbo.asset_replacement_detail
				where	replacement_code = @p_code

				open currapplicationasset ;

				fetch next from currapplicationasset
				into @asset_no 
					,@fa_code ;

				while @@fetch_status = 0
				begin

					exec ifinams.dbo.xsp_asset_update_rental_status @p_code				= @fa_code
																	,@p_rental_reff_no	= @asset_no
																	,@p_rental_status	= null
																	,@p_reserved_by		= null
																	,@p_is_cancel		= '1'
																	,@p_mod_date		= @p_mod_date
																	,@p_mod_by			= @p_mod_by
																	,@p_mod_ip_address	= @p_mod_ip_address
				
				
					fetch next from currapplicationasset
					into @asset_no 
						,@fa_code ;
				end ;

				close currapplicationasset ;
				deallocate currapplicationasset ;
			end
		end ;
		else
		begin
			set @msg = 'Data already Proceed or Post';
			raiserror(@msg, 16, -1) ;
		end ;
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
