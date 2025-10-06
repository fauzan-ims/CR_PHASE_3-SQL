CREATE TRIGGER trg_audit_sp_changes
ON DATABASE
FOR CREATE_PROCEDURE, ALTER_PROCEDURE, DROP_PROCEDURE
AS
BEGIN
    INSERT INTO dbo.Procedure_Audit
    (EventType, ObjectName, ObjectSchema, SqlText, EventDate, LoginName)
    SELECT
        EVENTDATA().value('(/EVENT_INSTANCE/EventType)[1]', 'nvarchar(100)'),
        EVENTDATA().value('(/EVENT_INSTANCE/ObjectName)[1]', 'nvarchar(100)'),
        EVENTDATA().value('(/EVENT_INSTANCE/SchemaName)[1]', 'nvarchar(100)'),
        EVENTDATA().value('(/EVENT_INSTANCE/TSQLCommand/CommandText)[1]', 'nvarchar(max)'),
        GETDATE(),
        ORIGINAL_LOGIN();
END

