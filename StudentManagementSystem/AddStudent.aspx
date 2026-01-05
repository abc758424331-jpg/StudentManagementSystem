<%@ Page Language="C#" AutoEventWireup="true" CodeFile="AddStudent.aspx.cs" Inherits="StudentManagementSystem.AddStudent" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
<meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
    <title>学生档案录入</title>
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.4/css/all.min.css" rel="stylesheet" />
    
    <style>
        /* === 系统 UI 设计规范 === */
        body { font-family: "Segoe UI", "Microsoft YaHei", Arial, sans-serif; background-color: #f5f7fa; margin: 0; padding: 20px; color: #333; }
        
        .main-container {
            width: 900px; margin: 0 auto; background-color: #fff; 
            padding: 30px; border-radius: 8px; 
            box-shadow: 0 4px 15px rgba(0,0,0,0.05);
        }

        h2 { 
            text-align: center; color: #2c3e50; 
            border-bottom: 2px solid #3498db; padding-bottom: 15px; margin-bottom: 30px; 
            font-weight: 600;
        }

        /* 表单区域样式 */
        .form-row { margin-bottom: 20px; display: flex; align-items: center; }
        .form-label { width: 120px; text-align: right; margin-right: 15px; font-weight: 600; color: #555; }
        
        .form-input { 
            flex: 1; padding: 10px; border: 1px solid #ddd; border-radius: 4px; 
            font-size: 14px; max-width: 300px; transition: border-color 0.3s;
        }
        .form-input:focus { border-color: #3498db; outline: none; box-shadow: 0 0 5px rgba(52,152,219,0.2); }

        /* 按钮样式 */
        .btn-submit { 
            margin-left: 135px; padding: 12px 35px; 
            background-color: #3498db; color: white; border: none; border-radius: 4px; 
            cursor: pointer; font-size: 16px; font-weight: bold; transition: background 0.3s;
        }
        .btn-submit:hover { background-color: #2980b9; }

        /* 错误提示样式 (红色小字) */
        .val-error { color: #e74c3c; font-size: 12px; margin-left: 10px; display: inline-block; }

        /* 数据列表样式 */
        .data-grid { width: 100%; border-collapse: collapse; margin-top: 40px; }
        .data-grid th { background-color: #f8f9fa; color: #2c3e50; padding: 12px; border: 1px solid #e9ecef; font-weight: 600; }
        .data-grid td { border: 1px solid #e9ecef; padding: 10px; text-align: center; color: #555; }
        .data-grid tr:hover { background-color: #f1faff; }

        /* 操作链接样式 */
        .link-del { color: #e74c3c; text-decoration: none; font-size: 14px; }
        .link-del:hover { text-decoration: underline; font-weight: bold; }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <div class="main-container">
            <h2><i class="fas fa-user-graduate"></i> 学生档案录入系统</h2>

            <div class="form-row">
                <label class="form-label">学号 (ID)：</label>
                <asp:TextBox ID="txtStuNumber" runat="server" CssClass="form-input" placeholder="请输入唯一学号"></asp:TextBox>
                <asp:RequiredFieldValidator ID="rfvStuNum" runat="server" ControlToValidate="txtStuNumber" 
                    ErrorMessage="* 学号不能为空" CssClass="val-error" Display="Dynamic"></asp:RequiredFieldValidator>
            </div>

            <div class="form-row">
                <label class="form-label">姓名：</label>
                <asp:TextBox ID="txtName" runat="server" CssClass="form-input" placeholder="请输入学生姓名"></asp:TextBox>
                <asp:RequiredFieldValidator ID="rfvName" runat="server" ControlToValidate="txtName" 
                    ErrorMessage="* 姓名不能为空" CssClass="val-error" Display="Dynamic"></asp:RequiredFieldValidator>
            </div>

            <div class="form-row">
                <label class="form-label">性别：</label>
                <asp:DropDownList ID="ddlGender" runat="server" CssClass="form-input">
                    <asp:ListItem Value="男">男</asp:ListItem>
                    <asp:ListItem Value="女">女</asp:ListItem>
                </asp:DropDownList>
            </div>

            <div class="form-row">
                <label class="form-label">班级编号：</label>
                <asp:TextBox ID="txtClassId" runat="server" CssClass="form-input" placeholder="请输入数字编号 (如: 101)"></asp:TextBox>
                
                <asp:RequiredFieldValidator ID="rfvClass" runat="server" ControlToValidate="txtClassId" 
                    ErrorMessage="* 班级ID必填" CssClass="val-error" Display="Dynamic"></asp:RequiredFieldValidator>
                
                <asp:RangeValidator ID="rvClass" runat="server" ControlToValidate="txtClassId" 
                    ErrorMessage="* 班级ID必须是大于0的正整数" MinimumValue="1" MaximumValue="9999999" Type="Integer" 
                    CssClass="val-error" Display="Dynamic"></asp:RangeValidator>
            </div>

            <div class="form-row">
                <label class="form-label">联系电话：</label>
                <asp:TextBox ID="txtPhone" runat="server" CssClass="form-input" MaxLength="11" placeholder="选填 (11位手机号)"></asp:TextBox>
                
                <asp:RegularExpressionValidator ID="revPhone" runat="server" ControlToValidate="txtPhone"
                    ErrorMessage="* 手机号格式不正确" ValidationExpression="^\d{11}$" 
                    CssClass="val-error" Display="Dynamic"></asp:RegularExpressionValidator>
            </div>

            <div class="form-row">
                <asp:Button ID="btnAdd" runat="server" Text="确认录入" CssClass="btn-submit" OnClick="btnAdd_Click" />
            </div>

            <hr style="margin-top: 30px; border: 0; border-top: 1px solid #eee;" />

            <asp:GridView ID="gvStudents" runat="server" AutoGenerateColumns="False" CssClass="data-grid" 
                OnRowCommand="gvStudents_RowCommand" EmptyDataText="当前数据库中没有学生数据">
                <Columns>
                    <asp:BoundField DataField="StudentId" HeaderText="系统ID" />
                    <asp:BoundField DataField="StuNumber" HeaderText="学号" />
                    <asp:BoundField DataField="Name" HeaderText="姓名" />
                    <asp:BoundField DataField="Gender" HeaderText="性别" />
                    
                    <%-- 
                       逻辑核心：这里必须绑定 ClassId，对应后端的 SQL 查询字段 
                       如果是 "Class" 会报错，因为数据库里没有这个列 
                    --%>
                    <asp:BoundField DataField="ClassId" HeaderText="班级编号" />
                    
                    <asp:BoundField DataField="Phone" HeaderText="联系电话" NullDisplayText="-" />
                    
                    <asp:TemplateField HeaderText="管理操作">
                        <ItemTemplate>
                            <%-- 
                                安全逻辑：OnClientClick return confirm 
                                防止用户手抖误删数据 
                            --%>
                            <asp:LinkButton ID="btnDelete" runat="server" CommandName="Del" 
                                CommandArgument='<%# Eval("StudentId") %>' CssClass="link-del"
                                OnClientClick="return confirm('⚠️ 警告：\n确定要删除该学生档案吗？\n此操作不可恢复。');">
                                <i class="fas fa-trash-alt"></i> 删除
                            </asp:LinkButton>
                        </ItemTemplate>
                    </asp:TemplateField>
                </Columns>
            </asp:GridView>
        </div>
    </form>
</body>
</html>