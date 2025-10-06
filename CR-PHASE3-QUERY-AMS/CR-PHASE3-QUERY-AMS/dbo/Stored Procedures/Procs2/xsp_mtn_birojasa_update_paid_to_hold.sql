CREATE PROCEDURE dbo.xsp_mtn_birojasa_update_paid_to_hold
(
   @p_register_no	 nvarchar(50) --= replace('00560/INV/2015/11/2023', '/', '.') -- NEW NO INVOICE 
   --				 
   ,@p_mtn_remark	 nvarchar(4000)
   ,@p_mtn_cre_by	 nvarchar(250)
)
as
begin
	declare @msg		 nvarchar(max) 

	BEGIN TRANSACTION 
	begin try 
		--validasi
		begin
			if (isnull(@p_mtn_remark, '') = '')
			begin
				set @msg = 'Harap diisi MTN Remark';
				raiserror(@msg, 16, 1) ;
				return
			end

			if (isnull(@p_mtn_cre_by, '') = '')
			begin
				set @msg = 'Harap diisi MTN Cre By';
				raiserror(@msg, 16, 1) ;
				return
			end

			if exists
			(
				select	1
				from	dbo.payment_request
				where	payment_source_no		   = @p_register_no
			)
			begin
				set @msg = 'Data already in Payment Request Process';
				raiserror(@msg, 16, 1) ;
				return
			end ;
		end ;

		--update register main payment status
		begin
			update	dbo.REGISTER_MAIN
			set		payment_status	= 'HOLD'
					,mod_date		= getdate()
					,mod_by			= N'MTN_DATA'
					,mod_ip_address = N'MTN_DATA'
			where	CODE			= @p_register_no; 
		end ; 
		
		--insert mtn log data
		begin
			INSERT INTO dbo.MTN_DATA_DSF_LOG
			(
				MAINTENANCE_NAME
				,REMARK
				,TABEL_UTAMA
				,REFF_1
				,REFF_2
				,REFF_3
				,CRE_DATE
				,CRE_BY
			)
			values
			(
				'MTN KOREKSI PAYMENT STATUS'
				,@p_mtn_remark
				,'REGISTER_MAIN'
				,@p_register_no
				,null -- REFF_2 - nvarchar(50)
				,null -- REFF_3 - nvarchar(50)
				,getdate()
				,@p_mtn_cre_by
			)
		end

		if @@error = 0
		begin
			select 'SUCCESS'
			commit transaction ;
			--rollback transaction ;
		end ;
		else
		begin
			select 'GAGAL'
			rollback transaction ;
		end ;
	end try
	begin catch 
		
		rollback transaction ;

		if (len(@msg) <> 0)
		begin
			set @msg = 'V' + ';' + @msg ;
		end ;
		else
		begin
			if (
				   error_message() like '%V;%'
				   or	error_message() like '%E;%'
			   )
			begin
				set @msg = error_message() ;
			end ;
			else
			begin
				set @msg = 'E;' + dbo.xfn_get_msg_err_generic() + ';' + error_message() ;
			end ;
		end ;

		raiserror(@msg, 16, -1) ;

		return ;
	end catch ;
end ;
