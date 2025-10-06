-- Louis Kamis, 04 April 2024 16.42.31 --
CREATE PROCEDURE [dbo].[xsp_master_other_budget_insert]
( 
	@p_code						nvarchar(50)	= '' output
	,@p_description				nvarchar(4000)
	,@p_class_code				nvarchar(50)
	,@p_class_description		nvarchar(4000)
	,@p_is_subject_to_purchase  nvarchar(1)
	,@p_is_active				nvarchar(1)
	--
	,@p_cre_date				datetime
	,@p_cre_by					nvarchar(15)
	,@p_cre_ip_address			nvarchar(15)
	,@p_mod_date				datetime
	,@p_mod_by					nvarchar(15)
	,@p_mod_ip_address			nvarchar(15)
)
as
begin
	declare @msg			 nvarchar(max)
			,@year			 nvarchar(2)
			,@month			 nvarchar(2)
			,@code			 nvarchar(50) 
			,@value_exp_date nvarchar(50)

	begin try
		set @year = substring(cast(datepart(year, @p_cre_date) as nvarchar), 3, 2) ;
		set @month = replace(str(cast(datepart(month, @p_cre_date) as nvarchar), 2, 0), ' ', '0') ;

		exec dbo.xsp_get_next_unique_code_for_table @p_unique_code = @code output
													,@p_branch_code = ''
													,@p_sys_document_code = N''
													,@p_custom_prefix = 'OPLMOB'
													,@p_year = @year
													,@p_month = @month
													,@p_table_name = 'MASTER_OTHER_BUDGET'
													,@p_run_number_length = 6
													,@p_delimiter = '.'
													,@p_run_number_only = N'0' ;

		--mengkondisikan is active
		if @p_is_active = 'T'
			set @p_is_active = '1' ;
		else
			set @p_is_active = '0' ;

		if @p_is_subject_to_purchase = 'T'
			set @p_is_subject_to_purchase = '1' ;
		else
			set @p_is_subject_to_purchase = '0' ;

		if exists
		(
			select	1
			from	dbo.master_other_budget
			where	class_code = @p_class_code
					and description   = @p_description
		)
		begin
			set @msg = 'Class already exist' ;

			raiserror(@msg, 16, -1) ;
		end ;
		
		select	@value_exp_date = value
		from	dbo.sys_global_param
		where	code = 'EXPDATE' 

		--insert ke tabel master budget
		insert into dbo.master_other_budget
		(
			code
			,description
			,class_code
			,class_description
			,exp_date
			,is_subject_to_purchase
			,is_active
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
			@code						
			,@p_description				
			,@p_class_code				
			,@p_class_description		
			,dateadd(month, convert (int, @value_exp_date), dbo.xfn_get_system_date())				
			,@p_is_subject_to_purchase  
			,@p_is_active				
			--
			,@p_cre_date				
			,@p_cre_by					
			,@p_cre_ip_address			
			,@p_mod_date				
			,@p_mod_by					
			,@p_mod_ip_address			
		) ;

		set @p_code = @code ;
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
