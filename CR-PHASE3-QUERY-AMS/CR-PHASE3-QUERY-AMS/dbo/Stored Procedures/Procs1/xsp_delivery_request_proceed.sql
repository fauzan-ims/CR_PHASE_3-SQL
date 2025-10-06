CREATE PROCEDURE [dbo].[xsp_delivery_request_proceed]
(
	@p_code_list			NVARCHAR(MAX), 
	@p_cre_date				DATETIME,
	@p_cre_by				NVARCHAR(15),
	@p_cre_ip_address		NVARCHAR(15),
	@p_mod_date				DATETIME,
	@p_mod_by				NVARCHAR(15),
	@p_mod_ip_address		NVARCHAR(15)
)
AS
BEGIN
	BEGIN TRY
		DECLARE @tbl_code TABLE (code NVARCHAR(50));
		INSERT INTO @tbl_code (code)
		SELECT value FROM dbo.fnSplitString(@p_code_list, ',');

		IF NOT EXISTS (
			SELECT 1 FROM @tbl_code
		)
		BEGIN
			RAISERROR('Tidak ada transaksi yang dipilih.', 16, 1);
		END

		-- Ambil 1 baris saja untuk referensi header
		DECLARE @first_code NVARCHAR(50) = (SELECT TOP 1 code FROM @tbl_code);
		DECLARE @branch_code NVARCHAR(50), @branch_name NVARCHAR(250);
		SELECT @branch_code = branch_code, @branch_name = branch_name
		FROM dbo.REGISTER_MAIN
		WHERE code = @first_code;

		-- Insert register_delivery dan ambil delivery_code
		DECLARE @delivery_code NVARCHAR(50);
		EXEC dbo.xsp_register_delivery_insert
			@p_code = @delivery_code OUTPUT,
			@p_branch_code = @branch_code,
			@p_branch_name = @branch_name,
			@p_status = 'HOLD',
			@p_delivery_date = NULL,
			@p_deliver_by = N'',
			@p_delivery_to_name = N'',
			@p_delivery_to_area_no = N'',
			@p_delivery_to_phone_no = N'',
			@p_delivery_to_address = N'',
			@p_remark = 'Proses Pengiriman',
			@p_result = N'',
			@p_received_date = NULL,
			@p_received_by = N'',
			@p_resi_no = N'',
			@p_reject_date = NULL,
			@p_reason_code = N'',
			@p_reason_desc = N'',
			@p_cre_date = @p_cre_date,
			@p_cre_by = @p_cre_by,
			@p_cre_ip_address = @p_cre_ip_address,
			@p_mod_date = @p_mod_date,
			@p_mod_by = @p_mod_by,
			@p_mod_ip_address = @p_mod_ip_address;

		-- Insert detail untuk setiap register_code
		DECLARE @p_id BIGINT;
		DECLARE @code NVARCHAR(50);

		DECLARE cur CURSOR FOR SELECT code FROM @tbl_code;
		OPEN cur;
		FETCH NEXT FROM cur INTO @code;

		WHILE @@FETCH_STATUS = 0
		BEGIN
			EXEC dbo.xsp_register_delivery_detail_insert
				@p_id = @p_id OUTPUT,
				@p_delivery_code = @delivery_code,
				@p_register_code = @code,
				@p_cre_date = @p_cre_date,
				@p_cre_by = @p_cre_by,
				@p_cre_ip_address = @p_cre_ip_address,
				@p_mod_date = @p_mod_date,
				@p_mod_by = @p_mod_by,
				@p_mod_ip_address = @p_mod_ip_address;

			UPDATE dbo.REGISTER_MAIN
			SET DELIVERY_STATUS = 'HOLD'
			WHERE CODE = @code

			FETCH NEXT FROM cur INTO @code;
		END
		CLOSE cur;
		DEALLOCATE cur;
	END TRY
	BEGIN CATCH
		DECLARE @msg NVARCHAR(MAX);
		SET @msg = ERROR_MESSAGE();
		RAISERROR(@msg, 16, 1);
	END CATCH
END;
