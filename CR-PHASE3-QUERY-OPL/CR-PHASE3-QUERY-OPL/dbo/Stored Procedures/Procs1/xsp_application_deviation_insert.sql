CREATE PROCEDURE dbo.xsp_application_deviation_insert
(
	@p_id				bigint = 0 output
	,@p_application_no	nvarchar(50)
	,@p_deviation_code	nvarchar(50)
	,@p_position_code	nvarchar(50)
	,@p_position_name	nvarchar(250)
	,@p_remarks			nvarchar(4000)
	,@p_is_manual		nvarchar(1) = '1'
	--
	,@p_cre_date		datetime
	,@p_cre_by			nvarchar(15)
	,@p_cre_ip_address	nvarchar(15)
	,@p_mod_date		datetime
	,@p_mod_by			nvarchar(15)
	,@p_mod_ip_address	nvarchar(15)
)
as
begin
	declare @msg nvarchar(max) ;

	begin try
		if @p_is_manual = 'F'
			set @p_is_manual = '1' ;
		insert into application_deviation
		(
			application_no
			,deviation_code
			,remarks
			,position_code
			,position_name
			,is_manual
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
			,@p_deviation_code
			,@p_remarks
			,@p_position_code
			,@p_position_name
			,@p_is_manual
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


