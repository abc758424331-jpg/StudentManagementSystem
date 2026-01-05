<%@ Page Language="C#" AutoEventWireup="true" CodeFile="CourseSelection.aspx.cs" Inherits="CourseSelection" MaintainScrollPositionOnPostback="true" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml" data-theme="dark">
<head runat="server">
    <title>选课中心 | 智慧教务系统</title>
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.4/css/all.min.css" rel="stylesheet" />
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;600;700&family=Rajdhani:wght@500;700&display=swap" rel="stylesheet">
    <link href="Style.css" rel="stylesheet" />
    
    <style>
        /* === 页面独有样式 === */
        .page-header {
            display: flex; justify-content: space-between; align-items: center;
            margin-bottom: 30px; padding-bottom: 20px; border-bottom: 1px solid rgba(255,255,255,0.1);
        }
        .header-title h2 { margin: 0; font-family: 'Rajdhani', sans-serif; font-weight: 700; color: #f8fafc; }
        .header-info { color: #94a3b8; font-size: 0.9rem; }

        /* 课程状态徽章 */
        .status-badge {
            padding: 4px 8px; border-radius: 4px; font-size: 12px; font-weight: 600;
        }
        .status-selected { background: rgba(16, 185, 129, 0.2); color: #34d399; border: 1px solid rgba(16, 185, 129, 0.3); }
        .status-available { background: rgba(59, 130, 246, 0.2); color: #60a5fa; border: 1px solid rgba(59, 130, 246, 0.3); }
        .status-full { background: rgba(239, 68, 68, 0.2); color: #f87171; border: 1px solid rgba(239, 68, 68, 0.3); }

        /* 操作按钮 */
        .btn-action {
            border: none; padding: 6px 12px; border-radius: 4px; cursor: pointer; transition: all 0.2s;
            font-size: 13px; display: inline-flex; align-items: center; gap: 5px; text-decoration: none;
        }
        .btn-select { background: #2563eb; color: white; }
        .btn-select:hover { background: #1d4ed8; }
        .btn-drop { background: #dc2626; color: white; }
        .btn-drop:hover { background: #b91c1c; }
        .btn-full { background: #475569; color: #94a3b8; cursor: not-allowed; }

        .progress-bar-bg { width: 100px; height: 6px; background: rgba(255,255,255,0.1); border-radius: 3px; overflow: hidden; display: inline-block; vertical-align: middle; margin-left: 8px; }
        .progress-bar-fill { height: 100%; border-radius: 3px; transition: width 0.3s ease; }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <div style="background: rgba(15, 23, 42, 0.9); padding: 15px 30px; display: flex; justify-content: space-between; align-items: center; border-bottom: 1px solid rgba(255,255,255,0.05);">
            <div style="font-family: 'Rajdhani'; font-weight: 700; font-size: 20px; color: #38bdf8;">
                <i class="fas fa-atom"></i> EDU-HUB
            </div>
            <div style="display: flex; gap: 20px; align-items: center;">
                <span style="color: #94a3b8;"><i class="fas fa-user-graduate"></i> <asp:Label ID="lblUser" runat="server"></asp:Label></span>
                <asp:LinkButton ID="btnLogout" runat="server" OnClick="btnLogout_Click" CssClass="btn-action" Style="background:transparent; color:#ef4444; border:1px solid #ef4444;">
                    <i class="fas fa-sign-out-alt"></i> Logout
                </asp:LinkButton>
            </div>
        </div>

        <div class="container">
            <div class="page-header">
                <div class="header-title">
                    <h2>Course Enrollment</h2>
                    <p class="header-info">Select your courses for the upcoming semester</p>
                </div>
                <div class="header-actions">
                    <a href="StudentHome.aspx" class="btn-action" style="background:rgba(255,255,255,0.1); color:#fff;">
                        <i class="fas fa-arrow-left"></i> Back to Dashboard
                    </a>
                </div>
            </div>

            <asp:GridView ID="gvCourses" runat="server" CssClass="grid" AutoGenerateColumns="False" 
                OnRowCommand="gvCourses_RowCommand" GridLines="None" EmptyDataText="No courses available currently.">
                <Columns>
                    <asp:BoundField DataField="CourseName" HeaderText="Course" />
                    <asp:BoundField DataField="TeacherInfo" HeaderText="Instructor" />
                    <asp:BoundField DataField="Credit" HeaderText="Credit" ItemStyle-HorizontalAlign="Center" />
                    
                    <%-- 容量条 --%>
                    <asp:TemplateField HeaderText="Capacity">
                        <ItemTemplate>
                            <span style="color:#cbd5e1;"><%# Eval("CurrentCount") %> / <%# Eval("MaxCapacity") %></span>
                            <div class="progress-bar-bg">
                                <div class="progress-bar-fill" 
                                     style='width: <%# (Convert.ToDouble(Eval("CurrentCount")) / Convert.ToDouble(Eval("MaxCapacity"))) * 100 %>%; 
                                            background: <%# (Convert.ToDouble(Eval("CurrentCount")) >= Convert.ToDouble(Eval("MaxCapacity"))) ? "#ef4444" : "#3b82f6" %>;'>
                                </div>
                            </div>
                        </ItemTemplate>
                    </asp:TemplateField>

                    <%-- 状态列 --%>
                    <asp:TemplateField HeaderText="Status" ItemStyle-HorizontalAlign="Center">
                        <ItemTemplate>
                            <%# Convert.ToInt32(Eval("IsSelected")) == 1 
                                ? "<span class='status-badge status-selected'>Enrolled</span>" 
                                : "<span class='status-badge status-available'>Available</span>" %>
                        </ItemTemplate>
                    </asp:TemplateField>

                    <%-- 操作按钮列 --%>
                    <asp:TemplateField HeaderText="Action" ItemStyle-HorizontalAlign="Center">
                        <ItemTemplate>
                            <%-- 逻辑：
                                 1. 如果已选 (IsSelected==1) -> 显示退课 (Drop)
                                 2. 如果未选 且 没满 -> 显示选课 (Select)
                                 3. 如果未选 且 满了 -> 显示满员 (Full) --%>
                            
                            <asp:LinkButton runat="server" CommandName="DropCourse" CommandArgument='<%# Eval("CourseId") %>' 
                                CssClass="btn-action btn-drop"
                                Visible='<%# Convert.ToInt32(Eval("IsSelected")) == 1 %>'
                                OnClientClick="return confirm('Are you sure you want to drop this course?');">
                                <i class="fas fa-minus-circle"></i> Drop
                            </asp:LinkButton>

                            <asp:LinkButton runat="server" CommandName="SelectCourse" CommandArgument='<%# Eval("CourseId") %>' 
                                CssClass="btn-action btn-select"
                                Visible='<%# Convert.ToInt32(Eval("IsSelected")) == 0 && Convert.ToInt32(Eval("CurrentCount")) < Convert.ToInt32(Eval("MaxCapacity")) %>'>
                                <i class="fas fa-plus-circle"></i> Select
                            </asp:LinkButton>

                            <asp:Label runat="server" CssClass="btn-action btn-full" Text="FULL"
                                Visible='<%# Convert.ToInt32(Eval("IsSelected")) == 0 && Convert.ToInt32(Eval("CurrentCount")) >= Convert.ToInt32(Eval("MaxCapacity")) %>'>
                            </asp:Label>
                        </ItemTemplate>
                    </asp:TemplateField>
                </Columns>
                <EmptyDataTemplate>
                    <div style="padding:40px; text-align:center; color:#64748b;">
                        <i class="fas fa-inbox" style="font-size:40px; margin-bottom:15px; display:block;"></i>
                        No courses available for selection at this time.
                    </div>
                </EmptyDataTemplate>
            </asp:GridView>
        </div>
    </form>
</body>
</html>