CREATE PROCEDURE dbo.xsp_core_upload_generic_insert
(
	@p_table_name					nvarchar(250)
	,@p_primary_key					nvarchar(250)
	,@p_column_01					nvarchar(4000)=''
	,@p_column_02					nvarchar(4000)=''
	,@p_column_03					nvarchar(4000)=''
	,@p_column_04					nvarchar(4000)=''
	,@p_column_05					nvarchar(4000)=''
	,@p_column_06					nvarchar(4000)=''
	,@p_column_07					nvarchar(4000)=''
	,@p_column_08					nvarchar(4000)=''
	,@p_column_09					nvarchar(4000)=''
	,@p_column_10					nvarchar(4000)=''
	,@p_column_11					nvarchar(4000)=''
	,@p_column_12					nvarchar(4000)=''
	,@p_column_13					nvarchar(4000)=''
	,@p_column_14					nvarchar(4000)=''
	,@p_column_15					nvarchar(4000)=''
	,@p_column_16					nvarchar(4000)=''
	,@p_column_17					nvarchar(4000)=''
	,@p_column_18					nvarchar(4000)=''
	,@p_column_19					nvarchar(4000)=''
	,@p_column_20					nvarchar(4000)=''
	,@p_column_21					nvarchar(4000)=''
	,@p_column_22					nvarchar(4000)=''
	,@p_column_23					nvarchar(4000)=''
	,@p_column_24					nvarchar(4000)=''
	,@p_column_25					nvarchar(4000)=''
	,@p_column_26					nvarchar(4000)=''
	,@p_column_27					nvarchar(4000)=''
	,@p_column_28					nvarchar(4000)=''
	,@p_column_29					nvarchar(4000)=''
	,@p_column_30					nvarchar(4000)=''
	,@p_column_31					nvarchar(4000)=''
	,@p_column_32					nvarchar(4000)=''
	,@p_column_33					nvarchar(4000)=''
	,@p_column_34					nvarchar(4000)=''
	,@p_column_35					nvarchar(4000)=''
	,@p_column_36					nvarchar(4000)=''
	,@p_column_37					nvarchar(4000)=''
	,@p_column_38					nvarchar(4000)=''
	,@p_column_39					nvarchar(4000)=''
	,@p_column_40					nvarchar(4000)=''
	,@p_column_41					nvarchar(4000)=''
	,@p_column_42					nvarchar(4000)=''
	,@p_column_43					nvarchar(4000)=''
	,@p_column_44					nvarchar(4000)=''
	,@p_column_45					nvarchar(4000)=''
	,@p_column_46					nvarchar(4000)=''
	,@p_column_47					nvarchar(4000)=''
	,@p_column_48					nvarchar(4000)=''
	,@p_column_49					nvarchar(4000)=''
	,@p_column_50					nvarchar(4000)=''
	,@p_status						nvarchar(250)=''
	--
	,@p_cre_date 					datetime
	,@p_cre_by 						nvarchar(15)
	,@p_cre_ip_address 				nvarchar(15)
	,@p_mod_date 					datetime
	,@p_mod_by 						nvarchar(15)
	,@p_mod_ip_address 				nvarchar(15)
)
as
begin

	declare @msg				nvarchar(max)

	begin try

		insert into dbo.core_upload_generic
		(
			table_name
		    ,primary_key
			,column_01
		    ,column_02
		    ,column_03
		    ,column_04
		    ,column_05
		    ,column_06
		    ,column_07
		    ,column_08
		    ,column_09
		    ,column_10
		    ,column_11
		    ,column_12
		    ,column_13
		    ,column_14
		    ,column_15
		    ,column_16
		    ,column_17
		    ,column_18
		    ,column_19
		    ,column_20
		    ,column_21
		    ,column_22
		    ,column_23
		    ,column_24
		    ,column_25
		    ,column_26
		    ,column_27
		    ,column_28
		    ,column_29
		    ,column_30
		    ,column_31
		    ,column_32
		    ,column_33
		    ,column_34
		    ,column_35
		    ,column_36
		    ,column_37
		    ,column_38
		    ,column_39
		    ,column_40
		    ,column_41
		    ,column_42
		    ,column_43
		    ,column_44
		    ,column_45
		    ,column_46
		    ,column_47
		    ,column_48
		    ,column_49
		    ,column_50
		    ,status
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
			@p_table_name
			,@p_primary_key
			,@p_column_01
		    ,@p_column_02
		    ,@p_column_03
		    ,@p_column_04
		    ,@p_column_05
		    ,@p_column_06
		    ,@p_column_07
		    ,@p_column_08
		    ,@p_column_09
		    ,@p_column_10
		    ,@p_column_11
		    ,@p_column_12
		    ,@p_column_13
		    ,@p_column_14
		    ,@p_column_15
		    ,@p_column_16
		    ,@p_column_17
		    ,@p_column_18
		    ,@p_column_19
		    ,@p_column_20
		    ,@p_column_21
		    ,@p_column_22
		    ,@p_column_23
		    ,@p_column_24
		    ,@p_column_25
		    ,@p_column_26
		    ,@p_column_27
		    ,@p_column_28
		    ,@p_column_29
		    ,@p_column_30
		    ,@p_column_31
		    ,@p_column_32
		    ,@p_column_33
		    ,@p_column_34
		    ,@p_column_35
		    ,@p_column_36
		    ,@p_column_37
		    ,@p_column_38
		    ,@p_column_39
		    ,@p_column_40
		    ,@p_column_41
		    ,@p_column_42
		    ,@p_column_43
		    ,@p_column_44
		    ,@p_column_45
		    ,@p_column_46
		    ,@p_column_47
		    ,@p_column_48
		    ,@p_column_49
		    ,@p_column_50
		    ,@p_status
			--
		    ,@p_cre_date
		    ,@p_cre_by
		    ,@p_cre_ip_address
		    ,@p_mod_date
		    ,@p_mod_by
		    ,@p_mod_ip_address
		)

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
