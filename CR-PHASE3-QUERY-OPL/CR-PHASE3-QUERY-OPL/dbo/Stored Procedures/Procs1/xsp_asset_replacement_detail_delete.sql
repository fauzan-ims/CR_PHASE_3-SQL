CREATE PROCEDURE dbo.xsp_asset_replacement_detail_delete
(
	@p_id			   bigint
	--
	,@p_mod_date	   datetime
	,@p_mod_by		   nvarchar(15)
	,@p_mod_ip_address nvarchar(15)
)
as
begin
	declare @msg nvarchar(max) ;

	begin try
	
		if exists (select 1 from dbo.asset_replacement_detail where id = @p_id and isnull(new_fa_code, '')<>'')
		begin
			--for update fixe asset status to Reserved when asset condition is USED
			declare @asset_no				 nvarchar(50)
					,@fa_code				 nvarchar(50)

			declare currapplicationasset cursor fast_forward read_only for
			select	old_asset_no
					,new_fa_code
			from	dbo.asset_replacement_detail
			where	id = @p_id

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

		delete	asset_replacement_detail
		where	id	= @p_id

	end try
	begin catch
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
