CREATE PROCEDURE dbo.xsp_mtn_non_mobilisasi
(
	--script non mobilisasi
	@p_procurment_no			NVARCHAR(50)--untuk code procurement
	--
	,@p_mtn_remark				NVARCHAR(4000)
	,@p_mod_by					NVARCHAR(15)
)
as
begin
	declare @msg						nvarchar(max)
			,@asset_no					nvarchar(50)
			,@application_no			nvarchar(50)
			,@mod_date				datetime = getdate()
			,@procurment_request_no	NVARCHAR(50)

	begin TRY

	select  @asset_no = ast.asset_no
			,@application_no = ast.application_no
			,@procurment_request_no = prr.code 
	from dbo.procurement pr
	inner join dbo.procurement_request prr on (prr.code = pr.procurement_request_code)
	inner join ifinopl.dbo.application_asset ast on (ast.asset_no = prr.asset_no)
	where pr.code = @p_procurment_no

	IF (isnull(@p_mtn_remark, '') = '')
	begin
		set @msg = 'Harap diisi MTN Remark';
		raiserror(@msg, 16, 1) ;
		return
	end

	if (isnull(@p_mod_by, '') = '')
	begin
		set @msg = 'Harap diisi MTN Mod By';
		raiserror(@msg, 16, 1) ;
		return
	end
    
	IF EXISTS (SELECT 1 FROM dbo.PROCUREMENT WHERE CODE = @p_procurment_no AND STATUS <> 'HOLD')
	BEGIN
		SET @msg = 'STATUS PROCURMENT HARUS KONDISI HOLD';
		raiserror(@msg, 16, -1) ;
		return
	END
	ELSE
	begin	
		SELECT 'BEFORE',STATUS,* FROM IFINPROC.dbo.PROCUREMENT_REQUEST WHERE CODE = @procurment_request_no
		SELECT 'BEFORE',STATUS,* FROM IFINPROC.dbo.PROCUREMENT WHERE CODE = @p_procurment_no
		
		
		UPDATE IFINPROC.dbo.PROCUREMENT_REQUEST
		SET STATUS = 'CANCEL'
			,MOD_DATE = @mod_date
			,MOD_BY = @p_mod_by
			,MOD_IP_ADDRESS = @p_mod_by
		WHERE CODE = @procurment_request_no
		
		UPDATE IFINPROC.dbo.PROCUREMENT
		SET STATUS = 'CANCEL'
			,MOD_DATE = @mod_date
			,MOD_BY = @p_mod_by
			,MOD_IP_ADDRESS = @p_mod_by
		WHERE CODE  = @p_procurment_no
		
		SELECT 'AFTER',STATUS,* FROM IFINPROC.dbo.PROCUREMENT_REQUEST WHERE CODE = @procurment_request_no
		SELECT 'AFTER',STATUS,* FROM IFINPROC.dbo.PROCUREMENT WHERE CODE = @p_procurment_no

		INSERT INTO IFINOPL.dbo.MTN_DATA_DSF_LOG
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
				'MTN NON MOBILISASI'
				,@p_mtn_remark
				,'PROCUREMENT'
				,@application_no
				,@asset_no -- REFF_2 - nvarchar(50)
				,@p_procurment_no -- REFF_3 - nvarchar(50)
				,getdate()
				,@p_mod_by
			)

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

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[xsp_mtn_non_mobilisasi] TO [DSF\eddy.rakhman]
    AS [dbo];

