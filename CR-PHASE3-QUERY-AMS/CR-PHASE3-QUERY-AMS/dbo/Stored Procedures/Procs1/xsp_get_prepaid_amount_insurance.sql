create PROCEDURE [dbo].[xsp_get_prepaid_amount_insurance]
(
	@p_prepaid_no	nvarchar(50)
)
as
begin
	declare @msg			nvarchar(max)
	
	begin try
		select prepaid_amount 
		from dbo.asset_prepaid_schedule aps
		inner join dbo.asset_prepaid_main apm on (apm.prepaid_no = aps.prepaid_no)
		where aps.prepaid_no = @p_prepaid_no
		and convert(varchar(30), aps.prepaid_date, 103) = convert(varchar(30), eomonth(dbo.xfn_get_system_date()), 103)
		and apm.prepaid_remark = 'PREPAID INSURANCE'

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
