CREATE PROCEDURE dbo.xsp_application_fee_cancel_peyment_request
(
	@p_application_no				nvarchar(50)
)
as
begin
	declare @msg						nvarchar(max)
			,@agreement_no				nvarchar(50)
			,@fee_name					nvarchar(250);

	begin try
		
			select	@agreement_no = agreement_no 
			from	dbo.application_main
			where	application_no = @p_application_no

			declare cursor_application_fee cursor local fast_forward for
		
			select	mf.description
			from	dbo.application_fee af
					inner join dbo.master_fee mf on (mf.code = af.fee_code)
			where	application_no = @p_application_no
					and af.fee_amount > 0

			open cursor_application_fee
			fetch next from cursor_application_fee  
			into	@fee_name			

			while @@fetch_status = 0
			begin
				if exists (select 1 from dbo.opl_interface_cashier_received_request where agreement_no = @agreement_no and request_status = 'PAID')
				begin
					close cursor_application_fee
					deallocate cursor_application_fee

					set @msg = @fee_name + ' fee has been paid, please reverse befor proceed'
				    raiserror(@msg, 16,1) ;
				end
				
				fetch next from cursor_application_fee  
				into	@fee_name		
			end

			close cursor_application_fee
			deallocate cursor_application_fee
			 
	end try
	begin catch
		set @msg =  error_message() ;

		raiserror(@msg, 16, -1) ;

		return @msg ;
	 end catch ;
end

