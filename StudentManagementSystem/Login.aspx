<%@ Page Language="C#" AutoEventWireup="true" CodeFile="Login.aspx.cs" Inherits="Login" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml" data-theme="dark">
<head runat="server">
    <title>身份验证 | 智慧教务中枢</title>
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.4/css/all.min.css" rel="stylesheet" />
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;600;700&family=Rajdhani:wght@500;700&display=swap" rel="stylesheet">
    
    <style>
        /* === 1. 核心 CSS 变量系统 === */
        :root {
            --ease-elastic: cubic-bezier(0.68, -0.55, 0.265, 1.55);
            --ease-smooth: cubic-bezier(0.25, 0.46, 0.45, 0.94);
        }

        /* 🌑 暗黑模式 (深空科技) */
        [data-theme="dark"] {
            --bg-color: #0b1120; /* 更深的蓝黑 */
            --bg-gradient: radial-gradient(circle at 50% 50%, #1e293b 0%, #0b1120 100%);
            --card-bg: rgba(30, 41, 59, 0.65);
            --glass-border: rgba(255, 255, 255, 0.1);
            --text-main: #f8fafc;
            --text-sub: #94a3b8;
            
            /* 粒子颜色配置 (RGB格式以便JS调整透明度) */
            --p-color-rgb: 6, 182, 212; /* 粒子颜色 (青色) */
            --l-color-rgb: 148, 163, 184; /* 连线颜色 (灰蓝) */
            
            --primary: #06b6d4; /* 霓虹青 */
            --primary-shadow: rgba(6, 182, 212, 0.4);
            --input-bg: rgba(15, 23, 42, 0.8);
            --shadow-card: 0 25px 50px -12px rgba(0, 0, 0, 0.6);
        }

        /* ☀️ 明亮模式 (未来实验室) */
        [data-theme="light"] {
            --bg-color: #f1f5f9;
            --bg-gradient: linear-gradient(135deg, #e2e8f0 0%, #f8fafc 100%);
            --card-bg: rgba(255, 255, 255, 0.75);
            --glass-border: rgba(255, 255, 255, 0.8);
            --text-main: #1e293b;
            --text-sub: #64748b;
            
            /* 粒子颜色配置 */
            --p-color-rgb: 37, 99, 235; /* 粒子颜色 (深蓝) */
            --l-color-rgb: 148, 163, 184; /* 连线颜色 (浅灰) */
            
            --primary: #2563eb; /* 科技蓝 */
            --primary-shadow: rgba(37, 99, 235, 0.3);
            --input-bg: rgba(255, 255, 255, 0.9);
            --shadow-card: 0 20px 40px -10px rgba(0, 0, 0, 0.15);
        }

        /* === 2. 布局与动画 === */
        body {
            margin: 0; padding: 0;
            height: 100vh; width: 100vw;
            overflow: hidden;
            font-family: 'Inter', sans-serif;
            background: var(--bg-color);
            background-image: var(--bg-gradient);
            color: var(--text-main);
            display: flex; align-items: center; justify-content: center;
            transition: background 0.6s ease, color 0.6s ease;
        }

        /* 粒子画布 */
        #particle-canvas {
            position: absolute; top: 0; left: 0; width: 100%; height: 100%;
            z-index: 0; pointer-events: none;
        }

        /* 主题切换悬浮球 */
        .theme-toggle {
            position: absolute; top: 30px; right: 30px;
            width: 48px; height: 48px;
            border-radius: 50%;
            background: var(--card-bg);
            border: 1px solid var(--glass-border);
            backdrop-filter: blur(10px);
            cursor: pointer; z-index: 100;
            display: flex; align-items: center; justify-content: center;
            color: var(--text-main); font-size: 20px;
            box-shadow: 0 4px 20px rgba(0,0,0,0.1);
            transition: all 0.4s var(--ease-elastic);
        }
        .theme-toggle:hover { transform: scale(1.15) rotate(180deg); color: var(--primary); border-color: var(--primary); }

        /* === 3. 登录主卡片 (玻璃拟态 + 3D Tilt) === */
        .login-container {
            position: relative; width: 420px; padding: 50px;
            background: var(--card-bg);
            backdrop-filter: blur(20px); -webkit-backdrop-filter: blur(20px);
            border-radius: 24px;
            border: 1px solid var(--glass-border);
            box-shadow: var(--shadow-card);
            z-index: 10;
            transform-style: preserve-3d; /* 开启3D空间 */
            perspective: 1000px;
            transition: all 0.1s ease-out; /* 鼠标跟随响应速度 */
        }

        /* Logo 区域 */
        .header { text-align: center; margin-bottom: 40px; transform: translateZ(30px); /* 元素凸起 */ }
        .logo-box {
            width: 72px; height: 72px; margin: 0 auto 15px;
            background: linear-gradient(135deg, rgba(255,255,255,0.1), rgba(255,255,255,0.02));
            border-radius: 18px;
            display: flex; align-items: center; justify-content: center;
            border: 1px solid var(--glass-border);
            box-shadow: 0 0 40px var(--primary-shadow);
            animation: pulseLogo 4s infinite ease-in-out;
        }
        @keyframes pulseLogo { 0%, 100% { box-shadow: 0 0 20px var(--primary-shadow); } 50% { box-shadow: 0 0 50px var(--primary-shadow); transform: scale(1.05); } }
        
        .logo-icon { font-size: 36px; color: var(--primary); transition: color 0.5s; }
        .header h2 { 
            margin: 0; font-family: 'Rajdhani', sans-serif; 
            font-size: 32px; font-weight: 700; letter-spacing: 2px; text-transform: uppercase;
        }
        .header p { margin: 8px 0 0; color: var(--text-sub); font-size: 13px; font-weight: 500; letter-spacing: 1px; }

        /* 输入区域 */
        .input-group { position: relative; margin-bottom: 25px; transform: translateZ(20px); }
        .input-field {
            width: 100%; padding: 16px 16px 16px 50px;
            background: var(--input-bg);
            border: 1px solid var(--glass-border);
            border-radius: 14px;
            color: var(--text-main); font-size: 15px; font-weight: 500;
            transition: all 0.3s var(--ease-smooth); box-sizing: border-box;
        }
        .input-field:focus {
            border-color: var(--primary);
            box-shadow: 0 0 0 4px var(--primary-shadow);
            outline: none; transform: translateY(-2px);
        }
        .input-icon {
            position: absolute; left: 18px; top: 50%; transform: translateY(-50%);
            color: var(--text-sub); font-size: 18px; transition: 0.3s;
        }
        .input-field:focus + .input-icon { color: var(--primary); transform: translateY(-50%) scale(1.1); }

        /* 液态滑块 (Fluid Switch) */
        .role-switch {
            display: flex; position: relative;
            background: rgba(0,0,0,0.2);
            border-radius: 14px; padding: 5px;
            margin-bottom: 35px; border: 1px solid var(--glass-border);
            transform: translateZ(20px);
        }
        [data-theme="light"] .role-switch { background: rgba(0,0,0,0.05); }

        .glider {
            position: absolute; top: 5px; left: 5px;
            height: calc(100% - 10px); width: 33.33%;
            background: var(--primary);
            border-radius: 10px; z-index: 1;
            transition: transform 0.4s var(--ease-elastic), background 0.5s;
            box-shadow: 0 4px 15px var(--primary-shadow);
        }
        .role-item {
            flex: 1; text-align: center; padding: 12px 0;
            font-size: 13px; font-weight: 700; color: var(--text-sub);
            cursor: pointer; z-index: 2; transition: color 0.3s;
            position: relative; user-select: none; text-transform: uppercase; letter-spacing: 1px;
        }
        .role-item.active { color: #fff; }

        /* 登录按钮 */
        .btn-login {
            width: 100%; padding: 16px;
            border: none; border-radius: 14px;
            background: linear-gradient(135deg, var(--primary), #3b82f6);
            color: #fff;
            font-size: 16px; font-weight: 700; letter-spacing: 1px;
            cursor: pointer; position: relative; overflow: hidden;
            transition: 0.3s; box-shadow: 0 10px 25px -5px var(--primary-shadow);
            transform: translateZ(30px);
        }
        .btn-login:hover { transform: translateZ(30px) translateY(-3px) scale(1.02); box-shadow: 0 20px 40px -10px var(--primary-shadow); }
        .btn-login:active { transform: translateZ(20px) scale(0.98); }

        .footer { margin-top: 35px; text-align: center; font-size: 12px; color: var(--text-sub); opacity: 0.7; transform: translateZ(10px); }
        .msg-box { height: 24px; text-align: center; margin-bottom: 10px; font-size: 13px; font-weight: 600; }
        
        /* 隐藏 ASP 默认控件 */
        .role-switch input { display: none; }
    </style>
</head>
<body>
    <button class="theme-toggle" id="btnTheme" onclick="toggleTheme()" type="button" title="Switch Theme">
        <i class="fas fa-moon" id="themeIcon"></i>
    </button>

    <canvas id="particle-canvas"></canvas>

    <form id="form1" runat="server">
        <div class="login-container" id="loginCard">
            <div class="header">
                <div class="logo-box">
                    <i class="fas fa-network-wired logo-icon"></i>
                </div>
                <h2>学生管理系统</h2>
                <p>Advanced Academic Management</p>
            </div>

            <div class="msg-box">
                <asp:Label ID="lblMsg" runat="server" ForeColor="#ef4444"></asp:Label>
            </div>

            <div class="input-group">
                <asp:TextBox ID="txtUser" runat="server" CssClass="input-field" placeholder="User ID / 工号"></asp:TextBox>
                <i class="fas fa-id-badge input-icon"></i>
            </div>

            <div class="input-group">
                <asp:TextBox ID="txtPwd" runat="server" CssClass="input-field" TextMode="Password" placeholder="Password / 密码"></asp:TextBox>
                <i class="fas fa-fingerprint input-icon"></i>
            </div>

            <div class="role-switch">
                <div class="glider" id="glider"></div>
                <label class="role-item active" onclick="switchRole(0)">
                    STUDENT
                    <asp:RadioButton ID="rbStudent" runat="server" GroupName="Role" Checked="true" />
                </label>
                <label class="role-item" onclick="switchRole(1)">
                    TEACHER
                    <asp:RadioButton ID="rbTeacher" runat="server" GroupName="Role" />
                </label>
                <label class="role-item" onclick="switchRole(2)">
                    ADMIN
                    <asp:RadioButton ID="rbAdmin" runat="server" GroupName="Role" />
                </label>
            </div>

            <asp:Button ID="btnLogin" runat="server" Text="INITIALIZE LOGIN" CssClass="btn-login" OnClick="btnLogin_Click" />

            <div class="footer">
                &copy; 2025 Smart Campus Inc. All systems operational.
            </div>
        </div>
    </form>

    <script>
        // ==========================================
        // 1. 粒子神经网络引擎 (Particle Neural Network)
        // ==========================================
        const canvas = document.getElementById('particle-canvas');
        const ctx = canvas.getContext('2d');
        let width, height;
        let particles = [];
        let mouse = { x: null, y: null };

        // 颜色获取助手 (从CSS变量读取)
        function getThemeColors() {
            const style = getComputedStyle(document.documentElement);
            const pColor = style.getPropertyValue('--p-color-rgb').trim().split(',');
            const lColor = style.getPropertyValue('--l-color-rgb').trim().split(',');
            return { p: pColor, l: lColor };
        }

        function resize() {
            width = canvas.width = window.innerWidth;
            height = canvas.height = window.innerHeight;
        }

        class Particle {
            constructor() {
                this.x = Math.random() * width;
                this.y = Math.random() * height;
                // [核心特性] 景深效果 (Depth)
                // z 越大，粒子越大，移动越快，连线越粗
                this.z = Math.random() * 1.5 + 0.5;
                this.vx = (Math.random() - 0.5) * 0.8 * this.z;
                this.vy = (Math.random() - 0.5) * 0.8 * this.z;
                this.size = Math.random() * 2 * this.z;
            }

            update() {
                this.x += this.vx;
                this.y += this.vy;

                // 鼠标引力场 (Force Field)
                if (mouse.x != null) {
                    let dx = mouse.x - this.x;
                    let dy = mouse.y - this.y;
                    let distance = Math.sqrt(dx * dx + dy * dy);
                    // 250px 范围内受到引力
                    if (distance < 250) {
                        const forceDirectionX = dx / distance;
                        const forceDirectionY = dy / distance;
                        const force = (250 - distance) / 250;
                        // 吸引力，稍微加速靠近
                        const attraction = 0.05 * force * this.z;
                        this.vx += forceDirectionX * attraction;
                        this.vy += forceDirectionY * attraction;
                    }
                }

                // 边界反弹
                if (this.x < 0 || this.x > width) this.vx *= -1;
                if (this.y < 0 || this.y > height) this.vy *= -1;
            }

            draw(colors) {
                ctx.beginPath();
                ctx.arc(this.x, this.y, this.size, 0, Math.PI * 2);
                // 根据 z-depth 调整透明度 (远处模糊)
                ctx.fillStyle = `rgba(${colors.p[0]}, ${colors.p[1]}, ${colors.p[2]}, ${0.6 * this.z})`;
                ctx.fill();
            }
        }

        function initParticles() {
            particles = [];
            // 创建 100 个粒子
            for (let i = 0; i < 100; i++) particles.push(new Particle());
        }

        function animate() {
            ctx.clearRect(0, 0, width, height);
            const colors = getThemeColors();

            for (let i = 0; i < particles.length; i++) {
                particles[i].update();
                particles[i].draw(colors);

                // [核心特性] 连线逻辑 (Connections)
                for (let j = i + 1; j < particles.length; j++) {
                    let dx = particles[i].x - particles[j].x;
                    let dy = particles[i].y - particles[j].y;
                    let distance = Math.sqrt(dx * dx + dy * dy);

                    // 连线阈值：距离小于 120px 且两个粒子在类似的 Z 轴深度 (可选，此处简化为只看距离)
                    if (distance < 120) {
                        ctx.beginPath();
                        // 连线透明度：距离越近越亮，且受粒子深度影响
                        let opacity = (1 - distance / 120) * 0.5 * particles[i].z;
                        ctx.strokeStyle = `rgba(${colors.l[0]}, ${colors.l[1]}, ${colors.l[2]}, ${opacity})`;
                        ctx.lineWidth = 0.8 * particles[i].z; // 近处线粗
                        ctx.moveTo(particles[i].x, particles[i].y);
                        ctx.lineTo(particles[j].x, particles[j].y);
                        ctx.stroke();
                    }
                }
            }
            requestAnimationFrame(animate);
        }

        // 监听鼠标
        window.addEventListener('mousemove', (e) => { mouse.x = e.x; mouse.y = e.y; });
        window.addEventListener('mouseout', () => { mouse.x = null; mouse.y = null; });
        window.addEventListener('resize', () => { resize(); initParticles(); });

        // 启动引擎
        resize();
        initParticles();
        animate();

        // ==========================================
        // 2. 3D 视差卡片 (3D Tilt Effect)
        // ==========================================
        const card = document.getElementById('loginCard');
        document.addEventListener('mousemove', (e) => {
            // 计算鼠标相对于屏幕中心的偏移
            const xAxis = (window.innerWidth / 2 - e.pageX) / 30; // 分母越小倾斜越大
            const yAxis = (window.innerHeight / 2 - e.pageY) / 30;
            // 应用旋转
            card.style.transform = `rotateY(${xAxis}deg) rotateX(${yAxis}deg)`;
        });

        // ==========================================
        // 3. 主题切换与持久化 (Theme System)
        // ==========================================
        const html = document.documentElement;
        const themeIcon = document.getElementById('themeIcon');
        const savedTheme = localStorage.getItem('theme') || 'dark';

        applyTheme(savedTheme);

        function toggleTheme() {
            const current = html.getAttribute('data-theme');
            const target = current === 'dark' ? 'light' : 'dark';
            applyTheme(target);
            localStorage.setItem('theme', target);
        }

        function applyTheme(theme) {
            html.setAttribute('data-theme', theme);
            themeIcon.className = theme === 'dark' ? 'fas fa-moon' : 'fas fa-sun';
        }

        // ==========================================
        // 4. 身份滑块 (PostBack 恢复)
        // ==========================================
        window.onload = function () {
            if (document.getElementById('<%= rbTeacher.ClientID %>').checked) switchRole(1);
            else if (document.getElementById('<%= rbAdmin.ClientID %>').checked) switchRole(2);
            else switchRole(0);
        };

        function switchRole(index) {
            const glider = document.getElementById('glider');
            const items = document.querySelectorAll('.role-item');
            glider.style.transform = `translateX(${index * 100}%)`;
            items.forEach(i => i.classList.remove('active'));
            items[index].classList.add('active');
        }
    </script>
</body>
</html>