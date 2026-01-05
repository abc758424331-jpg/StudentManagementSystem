<%@ Page Language="C#" AutoEventWireup="true" CodeFile="Default.aspx.cs" Inherits="_Default" MaintainScrollPositionOnPostback="true" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>教务总控台 | 智慧教务系统</title>
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.4/css/all.min.css" rel="stylesheet" />
    <link href="https://fonts.googleapis.com/css2?family=Noto+Sans+SC:wght@300;400;500;700&family=Inter:wght@400;600&display=swap" rel="stylesheet">
    
    <script>
        // === 关键：在页面渲染前立即应用主题，防止闪烁 ===
        (function () {
            const savedTheme = localStorage.getItem('theme') || 'dark';
            document.documentElement.setAttribute('data-theme', savedTheme);
        })();
    </script>

    <style>
        /* === 1. 基础变量 (支持明暗切换) === */
        :root {
            --primary: #10b981;
            --primary-hover: #059669;
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
        }

        /* ☀️ 明亮模式 */
        [data-theme="light"] {
            --bg-body: #f1f5f9;
            --bg-card: #ffffff;
            --text-main: #1e293b;
            --text-sub: #64748b;
            --border: #e2e8f0;
            --hover-bg: #f8fafc;
        }

        body {
            margin: 0; padding: 0;
            background-color: var(--bg-body);
            color: var(--text-main);
            font-family: 'Noto Sans SC', 'Inter', sans-serif;
            transition: background-color 0.3s, color 0.3s;
        }

        form { display: flex; flex-direction: column; min-height: 100vh; }

        /* === 2. 顶部导航栏 === */
        .navbar {
            background-color: var(--bg-card);
            border-bottom: 1px solid var(--border);
            padding: 0 40px;
            height: 64px;
            display: flex; justify-content: space-between; align-items: center;
            position: sticky; top: 0; z-index: 100;
            box-shadow: var(--shadow);
            transition: background-color 0.3s, border-color 0.3s;
        }

        .brand {
            font-size: 20px; font-weight: 700; color: var(--primary);
            display: flex; align-items: center; gap: 10px;
        }

        .nav-right { display: flex; align-items: center; gap: 20px; }

        .user-menu {
            display: flex; align-items: center; gap: 20px; font-size: 14px;
        }
        .user-name { color: var(--text-sub); }
        .btn-logout {
            color: #ef4444; text-decoration: none; font-weight: 600;
            transition: opacity 0.2s; display: flex; align-items: center; gap: 6px;
        }
        .btn-logout:hover { opacity: 0.8; }

        /* 主题切换按钮 */
        .theme-toggle-btn {
            background: none; border: none; cursor: pointer;
            color: var(--text-sub); font-size: 18px;
            padding: 8px; border-radius: 50%;
            transition: all 0.2s;
            display: flex; align-items: center; justify-content: center;
        }
        .theme-toggle-btn:hover {
            background-color: var(--hover-bg);
            color: var(--text-main);
        }

        /* === 3. 主内容区 === */
        .main-content {
            flex: 1; padding: 40px; max-width: 1400px; margin: 0 auto; width: 100%; box-sizing: border-box;
        }

        .page-header { margin-bottom: 30px; }
        .page-title { font-size: 24px; font-weight: 700; margin: 0; color: var(--text-main); }
        .page-subtitle { color: var(--text-sub); margin-top: 5px; font-size: 14px; }

        /* === 4. 数据仪表盘 === */
        .stats-row {
            display: grid; grid-template-columns: repeat(3, 1fr); gap: 24px; margin-bottom: 40px;
        }

        .stat-card {
            background-color: var(--bg-card);
            border: 1px solid var(--border);
            border-radius: 12px; padding: 24px;
            display: flex; align-items: center; justify-content: space-between;
            box-shadow: var(--shadow);
            transition: background-color 0.3s, border-color 0.3s;
        }

        .stat-info h3 { margin: 0; font-size: 14px; color: var(--text-sub); font-weight: 500; }
        .stat-info .value { 
            font-size: 32px; font-weight: 700; color: var(--text-main); margin-top: 8px; 
            font-family: 'Inter', sans-serif; 
        }
        .stat-icon-box {
            width: 48px; height: 48px; border-radius: 10px;
            background: rgba(16, 185, 129, 0.1); color: var(--primary);
            display: flex; align-items: center; justify-content: center; font-size: 24px;
        }

        /* === 5. 快捷操作区 === */
        .action-section { margin-bottom: 40px; }
        .section-label { 
            font-size: 16px; font-weight: 600; color: var(--text-main); margin-bottom: 16px; 
            border-left: 4px solid var(--primary); padding-left: 12px;
        }

        .action-grid { display: flex; gap: 16px; flex-wrap: wrap; }

        .btn-quick {
            background-color: var(--bg-card);
            border: 1px solid var(--border);
            color: var(--text-main);
            padding: 14px 24px; border-radius: 8px;
            text-decoration: none; font-size: 14px; font-weight: 500;
            display: flex; align-items: center; gap: 10px;
            transition: all 0.2s; box-shadow: var(--shadow);
        }
        .btn-quick i { color: var(--primary); font-size: 16px; }
        
        .btn-quick:hover {
            border-color: var(--primary);
            background-color: var(--hover-bg);
            transform: translateY(-2px);
        }

        /* === 6. 表格区域 === */
        .table-section {
            background-color: var(--bg-card);
            border: 1px solid var(--border);
            border-radius: 12px; padding: 24px; margin-bottom: 40px;
            box-shadow: var(--shadow);
            transition: background-color 0.3s, border-color 0.3s;
        }
        .table-header {
            display: flex; justify-content: space-between; align-items: center;
            margin-bottom: 20px; padding-bottom: 15px;
            border-bottom: 1px solid var(--border);
        }
        .table-title { font-size: 18px; font-weight: 600; color: var(--text-main); }

        .custom-grid { width: 100%; border-collapse: collapse; color: var(--text-main); }
        .custom-grid th {
            text-align: left; padding: 12px 16px;
            color: var(--text-sub); font-size: 13px; font-weight: 600;
            border-bottom: 1px solid var(--border);
        }
        .custom-grid td {
            padding: 16px; border-bottom: 1px solid var(--border); font-size: 14px;
        }
        .custom-grid tr:last-child td { border-bottom: none; }
        .custom-grid tr:hover { background-color: var(--hover-bg); }

        .btn-del {
            color: #ef4444; cursor: pointer; text-decoration: none;
            font-size: 13px; padding: 6px 12px; border-radius: 4px;
            background: rgba(239, 68, 68, 0.1); transition: all 0.2s;
        }
        .btn-del:hover { background: #ef4444; color: #fff; }

        /* 分页 */
        .pager-row td { padding: 20px 0 !important; border: none !important; }
        .pager-row a, .pager-row span {
            padding: 6px 12px; margin: 0 4px; border-radius: 4px; text-decoration: none;
            border: 1px solid var(--border); color: var(--text-sub);
        }
        .pager-row span { background: var(--primary); color: #fff; border-color: var(--primary); }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <nav class="navbar">
            <div class="brand">
                <i class="fas fa-layer-group"></i> 智慧教务总控台
            </div>
            
            <div class="nav-right">
                <button type="button" class="theme-toggle-btn" onclick="toggleTheme()" title="切换主题">
                    <i class="fas fa-adjust" id="themeIcon"></i>
                </button>

                <div class="user-menu">
                    <span class="user-name">
                        管理员：<asp:Label ID="lblName" runat="server"></asp:Label>
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
                <h1 class="page-title">系统概览</h1>
                <p class="page-subtitle">实时监控教务数据与人员档案管理</p>
            </div>

            <div class="stats-row">
                <div class="stat-card">
                    <div class="stat-info">
                        <h3>在籍学生总数</h3>
                        <div class="value"><asp:Literal ID="ltlStudents" runat="server" Text="0"></asp:Literal></div>
                    </div>
                    <div class="stat-icon-box"><i class="fas fa-user-graduate"></i></div>
                </div>
                <div class="stat-card">
                    <div class="stat-info">
                        <h3>在职教师总数</h3>
                        <div class="value"><asp:Literal ID="ltlTeachers" runat="server" Text="0"></asp:Literal></div>
                    </div>
                    <div class="stat-icon-box"><i class="fas fa-chalkboard-teacher"></i></div>
                </div>
                <div class="stat-card">
                    <div class="stat-info">
                        <h3>当前开设课程</h3>
                        <div class="value"><asp:Literal ID="ltlCourses" runat="server" Text="0"></asp:Literal></div>
                    </div>
                    <div class="stat-icon-box"><i class="fas fa-book"></i></div>
                </div>
            </div>

            <div class="action-section">
                <div class="section-label">常用管理操作</div>
                <div class="action-grid">
                    <a href="AddStudent.aspx" class="btn-quick">
                        <i class="fas fa-user-plus"></i> 录入学生
                    </a>
                    <a href="AddTeacher.aspx" class="btn-quick">
                        <i class="fas fa-user-tie"></i> 录入教师
                    </a>
                    <a href="CourseApproval.aspx" class="btn-quick">
                        <i class="fas fa-check-circle"></i> 新课审批
                    </a>
                    <a href="AdminUnlock.aspx" class="btn-quick">
                        <i class="fas fa-lock-open"></i> 成绩解锁
                    </a>
                    <a href="TeacherList.aspx" class="btn-quick">
                        <i class="fas fa-list"></i> 教师名录
                    </a>
                </div>
            </div>

            <div class="table-section">
                <div class="table-header">
                    <div class="table-title">最新学生档案</div>
                </div>
                <asp:GridView ID="gvStudents" runat="server" CssClass="custom-grid" AutoGenerateColumns="False" 
                    OnRowCommand="gvStudents_RowCommand" AllowPaging="True" PageSize="5" OnPageIndexChanging="gvStudents_PageIndexChanging"
                    GridLines="None" EmptyDataText="暂无数据">
                    <Columns>
                        <asp:BoundField DataField="StuNumber" HeaderText="学号" />
                        <asp:BoundField DataField="Name" HeaderText="姓名" />
                        <asp:BoundField DataField="ClassName" HeaderText="行政班级" />
                        <asp:BoundField DataField="Phone" HeaderText="联系方式" />
                        <asp:TemplateField HeaderText="操作" ItemStyle-Width="120px">
                            <ItemTemplate>
                                <asp:LinkButton runat="server" CommandName="DelStudent" CommandArgument='<%# Eval("StudentId") %>' 
                                    CssClass="btn-del"
                                    OnClientClick="return confirm('⚠️ 确定要删除该学生档案吗？\n删除后不可恢复！');">
                                    <i class="fas fa-trash-alt"></i> 删除
                                </asp:LinkButton>
                            </ItemTemplate>
                        </asp:TemplateField>
                    </Columns>
                    <PagerStyle CssClass="pager-row" HorizontalAlign="Right" />
                </asp:GridView>
            </div>

            <div class="table-section">
                <div class="table-header">
                    <div class="table-title">最新教师档案</div>
                </div>
                <asp:GridView ID="gvTeachers" runat="server" CssClass="custom-grid" AutoGenerateColumns="False" 
                    OnRowCommand="gvTeachers_RowCommand" AllowPaging="True" PageSize="5" OnPageIndexChanging="gvTeachers_PageIndexChanging"
                    GridLines="None" EmptyDataText="暂无数据">
                    <Columns>
                        <asp:BoundField DataField="WorkNo" HeaderText="工号" />
                        <asp:BoundField DataField="Name" HeaderText="姓名" />
                        <asp:BoundField DataField="Phone" HeaderText="办公电话" />
                        <asp:TemplateField HeaderText="操作" ItemStyle-Width="120px">
                            <ItemTemplate>
                                <asp:LinkButton runat="server" CommandName="DelTeacher" CommandArgument='<%# Eval("TeacherId") %>' 
                                    CssClass="btn-del"
                                    OnClientClick="return confirm('⚠️ 确定要删除该教师档案吗？\n该操作将强制下架其所有课程！');">
                                    <i class="fas fa-trash-alt"></i> 删除
                                </asp:LinkButton>
                            </ItemTemplate>
                        </asp:TemplateField>
                    </Columns>
                    <PagerStyle CssClass="pager-row" HorizontalAlign="Right" />
                </asp:GridView>
            </div>
        </div>
    </form>

    <script>
        // === 主题切换逻辑 ===
        function toggleTheme() {
            const current = document.documentElement.getAttribute('data-theme');
            const target = current === 'dark' ? 'light' : 'dark';

            document.documentElement.setAttribute('data-theme', target);
            localStorage.setItem('theme', target);
            updateIcon(target);
        }

        function updateIcon(theme) {
            const icon = document.getElementById('themeIcon');
            if (icon) {
                icon.className = theme === 'dark' ? 'fas fa-moon' : 'fas fa-sun';
            }
        }

        // 初始化图标状态
        const saved = localStorage.getItem('theme') || 'dark';
        updateIcon(saved);
    </script>
</body>
</html>