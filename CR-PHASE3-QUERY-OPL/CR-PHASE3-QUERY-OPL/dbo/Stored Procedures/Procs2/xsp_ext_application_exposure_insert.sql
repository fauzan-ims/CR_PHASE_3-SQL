
CREATE PROCEDURE dbo.xsp_ext_application_exposure_insert
(
	@p_application_no		nvarchar(50)
	,@p_AgrmntNo			nvarchar(50)   = null
	,@p_AppNo				nvarchar(50)   = null
	,@p_CustName			nvarchar(250)  = null
	,@p_ProductOfferingName nvarchar(250)  = null
	,@p_NTFAmount			decimal(18, 2) = 0
	,@p_OsPrincipalAmt		decimal(18, 2) = 0
	,@p_InstallmentAmt		decimal(18, 2) = 0
	,@p_Tenor				nvarchar(250)  = null
	,@p_OverdueDays			int			   = 0
	,@p_MaxOverdueDays		int			   = 0
	,@p_AgreementDate		datetime	   = null
	,@p_NextInstNum			int			   = null
	,@p_OverdueAmt			decimal(18, 2) = 0
	,@p_IsGroup				nvarchar(10)   = 'false'
	,@p_Status				nvarchar(250)  = ''
	--																	
	,@p_cre_date			datetime
	,@p_cre_by				nvarchar(15)
	,@p_cre_ip_address		nvarchar(15)
	,@p_mod_date			datetime
	,@p_mod_by				nvarchar(15)
	,@p_mod_ip_address		nvarchar(15)
--
)
as
begin
	declare @msg		  nvarchar(max)
			,@description nvarchar(4000)
			,@client_no	  nvarchar(50) ;

	begin try
		if (isnull(@p_AgrmntNo, '') <> '')
		begin
			set @description = N'AGREEMENT'+ ' - ' + upper(@p_Status)  ;
		end ;
		else
		begin
			set @description = N'APPLICATION'+ ' - ' + upper(@p_Status) ;
			set @p_OsPrincipalAmt = @p_NTFAmount ;
		end ;
		 
		insert into dbo.application_exposure
		(
			application_no
			,relation_type
			,agreement_no
			,agreement_date
			,facility_name
			,amount_finance_amount
			,os_installment_amount
			,installment_amount
			,tenor
			,os_tenor
			,last_due_date
			,ovd_days
			,max_ovd_days
			,ovd_installment_amount
			,description
			,group_name
			--
			,cre_date
			,cre_by
			,cre_ip_address
			,mod_date
			,mod_by
			,mod_ip_address
		)
		values
		(
			@p_application_no
			,''
			,isnull(@p_AgrmntNo, @p_AppNo)
			,isnull(@p_AgreementDate, getdate())
			,@p_ProductOfferingName
			,isnull(@p_NTFAmount, 0)
			,isnull(@p_OsPrincipalAmt, 0)
			,isnull(@p_InstallmentAmt, 0)
			,@p_Tenor
			,@p_NextInstNum
			,''
			,@p_OverdueDays
			,@p_MaxOverdueDays
			,@p_OverdueAmt
			,@description 
			,@p_CustName
			--,case @p_IsGroup
			--	 when 'true' then @p_CustName
			--	 else ''
			-- end
			--
			,@p_cre_date
			,@p_cre_by
			,@p_cre_ip_address
			,@p_mod_date
			,@p_mod_by
			,@p_mod_ip_address
		) ;
		 
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
