<%@ Page Language="C#" AutoEventWireup="true" CodeFile="StudentScore.aspx.cs" Inherits="StudentScore" MaintainScrollPositionOnPostback="true" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml" data-theme="dark">
<head runat="server">
    <title>成绩查询 | 智慧教务中枢</title>
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.4/css/all.min.css" rel="stylesheet" />
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;600;700&family=Rajdhani:wght@500;700&display=swap" rel="stylesheet">
    
    <style>
        /* === 复用核心主题 === */
        :root { --ease-smooth: cubic-bezier(0.25, 0.46, 0.45, 0.94); }
        [data-theme="dark"] {
            --bg-color: #0b1120;
            --bg-gradient: radial-gradient(circle at 50% 50%, #1e293b 0%, #0b1120 100%);
            --glass-panel: rgba(30, 41, 59, 0.75);
            --glass-border: rgba(255, 255, 255, 0.1);
            --text-main: #f8fafc;
            --text-sub: #94a3b8;
            --primary: #06b6d4; 
            --accent: #f59e0b;
            --danger: #ef4444;
            --success: #10b981;
            
            --p-color-rgb: 6, 182, 212; 
            --l-color-rgb: 148, 163, 184;
            --table-hover: rgba(6, 182, 212, 0.05);
            --shadow-card: 0 20px 40px -10px rgba(0, 0, 0, 0.5);
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

        .btn-back {
            background: transparent; border: 1px solid var(--glass-border); color: var(--text-sub);
            padding: 8px 20px; border-radius: 8px; cursor: pointer; transition: 0.3s;
            font-size: 13px; text-decoration: none; display: flex; align-items: center; gap: 8px;
        }
        .btn-back:hover { background: var(--glass-border); color: var(--text-main); }

        /* 主容器 */
        .main-container { max-width: 1200px; margin: 110px auto 50px; padding: 0 20px; }

        /* 头部筛选区 */
        .filter-panel {
            background: var(--glass-panel); border: 1px solid var(--glass-border);
            border-radius: 16px; padding: 25px; margin-bottom: 30px;
            display: flex; justify-content: space-between; align-items: center;
            box-shadow: var(--shadow-card);
        }
        .filter-group { display: flex; align-items: center; gap: 15px; }
        .filter-label { font-family: 'Rajdhani'; font-weight: 700; color: var(--primary); letter-spacing: 1px; }
        
        .cyber-select {
            background: rgba(0,0,0,0.3); border: 1px solid var(--glass-border); color: var(--text-main);
            padding: 10px 20px; border-radius: 8px; outline: none; font-family: inherit; cursor: pointer;
            min-width: 200px; transition: 0.3s;
        }
        .cyber-select:hover { border-color: var(--primary); }

        /* 成绩统计胶囊 */
        .stats-capsule { display: flex; gap: 20px; }
        .stat-item { text-align: center; }
        .stat-val { font-family: 'Rajdhani'; font-size: 24px; font-weight: 700; display: block; }
        .stat-lbl { font-size: 11px; color: var(--text-sub); text-transform: uppercase; letter-spacing: 1px; }

        /* 成绩表格 */
        .grid-container {
            background: var(--glass-panel); border: 1px solid var(--glass-border);
            border-radius: 16px; overflow: hidden; box-shadow: var(--shadow-card);
        }
        .cyber-grid { width: 100%; border-collapse: collapse; }
        .cyber-grid th {
            background: rgba(0,0,0,0.2); color: var(--text-sub);
            padding: 20px 20px; text-align: left; font-weight: 600; font-size: 12px;
            text-transform: uppercase; letter-spacing: 1px; border-bottom: 1px solid var(--glass-border);
        }
        .cyber-grid td {
            padding: 18px 20px; color: var(--text-main);
            border-bottom: 1px solid var(--glass-border); font-size: 14px; vertical-align: middle;
        }
        .cyber-grid tr:hover td { background: var(--table-hover); }

        /* 分数样式 */
        .score-val { font-family: 'Rajdhani'; font-weight: 700; font-size: 16px; }
        .score-pass { color: var(--success); }
        .score-fail { color: var(--danger); text-shadow: 0 0 10px rgba(239, 68, 68, 0.4); }

        /* 按钮与徽章 */
        .btn-retake {
            background: rgba(239, 68, 68, 0.1); border: 1px solid var(--danger); color: var(--danger);
            padding: 6px 16px; border-radius: 6px; font-size: 12px; font-weight: 700; cursor: pointer;
            transition: 0.3s; text-transform: uppercase; letter-spacing: 1px;
        }
        .btn-retake:hover { background: var(--danger); color: #fff; box-shadow: 0 0 15px var(--danger); }

        .badge { padding: 4px 10px; border-radius: 4px; font-size: 11px; font-weight: 700; text-transform: uppercase; }
        .badge-pass { color: var(--success); background: rgba(16, 185, 129, 0.1); }
        .badge-pending { color: var(--accent); background: rgba(245, 158, 11, 0.1); border: 1px solid var(--accent); }
    </style>
</head>
<body>
    <button class="theme-toggle" id="btnTheme" onclick="toggleTheme()" type="button" style="position:fixed; top:85px; right:40px; z-index:900;">
        <i class="fas fa-moon" id="themeIcon"></i>
    </button>

    <canvas id="particle-canvas"></canvas>

    <form id="form1" runat="server">
    <asp:ScriptManager ID="ScriptManager1" runat="server"></asp:ScriptManager>

    <div class="navbar fade-in">
        <a href="StudentHome.aspx" class="brand">
            <i class="fas fa-chart-pie"></i> ACADEMIC <span style="font-weight:300; opacity:0.6; font-size:14px; margin-left:5px;">RECORDS</span>
        </a>
        <div class="nav-actions">
            <a href="StudentHome.aspx" class="btn-back">
                <i class="fas fa-arrow-left"></i> Dashboard
            </a>
        </div>
    </div>

    <div class="main-container fade-in">
        
        <div class="filter-panel">
            <div class="filter-group">
                <span class="filter-label">学期:</span>
                <asp:DropDownList ID="ddlTerm" runat="server" CssClass="cyber-select" AutoPostBack="true" OnSelectedIndexChanged="ddlTerm_SelectedIndexChanged">
                </asp:DropDownList>
            </div>
            
            <div class="stats-capsule">
                <div class="stat-item">
                    <span class="stat-val" style="color:var(--primary);">
                        <asp:Literal ID="ltlTermAvg" runat="server">0.0</asp:Literal>
                    </span>
                    <span class="stat-lbl">Term GPA</span>
                </div>
                <div class="stat-item">
                    <span class="stat-val" style="color:var(--accent);">
                        <asp:Literal ID="ltlTermCredit" runat="server">0</asp:Literal>
                    </span>
                    <span class="stat-lbl">Credits</span>
                </div>
            </div>
        </div>

        <asp:UpdatePanel ID="UpdatePanel1" runat="server">
            <ContentTemplate>
                
                <div class="grid-container">
                    <asp:GridView ID="gvScores" runat="server" AutoGenerateColumns="False" 
                        DataKeyNames="ScoreId" CssClass="cyber-grid" GridLines="None"
                        OnRowCommand="gvScores_RowCommand">
                        <Columns>
                            <%-- 课程信息 --%>
                            <asp:TemplateField HeaderText="COURSE">
                                <ItemTemplate>
                                    <div style="font-weight:700; font-size:15px;"><%# Eval("CourseName") %></div>
                                    <div style="font-size:12px; color:var(--text-sub);"><%# Eval("TeacherName") %></div>
                                </ItemTemplate>
                            </asp:TemplateField>

                            <asp:BoundField DataField="Credit" HeaderText="CREDIT" ItemStyle-HorizontalAlign="Center" />
                            <asp:BoundField DataField="CourseType" HeaderText="TYPE" ItemStyle-HorizontalAlign="Center" />

                            <%-- 分数展示 --%>
                            <asp:BoundField DataField="ScoreRegular" HeaderText="REG" ItemStyle-CssClass="text-sub" ItemStyle-HorizontalAlign="Center" />
                            <asp:BoundField DataField="ScoreMidterm" HeaderText="MID" ItemStyle-CssClass="text-sub" ItemStyle-HorizontalAlign="Center" />
                            <asp:BoundField DataField="ScoreFinal" HeaderText="FIN" ItemStyle-CssClass="text-sub" ItemStyle-HorizontalAlign="Center" />

                            <%-- 总分 (逻辑变色) --%>
                            <asp:TemplateField HeaderText="TOTAL" ItemStyle-HorizontalAlign="Center">
                                <ItemTemplate>
                                    <span class='score-val <%# Convert.ToDouble(Eval("Score")) >= 60 ? "score-pass" : "score-fail" %>'>
                                        <%# Eval("Score") %>
                                    </span>
                                </ItemTemplate>
                            </asp:TemplateField>

                            <%-- 操作/状态列 (核心逻辑) --%>
                            <asp:TemplateField HeaderText="STATUS / ACTION" ItemStyle-HorizontalAlign="Right" ItemStyle-Width="180px">
                                <ItemTemplate>
                                    <span runat="server" visible='<%# Convert.ToDouble(Eval("Score")) >= 60 %>' class="badge badge-pass">
                                        <i class="fas fa-check"></i> PASSED
                                    </span>

                                    <asp:Button ID="btnRetake" runat="server" Text="APPLY RETAKE" 
                                        CommandName="ApplyRetake" CommandArgument='<%# Eval("ScoreId") %>'
                                        CssClass="btn-retake" 
                                        Visible='<%# Convert.ToDouble(Eval("Score")) < 60 && Convert.ToInt32(Eval("RetakeStatus")) <= 1 %>'
                                        OnClientClick="return confirm('Confirm application for retake exam?');" />

                                    <span runat="server" visible='<%# Convert.ToInt32(Eval("RetakeStatus")) == 2 %>' class="badge badge-pending">
                                        <i class="fas fa-clock"></i> PENDING
                                    </span>

                                    <span runat="server" visible='<%# Convert.ToInt32(Eval("RetakeStatus")) == 3 %>' class="badge" style="color:var(--primary); border:1px solid var(--primary);">
                                        <i class="fas fa-calendar-check"></i> SCHEDULED
                                    </span>
                                </ItemTemplate>
                            </asp:TemplateField>
                        </Columns>
                        <EmptyDataTemplate>
                            <div style="padding:50px; text-align:center; color:var(--text-sub);">
                                <i class="fas fa-folder-open" style="font-size:30px; margin-bottom:10px;"></i>
                                <p>No grade records found for this semester.</p>
                            </div>
                        </EmptyDataTemplate>
                    </asp:GridView>
                </div>

            </ContentTemplate>
        </asp:UpdatePanel>

    </div>
    </form>

    <script>
        // === 粒子与主题 (复用) ===
        const html = document.documentElement;
        const themeIcon = document.getElementById('themeIcon');
        const savedTheme = localStorage.getItem('theme') || 'dark';
        applyTheme(savedTheme);

        function toggleTheme() {
            const current = html.getAttribute('data-theme');
            const target = current === 'dark' ? 'light' : 'dark';
            document.body.style.transition = 'background 0.6s ease, color 0.6s ease';
            applyTheme(target);
            localStorage.setItem('theme', target);
        }

        function applyTheme(theme) {
            html.setAttribute('data-theme', theme);
            themeIcon.className = theme === 'dark' ? 'fas fa-moon' : 'fas fa-sun';
        }

        const canvas = document.getElementById('particle-canvas');
        const ctx = canvas.getContext('2d');
        let width, height, particles = [], mouse = { x: null, y: null };

        function getThemeColors() {
            const style = getComputedStyle(document.documentElement);
            const pColor = style.getPropertyValue('--p-color-rgb').trim().split(',');
            const lColor = style.getPropertyValue('--l-color-rgb').trim().split(',');
            return { p: pColor, l: lColor };
        }

        function resize() { width = canvas.width = window.innerWidth; height = canvas.height = window.innerHeight; }

        class Particle {
            constructor() {
                this.x = Math.random() * width; this.y = Math.random() * height;
                this.z = Math.random() * 1.5 + 0.5;
                this.vx = (Math.random() - 0.5) * 0.5 * this.z;
                this.vy = (Math.random() - 0.5) * 0.5 * this.z;
                this.size = Math.random() * 2 * this.z;
            }
            update() {
                this.x += this.vx; this.y += this.vy;
                if (mouse.x != null) {
                    let dx = mouse.x - this.x; let dy = mouse.y - this.y;
                    let distance = Math.sqrt(dx*dx + dy*dy);
                    if(distance < 250) {
                        const force = (250 - distance) / 250;
                        this.vx += (dx/distance) * force * 0.02 * this.z;
                        this.vy += (dy/distance) * force * 0.02 * this.z;
                    }
                }
                if (this.x < 0 || this.x > width) this.vx *= -1;
                if (this.y < 0 || this.y > height) this.vy *= -1;
            }
            draw(colors) {
                ctx.beginPath(); ctx.arc(this.x, this.y, this.size, 0, Math.PI * 2);
                ctx.fillStyle = `rgba(${colors.p[0]}, ${colors.p[1]}, ${colors.p[2]}, ${0.5 * this.z})`; ctx.fill();
            }
        }

        function initParticles() { particles = []; for (let i = 0; i < 80; i++) particles.push(new Particle()); }

        function animate() {
            ctx.clearRect(0, 0, width, height); const colors = getThemeColors();
            for (let i = 0; i < particles.length; i++) {
                particles[i].update(); particles[i].draw(colors);
                for (let j = i + 1; j < particles.length; j++) {
                    let dx = particles[i].x - particles[j].x; let dy = particles[i].y - particles[j].y;
                    let distance = Math.sqrt(dx*dx + dy*dy);
                    if (distance < 100) {
                        ctx.beginPath();
                        let opacity = (1 - distance/100) * 0.4 * particles[i].z;
                        ctx.strokeStyle = `rgba(${colors.l[0]}, ${colors.l[1]}, ${colors.l[2]}, ${opacity})`;
                        ctx.lineWidth = 0.5 * particles[i].z;
                        ctx.moveTo(particles[i].x, particles[i].y); ctx.lineTo(particles[j].x, particles[j].y); ctx.stroke();
                    }
                }
            }
            requestAnimationFrame(animate);
        }

        window.addEventListener('resize', () => { resize(); initParticles(); });
        window.addEventListener('mousemove', (e) => { mouse.x = e.x; mouse.y = e.y; });
        window.addEventListener('mouseout', () => { mouse.x = null; mouse.y = null; });
        resize(); initParticles(); animate();
    </script>
</body>
</html>