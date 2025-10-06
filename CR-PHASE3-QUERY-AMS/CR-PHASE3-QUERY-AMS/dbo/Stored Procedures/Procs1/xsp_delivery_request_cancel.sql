CREATE PROCEDURE [dbo].[xsp_delivery_request_cancel]
(
	@p_code_list			NVARCHAR(MAX) = '',
	@p_code					NVARCHAR(50),
	@p_cre_date				DATETIME,
	@p_cre_by				NVARCHAR(15),
	@p_cre_ip_address		NVARCHAR(15),
	@p_mod_date				DATETIME,
	@p_mod_by				NVARCHAR(15),
	@p_mod_ip_address		NVARCHAR(15)
)
AS
BEGIN
	--SELECT @register_code = rdd.register_code
	--FROM dbo.REGISTER_DELIVERY_DETAIL rdd
	--WHERE rdd.DELIVERY_CODE = @p_code

	BEGIN TRY
		UPDATE dbo.REGISTER_DELIVERY
		SET STATUS = 'CANCEL'
			,REMARK = 'CANCEL PENGIRIMAN'
			,MOD_DATE = @p_mod_date
			,MOD_BY = @p_mod_by
			,MOD_IP_ADDRESS = @p_mod_ip_address
		WHERE CODE = @p_code;

		DECLARE @tbl_code TABLE (code NVARCHAR(50));
		INSERT INTO @tbl_code (code)
		SELECT value FROM dbo.fnSplitString(@p_code_list, ',');

		UPDATE dbo.REGISTER_MAIN
		SET DELIVERY_STATUS = 'CANCEL',
			MOD_DATE = @p_mod_date,
			MOD_BY = @p_mod_by,
			MOD_IP_ADDRESS = @p_mod_ip_address
		WHERE CODE IN (SELECT code COLLATE SQL_Latin1_General_CP1_CI_AS FROM @tbl_code);

	END TRY
	BEGIN CATCH
		DECLARE @msg NVARCHAR(MAX);
		SET @msg = ERROR_MESSAGE();
		RAISERROR(@msg, 16, 1);
	END CATCH
END;
