CREATE PROCEDURE dbo.xsp_mtn_application_roa
(
   @p_application_no	    nvarchar(50)
   ,@p_asset_no			    nvarchar(50) = null
   ,@p_average_asset_amount decimal(18,2)
   ,@p_yearly_profit_amount decimal(18,2)
   ,@p_roa_pct				decimal(9,6)
   --				 
   ,@p_mtn_remark			nvarchar(4000)
   ,@p_mtn_cre_by			nvarchar(250)
)
as
begin
	declare @msg			 nvarchar(max)
			,@application_no nvarchar(50) = replace(@p_application_no, '/', '.')
			,@mod_date		 datetime	  = getdate() ;

	begin transaction 
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
				from	dbo.application_main
				where	application_no		   = @application_no
						and application_status = 'HOLD'
			)
			begin
				set @msg = 'Application Status HOLD, Please do application asset update via IFIN system' ;
				raiserror(@msg, 16, 1) ;
				return
			end ;   
		end ;

		--cancel application
		begin
			
			update	dbo.application_asset
			set		average_asset_amount  = @p_average_asset_amount
					,yearly_profit_amount = @p_yearly_profit_amount
					,roa_pct			  = @p_roa_pct
					,mod_date			  = getdate()
					,mod_by				  = N'MTN_DATA'
					,mod_ip_address		  = N'MTN_DATA'
			where	application_no		  = @application_no 
					and asset_no		  = case @p_asset_no when 'ALL' then asset_no else @p_asset_no end
		end ;

		select	average_asset_amount
				,yearly_profit_amount
				,roa_pct
		from	dbo.application_asset
		where	application_no = @application_no ;

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
				'MTN APPLICATION ASSET ROA'
				,@p_mtn_remark
				,'APPLICATION_ASSET'
				,@application_no
				,@p_asset_no 
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
