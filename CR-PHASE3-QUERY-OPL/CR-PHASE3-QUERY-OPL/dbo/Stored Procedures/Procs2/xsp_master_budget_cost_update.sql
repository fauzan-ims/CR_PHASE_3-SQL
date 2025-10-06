
CREATE PROCEDURE [dbo].[xsp_master_budget_cost_update]
(
	@p_code						nvarchar(50)
	,@p_description				nvarchar(4000)
	,@p_class_code				nvarchar(50)
	,@p_class_description		nvarchar(4000)
	,@p_is_subject_to_purchase  nvarchar(1)
	,@p_is_active				nvarchar(1)
	,@p_item_code			    nvarchar(50)  = null
	,@p_item_description	    nvarchar(250) = null
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
			,@value_exp_date nvarchar(50) ;

	if @p_is_active = 'T'
		set @p_is_active = '1' ;
	else
		set @p_is_active = '0' ;

	if @p_is_subject_to_purchase = 'T'
		set	@p_is_subject_to_purchase = '1'
	else
		set	@p_is_subject_to_purchase = '0'
		
	select	@value_exp_date = value
	from	dbo.sys_global_param
	where	code = 'EXPDATE' 
	
	if exists
	(
		select	1
		from	dbo.master_budget_cost
		where	class_code = @p_class_code
				and code   <> @p_code
				and description   = @p_description
	)
	begin
		set @msg = 'Class already exist' ;

		raiserror(@msg, 16, -1) ;
	end ; 

	begin try
		update	master_budget_cost
		set		description				= @p_description
				,class_code				= @p_class_code
				,class_description		= @p_class_description 
				,is_subject_to_purchase = @p_is_subject_to_purchase
				,is_active				= @p_is_active
				,exp_date				= dateadd(month, convert (int, @value_exp_date), dbo.xfn_get_system_date())
				,item_code				= @p_item_code		
				,item_description		= @p_item_description
				--	
				,mod_date				= @p_mod_date
				,mod_by					= @p_mod_by
				,mod_ip_address			= @p_mod_ip_address
		where	code					= @p_code ;
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
