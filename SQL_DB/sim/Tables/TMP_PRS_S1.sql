CREATE TABLE [sim].[TMP_PRS_S1] (
    [LINE_ID]   INT           NOT NULL,
    [LINE_TEXT] VARCHAR (200) NULL,
    [ROW_TYPE]  TINYINT       NULL,
    [FILE_NAME] VARCHAR (255) NULL,
    [LOAD_TIME] SMALLDATETIME CONSTRAINT [DF_TMP_SSIM_LOAD_TIME] DEFAULT (getdate()) NULL,
    [LOAD_DATE] AS            (CONVERT([date],[LOAD_TIME])) PERSISTED
);

