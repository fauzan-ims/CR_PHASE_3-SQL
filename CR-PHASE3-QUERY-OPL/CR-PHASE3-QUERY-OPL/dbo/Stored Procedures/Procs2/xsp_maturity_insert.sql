--created by, Rian at 03/03/2023 

CREATE procedure [dbo].[xsp_maturity_insert]
(
	@p_code				   nvarchar(50)
	,@p_branch_code		   nvarchar(50)
	,@p_branch_name		   nvarchar(250)
	,@p_agreement_no	   nvarchar(50)
	,@p_date			   datetime
	,@p_status			   nvarchar(10)
	,@p_result			   nvarchar(10)
	,@p_additional_periode int
	,@p_pickup_date		   datetime
	,@p_file_name		   nvarchar(250)
	,@p_file_path		   nvarchar(250)
	,@p_remark			   nvarchar(4000)
	,@p_new_billing_type   nvarchar(50)
	--
	,@p_cre_date		   datetime
	,@p_cre_by			   nvarchar(15)
	,@p_cre_ip_address	   nvarchar(15)
	,@p_mod_date		   datetime
	,@p_mod_by			   nvarchar(15)
	,@p_mod_ip_address	   nvarchar(15)
)
as
begin
	declare @msg			nvarchar(max)
			,@maturity_date datetime ;

	begin try
		select	@maturity_date = maturity_date
		from	dbo.agreement_information
		where	agreement_no = @p_agreement_no ;

		insert into dbo.maturity
		(
			code
			,branch_code
			,branch_name
			,agreement_no
			,date
			,status
			,result
			,additional_periode
			,pickup_date
			,file_name
			,file_paths
			,remark
			,new_billing_type
			,maturity_date
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
			@p_code
			,@p_branch_code
			,@p_branch_name
			,@p_agreement_no
			,@p_date
			,@p_status
			,@p_result
			,@p_additional_periode
			,@p_pickup_date
			,@p_file_name
			,@p_file_path
			,@p_remark
			,@p_new_billing_type
			,@maturity_date
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
