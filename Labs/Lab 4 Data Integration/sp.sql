SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [integration].[sp_UpsertLandingzoneBronzeSilver]
(
    @DataSourceId INT,
    @SourceSchema NVARCHAR(100),
    @SourceName NVARCHAR(200),
    @TargetSchema NVARCHAR(100),
    @TargetName NVARCHAR(200),
    @FileName NVARCHAR(200),
    @FilePath NVARCHAR(100),
    @FileType NVARCHAR(20),
    @IsIncremental BIT,
    @IsIncrementalColumn NVARCHAR(50) = NULL,
    -- Bronze parameters
    @PrimaryKeys NVARCHAR(200)
)
WITH EXECUTE AS CALLER
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        -- Output tables
        DECLARE @LandingzoneOutput TABLE (LandingzoneEntityId INT);
        DECLARE @BronzeOutput      TABLE (BronzeLayerEntityId INT);
        DECLARE @SilverOutput      TABLE (SilverLayerEntityId INT);

        DECLARE @IsActiveLandingzone BIT = 1;
        DECLARE @IsActiveBronze      BIT = 1;
        DECLARE @IsActiveSilver      BIT = 1;

        DECLARE @BronzeFileType NVARCHAR(20) = N'Delta';
        DECLARE @SilverFileType NVARCHAR(20) = N'Delta';

        ------------------------------------------------------------
        -- 1. Upsert Landingzone
        ------------------------------------------------------------
        MERGE [integration].[LandingzoneEntity] AS target
        USING (
            SELECT
                @SourceSchema AS SourceSchema,
                @SourceName   AS SourceName,
                @DataSourceId AS DataSourceId
        ) AS source
        ON  target.SourceSchema = source.SourceSchema
        AND target.SourceName   = source.SourceName
        AND target.DataSourceId = source.DataSourceId
             WHEN MATCHED THEN
            UPDATE SET
                DataSourceId        = @DataSourceId,
                IsActive            = @IsActiveLandingzone,
                FileName            = @FileName,
                FileType            = @FileType,
                FilePath            = @FilePath,
                IsIncremental       = @IsIncremental,
                IsIncrementalColumn = @IsIncrementalColumn
        WHEN NOT MATCHED THEN
            INSERT (
                DataSourceId, IsActive, SourceSchema, SourceName, 
                FileName, FileType, FilePath, IsIncremental, IsIncrementalColumn
            )
            VALUES (
                @DataSourceId, @IsActiveLandingzone, @SourceSchema, @SourceName,
                @FileName, @FileType, @FilePath,  @IsIncremental, @IsIncrementalColumn
            )
        OUTPUT INSERTED.LandingzoneEntityId INTO @LandingzoneOutput;

        DECLARE @FinalLandingzoneId INT = (SELECT TOP (1) LandingzoneEntityId FROM @LandingzoneOutput);

        ------------------------------------------------------------
        -- 2. Upsert Bronze Layer
        ------------------------------------------------------------


        MERGE [integration].[BronzeLayerEntity] AS target
        USING (
            SELECT
                @TargetSchema AS TargetSchema,
                @TargetName   AS TargetName
        ) AS source
        ON  target.[Schema]    = source.TargetSchema
        AND target.[Name]      = source.TargetName

        WHEN MATCHED THEN
            UPDATE SET
                [IsActive]            = @IsActiveBronze,
                [Schema]              = @TargetSchema,
                [Name]                = @TargetName,
                [FileType]            = @BronzeFileType,
                [PrimaryKeys]         = @PrimaryKeys
        WHEN NOT MATCHED THEN
            INSERT ([LandingzoneEntityId], [IsActive], [Schema], [Name], [FileType], [PrimaryKeys])
            VALUES (@FinalLandingzoneId, @IsActiveBronze, @TargetSchema, @TargetName, @BronzeFileType, @PrimaryKeys)
        OUTPUT INSERTED.BronzeLayerEntityId INTO @BronzeOutput;

        DECLARE @FinalBronzeId INT = (SELECT TOP (1) BronzeLayerEntityId FROM @BronzeOutput);

        ------------------------------------------------------------
        -- 3. Upsert Silver Layer
        ------------------------------------------------------------

        MERGE [integration].[SilverLayerEntity] AS target
        USING (SELECT @FinalBronzeId AS BronzeLayerEntityId) AS source
        ON target.BronzeLayerEntityId = source.BronzeLayerEntityId
        WHEN MATCHED THEN
            UPDATE SET
                [BronzeLayerEntityId] = @FinalBronzeId,
                [Schema]               = @TargetSchema,
                [Name]                 = @TargetName,
                [FileType]             = @SilverFileType,
          
                [IsActive]             = @IsActiveSilver
        WHEN NOT MATCHED THEN
            INSERT ([BronzeLayerEntityId], [IsActive], [Schema], [Name], [FileType])
            VALUES (@FinalBronzeId, @IsActiveSilver, @TargetSchema, @TargetName, @SilverFileType)
        OUTPUT INSERTED.SilverLayerEntityId INTO @SilverOutput;

        DECLARE @FinalSilverId INT = (SELECT TOP (1) SilverLayerEntityId FROM @SilverOutput);

        ------------------------------------------------------------
        -- Final Output
        ------------------------------------------------------------
        SELECT
            LandingzoneEntityId = @FinalLandingzoneId,
            BronzeLayerEntityId = @FinalBronzeId,
            SilverLayerEntityId = @FinalSilverId;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT           = ERROR_SEVERITY();
        DECLARE @ErrorState INT              = ERROR_STATE();

        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH
END;
GO
