CREATE PROCEDURE dbo.xsp_doc_interface_agreement_collateral_aging_insert
(
	@p_id					  bigint = 0 output
	,@p_aging_date			  datetime
	,@p_agreement_no		  nvarchar(50)
	,@p_collateral_no		  nvarchar(50)
	,@p_branch_code			  nvarchar(50)
	,@p_branch_name			  nvarchar(250)
	,@p_locker_position		  nvarchar(10)
	,@p_locker_name			  nvarchar(250)
	,@p_drawer_name			  nvarchar(250)
	,@p_row_name			  nvarchar(250)
	,@p_document_status		  nvarchar(20)
	,@p_mutation_type		  nvarchar(20)
	,@p_mutation_location	  nvarchar(20)
	,@p_mutation_from		  nvarchar(50)
	,@p_mutation_to			  nvarchar(50)
	,@p_mutation_by			  nvarchar(250)
	,@p_mutation_date		  datetime
	,@p_mutation_return_date  datetime
	,@p_last_mutation_type	  nvarchar(20)
	,@p_last_mutation_date	  datetime
	,@p_last_locker_position  nvarchar(10)
	,@p_first_receive_date	  datetime
	,@p_release_customer_date datetime
	--
	,@p_cre_date			  datetime
	,@p_cre_by				  nvarchar(15)
	,@p_cre_ip_address		  nvarchar(15)
	,@p_mod_date			  datetime
	,@p_mod_by				  nvarchar(15)
	,@p_mod_ip_address		  nvarchar(15)
)
as
begin
	declare @msg nvarchar(max) ;

	begin try
		insert into doc_interface_agreement_collateral_aging
		(
			aging_date
			,agreement_no
			,collateral_no
			,branch_code
			,branch_name
			,locker_position
			,locker_name
			,drawer_name
			,row_name
			,document_status
			,mutation_type
			,mutation_location
			,mutation_from
			,mutation_to
			,mutation_by
			,mutation_date
			,mutation_return_date
			,last_mutation_type
			,last_mutation_date
			,last_locker_position
			,first_receive_date
			,release_customer_date
			--
			,cre_date
			,cre_by
			,cre_ip_address
			,mod_date
			,mod_by
			,mod_ip_address
		)
		values
		(	@p_aging_date
			,@p_agreement_no
			,@p_collateral_no
			,@p_branch_code
			,@p_branch_name
			,@p_locker_position
			,@p_locker_name
			,@p_drawer_name
			,@p_row_name
			,@p_document_status
			,@p_mutation_type
			,@p_mutation_location
			,@p_mutation_from
			,@p_mutation_to
			,@p_mutation_by
			,@p_mutation_date
			,@p_mutation_return_date
			,@p_last_mutation_type
			,@p_last_mutation_date
			,@p_last_locker_position
			,@p_first_receive_date
			,@p_release_customer_date
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
