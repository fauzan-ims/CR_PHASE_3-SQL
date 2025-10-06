CREATE PROCEDURE dbo.xsp_supplier_selection_reject_from_approval
(
	@p_code			   nvarchar(50)
	--
	,@p_mod_date	   datetime
	,@p_mod_by		   nvarchar(15)
	,@p_mod_ip_address nvarchar(15)
)
as
begin
	declare @msg								nvarchar(max)
			,@quotation_code					nvarchar(50)
			,@reff_no							nvarchar(50);
			
	begin TRY
    	
		--Raffyanda 22/01/2024 (+) Penambahan kondisi agar ketika supplier selection di reject, data quotation nya berubah menjadi hold	
		IF exists (select 1 from supplier_selection where status = 'ON PROCESS' AND code = @p_code)
		BEGIN
			
			update	dbo.supplier_selection
			set		status			= 'REJECT'
					--
					,mod_date		= @p_mod_date
					,mod_by			= @p_mod_by
					,mod_ip_address = @p_mod_ip_address
			where	code			= @p_code ;

			declare cursor_name cursor fast_forward read_only for
			select reff_no 
			from dbo.supplier_selection_detail
			where selection_code = @p_code
			
			open cursor_name
			
			fetch next from cursor_name 
			into @reff_no
			
			while @@fetch_status = 0
			begin
			    update dbo.quotation_review
				set		status = 'HOLD'
						--
						,mod_date		= @p_mod_date
						,mod_by			= @p_mod_by
						,mod_ip_address = @p_mod_ip_address
				where	code = @reff_no;

				 update dbo.procurement
				 set	status = 'HOLD'
				 		--
				 		,mod_date		= @p_mod_date
				 		,mod_by			= @p_mod_by
				 		,mod_ip_address = @p_mod_ip_address
				 where	code = @reff_no;
			
			    fetch next from cursor_name 
				into @reff_no
			end
			
			close cursor_name
			deallocate cursor_name
		
		END
        else
		begin
			set @msg = 'Data already proceed';
			raiserror(@msg ,16,-1);
		end
	end TRY
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
