<%@ Page Language="C#" AutoEventWireup="true" CodeFile="CourseApproval.aspx.cs" Inherits="CourseApproval" MaintainScrollPositionOnPostback="true" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>新课审批 | 智慧教务系统</title>
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.4/css/all.min.css" rel="stylesheet" />
    <link href="https://fonts.googleapis.com/css2?family=Noto+Sans+SC:wght@300;400;500;700&family=Inter:wght@400;600&display=swap" rel="stylesheet">
    
    <script>
        // === 1. 主题同步 ===
        (function () {
            const savedTheme = localStorage.getItem('theme') || 'dark';
            document.documentElement.setAttribute('data-theme', savedTheme);
        })();
    </script>

    <style>
        /* === 2. 管理员审批版主题 (翡翠绿) === */
        :root {
            --primary: #10b981;       /* Emerald 500 */
            --primary-hover: #059669; /* Emerald 600 */
            --danger: #ef4444;        /* Red 500 */
            --shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);
        }

        [data-theme="dark"] {
            --bg-body: #0b1120;
            --bg-card: #1e293b;
            --text-main: #f8fafc;
            --text-sub: #94a3b8;
            --border: #334155;
            --hover-bg: rgba(255,255,255,0.05);
            --info-bg: rgba(16, 185, 129, 0.1);
        }

        [data-theme="light"] {
            --bg-body: #f1f5f9;
            --bg-card: #ffffff;
            --text-main: #1e293b;
            --text-sub: #64748b;
            --border: #e2e8f0;
            --hover-bg: #f8fafc;
            --info-bg: #ecfdf5;
        }

        body {
            margin: 0; padding: 0;
            background-color: var(--bg-body);
            color: var(--text-main);
            font-family: 'Noto Sans SC', 'Inter', sans-serif;
            transition: background-color 0.3s;
        }

        form { display: flex; flex-direction: column; min-height: 100vh; }

        /* 导航栏 */
        .navbar {
            background-color: var(--bg-card);
            border-bottom: 1px solid var(--border);
            padding: 0 40px; height: 64px;
            display: flex; justify-content: space-between; align-items: center;
            position: sticky; top: 0; z-index: 100;
            box-shadow: var(--shadow);
        }
        .brand { font-size: 20px; font-weight: 700; color: var(--primary); display: flex; align-items: center; gap: 10px; }
        .nav-right { display: flex; align-items: center; gap: 20px; }
        .theme-toggle-btn { background: none; border: none; cursor: pointer; color: var(--text-sub); font-size: 18px; padding: 8px; border-radius: 50%; transition: all 0.2s; }
        .theme-toggle-btn:hover { background-color: var(--hover-bg); color: var(--text-main); }
        .btn-logout { color: #ef4444; text-decoration: none; font-weight: 600; display: flex; align-items: center; gap: 6px; }

        /* 主内容区 */
        .main-content {
            flex: 1; padding: 40px; max-width: 1200px; margin: 0 auto; width: 100%; box-sizing: border-box;
        }

        .page-header { margin-bottom: 30px; display:flex; justify-content:space-between; align-items:center; }
        .page-title { font-size: 24px; font-weight: 700; margin: 0; color: var(--text-main); }
        .btn-back {
            color: var(--text-sub); text-decoration: none; font-size: 14px; display: flex; align-items: center; gap: 6px;
            padding: 8px 16px; border-radius: 6px; border: 1px solid var(--border); transition: all 0.2s;
        }
        .btn-back:hover { background: var(--hover-bg); color: var(--text-main); border-color: var(--text-sub); }

        /* 提示卡片 */
        .alert-box {
            background: var(--info-bg); border-left: 4px solid var(--primary);
            padding: 16px 20px; border-radius: 8px; margin-bottom: 30px;
            color: var(--text-main); font-size: 14px; line-height: 1.6;
            display: flex; gap: 15px; align-items: center;
        }
        .alert-icon { font-size: 24px; color: var(--primary); }

        /* 表格区域 */
        .table-section {
            background-color: var(--bg-card);
            border: 1px solid var(--border);
            border-radius: 12px; padding: 24px;
            box-shadow: var(--shadow);
        }
        .table-header { margin-bottom: 20px; padding-bottom: 15px; border-bottom: 1px solid var(--border); }
        .table-title { font-size: 18px; font-weight: 600; color: var(--text-main); display: flex; align-items: center; gap: 10px; }
        .badge-count { background: var(--primary); color: #fff; padding: 2px 8px; border-radius: 10px; font-size: 12px; margin-left: 5px; }

        .custom-grid { width: 100%; border-collapse: collapse; color: var(--text-main); }
        .custom-grid th {
            text-align: left; padding: 14px 16px;
            color: var(--text-sub); font-size: 13px; font-weight: 600;
            border-bottom: 1px solid var(--border);
        }
        .custom-grid td { padding: 16px; border-bottom: 1px solid var(--border); font-size: 14px; vertical-align: middle; }
        .custom-grid tr:hover { background-color: var(--hover-bg); }

        /* 信息列样式 */
        .teacher-info { display: flex; flex-direction: column; }
        .teacher-name { font-weight: 600; font-size: 15px; }
        .teacher-id { font-size: 12px; color: var(--text-sub); margin-top: 2px; }

        .course-highlight { color: var(--primary); font-weight: 600; }

        /* 操作按钮 */
        .btn-action {
            padding: 8px 16px; border-radius: 6px; font-size: 13px; font-weight: 600; text-decoration: none;
            display: inline-flex; align-items: center; gap: 6px; transition: all 0.2s; border: none; cursor: pointer;
        }
        .btn-approve { background: linear-gradient(135deg, var(--primary) 0%, #059669 100%); color: white; box-shadow: 0 4px 10px rgba(16, 185, 129, 0.3); }
        .btn-approve:hover { transform: translateY(-2px); box-shadow: 0 6px 15px rgba(16, 185, 129, 0.4); }

        .btn-reject { background: transparent; color: var(--danger); border: 1px solid var(--danger); }
        .btn-reject:hover { background: var(--danger); color: white; }

    </style>
</head>
<body>
    <form id="form1" runat="server">
        <nav class="navbar">
            <div class="brand">
                <i class="fas fa-gavel"></i> 新课审批台
            </div>
            
            <div class="nav-right">
                <button type="button" class="theme-toggle-btn" onclick="toggleTheme()" title="切换主题">
                    <i class="fas fa-adjust" id="themeIcon"></i>
                </button>
                <asp:LinkButton ID="btnLogout" runat="server" OnClick="btnLogout_Click" CssClass="btn-logout">
                    <i class="fas fa-sign-out-alt"></i> 退出
                </asp:LinkButton>
            </div>
        </nav>

        <div class="main-content">
            
            <div class="page-header">
                <h1 class="page-title">课程准入审核</h1>
                <a href="Default.aspx" class="btn-back"><i class="fas fa-arrow-left"></i> 返回总控台</a>
            </div>

            <div class="alert-box">
                <i class="fas fa-clipboard-list alert-icon"></i>
                <div>
                    <strong>审核须知：</strong><br/>
                    请重点核查 <span style="color:var(--primary)">学分设置</span> 与 <span style="color:var(--primary)">班级容量</span> 是否符合教学资源配置要求。<br/>
                    通过后的课程将立即对学生开放选课；驳回的申请将被移除，教师需重新提交。
                </div>
            </div>

            <div class="table-section">
                <div class="table-header">
                    <div class="table-title">
                        待审课程队列 
                        <span class="badge-count"><%= gvCourses.Rows.Count %></span>
                    </div>
                </div>

                <asp:GridView ID="gvCourses" runat="server" CssClass="custom-grid" AutoGenerateColumns="False" 
                    OnRowCommand="gvCourses_RowCommand" GridLines="None" EmptyDataText="🎉 目前没有待审批的新课申请。">
                    <Columns>
                        <asp:TemplateField HeaderText="申请教师">
                            <ItemTemplate>
                                <div class="teacher-info">
                                    <span class="teacher-name"><%# Eval("TeacherName") %></span>
                                    <span class="teacher-id">工号: <%# Eval("WorkNo") %></span>
                                </div>
                            </ItemTemplate>
                        </asp:TemplateField>

                        <asp:BoundField DataField="CourseName" HeaderText="课程名称" ItemStyle-Font-Bold="true" />
                        <asp:BoundField DataField="Semester" HeaderText="拟开课学期" />
                        
                        <asp:TemplateField HeaderText="学分 / 容量" ItemStyle-HorizontalAlign="Center" HeaderStyle-HorizontalAlign="Center">
                            <ItemTemplate>
                                <span class="course-highlight"><%# Eval("Credit") %> 学分</span> 
                                <span style="color:var(--text-sub); margin:0 5px;">/</span>
                                <span><%# Eval("MaxCapacity") %> 人</span>
                            </ItemTemplate>
                        </asp:TemplateField>

                        <asp:TemplateField HeaderText="决策" ItemStyle-Width="220px" ItemStyle-HorizontalAlign="Right">
                            <ItemTemplate>
                                <asp:LinkButton ID="btnApprove" runat="server" CommandName="Approve" CommandArgument='<%# Eval("CourseId") %>' 
                                    CssClass="btn-action btn-approve"
                                    OnClientClick="return confirm('✅ 确定批准该课程上架吗？\n上架后学生即可选课。');">
                                    <i class="fas fa-check"></i> 批准上架
                                </asp:LinkButton>

                                <asp:LinkButton ID="btnReject" runat="server" CommandName="Reject" CommandArgument='<%# Eval("CourseId") %>' 
                                    CssClass="btn-action btn-reject"
                                    OnClientClick="return confirm('⛔ 确定驳回该申请吗？\n该操作将删除此申请记录。');">
                                    <i class="fas fa-times"></i> 驳回
                                </asp:LinkButton>
                            </ItemTemplate>
                        </asp:TemplateField>
                    </Columns>
                    <EmptyDataTemplate>
                        <div style="padding:60px; text-align:center; color:var(--text-sub);">
                            <i class="fas fa-check-circle" style="font-size:48px; margin-bottom:15px; opacity:0.3; color:var(--primary);"></i>
                            <p style="font-size:16px;">工作完成！当前所有新课申请均已处理。</p>
                        </div>
                    </EmptyDataTemplate>
                </asp:GridView>
            </div>
        </div>
    </form>

    <script>
        // === 主题切换 ===
        function toggleTheme() {
            const current = document.documentElement.getAttribute('data-theme');
            const target = current === 'dark' ? 'light' : 'dark';
            document.documentElement.setAttribute('data-theme', target);
            localStorage.setItem('theme', target);
            updateIcon(target);
        }

        function updateIcon(theme) {
            const icon = document.getElementById('themeIcon');
            if (icon) icon.className = theme === 'dark' ? 'fas fa-moon' : 'fas fa-sun';
        }

        const saved = localStorage.getItem('theme') || 'dark';
        updateIcon(saved);
    </script>
</body>
</html>