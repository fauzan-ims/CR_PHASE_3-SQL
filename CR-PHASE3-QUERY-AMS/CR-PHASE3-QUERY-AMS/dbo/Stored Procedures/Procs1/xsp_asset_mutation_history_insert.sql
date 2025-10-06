CREATE PROCEDURE dbo.xsp_asset_mutation_history_insert
(
	@p_id						 bigint = 0 output
	,@p_asset_code				 nvarchar(50)
	,@p_date					 datetime
	,@p_document_refference_no	 nvarchar(50)
	,@p_document_refference_type nvarchar(10)
	,@p_usage_duration			 int
	,@p_from_branch_code		 nvarchar(50)
	,@p_from_branch_name		 nvarchar(250)
	,@p_to_branch_code			 nvarchar(50)
	,@p_to_branch_name			 nvarchar(250)
	,@p_from_location_code		 nvarchar(50)
	,@p_to_location_code		 nvarchar(50)
	,@p_from_pic_code			 nvarchar(50)
	,@p_to_pic_code				 nvarchar(50)
	,@p_from_division_code		 nvarchar(50)
	,@p_from_division_name		 nvarchar(250)
	,@p_to_division_code		 nvarchar(50)
	,@p_to_division_name		 nvarchar(250)
	,@p_from_department_code	 nvarchar(50)
	,@p_from_department_name	 nvarchar(250)
	,@p_to_department_code		 nvarchar(50)
	,@p_to_department_name		 nvarchar(250)
	,@p_from_sub_department_code nvarchar(50)
	,@p_from_sub_department_name nvarchar(250)
	,@p_to_sub_department_code	 nvarchar(50)
	,@p_to_sub_department_name	 nvarchar(250)
	,@p_from_unit_code			 nvarchar(50)
	,@p_from_unit_name			 nvarchar(250)
	,@p_to_unit_code			 nvarchar(50)
	,@p_to_unit_name			 nvarchar(250)
	--
	,@p_cre_date				 datetime
	,@p_cre_by					 nvarchar(15)
	,@p_cre_ip_address			 nvarchar(15)
	,@p_mod_date				 datetime
	,@p_mod_by					 nvarchar(15)
	,@p_mod_ip_address			 nvarchar(15)
)
as
begin
	declare @msg nvarchar(max) ;

	begin try
		insert into asset_mutation_history
		(
			asset_code
			,date
			,document_refference_no
			,document_refference_type
			,usage_duration
			,from_branch_code
			,from_branch_name
			,to_branch_code
			,to_branch_name
			,from_location_code
			,to_location_code
			,from_pic_code
			,to_pic_code
			,from_division_code
			,from_division_name
			,to_division_code
			,to_division_name
			,from_department_code
			,from_department_name
			,to_department_code
			,to_department_name
			,from_sub_department_code
			,from_sub_department_name
			,to_sub_department_code
			,to_sub_department_name
			,from_unit_code
			,from_unit_name
			,to_unit_code
			,to_unit_name
			--
			,cre_date
			,cre_by
			,cre_ip_address
			,mod_date
			,mod_by
			,mod_ip_address
		)
		values
		(	@p_asset_code
			,@p_date
			,@p_document_refference_no
			,@p_document_refference_type
			,@p_usage_duration
			,@p_from_branch_code
			,@p_from_branch_name
			,@p_to_branch_code
			,@p_to_branch_name
			,@p_from_location_code
			,@p_to_location_code
			,@p_from_pic_code
			,@p_to_pic_code
			,@p_from_division_code
			,@p_from_division_name
			,@p_to_division_code
			,@p_to_division_name
			,@p_from_department_code
			,@p_from_department_name
			,@p_to_department_code
			,@p_to_department_name
			,@p_from_sub_department_code
			,@p_from_sub_department_name
			,@p_to_sub_department_code
			,@p_to_sub_department_name
			,@p_from_unit_code
			,@p_from_unit_name
			,@p_to_unit_code
			,@p_to_unit_name
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
	Begin catch
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
