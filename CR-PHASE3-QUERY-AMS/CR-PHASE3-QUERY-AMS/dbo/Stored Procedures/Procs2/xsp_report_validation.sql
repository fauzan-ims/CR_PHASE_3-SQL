CREATE PROCEDURE [dbo].[xsp_report_validation]
(
	@p_code				nvarchar(50)
)
AS
BEGIN

	DECLARE @msg	NVARCHAR(max)
			,@spk_no	NVARCHAR(50);
	BEGIN try

		SELECT		@spk_no = spk_no
		FROM		dbo.MAINTENANCE m
		INNER JOIN	dbo.WORK_ORDER wo ON wo.MAINTENANCE_CODE = m.CODE
		WHERE		wo.CODE = @p_code

		--validasi untuk SPK No
		IF  (ISNULL(@spk_no, '') = '')
		begin
			set	@msg = 'Print Surat Perintah Kerja First.'
			raiserror(@msg, 16, -1) ;
		END
	END TRY
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
END
