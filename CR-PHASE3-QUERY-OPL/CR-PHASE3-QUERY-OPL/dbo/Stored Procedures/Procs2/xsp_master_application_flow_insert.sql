CREATE PROCEDURE dbo.xsp_master_application_flow_insert
(
	@p_code				  nvarchar(50) output
	,@p_description		  nvarchar(250)
	,@p_flow_type		  nvarchar(15)
	,@p_is_active		  nvarchar(1)
	,@p_dim_count		  int
	,@p_dim_1			  nvarchar(50) = null
	,@p_operator_1		  nvarchar(50) = null
	,@p_dim_value_from_1  nvarchar(50) = null
	,@p_dim_value_to_1	  nvarchar(50) = null
	,@p_dim_2			  nvarchar(50) = null
	,@p_operator_2		  nvarchar(50) = null
	,@p_dim_value_from_2  nvarchar(50) = null
	,@p_dim_value_to_2	  nvarchar(50) = null
	,@p_dim_3			  nvarchar(50) = null
	,@p_operator_3		  nvarchar(50) = null
	,@p_dim_value_from_3  nvarchar(50) = null
	,@p_dim_value_to_3	  nvarchar(50) = null
	,@p_dim_4			  nvarchar(50) = null
	,@p_operator_4		  nvarchar(50) = null
	,@p_dim_value_from_4  nvarchar(50) = null
	,@p_dim_value_to_4	  nvarchar(50) = null
	,@p_dim_5			  nvarchar(50) = null
	,@p_operator_5		  nvarchar(50) = null
	,@p_dim_value_from_5  nvarchar(50) = null
	,@p_dim_value_to_5	  nvarchar(50) = null
	,@p_dim_6			  nvarchar(50) = null
	,@p_operator_6		  nvarchar(50) = null
	,@p_dim_value_from_6  nvarchar(50) = null
	,@p_dim_value_to_6	  nvarchar(50) = null
	,@p_dim_7			  nvarchar(50) = null
	,@p_operator_7		  nvarchar(50) = null
	,@p_dim_value_from_7  nvarchar(50) = null
	,@p_dim_value_to_7	  nvarchar(50) = null
	,@p_dim_8			  nvarchar(50) = null
	,@p_operator_8		  nvarchar(50) = null
	,@p_dim_value_from_8  nvarchar(50) = null
	,@p_dim_value_to_8	  nvarchar(50) = null
	,@p_dim_9			  nvarchar(50) = null
	,@p_operator_9		  nvarchar(50) = null
	,@p_dim_value_from_9  nvarchar(50) = null
	,@p_dim_value_to_9	  nvarchar(50) = null
	,@p_dim_10			  nvarchar(50) = null
	,@p_operator_10		  nvarchar(50) = null
	,@p_dim_value_from_10 nvarchar(50) = null
	,@p_dim_value_to_10	  nvarchar(50) = null
	--									 
	,@p_cre_date		  datetime
	,@p_cre_by			  nvarchar(15)
	,@p_cre_ip_address	  nvarchar(15)
	,@p_mod_date		  datetime
	,@p_mod_by			  nvarchar(15)
	,@p_mod_ip_address	  nvarchar(15)
)
as
begin
	declare @msg	nvarchar(max)
			,@year	nvarchar(2)
			,@month nvarchar(2) ;

	set @year = substring(cast(datepart(year, @p_cre_date) as nvarchar), 3, 2) ;
	set @month = replace(str(cast(datepart(month, @p_cre_date) as nvarchar), 2, 0), ' ', '0') ;

	exec dbo.xsp_get_next_unique_code_for_table @p_unique_code = @p_code output
												,@p_branch_code = N''
												,@p_sys_document_code = N''
												,@p_custom_prefix = 'MAF'
												,@p_year = @year
												,@p_month = @month
												,@p_table_name = 'MASTER_APPLICATION_FLOW'
												,@p_run_number_length = 6
												,@p_delimiter = '.'
												,@p_run_number_only = N'0' ;

	if @p_is_active = 'T'
		set @p_is_active = '1' ;
	else
		set @p_is_active = '0' ;

	begin try
		insert into master_application_flow
		(
			code
			,description
			,flow_type
			,is_active
			,dim_count
			,dim_1
			,operator_1
			,dim_value_from_1
			,dim_value_to_1
			,dim_2
			,operator_2
			,dim_value_from_2
			,dim_value_to_2
			,dim_3
			,operator_3
			,dim_value_from_3
			,dim_value_to_3
			,dim_4
			,operator_4
			,dim_value_from_4
			,dim_value_to_4
			,dim_5
			,operator_5
			,dim_value_from_5
			,dim_value_to_5
			,dim_6
			,operator_6
			,dim_value_from_6
			,dim_value_to_6
			,dim_7
			,operator_7
			,dim_value_from_7
			,dim_value_to_7
			,dim_8
			,operator_8
			,dim_value_from_8
			,dim_value_to_8
			,dim_9
			,operator_9
			,dim_value_from_9
			,dim_value_to_9
			,dim_10
			,operator_10
			,dim_value_from_10
			,dim_value_to_10
			--
			,cre_date
			,cre_by
			,cre_ip_address
			,mod_date
			,mod_by
			,mod_ip_address
		)
		values
		(	@p_code
			,upper(@p_description)
			,@p_flow_type
			,@p_is_active
			,@p_dim_count
			,@p_dim_1
			,@p_operator_1
			,@p_dim_value_from_1
			,@p_dim_value_to_1
			,@p_dim_2
			,@p_operator_2
			,@p_dim_value_from_2
			,@p_dim_value_to_2
			,@p_dim_3
			,@p_operator_3
			,@p_dim_value_from_3
			,@p_dim_value_to_3
			,@p_dim_4
			,@p_operator_4
			,@p_dim_value_from_4
			,@p_dim_value_to_4
			,@p_dim_5
			,@p_operator_5
			,@p_dim_value_from_5
			,@p_dim_value_to_5
			,@p_dim_6
			,@p_operator_6
			,@p_dim_value_from_6
			,@p_dim_value_to_6
			,@p_dim_7
			,@p_operator_7
			,@p_dim_value_from_7
			,@p_dim_value_to_7
			,@p_dim_8
			,@p_operator_8
			,@p_dim_value_from_8
			,@p_dim_value_to_8
			,@p_dim_9
			,@p_operator_9
			,@p_dim_value_from_9
			,@p_dim_value_to_9
			,@p_dim_10
			,@p_operator_10
			,@p_dim_value_from_10
			,@p_dim_value_to_10
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
