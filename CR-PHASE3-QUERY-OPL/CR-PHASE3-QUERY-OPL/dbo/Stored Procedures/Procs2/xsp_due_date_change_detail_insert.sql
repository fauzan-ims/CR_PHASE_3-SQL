--created by, Rian at 04/05/2023 

CREATE PROCEDURE [dbo].[xsp_due_date_change_detail_insert]
(
	@p_id					 bigint output
	,@p_due_date_change_code nvarchar(50)
	,@p_asset_no			 nvarchar(50)
	,@p_os_rental_amount	 decimal(18, 2)
	,@p_old_due_date_day	 datetime
	,@p_new_due_date_day	 datetime
	,@p_at_installment_no	 int
	,@p_is_change			 nvarchar(1)   = '0'
	--
	,@p_cre_date			 datetime
	,@p_cre_by				 nvarchar(15)
	,@p_cre_ip_address		 nvarchar(15)
	,@p_mod_date			 datetime
	,@p_mod_by				 nvarchar(15)
	,@p_mod_ip_address		 nvarchar(15)
	,@p_date_for_billing		int = 0

)
as
begin
	declare @msg nvarchar(max) ;

	begin try
		insert into dbo.due_date_change_detail
		(
			due_date_change_code
			,asset_no
			,os_rental_amount
			,old_due_date_day
			,new_due_date_day
			,at_installment_no
			,is_change
			--
			,cre_date
			,cre_by
			,cre_ip_address
			,mod_date
			,mod_by
			,mod_ip_address
			,date_for_billing
		)
		values
		(	@p_due_date_change_code
			,@p_asset_no
			,@p_os_rental_amount
			,@p_old_due_date_day
			,@p_new_due_date_day
			,@p_at_installment_no
			,@p_is_change
			--
			,@p_cre_date
			,@p_cre_by
			,@p_cre_ip_address
			,@p_mod_date
			,@p_mod_by
			,@p_mod_ip_address
			,@p_date_for_billing
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
