--create table MTN_APPLICATION_RENTAL
--(
--	APPLICATION_NO		   nvarchar(50)
--	,LEASED_ROUNDED_AMOUNT decimal(18, 2)
--	,MAIN_CONTRACT_NO	   nvarchar(50)
--) ;

--create table MTN_REALIZATION_CONTRACT
--(
--	REALIZATION_NO nvarchar(50)
--	,AGREEMENT_NO  nvarchar(50)
--) ;
--go


/*

exec dbo.xsp_mtn_application_rental @p_application_no	= @p_application_no
								,@p_mod_date		= @p_mod_date
								,@p_mod_by			= @p_mod_by
								,@p_mod_ip_address	= @p_mod_ip_address
*/
-- Louis Jumat, 10 November 2023 20.20.06 --
CREATE PROCEDURE dbo.xsp_mtn_application_rental
(
	@p_application_no  nvarchar(50)
	--
	,@p_mod_date	   datetime
	,@p_mod_by		   nvarchar(15)
	,@p_mod_ip_address nvarchar(15)
)
as
begin
	declare @msg					nvarchar(max)
			,@rv_pct				decimal(9, 6)
			,@rv_amount				decimal(18, 2)
			,@leased_rounded_amount decimal(18, 2)
			,@main_contract_no		nvarchar(50) ;

	begin try
		--SELECT BASIC_LEASE_AMOUNT, LEASE_ROUNDED_AMOUNT, MONTHLY_RENTAL_ROUNDED_AMOUNT, ASSET_RV_AMOUNT,* FROM dbo.APPLICATION_ASSET WHERE APPLICATION_NO = REPLACE('0005820/4/08/07/2025','/','.')
		--if (@p_application_no = '0000605.4.01.01.2024')
		if (@p_application_no = '0005820.4.08.07.2025')
		begin  
			update	dbo.application_asset
			set		basic_lease_amount		= 4915174.14
					,lease_rounded_amount	= 4915000.00
					,MONTHLY_RENTAL_ROUNDED_AMOUNT = 4915000.00
					,ASSET_RV_AMOUNT		= 219165041.55
					,mod_date				= @p_mod_date
					,mod_by					= @p_mod_by
					,mod_ip_address			= @p_mod_ip_address
			where	application_no			= @p_application_no ;
		end ;
		
		if exists
		(
			select	1
			from	dbo.mtn_application_rental
			where	application_no = @p_application_no
		)
		begin
			select	@leased_rounded_amount = leased_rounded_amount
					,@rv_pct			   = rv_pct
					,@rv_amount			   = rv_amount
			from	dbo.mtn_application_rental
			where	application_no = @p_application_no ;

			update	dbo.application_asset
			set		basic_lease_amount		= @leased_rounded_amount
					,lease_rounded_amount	= @leased_rounded_amount
					--,asset_rv_pct			= @rv_pct	
					--,asset_rv_amount		= @rv_amount
					,mod_date				= @p_mod_date
					,mod_by					= @p_mod_by
					,mod_ip_address			= @p_mod_ip_address
			where	application_no			= @p_application_no ;
		end ;
	end try
	begin catch
		if (len(@msg) <> 0)
		begin
			set @msg = N'V' + N';' + @msg ;
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
				set @msg = N'E;' + dbo.xfn_get_msg_err_generic() + N';' + error_message() ;
			end ;
		end ;

		raiserror(@msg, 16, -1) ;

		return ;
	end catch ;
end ;
