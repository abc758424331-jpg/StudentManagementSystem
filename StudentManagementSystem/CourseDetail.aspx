<%@ Page Language="C#" AutoEventWireup="true" CodeFile="CourseDetail.aspx.cs" Inherits="CourseDetail" MaintainScrollPositionOnPostback="true" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml" data-theme="dark">
<head runat="server">
    <title>课程详情与反馈 | 智慧教务系统</title>
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.4/css/all.min.css" rel="stylesheet" />
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;600;700&family=Rajdhani:wght@500;700&display=swap" rel="stylesheet" />
    
    <style>
        :root { --ease-smooth: cubic-bezier(0.25, 0.46, 0.45, 0.94); }
        [data-theme="dark"] {
            --bg-color: #0f172a; --glass-panel: rgba(30, 41, 59, 0.7); --glass-border: rgba(255, 255, 255, 0.1);
            --text-main: #f8fafc; --text-sub: #94a3b8; --primary: #0ea5e9; --primary-glow: rgba(14, 165, 233, 0.3);
            --input-bg: rgba(15, 23, 42, 0.6);
        }
        body {
            margin: 0; padding: 0; background: var(--bg-color); color: var(--text-main); font-family: 'Inter', sans-serif;
            min-height: 100vh;
        }
        #particle-canvas { position: fixed; top: 0; left: 0; width: 100%; height: 100%; z-index: -1; opacity: 0.5; }

        .navbar {
            height: 70px; padding: 0 40px; display: flex; align-items: center; justify-content: space-between;
            background: var(--glass-panel); border-bottom: 1px solid var(--glass-border);
            backdrop-filter: blur(20px); position: fixed; top: 0; width: 100%; z-index: 1000; box-sizing: border-box;
        }
        .brand { font-family: 'Rajdhani', sans-serif; font-weight: 700; font-size: 24px; color: var(--text-main); text-decoration: none; }
        .btn-back { color: var(--text-sub); text-decoration: none; font-size: 14px; padding: 8px 16px; border: 1px solid var(--glass-border); border-radius: 8px; }

        .container { max-width: 1000px; margin: 100px auto 40px; padding: 0 20px; display: flex; flex-direction: column; gap: 30px; }

        .course-header {
            background: var(--glass-panel); border: 1px solid var(--glass-border); border-radius: 20px; padding: 30px;
            display: flex; justify-content: space-between; align-items: center; position: relative; overflow: hidden;
        }
        .course-header::before { content: ''; position: absolute; left: 0; top: 0; height: 100%; width: 4px; background: var(--primary); }
        .course-title h1 { margin: 0; font-size: 28px; }
        .course-info { margin-top: 8px; color: var(--text-sub); font-size: 14px; display: flex; gap: 20px; }
        .tag { background: rgba(14, 165, 233, 0.1); color: var(--primary); padding: 4px 10px; border-radius: 6px; font-size: 12px; }

        .input-panel {
            background: var(--glass-panel); border: 1px solid var(--glass-border); border-radius: 16px; padding: 20px;
            display: flex; gap: 15px; margin-bottom: 30px;
        }
        .comment-input { width: 100%; background: transparent; border: none; color: var(--text-main); font-size: 14px; resize: none; outline: none; }
        .btn-post { background: var(--primary); color: #fff; border: none; padding: 8px 20px; border-radius: 8px; cursor: pointer; }

        .comment-list { display: flex; flex-direction: column; gap: 15px; }
        .comment-card {
            background: var(--glass-panel); border: 1px solid var(--glass-border); border-radius: 12px; padding: 15px 20px;
            display: flex; gap: 15px;
        }
        .comment-header { display: flex; justify-content: space-between; margin-bottom: 5px; }
        .comment-user { font-weight: 600; font-size: 14px; }
        .comment-time { font-size: 12px; color: var(--text-sub); }
        .comment-body { font-size: 14px; color: var(--text-sub); line-height: 1.5; }
    </style>
</head>
<body>
    <form id="form1" runat="server">
    <asp:ScriptManager ID="ScriptManager1" runat="server"></asp:ScriptManager>

    <div class="navbar">
        <a href="#" class="brand"><i class="fas fa-atom"></i> SMART CAMPUS</a>
        <a href="CourseSelection.aspx" class="btn-back"><i class="fas fa-arrow-left"></i> 返回选课</a>
    </div>

    <div class="container">
        <div class="course-header">
            <div class="course-title">
                <h1><asp:Label ID="lblCourseName" runat="server"></asp:Label></h1>
                <div class="course-info">
                    <span><i class="fas fa-chalkboard-teacher"></i> <asp:Label ID="lblTeacher" runat="server"></asp:Label></span>
                    <span><i class="fas fa-layer-group"></i> <asp:Label ID="lblCredit" runat="server"></asp:Label> 学分</span>
                    <span class="tag"><asp:Label ID="lblType" runat="server"></asp:Label></span>
                </div>
            </div>
            <div style="text-align:right;">
                <div style="font-size:32px; font-weight:700; color:var(--primary); font-family:'Rajdhani'">
                    <asp:Label ID="lblStudentCount" runat="server">0</asp:Label>
                </div>
                <div style="font-size:12px; color:var(--text-sub);">已选人数</div>
            </div>
        </div>

        <div class="discussion-area">
            <div style="font-size:18px; font-weight:600; margin-bottom:20px;">
                <i class="far fa-comments"></i> 课程讨论与反馈
            </div>

            <asp:UpdatePanel ID="UpdatePanel1" runat="server">
                <ContentTemplate>
                    
                    <div class="input-panel">
                        <div style="width:40px; height:40px; border-radius:50%; background:linear-gradient(135deg,var(--primary),#6366f1); display:flex; align-items:center; justify-content:center; font-weight:bold;">ME</div>
                        <asp:TextBox ID="txtComment" runat="server" CssClass="comment-input" TextMode="MultiLine" placeholder="分享你的学习心得..."></asp:TextBox>
                        <asp:Button ID="btnPost" runat="server" Text="发布留言" OnClick="btnPost_Click" CssClass="btn-post" />
                    </div>

                    <div class="comment-list">
                        <asp:Repeater ID="rptComments" runat="server">
                            <ItemTemplate>
                                <div class="comment-card">
                                    <div style="width:32px; height:32px; border-radius:50%; background:rgba(255,255,255,0.1); display:flex; align-items:center; justify-content:center;">
                                        <i class="fas fa-user"></i>
                                    </div>
                                    <div style="flex:1;">
                                        <div class="comment-header">
                                            <span class="comment-user"><%# Eval("StudentName") %></span>
                                            <span class="comment-time"><%# Eval("PostTime", "{0:yyyy-MM-dd HH:mm}") %></span>
                                        </div>
                                        <div class="comment-body"><%# Eval("Content") %></div>
                                    </div>
                                </div>
                            </ItemTemplate>
                        </asp:Repeater>
                        <asp:Label ID="lblEmpty" runat="server" Visible="false" style="text-align:center; color:var(--text-sub); padding:20px;">暂无留言</asp:Label>
                    </div>

                </ContentTemplate>
            </asp:UpdatePanel>
        </div>
    </div>
    </form>
</body>
</html>