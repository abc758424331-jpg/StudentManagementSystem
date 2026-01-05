<%@ Page Language="C#" AutoEventWireup="true" CodeFile="Default.aspx.cs" Inherits="_Default" MaintainScrollPositionOnPostback="true" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml" data-theme="dark">
<head runat="server">
    <title>总控台 | 智慧教务中枢</title>
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.4/css/all.min.css" rel="stylesheet" />
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;600;700&family=Rajdhani:wght@500;700&display=swap" rel="stylesheet">
    
    <style>
        /* === 1. 核心主题变量 (管理员 - 翡翠绿/信号绿) === */
        :root {
            --ease-elastic: cubic-bezier(0.68, -0.55, 0.265, 1.55);
            --ease-smooth: cubic-bezier(0.25, 0.46, 0.45, 0.94);
        }

        [data-theme="dark"] {
            --bg-color: #0b1120;
            --bg-gradient: radial-gradient(circle at 50% 50%, #1e293b 0%, #0b1120 100%);
            --glass-panel: rgba(30, 41, 59, 0.75);
            --glass-border: rgba(255, 255, 255, 0.1);
            --text-main: #f8fafc;
            --text-sub: #94a3b8;
            --primary: #10b981; /* 翡翠绿 */
            --primary-shadow: rgba(16, 185, 129, 0.4);
            --danger: #ef4444;
            --warning: #f59e0b; /* 橙色 */
            --table-hover: rgba(16, 185, 129, 0.05);
        }

        body {
            margin: 0; padding: 0;
            background: var(--bg-color); background-image: var(--bg-gradient);
            color: var(--text-main); font-family: 'Inter', sans-serif;
            overflow-x: hidden; min-height: 100vh;
        }

        #particle-canvas { position: fixed; top: 0; left: 0; width: 100%; height: 100%; z-index: -1; pointer-events: none; }
        .fade-in { animation: fadeIn 0.8s var(--ease-smooth) forwards; opacity: 0; transform: translateY(20px); }
        @keyframes fadeIn { to { opacity: 1; transform: translateY(0); } }

        /* 导航栏 */
        .navbar {
            height: 70px; padding: 0 40px;
            background: var(--glass-panel); backdrop-filter: blur(20px);
            border-bottom: 1px solid var(--glass-border);
            display: flex; align-items: center; justify-content: space-between;
            position: fixed; top: 0; width: 100%; z-index: 1000; box-sizing: border-box;
        }
        .brand {
            font-family: 'Rajdhani', sans-serif; font-weight: 700; font-size: 24px;
            letter-spacing: 2px; color: var(--text-main); text-decoration:none;
            display: flex; align-items: center; gap: 10px;
        }
        .brand i { color: var(--primary); }

        .btn-logout {
            background: transparent; border: 1px solid var(--danger); color: var(--danger);
            padding: 6px 16px; border-radius: 6px; cursor: pointer; transition: 0.3s;
            font-size: 12px; letter-spacing: 1px; font-weight: 600;
        }
        .btn-logout:hover { background: var(--danger); color: #fff; box-shadow: 0 0 15px rgba(239, 68, 68, 0.4); }

        /* 快捷操作按钮组 */
        .action-group { display: flex; align-items: center; gap: 15px; }
        
        .btn-action {
            text-decoration: none; display: inline-flex; align-items: center; gap: 8px;
            padding: 8px 16px; border-radius: 6px; font-size: 13px; font-weight: 700;
            transition: 0.3s; border: 1px solid transparent;
        }
        
        /* 绿色按钮 (新课) */
        .btn-green { background: rgba(16, 185, 129, 0.1); color: var(--primary); border-color: var(--primary); }
        .btn-green:hover { background: var(--primary); color: #fff; box-shadow: 0 0 20px var(--primary-shadow); transform: translateY(-2px); }

        /* 橙色按钮 (解锁) */
        .btn-orange { background: rgba(245, 158, 11, 0.1); color: var(--warning); border-color: var(--warning); }
        .btn-orange:hover { background: var(--warning); color: #fff; box-shadow: 0 0 20px rgba(245, 158, 11, 0.4); transform: translateY(-2px); }


        /* 主容器 */
        .main-container { max-width: 1200px; margin: 100px auto 50px; padding: 0 20px; }

        .welcome-header { margin-bottom: 40px; display: flex; justify-content: space-between; align-items: flex-end; }
        .welcome-header h1 { font-family: 'Rajdhani'; font-size: 36px; margin: 0; letter-spacing: 1px; }
        .welcome-header p { color: var(--text-sub); margin-top: 5px; font-size: 14px; }

        /* HUD 仪表盘 */
        .dashboard-grid {
            display: grid; grid-template-columns: repeat(3, 1fr); gap: 20px; margin-bottom: 40px;
        }
        .hud-card {
            background: var(--glass-panel); border: 1px solid var(--glass-border);
            border-radius: 16px; padding: 25px; display: flex; align-items: center; gap: 20px;
            transition: 0.3s;
        }
        .hud-card:hover { transform: translateY(-5px); border-color: var(--primary); box-shadow: 0 10px 30px -10px rgba(0,0,0,0.5); }
        
        .hud-icon {
            width: 60px; height: 60px; border-radius: 16px; background: rgba(255,255,255,0.05);
            display: flex; align-items: center; justify-content: center; font-size: 28px; color: var(--text-sub);
        }
        .hud-info h4 { margin: 0; font-size: 12px; color: var(--text-sub); text-transform: uppercase; letter-spacing: 1px; }
        .hud-info .value { font-family: 'Rajdhani'; font-size: 42px; font-weight: 700; color: var(--text-main); line-height: 1; margin-top: 5px; }

        /* 列表区域 */
        .section-title { font-family: 'Rajdhani'; font-size: 24px; font-weight: 700; margin-bottom: 20px; display: flex; align-items: center; gap: 10px; color: var(--primary); }
        .grid-wrapper {
            background: var(--glass-panel); border: 1px solid var(--glass-border);
            border-radius: 16px; overflow: hidden; margin-bottom: 40px;
        }
        .cyber-grid { width: 100%; border-collapse: collapse; }
        .cyber-grid th {
            background: rgba(0,0,0,0.2); color: var(--text-sub); padding: 15px 25px; text-align: left;
            font-size: 12px; text-transform: uppercase; border-bottom: 1px solid var(--glass-border);
        }
        .cyber-grid td {
            padding: 15px 25px; color: var(--text-main); border-bottom: 1px solid var(--glass-border);
            font-size: 14px; vertical-align: middle;
        }
        .cyber-grid tr:hover td { background: var(--table-hover); }

        .btn-del {
            color: var(--danger); background: transparent; border: 1px solid var(--danger);
            padding: 4px 10px; border-radius: 4px; font-size: 11px; cursor: pointer; transition: 0.2s;
        }
        .btn-del:hover { background: var(--danger); color: #fff; }
        
        .add-btn { float: right; font-size: 14px; text-decoration: none; color: var(--primary); border: 1px solid var(--primary); padding: 5px 15px; border-radius: 20px; }
        .add-btn:hover { background: var(--primary); color: #fff; }
    </style>
</head>
<body>
    <canvas id="particle-canvas"></canvas>

    <form id="form1" runat="server">
    
    <div class="navbar fade-in">
        <a href="#" class="brand">
            <i class="fas fa-shield-alt"></i> MASTER CONTROL
        </a>
        
        <div class="action-group">
            <a href="CourseApproval.aspx" class="btn-action btn-green">
                <i class="fas fa-bell"></i> PENDING COURSES
            </a>

            <a href="AdminUnlock.aspx" class="btn-action btn-orange">
                <i class="fas fa-key"></i> UNLOCK REQUESTS
            </a>

            <div style="width:10px;"></div>
            <asp:Button ID="btnLogout" runat="server" Text="LOGOUT" OnClick="btnLogout_Click" CssClass="btn-logout" />
        </div>
    </div>

    <div class="main-container fade-in">
        
        <div class="welcome-header">
            <div>
                <h1>SYSTEM OVERVIEW</h1>
                <p>Welcome back, Administrator. All nodes operational.</p>
            </div>
            <div style="font-family:'Rajdhani'; font-size:18px; color:var(--primary);">
                <i class="fas fa-user-shield"></i> <asp:Label ID="lblName" runat="server"></asp:Label>
            </div>
        </div>

        <div class="dashboard-grid">
            <div class="hud-card">
                <div class="hud-icon" style="color:#3b82f6;"><i class="fas fa-user-graduate"></i></div>
                <div class="hud-info"><h4>Total Students</h4><asp:Literal ID="ltlStudents" runat="server">0</asp:Literal></div>
            </div>
            <div class="hud-card">
                <div class="hud-icon" style="color:#f59e0b;"><i class="fas fa-chalkboard-teacher"></i></div>
                <div class="hud-info"><h4>Total Faculty</h4><asp:Literal ID="ltlTeachers" runat="server">0</asp:Literal></div>
            </div>
            <div class="hud-card">
                <div class="hud-icon" style="color:#10b981;"><i class="fas fa-cube"></i></div>
                <div class="hud-info"><h4>Active Courses</h4><asp:Literal ID="ltlCourses" runat="server">0</asp:Literal></div>
            </div>
        </div>

        <div class="section-title">
            <span><i class="fas fa-users"></i> STUDENT DATABASE</span>
            <a href="AddStudent.aspx" class="add-btn"><i class="fas fa-plus"></i> Add Student</a>
        </div>
        <div class="grid-wrapper">
            <asp:GridView ID="gvStudents" runat="server" AutoGenerateColumns="False" DataKeyNames="StudentId"
                CssClass="cyber-grid" GridLines="None" AllowPaging="True" PageSize="5" 
                OnPageIndexChanging="gvStudents_PageIndexChanging" OnRowCommand="gvStudents_RowCommand">
                <Columns>
                    <asp:BoundField DataField="StuNumber" HeaderText="ID" />
                    <asp:BoundField DataField="Name" HeaderText="NAME" ItemStyle-Font-Bold="true" />
                    <asp:BoundField DataField="ClassName" HeaderText="CLASS" />
                    <asp:BoundField DataField="Phone" HeaderText="CONTACT" />
                    <asp:TemplateField HeaderText="ACTION" ItemStyle-HorizontalAlign="Right">
                        <ItemTemplate>
                            <asp:Button ID="btnDelStu" runat="server" Text="DELETE" 
                                CommandName="DelStudent" CommandArgument='<%# Eval("StudentId") %>'
                                CssClass="btn-del" OnClientClick="return confirm('WARNING: Deleting this student will wipe all their academic records. Proceed?');" />
                        </ItemTemplate>
                    </asp:TemplateField>
                </Columns>
            </asp:GridView>
        </div>

        <div class="section-title">
            <span><i class="fas fa-id-badge"></i> FACULTY DIRECTORY</span>
            <a href="AddTeacher.aspx" class="add-btn"><i class="fas fa-plus"></i> Add Teacher</a>
        </div>
        <div class="grid-wrapper">
            <asp:GridView ID="gvTeachers" runat="server" AutoGenerateColumns="False" DataKeyNames="TeacherId"
                CssClass="cyber-grid" GridLines="None" AllowPaging="True" PageSize="5"
                OnPageIndexChanging="gvTeachers_PageIndexChanging" OnRowCommand="gvTeachers_RowCommand">
                <Columns>
                    <asp:BoundField DataField="WorkNo" HeaderText="WORK ID" />
                    <asp:BoundField DataField="Name" HeaderText="NAME" ItemStyle-Font-Bold="true" />
                    <asp:BoundField DataField="Phone" HeaderText="CONTACT" />
                    <asp:TemplateField HeaderText="ACTION" ItemStyle-HorizontalAlign="Right">
                        <ItemTemplate>
                            <asp:Button ID="btnDelTea" runat="server" Text="DELETE" 
                                CommandName="DelTeacher" CommandArgument='<%# Eval("TeacherId") %>'
                                CssClass="btn-del" OnClientClick="return confirm('WARNING: Deleting this teacher will remove all their courses. Proceed?');" />
                        </ItemTemplate>
                    </asp:TemplateField>
                </Columns>
            </asp:GridView>
        </div>

    </div>
    </form>

    <script>
        // === 绿色系粒子特效 ===
        const canvas = document.getElementById('particle-canvas');
        const ctx = canvas.getContext('2d');
        let width, height, particles = [];

        function resize() { width = canvas.width = window.innerWidth; height = canvas.height = window.innerHeight; }
        class Particle {
            constructor() { this.x = Math.random() * width; this.y = Math.random() * height; this.vx = (Math.random() - .5) * 0.5; this.vy = (Math.random() - .5) * 0.5; this.size = Math.random() * 2; }
            update() { this.x += this.vx; this.y += this.vy; if (this.x < 0 || this.x > width) this.vx *= -1; if (this.y < 0 || this.y > height) this.vy *= -1; }
            draw() { ctx.beginPath(); ctx.arc(this.x, this.y, this.size, 0, Math.PI * 2); ctx.fillStyle = 'rgba(16, 185, 129, 0.3)'; ctx.fill(); }
        }
        function init() { particles = []; for (let i = 0; i < 60; i++) particles.push(new Particle()); }
        function animate() { ctx.clearRect(0, 0, width, height); particles.forEach(p => { p.update(); p.draw(); }); requestAnimationFrame(animate); }

        window.addEventListener('resize', () => { resize(); init(); }); resize(); init(); animate();
    </script>
</body>
</html>