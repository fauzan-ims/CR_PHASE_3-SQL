CREATE PROCEDURE dbo.xsp_master_barcode_post
(
	@p_code			   nvarchar(50)
	--
	,@p_mod_date	   datetime
	,@p_mod_by		   nvarchar(15)
	,@p_mod_ip_address nvarchar(15)
)
as
begin
	declare @msg					nvarchar(max)
			,@status				nvarchar(20)
			,@barcode_code			nvarchar(50);

	begin try -- 
		select	@status				= dor.status
				,@barcode_code		= mbrd.barcode_register_code
		from	dbo.master_barcode_register dor
				left join dbo.master_barcode_register_detail mbrd on (mbrd.barcode_register_code = dor.code)
		where	dor.code = @p_code ;

		if (@status = 'HOLD' and @barcode_code is not null)
		begin
			    update	dbo.master_barcode_register
				set		status			= 'POST'
						--
						,mod_date		= @p_mod_date
						,mod_by			= @p_mod_by
						,mod_ip_address = @p_mod_ip_address
				where	code			= @p_code ;
		end
		else if (@status = 'HOLD' and @barcode_code is null)
		begin
			--set @msg = 'Mohon isi Master Barcode Register Detil.';
			set @msg = 'Please Input Master Barcode Register Detail';
			raiserror(@msg ,16,-1);
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
