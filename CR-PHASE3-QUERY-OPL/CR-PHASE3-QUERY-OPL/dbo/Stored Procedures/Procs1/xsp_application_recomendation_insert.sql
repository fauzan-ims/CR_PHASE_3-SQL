CREATE PROCEDURE dbo.xsp_application_recomendation_insert
(
	@p_id					   bigint = 0 output
	,@p_application_no		   nvarchar(50)
	,@p_recomendation_result   nvarchar(20)
	,@p_recomendation_date	   datetime
	,@p_employee_code		   nvarchar(50)
	,@p_employee_name		   nvarchar(250)
	,@p_level_status		   nvarchar(20)
	,@p_remarks				   nvarchar(4000)
	--
	,@p_cre_date			   datetime
	,@p_cre_by				   nvarchar(15)
	,@p_cre_ip_address		   nvarchar(15)
	,@p_mod_date			   datetime
	,@p_mod_by				   nvarchar(15)
	,@p_mod_ip_address		   nvarchar(15)
)
as
begin
	declare @msg		nvarchar(max)
			,@log_cycle int ;

	begin try
		select	@log_cycle = return_count + 1
		from	dbo.application_main
		where	application_no = @p_application_no ;

		insert into application_recomendation
		(
			application_no
			,recomendation_result
			,recomendation_date
			,employee_code
			,employee_name
			,level_status
			,remarks
			,cycle
			--
			,cre_date
			,cre_by
			,cre_ip_address
			,mod_date
			,mod_by
			,mod_ip_address
		)
		values
		(	@p_application_no
			,isnull(@p_recomendation_result, '')
			,@p_recomendation_date
			,@p_employee_code
			,@p_employee_name
			,@p_level_status
			,@p_remarks
			,@log_cycle
			--
			,@p_cre_date
			,@p_cre_by
			,@p_cre_ip_address
			,@p_mod_date
			,@p_mod_by
			,@p_mod_ip_address
		) ;

		set @p_id = @@identity ;
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

