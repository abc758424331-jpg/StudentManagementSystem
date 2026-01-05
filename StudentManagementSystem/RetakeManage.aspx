<%@ Page Language="C#" AutoEventWireup="true" CodeFile="RetakeManage.aspx.cs" Inherits="RetakeManage" MaintainScrollPositionOnPostback="true" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>补考审批中心 | 智慧教务系统</title>
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.4/css/all.min.css" rel="stylesheet" />
    <link href="https://fonts.googleapis.com/css2?family=Noto+Sans+SC:wght@300;400;500;700&family=Inter:wght@400;600&display=swap" rel="stylesheet" />
    
    <script>
        // === 1. 页面加载前立即同步主题 ===
        (function() {
            const savedTheme = localStorage.getItem('theme') || 'dark';
            document.documentElement.setAttribute('data-theme', savedTheme);
        })();
    </script>

    <style>
        /* === 2. 教师版主题 (天际蓝) === */
        :root {
            --primary: #0ea5e9;
            --primary-hover: #0284c7;
            --success: #10b981;
            --danger: #ef4444;
            --warning: #f59e0b;
            --shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);
        }

        [data-theme="dark"] {
            --bg-body: #0f172a;
            --bg-card: #1e293b;
            --text-main: #f1f5f9;
            --text-sub: #94a3b8;
            --border: #334155;
            --hover-bg: rgba(255,255,255,0.05);
            --info-bg: rgba(14, 165, 233, 0.1);
        }

        [data-theme="light"] {
            --bg-body: #f1f5f9;
            --bg-card: #ffffff;
            --text-main: #1e293b;
            --text-sub: #64748b;
            --border: #e2e8f0;
            --hover-bg: #f8fafc;
            --info-bg: #e0f2fe;
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

        /* 顶部提示卡 */
        .info-alert {
            background: var(--info-bg); border-left: 4px solid var(--primary);
            padding: 16px 20px; border-radius: 8px; margin-bottom: 30px;
            color: var(--text-main); font-size: 14px; line-height: 1.6;
            display: flex; gap: 12px; align-items: flex-start;
        }
        .info-alert i { color: var(--primary); font-size: 18px; margin-top: 2px; }

        /* 表格容器 */
        .table-section {
            background-color: var(--bg-card);
            border: 1px solid var(--border);
            border-radius: 12px; padding: 24px;
            box-shadow: var(--shadow);
        }
        .table-header { margin-bottom: 20px; padding-bottom: 15px; border-bottom: 1px solid var(--border); }
        .table-title { font-size: 18px; font-weight: 600; color: var(--text-main); display: flex; align-items: center; gap: 10px; }
        
        .badge-count { 
            background: var(--warning); color: #fff; padding: 2px 8px; border-radius: 10px; font-size: 12px; margin-left: 5px; 
        }

        /* GridView */
        .custom-grid { width: 100%; border-collapse: collapse; color: var(--text-main); }
        .custom-grid th {
            text-align: left; padding: 14px 16px;
            color: var(--text-sub); font-size: 13px; font-weight: 600;
            border-bottom: 1px solid var(--border);
        }
        .custom-grid td { padding: 16px; border-bottom: 1px solid var(--border); font-size: 14px; vertical-align: middle; }
        .custom-grid tr:hover { background-color: var(--hover-bg); }

        /* 课程信息组合 */
        .course-meta { display: flex; flex-direction: column; }
        .course-name { font-weight: 600; font-size: 15px; }
        .course-term { font-size: 12px; color: var(--text-sub); margin-top: 2px; }

        /* 操作按钮组 */
        .action-group { display: flex; gap: 10px; justify-content: flex-end; }
        
        .btn-approve {
            background: rgba(16, 185, 129, 0.1); color: var(--success);
            border: 1px solid rgba(16, 185, 129, 0.2);
            padding: 6px 12px; border-radius: 6px; font-size: 13px; font-weight: 500;
            text-decoration: none; display: inline-flex; align-items: center; gap: 5px; transition: all 0.2s;
        }
        .btn-approve:hover { background: var(--success); color: white; transform: translateY(-1px); }

        .btn-reject {
            background: transparent; color: var(--text-sub);
            border: 1px solid var(--border);
            padding: 6px 12px; border-radius: 6px; font-size: 13px;
            text-decoration: none; display: inline-flex; align-items: center; gap: 5px; transition: all 0.2s;
        }
        .btn-reject:hover { border-color: var(--danger); color: var(--danger); }

    </style>
</head>
<body>
    <form id="form1" runat="server">
        <nav class="navbar">
            <div class="brand">
                <i class="fas fa-clipboard-check"></i> 补考审批中心
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
                <h1 class="page-title">申请审核队列</h1>
                <asp:LinkButton ID="btnBack" runat="server" PostBackUrl="~/TeacherHome.aspx" CssClass="btn-back">
                    <i class="fas fa-home"></i> 返回工作台
                </asp:LinkButton>
            </div>

            <div class="info-alert">
                <i class="fas fa-lightbulb"></i>
                <div>
                    <strong>审批说明：</strong><br/>
                    1. 请核对学生的原始成绩情况，确认是否符合补考资格。<br/>
                    2. <strong>批准</strong>后，学生将获得补考资格，且无法撤销申请。<br/>
                    3. <strong>驳回</strong>后，申请将被退回，学生需重新提交或联系教师。
                </div>
            </div>

            <div class="table-section">
                <div class="table-header">
                    <div class="table-title">
                        待处理申请 
                        <%-- 显示待办数量 --%>
                        <span class="badge-count"><%= gvRetakeList.Rows.Count %></span>
                    </div>
                </div>

                <asp:GridView ID="gvRetakeList" runat="server" CssClass="custom-grid" AutoGenerateColumns="False" 
                    OnRowCommand="gvRetakeList_RowCommand" GridLines="None" EmptyDataText="🎉 真棒！目前没有待处理的补考申请。">
                    <Columns>
                        <asp:BoundField DataField="StuNumber" HeaderText="学号" ItemStyle-Width="120px" />
                        <asp:BoundField DataField="StudentName" HeaderText="姓名" ItemStyle-Width="120px" ItemStyle-Font-Bold="true" />
                        
                        <asp:TemplateField HeaderText="申请课程">
                            <ItemTemplate>
                                <div class="course-meta">
                                    <span class="course-name"><%# Eval("CourseName") %></span>
                                    <span class="course-term"><%# Eval("Semester") %></span>
                                </div>
                            </ItemTemplate>
                        </asp:TemplateField>

                        <asp:TemplateField HeaderText="原始成绩" ItemStyle-HorizontalAlign="Center" HeaderStyle-HorizontalAlign="Center">
                            <ItemTemplate>
                                <span style="font-weight:600; font-family:'Inter'">
                                    <%-- 调用后端的 FormatScore 处理负分/缺考显示 --%>
                                    <%# FormatScore(Eval("OriginalScore")) %>
                                </span>
                            </ItemTemplate>
                        </asp:TemplateField>

                        <asp:TemplateField HeaderText="决策操作" ItemStyle-Width="200px" ItemStyle-HorizontalAlign="Right">
                            <ItemTemplate>
                                <div class="action-group">
                                    <asp:LinkButton ID="btnApprove" runat="server" CommandName="Approve" CommandArgument='<%# Eval("ScoreId") %>' 
                                        CssClass="btn-approve"
                                        OnClientClick="return confirm('✅ 确定批准该学生的补考申请吗？');">
                                        <i class="fas fa-check"></i> 批准
                                    </asp:LinkButton>

                                    <asp:LinkButton ID="btnReject" runat="server" CommandName="Reject" CommandArgument='<%# Eval("ScoreId") %>' 
                                        CssClass="btn-reject"
                                        OnClientClick="return confirm('⛔ 确定驳回该申请吗？\n驳回后学生需要重新提交。');">
                                        <i class="fas fa-times"></i> 驳回
                                    </asp:LinkButton>
                                </div>
                            </ItemTemplate>
                        </asp:TemplateField>
                    </Columns>
                    <EmptyDataTemplate>
                        <div style="padding:50px; text-align:center; color:var(--text-sub);">
                            <i class="fas fa-check-double" style="font-size:40px; margin-bottom:15px; opacity:0.3; color:var(--success);"></i>
                            <p style="font-size:15px;">当前所有申请均已处理完毕。</p>
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
            if(icon) icon.className = theme === 'dark' ? 'fas fa-moon' : 'fas fa-sun';
        }

        // 初始化
        const saved = localStorage.getItem('theme') || 'dark';
        updateIcon(saved);
    </script>
</body>
</html>
