CREATE PROCEDURE [dbo].[xsp_invoice_delivery_detail_delete]
(
	@p_id		BIGINT
)
AS
BEGIN
	DECLARE @msg NVARCHAR(MAX) 
			,@register_code NVARCHAR(50)
			,@delivery_code NVARCHAR(50);

	BEGIN TRY
		SELECT @delivery_code = DELIVERY_CODE
		FROM dbo.invoice_delivery_detail 
		WHERE id = @p_id


		-- update data supaya data deliver = null supaya balik ke tabel invoice
		update	dbo.invoice
		set		deliver_code	= null
		where	invoice_no		=
			(
				select	invoice_no
				from	dbo.invoice_delivery_detail
				where	id  = @p_id
			)

		-- hapus semua data yg ada di delivery detail
		delete	invoice_delivery_detail
		where	id = @p_id

		IF NOT EXISTS (SELECT 1 FROM dbo.invoice_delivery_detail WHERE DELIVERY_CODE = @delivery_code)
		BEGIN
		    UPDATE dbo.invoice_delivery SET STATUS = 'CANCEL' WHERE CODE = @delivery_code
		END

	end try 
	begin catch
		declare @error int ;

		set @error = @@error ;

		if (@error = 2627)
		begin
			set @msg = dbo.xfn_get_msg_err_code_already_exist() ;
		end ;
		else if (@error = 547)
		begin
			set @msg = dbo.xfn_get_msg_err_code_already_used() ;
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
end
