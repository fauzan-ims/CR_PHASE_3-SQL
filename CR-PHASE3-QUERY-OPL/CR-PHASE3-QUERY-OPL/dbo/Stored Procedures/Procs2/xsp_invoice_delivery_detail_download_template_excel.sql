--created by, Rian at 12/04/2023 

CREATE procedure dbo.xsp_invoice_delivery_detail_download_template_excel
(
	@p_code nvarchar(50)
)
as
begin
	declare @msg nvarchar(max) ;

	begin try
		select	id
				,invoice_no
				,delivery_status
				,delivery_date
				,delivery_remark
				,receiver_name
		from	dbo.invoice_delivery_detail
		where	delivery_code = @p_code ;
	end try
	begin catch
		set @msg = error_message() ;

		raiserror(@msg, 16, -1) ;

		return @msg ;
	end catch ;
end ;
