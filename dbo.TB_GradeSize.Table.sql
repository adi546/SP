USE [mazuagricusmssql01-db-db]
GO
/****** Object:  Table [dbo].[TB_GradeSize]    Script Date: 2/26/2025 5:29:08 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TB_GradeSize](
	[Grade] [nvarchar](10) NOT NULL,
	[Size] [nvarchar](20) NULL,
PRIMARY KEY CLUSTERED 
(
	[Grade] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
INSERT [dbo].[TB_GradeSize] ([Grade], [Size]) VALUES (N'M0', N'15-25mm')
INSERT [dbo].[TB_GradeSize] ([Grade], [Size]) VALUES (N'M1', N'25-35mm')
INSERT [dbo].[TB_GradeSize] ([Grade], [Size]) VALUES (N'M11', N'25-40mm')
INSERT [dbo].[TB_GradeSize] ([Grade], [Size]) VALUES (N'M12', N'41-50mm')
INSERT [dbo].[TB_GradeSize] ([Grade], [Size]) VALUES (N'M13', N'>50mm')
INSERT [dbo].[TB_GradeSize] ([Grade], [Size]) VALUES (N'M1A', N'25-30mm')
INSERT [dbo].[TB_GradeSize] ([Grade], [Size]) VALUES (N'M1B', N'31-35mm')
INSERT [dbo].[TB_GradeSize] ([Grade], [Size]) VALUES (N'M2', N'36-45mm')
INSERT [dbo].[TB_GradeSize] ([Grade], [Size]) VALUES (N'M2A', N'36-40mm')
INSERT [dbo].[TB_GradeSize] ([Grade], [Size]) VALUES (N'M2B', N'41-45mm')
INSERT [dbo].[TB_GradeSize] ([Grade], [Size]) VALUES (N'M3', N'46-55mm')
INSERT [dbo].[TB_GradeSize] ([Grade], [Size]) VALUES (N'M4', N'>55mm')
INSERT [dbo].[TB_GradeSize] ([Grade], [Size]) VALUES (N'M6', N'30-55mm')
INSERT [dbo].[TB_GradeSize] ([Grade], [Size]) VALUES (N'M7', N'35-55mm')
GO
