<%@ Page Language="C#" AutoEventWireup="true" CodeFile="TeacherHome.aspx.cs" Inherits="TeacherHome" MaintainScrollPositionOnPostback="true" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>教师工作台 | 智慧教务系统</title>
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.4/css/all.min.css" rel="stylesheet" />
    <link href="https://fonts.googleapis.com/css2?family=Noto+Sans+SC:wght@300;400;500;700&family=Inter:wght@400;600&display=swap" rel="stylesheet">
    
    <script>
        // === 1. 页面加载前立即同步主题，防止闪烁 ===
        (function () {
            const savedTheme = localStorage.getItem('theme') || 'dark';
            document.documentElement.setAttribute('data-theme', savedTheme);
        })();
    </script>

    <style>
        /* === 2. 教师版主题变量 (天际蓝/智慧蓝) === */
        :root {
            --primary: #0ea5e9;       /* Sky Blue 500 */
            --primary-hover: #0284c7; /* Sky Blue 600 */
            --accent: #f59e0b;        /* Amber (用于待办提醒) */
            --shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);
        }

        /* 🌑 暗黑模式 */
        [data-theme="dark"] {
            --bg-body: #0f172a;
            --bg-card: #1e293b;
            --text-main: #f1f5f9;
            --text-sub: #94a3b8;
            --border: #334155;
            --hover-bg: rgba(255,255,255,0.05);
            --input-bg: #0f172a;
        }

        /* ☀️ 明亮模式 */
        [data-theme="light"] {
            --bg-body: #f1f5f9;
            --bg-card: #ffffff;
            --text-main: #1e293b;
            --text-sub: #64748b;
            --border: #e2e8f0;
            --hover-bg: #f8fafc;
            --input-bg: #f8fafc;
        }

        body {
            margin: 0; padding: 0;
            background-color: var(--bg-body);
            color: var(--text-main);
            font-family: 'Noto Sans SC', 'Inter', sans-serif;
            transition: background-color 0.3s, color 0.3s;
        }

        form { display: flex; flex-direction: column; min-height: 100vh; }

        /* === 导航栏 === */
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

        /* === 主内容区 === */
        .main-content {
            flex: 1; padding: 40px; max-width: 1400px; margin: 0 auto; width: 100%; box-sizing: border-box;
        }
        .page-header { margin-bottom: 30px; display: flex; justify-content: space-between; align-items: flex-end; }
        .page-title { font-size: 24px; font-weight: 700; margin: 0; color: var(--text-main); }
        .page-subtitle { color: var(--text-sub); margin-top: 5px; font-size: 14px; }

        /* === 数据卡片行 === */
        .stats-row {
            display: grid; grid-template-columns: repeat(3, 1fr); gap: 24px; margin-bottom: 40px;
        }
        .stat-card {
            background-color: var(--bg-card);
            border: 1px solid var(--border);
            border-radius: 12px; padding: 24px;
            display: flex; align-items: center; justify-content: space-between;
            box-shadow: var(--shadow);
            position: relative; overflow: hidden;
            transition: all 0.3s;
        }

        /* 快捷入口卡片样式 */
        a.stat-card { text-decoration: none; cursor: pointer; }
        a.stat-card:hover { border-color: var(--primary); transform: translateY(-2px); }

        /* 待办事项高亮样式 (当后端添加 .card-alert 类时生效) */
        .stat-card.card-alert {
            border-color: var(--accent);
            background: rgba(245, 158, 11, 0.05);
        }
        .stat-card.card-alert .stat-icon-box { color: var(--accent); background: rgba(245, 158, 11, 0.15); }
        .stat-card.card-alert .value { color: var(--accent); }
        .stat-card.card-alert::after {
            content: ''; position: absolute; top: 0; left: 0; width: 4px; height: 100%; background: var(--accent);
        }

        .stat-info h3 { margin: 0; font-size: 15px; color: var(--text-sub); font-weight: 500; }
        .stat-info .value { font-size: 32px; font-weight: 700; color: var(--text-main); margin-top: 8px; font-family: 'Inter', sans-serif; }
        .stat-info .link-text { font-size: 13px; color: var(--primary); margin-top: 5px; display: inline-flex; align-items: center; gap: 5px; }
        
        .stat-icon-box {
            width: 48px; height: 48px; border-radius: 10px;
            background: rgba(14, 165, 233, 0.1); color: var(--primary);
            display: flex; align-items: center; justify-content: center; font-size: 24px;
        }

        /* === 表格区域 === */
        .table-section {
            background-color: var(--bg-card);
            border: 1px solid var(--border);
            border-radius: 12px; padding: 24px;
            box-shadow: var(--shadow);
        }
        .table-header {
            display: flex; justify-content: space-between; align-items: center;
            margin-bottom: 20px; padding-bottom: 15px;
            border-bottom: 1px solid var(--border);
        }
        .table-title { font-size: 18px; font-weight: 600; color: var(--text-main); display: flex; align-items: center; gap: 10px; }

        /* 下拉框样式 */
        .filter-box { display: flex; align-items: center; gap: 10px; font-size: 14px; color: var(--text-sub); }
        .form-select {
            background-color: var(--input-bg);
            border: 1px solid var(--border);
            color: var(--text-main);
            padding: 8px 12px; border-radius: 6px;
            font-family: inherit; font-size: 14px;
            outline: none; cursor: pointer;
        }
        .form-select:focus { border-color: var(--primary); }

        /* GridView */
        .custom-grid { width: 100%; border-collapse: collapse; color: var(--text-main); }
        .custom-grid th {
            text-align: left; padding: 14px 16px;
            color: var(--text-sub); font-size: 13px; font-weight: 600;
            border-bottom: 1px solid var(--border);
        }
        .custom-grid td { padding: 16px; border-bottom: 1px solid var(--border); font-size: 14px; vertical-align: middle; }
        .custom-grid tr:last-child td { border-bottom: none; }
        .custom-grid tr:hover { background-color: var(--hover-bg); }

        /* 状态徽章 */
        .badge { padding: 4px 10px; border-radius: 20px; font-size: 12px; font-weight: 600; display: inline-flex; align-items: center; gap: 5px; }
        .badge-success { background: rgba(16, 185, 129, 0.15); color: #10b981; border: 1px solid rgba(16, 185, 129, 0.2); }
        .badge-warning { background: rgba(245, 158, 11, 0.15); color: #f59e0b; border: 1px solid rgba(245, 158, 11, 0.2); }

        /* 表格操作按钮 */
        .btn-icon {
            text-decoration: none; padding: 8px 14px; border-radius: 6px; font-size: 13px; font-weight: 500;
            display: inline-flex; align-items: center; gap: 6px; transition: all 0.2s; border: 1px solid transparent;
        }
        .btn-config { background: var(--hover-bg); color: var(--text-sub); border-color: var(--border); }
        .btn-config:hover { border-color: var(--text-sub); color: var(--text-main); }
        
        .btn-grade { background: rgba(14, 165, 233, 0.1); color: var(--primary); border-color: rgba(14, 165, 233, 0.2); }
        .btn-grade:hover { background: var(--primary); color: #fff; }

        .btn-create {
            background: linear-gradient(135deg, var(--primary) 0%, #0284c7 100%);
            color: white; padding: 10px 20px; border-radius: 8px; text-decoration: none; font-size: 14px; font-weight: 600;
            display: inline-flex; align-items: center; gap: 8px; box-shadow: 0 4px 10px rgba(14, 165, 233, 0.3);
            transition: transform 0.2s;
        }
        .btn-create:hover { transform: translateY(-2px); }

    </style>
</head>
<body>
    <form id="form1" runat="server">
        <nav class="navbar">
            <div class="brand">
                <i class="fas fa-chalkboard-teacher"></i> 教师工作台
            </div>
            
            <div class="nav-right">
                <button type="button" class="theme-toggle-btn" onclick="toggleTheme()" title="切换主题">
                    <i class="fas fa-adjust" id="themeIcon"></i>
                </button>

                <div style="display:flex; align-items:center; gap:20px; font-size:14px;">
                    <span style="color:var(--text-sub);">
                        欢迎您，<asp:Label ID="lblName" runat="server" style="color:var(--text-main); font-weight:600;"></asp:Label> 老师
                    </span>
                    <span style="color:var(--border);">|</span>
                    <asp:LinkButton ID="btnLogout" runat="server" OnClick="btnLogout_Click" CssClass="btn-logout">
                        <i class="fas fa-sign-out-alt"></i> 退出
                    </asp:LinkButton>
                </div>
            </div>
        </nav>

        <div class="main-content">
            
            <div class="page-header">
                <div>
                    <h1 class="page-title">教学管理概览</h1>
                    <p class="page-subtitle">管理您的课程、学生成绩及审批事项</p>
                </div>
                <a href="CourseApply.aspx" class="btn-create">
                    <i class="fas fa-plus-circle"></i> 申报新课程
                </a>
            </div>

            <div class="stats-row">
                <asp:Panel ID="pnlTodo" runat="server" CssClass="stat-card">
                    <div class="stat-info">
                        <h3>待审批补考</h3>
                        <div class="value"><asp:Literal ID="ltlTodoCount" runat="server" Text="0"></asp:Literal></div>
                        <a href="RetakeManage.aspx" class="link-text">
                            前往审批 <i class="fas fa-arrow-right" style="font-size:12px;"></i>
                        </a>
                    </div>
                    <div class="stat-icon-box"><i class="fas fa-bell"></i></div>
                </asp:Panel>

                <a href="CourseApply.aspx" class="stat-card">
                    <div class="stat-info">
                        <h3>新课申报</h3>
                        <div class="link-text" style="color:var(--text-sub);">点击提交下学期计划</div>
                    </div>
                    <div class="stat-icon-box"><i class="fas fa-file-signature"></i></div>
                </a>

                <div class="stat-card">
                    <div class="stat-info">
                        <h3>当前学期</h3>
                        <div class="value" style="font-size:20px;">2025-2026-1</div>
                    </div>
                    <div class="stat-icon-box"><i class="fas fa-calendar-alt"></i></div>
                </div>
            </div>

            <div class="table-section">
                <div class="table-header">
                    <div class="table-title">
                        <i class="fas fa-book" style="color:var(--primary);"></i> 我的授课列表
                    </div>
                    <div class="filter-box">
                        <i class="fas fa-filter"></i>
                        <asp:DropDownList ID="ddlTerm" runat="server" CssClass="form-select" AutoPostBack="true" OnSelectedIndexChanged="ddlTerm_SelectedIndexChanged">
                        </asp:DropDownList>
                    </div>
                </div>

                <asp:GridView ID="gvMyCourses" runat="server" CssClass="custom-grid" AutoGenerateColumns="False" 
                    OnRowCommand="gvMyCourses_RowCommand" GridLines="None" EmptyDataText="当前学期暂无课程">
                    <Columns>
                        <asp:BoundField DataField="CourseName" HeaderText="课程名称" />
                        <asp:BoundField DataField="Credit" HeaderText="学分" ItemStyle-Width="80px" ItemStyle-HorizontalAlign="Center" HeaderStyle-HorizontalAlign="Center" />
                        
                        <asp:TemplateField HeaderText="选课人数 / 容量">
                            <ItemTemplate>
                                <%# Eval("StudentCount") %> / <%# Eval("MaxCapacity") %>
                            </ItemTemplate>
                        </asp:TemplateField>

                        <asp:TemplateField HeaderText="状态">
                            <ItemTemplate>
                                <%# GetStatusHtml(Eval("Status")) %>
                            </ItemTemplate>
                        </asp:TemplateField>

                        <asp:TemplateField HeaderText="管理操作" ItemStyle-Width="220px">
                            <ItemTemplate>
                                <asp:LinkButton runat="server" CommandName="Config" CommandArgument='<%# Eval("CourseId") %>' CssClass="btn-icon btn-config">
                                    <i class="fas fa-cog"></i> 权重设置
                                </asp:LinkButton>
                                <asp:LinkButton runat="server" CommandName="Grade" CommandArgument='<%# Eval("CourseId") %>' CssClass="btn-icon btn-grade">
                                    <i class="fas fa-edit"></i> 录入成绩
                                </asp:LinkButton>
                            </ItemTemplate>
                        </asp:TemplateField>
                    </Columns>
                    <EmptyDataTemplate>
                        <div style="padding:40px; text-align:center; color:var(--text-sub);">
                            <i class="fas fa-inbox" style="font-size:32px; margin-bottom:10px; opacity:0.5;"></i>
                            <p>您在所选学期暂未开设任何课程。</p>
                        </div>
                    </EmptyDataTemplate>
                </asp:GridView>
            </div>

        </div>
    </form>

    <script>
        // === 主题切换逻辑 (与 Default.aspx 保持一致) ===
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

        // 初始化图标
        const saved = localStorage.getItem('theme') || 'dark';
        updateIcon(saved);
    </script>
</body>
</html>