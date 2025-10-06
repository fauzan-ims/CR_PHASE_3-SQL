
-- Stored Procedure

CREATE PROCEDURE [dbo].[xsp_ifinproc_interface_adjustment_asset_insert]
(
	@p_id						bigint
	,@p_code					nvarchar(50)
	,@p_branch_code				nvarchar(50)
	,@p_branch_name				nvarchar(250)
	,@p_date					datetime
	,@p_fa_code					nvarchar(50)
	,@p_fa_name					nvarchar(250)
	,@p_item_code				nvarchar(50)
	,@p_item_name				nvarchar(250)
	,@p_division_code			nvarchar(50)
	,@p_division_name			nvarchar(250)
	,@p_department_code			nvarchar(50)
	,@p_department_name			nvarchar(250)
	,@p_description				nvarchar(4000)
	,@p_adjustment_amount		decimal(18,2)
	,@p_type_asset				nvarchar(15)
	,@p_quantity				int
	,@p_uom						nvarchar(15)
	,@p_job_status				nvarchar(50)
	,@p_failed_remarks			nvarchar(4000)
	,@p_adjust_type				nvarchar(15)
	--
	,@p_cre_date				datetime
	,@p_cre_by					nvarchar(15)
	,@p_cre_ip_address			nvarchar(15)
	,@p_mod_date				datetime
	,@p_mod_by					nvarchar(15)
	,@p_mod_ip_address			nvarchar(15)
	,@p_is_from_proc			nvarchar(1) = '0'
)
as
begin
	declare @msg	nvarchar(max);

	begin try
		insert into dbo.ifinproc_interface_adjustment_asset
		(
			code
			,branch_code
			,branch_name
			,date
			,fa_code
			,fa_name
			,item_code
			,item_name
			,division_code
			,division_name
			,department_code
			,department_name
			,description
			,adjustment_amount
			,type_asset
			,quantity
			,uom
			,job_status
			,failed_remarks
			,adjust_type
			--
			,cre_date
			,cre_by
			,cre_ip_address
			,mod_date
			,mod_by
			,mod_ip_address
			,is_from_proc
		)
		values
		(	
			@p_code					
			,@p_branch_code			
			,@p_branch_name			
			,@p_date				
			,@p_fa_code				
			,@p_fa_name
			,@p_item_code
			,@p_item_name		
			,@p_division_code		
			,@p_division_name		
			,@p_department_code		
			,@p_department_name		
			,@p_description			
			,@p_adjustment_amount
			,@p_type_asset
			,@p_quantity
			,@p_uom
			,@p_job_status			
			,@p_failed_remarks
			,@p_adjust_type
			--
			,@p_cre_date
			,@p_cre_by
			,@p_cre_ip_address
			,@p_mod_date
			,@p_mod_by
			,@p_mod_ip_address
			,@p_is_from_proc
		) set @p_id = @@identity ;
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

