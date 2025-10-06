--created by, Rian at 25/07/2023 

CREATE PROCEDURE dbo.xsp_validation_for_asset_mobilization
(
	@p_is_reimburse		nvarchar(1) = '0'
	,@p_fa_code			nvarchar(50) = ''
)
as
begin
	declare	@msg	nvarchar(max)

	begin try
		if (@p_is_reimburse = '1')
		begin
			if exists
			(
				select	1
				from	dbo.asset
				where	code						 = @p_fa_code
						and isnull(agreement_no, '') = ''
			)
			begin
				set @msg = 'Asset Cannot Used For Reimburse To Customer.'
				raiserror	(@msg, 16, -1)
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
end
