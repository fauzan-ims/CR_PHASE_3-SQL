CREATE PROCEDURE dbo.xsp_reverse_disposal_history_insert
(
	@p_code						nvarchar(50)
	,@p_company_code			nvarchar(50)
	,@p_disposal_code			nvarchar(50)
	,@p_disposal_date			datetime
	,@p_reverse_disposal_date	datetime
	,@p_branch_code				nvarchar(50)
	,@p_branch_name				nvarchar(250)
	,@p_location_code			nvarchar(50)
	,@p_location_name			nvarchar(250)
	,@p_description				nvarchar(4000)
	,@p_reason_type				nvarchar(50)
	,@p_remarks					nvarchar(4000)
	,@p_status					nvarchar(25)
	,@p_cre_by					nvarchar(15)
	,@p_cre_ip_address			nvarchar(15)
	,@p_mod_date				datetime
	,@p_mod_by					nvarchar(15)
	,@p_mod_ip_address			nvarchar(15)
)
as
begin
	declare @msg nvarchar(max) ;

	begin try
		insert into reverse_disposal_history
		(
			code
			,company_code
			,disposal_code
			,disposal_date
			,reverse_disposal_date
			,branch_code
			,branch_name
			,location_code
			,location_name
			,description
			,reason_type
			,remarks
			,status
			,cre_by
			,cre_ip_address
			,mod_date
			,mod_by
			,mod_ip_address
		)
		values
		(
			@p_code
			,@p_company_code
			,@p_disposal_code
			,@p_disposal_date
			,@p_reverse_disposal_date
			,@p_branch_code
			,@p_branch_name
			,@p_location_code
			,@p_location_name
			,@p_description
			,@p_reason_type
			,@p_remarks
			,@p_status
			,@p_cre_by
			,@p_cre_ip_address
			,@p_mod_date
			,@p_mod_by
			,@p_mod_ip_address
		)

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
