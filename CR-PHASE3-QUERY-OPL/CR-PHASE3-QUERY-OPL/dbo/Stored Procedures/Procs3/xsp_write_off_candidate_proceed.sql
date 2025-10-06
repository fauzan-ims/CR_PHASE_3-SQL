/*
    Created : Rian, 23/12/2022
*/
CREATE PROCEDURE dbo.xsp_write_off_candidate_proceed
(
	@p_agreement_no					nvarchar(50)
	--

	,@p_mod_date					datetime
	,@p_mod_by						nvarchar(15)
	,@p_mod_ip_address				nvarchar(15)
)
as
begin

	declare @msg						nvarchar(max)
			,@wo_remarks				nvarchar(4000)
			,@client_name				nvarchar(50)
			,@code						nvarchar(50)
			,@branch_code				nvarchar(50)
			,@branch_name				nvarchar(250)
			,@wo_type					nvarchar(10)
			,@date						datetime = dbo.xfn_get_system_date()
		
				

	begin TRY
    
			select	@client_name = client_name
					,@branch_code = branch_code
					,@branch_name = branch_name
					,@wo_type = isnull(agreement_sub_status , '')
			from	dbo.agreement_main 
			WHERE	agreement_no = @p_agreement_no

			set @wo_remarks = 'WRITE OFF FROM AGREEMENT NO. ' +@p_agreement_no +' CLIENT NAME ' +@client_name 

			exec dbo.xsp_write_off_main_insert	@p_code					= @code output
												,@p_branch_code			= @branch_code
												,@p_branch_name			= @branch_name
												,@p_wo_date				= @date
												,@p_wo_type				= @wo_type	
												,@p_wo_remarks			= @wo_remarks
												,@p_agreement_no		= @p_agreement_no
												,@p_cre_date			= @p_mod_date
												,@p_cre_by				= @p_mod_by
												,@p_cre_ip_address		= @p_mod_ip_address
												,@p_mod_date			= @p_mod_date
												,@p_mod_by				= @p_mod_by
												,@p_mod_ip_address		= @p_mod_ip_address


			

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
	

