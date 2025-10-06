create procedure [dbo].[xsp_rpt_masking_getrow]
as
begin
	create user MaskingTestUser without login ;

	--BEGIN TRANSACTION 
	grant select
	on schema::Data
	to	MaskingTestUser ;

	-- impersonate for testing:
	execute as user = 'MaskingTestUser' ;

	--INSERT INTO Data.Membership_rpt
	select	*
	into	#Membership_rpt
	from	Data.Membership ;

	select	*
	from	Data.Membership ;

	-- Revert impersonation
	revert ;

	-- Grant UNMASK permission
	--GRANT UNMASK TO MaskingTestUser;
	-- Impersonate again to show unmasked view
	--EXECUTE AS USER = 'MaskingTestUser';
	--REVERT;
	-- Remove the user
	drop user MaskingTestUser ;

	delete	Data.Membership_rpt ;

	--EXECUTE AS USER = 'sa';
	insert into Data.Membership_rpt
	select	FirstName
			,LastName
			,Phone
			,Email
			,DiscountCode
	from	#Membership_rpt ;

	drop table #Membership_rpt ;

	select	MemberID
			,FirstName
			,LastName
			,Phone
			,Email
			,DiscountCode
	from	Data.Membership_rpt ;
end ;
