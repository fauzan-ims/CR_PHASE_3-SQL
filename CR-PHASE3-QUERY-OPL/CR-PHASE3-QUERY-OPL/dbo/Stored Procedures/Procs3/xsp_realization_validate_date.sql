CREATE PROCEDURE [dbo].[xsp_realization_validate_date]
(
	@p_agreement_no		   nvarchar(50)	= ''
	,@p_handover_date		datetime
)
as
begin
	declare @msg				nvarchar(max) 
			,@agreement_date	datetime;
			
	begin try
		--select	@agreement_date = agreement_date
		--from	dbo.realization rlz
		--		inner join dbo.realization_detail rdl on (rdl.realization_code = rlz.code)
		--where	rdl.asset_no = @p_reff_no ;
		select	@agreement_date = ama.agreement_date
		from	dbo.agreement_main ama
		where	ama.agreement_no = @p_agreement_no or ama.agreement_external_no = @p_agreement_no;

		if (isnull(@p_agreement_no, '') <> '')
		begin
			if @p_handover_date < @agreement_date
			begin
				set @msg = 'Handover date must be equal or greater than agreement date';
				raiserror(@msg, 16, -1) ;
			end   
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
end ;



