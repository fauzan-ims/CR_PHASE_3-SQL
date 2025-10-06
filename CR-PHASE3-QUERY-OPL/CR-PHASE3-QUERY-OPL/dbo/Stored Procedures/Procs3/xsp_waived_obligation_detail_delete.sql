CREATE PROCEDURE [dbo].[xsp_waived_obligation_detail_delete]
(
	@p_id bigint
)
as
BEGIN

	declare @msg							nvarchar(max) 
			,@obligation_amount				decimal(18,2)
			,@waived_amount					decimal(18,2)
			,@waived_obligation_code		nvarchar(50)
			,@invoice_no					NVARCHAR(50);

	begin TRY
		
		select	@waived_obligation_code = waived_obligation_code 
				,@invoice_no			= invoice_no
		from	dbo.waived_obligation_detail 
		where	id = @p_id

		delete waived_obligation_detail
		where	id = @p_id ;


		--raffy 2025/08/11 cr fase 3
		update dbo.agreement_asset_late_return
		set		waive_no		= NULL
				,waive_amount	= 0
		where	asset_no		= @invoice_no

		select	@obligation_amount = sum(isnull(obligation_amount,0)) 
				,@waived_amount		= sum(isnull(waived_amount,0))
		from	waived_obligation_detail
		where	waived_obligation_code = @waived_obligation_code


		update	waived_obligation
		set		obligation_amount	= isnull(@obligation_amount,0)
				,waived_amount		= isnull(@waived_amount,0)  
		where	code = @waived_obligation_code
		

	end try
	begin catch
		if (LEN(@msg) <> 0)  
		begin
			set @msg = 'V' + ';' + @msg;
		end
        else
		begin
			set @msg = 'E;' + dbo.xfn_get_msg_err_generic() + ';' + ERROR_MESSAGE();
		end;

		raiserror(@msg, 16, -1) ;
		return ;  
	end catch;
end ;

