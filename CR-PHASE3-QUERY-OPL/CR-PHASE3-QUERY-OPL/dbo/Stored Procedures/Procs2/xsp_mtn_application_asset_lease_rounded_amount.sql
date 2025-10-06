CREATE PROCEDURE dbo.xsp_mtn_application_asset_lease_rounded_amount
(
   @p_application_no		nvarchar(50) --= replace('0001152/4/08/09/2023', '/', '.') -- NO APPLICATION
   ,@p_asset_no			    nvarchar(50)  = 'ALL'
   ,@p_lease_rounded_amount decimal(18, 2)
   --				 
   ,@p_mtn_remark			nvarchar(4000)
   ,@p_mtn_cre_by			nvarchar(250)
)
as
begin
	declare @msg			 nvarchar(max)
			,@application_no nvarchar(50) = replace(@p_application_no, '/', '.')
			,@mod_date		 datetime	  = getdate() 
			,@rounding_type	 nvarchar(20)
			,@rounding_value decimal(18, 2)
			
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

			if (@p_lease_rounded_amount <= 0)
			begin
				set @msg = 'lease_rounded_amount must be gereater than 0';
				raiserror(@msg, 16, 1) ;
				return
			end
		end 

		--update application asset leased rounded amount
		begin

			select	@rounding_type = round_type
					,@rounding_value = round_amount
			from	dbo.application_main
			where	application_no = @application_no ;

			if (@rounding_type = 'DOWN')
				set @p_lease_rounded_amount = dbo.fn_get_floor(@p_lease_rounded_amount, @rounding_value) ;
			else if (@rounding_type = 'UP')
				set @p_lease_rounded_amount = dbo.fn_get_ceiling(@p_lease_rounded_amount, @rounding_value) ;
			else
				set @p_lease_rounded_amount = dbo.fn_get_round(@p_lease_rounded_amount, @rounding_value) ;

			update	dbo.application_asset 
			set		lease_rounded_amount  = @p_lease_rounded_amount
					,mod_date			  = getdate()
					,mod_by				  = N'MTN_DATA'
					,mod_ip_address		  = N'MTN_DATA'
			where	application_no		  = @application_no
					and ASSET_NO		  = case @p_asset_no when 'ALL' then asset_no else @p_asset_no end

			update dbo.application_amortization
			set		billing_amount		  = @p_lease_rounded_amount
					,mod_date			  = getdate()
					,mod_by				  = N'MTN_DATA'
					,mod_ip_address		  = N'MTN_DATA'
			where	application_no		  = @application_no 
					and ASSET_NO		  = case @p_asset_no when 'ALL' then asset_no else @p_asset_no end
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
				'MTN APPLICATION ASSET RENTAL AMOUNT'
				,@p_mtn_remark
				,'APPLICATION_ASSET'
				,@application_no
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
