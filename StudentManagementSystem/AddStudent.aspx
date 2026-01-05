<%@ Page Language="C#" AutoEventWireup="true" CodeFile="AddStudent.aspx.cs" Inherits="AddStudent" MaintainScrollPositionOnPostback="true" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml" data-theme="dark">
<head runat="server">
    <title>录入学生 | 智慧教务中枢</title>
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.4/css/all.min.css" rel="stylesheet" />
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;600;700&family=Rajdhani:wght@500;700&display=swap" rel="stylesheet">
    
    <style>
        /* === 1. 核心主题变量 (管理员版 - 绿色系) === */
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
            
            --primary: #10b981; /* 信号绿 */
            --primary-shadow: rgba(16, 185, 129, 0.4);
            --accent: #06b6d4;
            --danger: #ef4444;
            
            --p-color-rgb: 16, 185, 129; 
            --l-color-rgb: 148, 163, 184;
            --input-bg: rgba(15, 23, 42, 0.6);
            --shadow-card: 0 25px 50px -12px rgba(0, 0, 0, 0.6);
        }

        [data-theme="light"] {
            --bg-color: #f1f5f9;
            --bg-gradient: linear-gradient(135deg, #e2e8f0 0%, #f8fafc 100%);
            --glass-panel: rgba(255, 255, 255, 0.85);
            --glass-border: rgba(255, 255, 255, 0.6);
            --text-main: #1e293b;
            --text-sub: #475569;
            
            --primary: #059669; 
            --primary-shadow: rgba(5, 150, 105, 0.2);
            --accent: #0891b2;
            --danger: #dc2626;
            
            --p-color-rgb: 5, 150, 105;
            --l-color-rgb: 148, 163, 184;
            --input-bg: rgba(255, 255, 255, 0.8);
            --shadow-card: 0 20px 40px -10px rgba(0, 0, 0, 0.15);
        }

        body {
            margin: 0; padding: 0;
            background: var(--bg-color); background-image: var(--bg-gradient);
            color: var(--text-main); font-family: 'Inter', sans-serif;
            overflow-x: hidden; min-height: 100vh;
            transition: background 0.6s ease, color 0.6s ease;
        }

        #particle-canvas {
            position: fixed; top: 0; left: 0; width: 100%; height: 100%;
            z-index: -1; pointer-events: none;
        }

        .fade-in { animation: fadeIn 0.8s var(--ease-smooth) forwards; opacity: 0; transform: translateY(20px); }
        @keyframes fadeIn { to { opacity: 1; transform: translateY(0); } }

        /* === 2. 导航栏 === */
        .navbar {
            height: 70px; padding: 0 40px;
            background: var(--glass-panel);
            backdrop-filter: blur(20px); -webkit-backdrop-filter: blur(20px);
            border-bottom: 1px solid var(--glass-border);
            display: flex; align-items: center; justify-content: space-between;
            position: fixed; top: 0; width: 100%; z-index: 1000; box-sizing: border-box;
        }

        .brand {
            font-family: 'Rajdhani', sans-serif; font-weight: 700; font-size: 24px;
            letter-spacing: 2px; color: var(--text-main);
            display: flex; align-items: center; gap: 10px; text-decoration:none;
        }
        .brand i { color: var(--primary); }

        .nav-actions { display: flex; align-items: center; gap: 20px; }

        .theme-toggle {
            width: 40px; height: 40px; border-radius: 50%;
            background: var(--glass-panel); border: 1px solid var(--glass-border);
            display: flex; align-items: center; justify-content: center;
            cursor: pointer; color: var(--text-main); font-size: 18px;
            transition: all 0.3s var(--ease-elastic);
        }
        .theme-toggle:hover { transform: rotate(180deg) scale(1.1); color: var(--primary); border-color: var(--primary); }

        .btn-back {
            background: transparent; border: 1px solid var(--glass-border); color: var(--text-sub);
            padding: 8px 20px; border-radius: 8px; cursor: pointer; transition: 0.3s;
            font-size: 13px; text-decoration: none; display: flex; align-items: center; gap: 8px;
        }
        .btn-back:hover { background: var(--glass-border); color: var(--text-main); }

        /* === 3. 录入终端 === */
        .main-container {
            display: flex; justify-content: center; align-items: center;
            min-height: calc(100vh - 70px); margin-top: 70px; padding: 20px;
        }

        .data-card {
            width: 100%; max-width: 550px; /* 稍微宽一点容纳两列 */
            background: var(--glass-panel); border: 1px solid var(--glass-border);
            border-radius: 24px; padding: 40px;
            box-shadow: var(--shadow-card);
            position: relative; overflow: hidden;
            transform-style: preserve-3d; perspective: 1000px;
            animation: cardFloat 6s ease-in-out infinite;
        }
        @keyframes cardFloat { 0%,100% { transform: translateY(0); } 50% { transform: translateY(-10px); } }

        .data-card::before {
            content: ''; position: absolute; top: 0; left: 0; width: 100%; height: 3px;
            background: linear-gradient(90deg, transparent, var(--primary), transparent);
            animation: scan 3s infinite linear; box-shadow: 0 0 10px var(--primary);
        }
        @keyframes scan { 0% { transform: translateX(-100%); } 100% { transform: translateX(100%); } }

        .card-header { text-align: center; margin-bottom: 30px; }
        .icon-box {
            width: 60px; height: 60px; margin: 0 auto 15px;
            background: rgba(255,255,255,0.05); border-radius: 16px;
            display: flex; align-items: center; justify-content: center;
            font-size: 30px; color: var(--primary);
            box-shadow: 0 0 30px var(--primary-shadow);
            border: 1px solid var(--glass-border);
        }
        .card-header h2 { margin: 0; font-family: 'Rajdhani', sans-serif; font-size: 26px; font-weight: 700; letter-spacing: 1px; }
        .card-header p { margin: 6px 0 0; color: var(--text-sub); font-size: 13px; }

        /* === 4. 赛博表单 (两列布局) === */
        .form-row { display: flex; gap: 20px; margin-bottom: 20px; }
        .form-group { flex: 1; position: relative; }
        .form-group.full-width { margin-bottom: 20px; }

        .form-label {
            display: block; font-size: 11px; color: var(--text-sub);
            margin-bottom: 8px; font-weight: 700; text-transform: uppercase; letter-spacing: 1px;
        }

        .cyber-input, .cyber-select {
            width: 100%; padding: 12px 12px 12px 40px;
            background: var(--input-bg); border: 1px solid var(--glass-border);
            border-radius: 10px; color: var(--text-main); font-size: 14px;
            box-sizing: border-box; transition: all 0.3s ease;
        }
        .cyber-input:focus, .cyber-select:focus {
            border-color: var(--primary); outline: none;
            box-shadow: 0 0 0 4px var(--primary-shadow);
            background: rgba(255,255,255,0.08);
        }
        
        .cyber-select {
            padding-right: 30px; cursor: pointer;
            appearance: none; -webkit-appearance: none;
            background-image: url("data:image/svg+xml;charset=US-ASCII,%3Csvg%20xmlns%3D%22http%3A%2F%2Fwww.w3.org%2F2000%2Fsvg%22%20width%3D%22292.4%22%20height%3D%22292.4%22%3E%3Cpath%20fill%3D%22%23007CB2%22%20d%3D%22M287%2069.4a17.6%2017.6%200%200%200-13-5.4H18.4c-5%200-9.3%201.8-12.9%205.4A17.6%2017.6%200%200%200%200%2082.2c0%205%201.8%209.3%205.4%2012.9l128%20127.9c3.6%203.6%207.8%205.4%2012.8%205.4s9.2-1.8%2012.8-5.4L287%2095c3.5-3.5%205.4-7.8%205.4-12.8%200-5-1.9-9.2-5.5-12.8z%22%2F%3E%3C%2Fsvg%3E");
            background-repeat: no-repeat; background-position: right 12px top 50%; background-size: 10px;
        }
        .cyber-select option { background: var(--bg-color); color: var(--text-main); }

        .input-icon {
            position: absolute; left: 14px; top: 38px; /* 调整图标位置适配Label */
            color: var(--text-sub); font-size: 14px; transition: 0.3s;
        }
        .cyber-input:focus + .input-icon, .cyber-select:focus + .input-icon { 
            color: var(--primary); transform: scale(1.1); 
        }

        .btn-submit {
            width: 100%; padding: 15px; border: none; border-radius: 12px;
            background: linear-gradient(135deg, var(--primary), var(--accent));
            color: #fff; font-size: 15px; font-weight: 700; letter-spacing: 2px;
            text-transform: uppercase; cursor: pointer; transition: 0.3s;
            box-shadow: 0 10px 20px -5px var(--primary-shadow);
            margin-top: 10px; position: relative; overflow: hidden;
        }
        .btn-submit:hover { transform: translateY(-2px); box-shadow: 0 15px 30px -5px var(--primary-shadow); }
        .btn-submit:active { transform: scale(0.98); }

        .msg-box { min-height: 24px; text-align: center; margin-top: 20px; font-size: 13px; font-weight: 600; }
        
        .corner { position: absolute; width: 20px; height: 20px; border: 2px solid var(--glass-border); transition: 0.3s; }
        .corner-tl { top: 15px; left: 15px; border-right: none; border-bottom: none; }
        .corner-br { bottom: 15px; right: 15px; border-left: none; border-top: none; }
        .data-card:hover .corner { border-color: var(--primary); width: 30px; height: 30px; }
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
        <a href="Default.aspx" class="brand">
            <i class="fas fa-shield-alt fa-spin" style="animation-duration: 15s;"></i> UNIVERSE 
            <span style="font-weight:300; opacity:0.6; font-size:14px; margin-left:5px;">ADMIN CONSOLE</span>
        </a>
        <div class="nav-actions">
            <a href="Default.aspx" class="btn-back">
                <i class="fas fa-arrow-left"></i> Student List
            </a>
            <asp:Button ID="btnLogout" runat="server" Text="LOGOUT" OnClick="btnLogout_Click" 
                CssClass="btn-back" style="color:var(--danger); border-color:var(--danger);" />
        </div>
    </div>

    <div class="main-container fade-in">
        <div class="data-card">
            <div class="corner corner-tl"></div>
            <div class="corner corner-br"></div>

            <div class="card-header">
                <div class="icon-box"><i class="fas fa-user-graduate"></i></div>
                <h2>Enroll Student</h2>
                <p>Register new student profile to database</p>
            </div>

            <asp:UpdatePanel ID="UpdatePanel1" runat="server">
                <ContentTemplate>
                    
                    <div class="form-row">
                        <div class="form-group">
                            <label class="form-label">Student ID / 学号</label>
                            <asp:TextBox ID="txtStuNo" runat="server" CssClass="cyber-input" placeholder="e.g. 2025001"></asp:TextBox>
                            <i class="fas fa-id-card input-icon"></i>
                        </div>
                        <div class="form-group">
                            <label class="form-label">Full Name / 姓名</label>
                            <asp:TextBox ID="txtName" runat="server" CssClass="cyber-input" placeholder="Name"></asp:TextBox>
                            <i class="fas fa-user input-icon"></i>
                        </div>
                    </div>

                    <div class="form-row">
                        <div class="form-group">
                            <label class="form-label">Class / 班级</label>
                            <asp:DropDownList ID="ddlClass" runat="server" CssClass="cyber-select"></asp:DropDownList>
                            <i class="fas fa-users input-icon"></i>
                        </div>
                        <div class="form-group">
                            <label class="form-label">Gender / 性别</label>
                            <asp:DropDownList ID="ddlGender" runat="server" CssClass="cyber-select">
                                <asp:ListItem Value="男">Male (男)</asp:ListItem>
                                <asp:ListItem Value="女">Female (女)</asp:ListItem>
                            </asp:DropDownList>
                            <i class="fas fa-venus-mars input-icon"></i>
                        </div>
                    </div>

                    <div class="form-group full-width">
                        <label class="form-label">Contact / 电话 (Optional)</label>
                        <asp:TextBox ID="txtPhone" runat="server" CssClass="cyber-input" placeholder="Mobile Number"></asp:TextBox>
                        <i class="fas fa-phone-alt input-icon"></i>
                    </div>

                    <asp:Button ID="btnSave" runat="server" Text="CONFIRM ENROLLMENT" CssClass="btn-submit" OnClick="btnSave_Click" />
                    
                    <div class="msg-box">
                        <asp:Label ID="lblMsg" runat="server"></asp:Label>
                    </div>

                </ContentTemplate>
            </asp:UpdatePanel>
        </div>
    </div>
    </form>

    <script>
        // === 主题引擎 ===
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

        // === 粒子引擎 ===
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
                    let distance = Math.sqrt(dx * dx + dy * dy);
                    if (distance < 250) {
                        const force = (250 - distance) / 250;
                        this.vx += (dx / distance) * force * 0.02 * this.z;
                        this.vy += (dy / distance) * force * 0.02 * this.z;
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
                    let distance = Math.sqrt(dx * dx + dy * dy);
                    if (distance < 100) {
                        ctx.beginPath();
                        let opacity = (1 - distance / 100) * 0.4 * particles[i].z;
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

        const card = document.querySelector('.data-card');
        document.addEventListener('mousemove', (e) => {
            const xAxis = (window.innerWidth / 2 - e.pageX) / 30;
            const yAxis = (window.innerHeight / 2 - e.pageY) / 30;
            card.style.transform = `rotateY(${xAxis}deg) rotateX(${yAxis}deg)`;
        });
    </script>
</body>
</html>