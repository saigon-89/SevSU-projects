namespace UWManipulator
{
    partial class mainMenu
    {
        /// <summary>
        /// Обязательная переменная конструктора.
        /// </summary>
        private System.ComponentModel.IContainer components = null;

        /// <summary>
        /// Освободить все используемые ресурсы.
        /// </summary>
        /// <param name="disposing">истинно, если управляемый ресурс должен быть удален; иначе ложно.</param>
        protected override void Dispose(bool disposing)
        {
            if (disposing && (components != null))
            {
                components.Dispose();
            }
            base.Dispose(disposing);
        }

        #region Код, автоматически созданный конструктором форм Windows

        /// <summary>
        /// Требуемый метод для поддержки конструктора — не изменяйте 
        /// содержимое этого метода с помощью редактора кода.
        /// </summary>
        private void InitializeComponent()
        {
            this.comboBoxCOM = new System.Windows.Forms.ComboBox();
            this.connectButton = new System.Windows.Forms.Button();
            this.labelSerialPort = new System.Windows.Forms.Label();
            this.manualControlButton = new System.Windows.Forms.Button();
            this.textBoxTelemetry = new System.Windows.Forms.TextBox();
            this.checkBoxCSVLogs = new System.Windows.Forms.CheckBox();
            this.checkBoxTCP = new System.Windows.Forms.CheckBox();
            this.labelLinkDes1 = new System.Windows.Forms.Label();
            this.labelLinkDes2 = new System.Windows.Forms.Label();
            this.labelLinkDes3 = new System.Windows.Forms.Label();
            this.SuspendLayout();
            // 
            // comboBoxCOM
            // 
            this.comboBoxCOM.FormattingEnabled = true;
            this.comboBoxCOM.Location = new System.Drawing.Point(12, 25);
            this.comboBoxCOM.Name = "comboBoxCOM";
            this.comboBoxCOM.Size = new System.Drawing.Size(121, 21);
            this.comboBoxCOM.TabIndex = 2;
            // 
            // connectButton
            // 
            this.connectButton.Location = new System.Drawing.Point(12, 52);
            this.connectButton.Name = "connectButton";
            this.connectButton.Size = new System.Drawing.Size(121, 23);
            this.connectButton.TabIndex = 3;
            this.connectButton.Text = "Connect";
            this.connectButton.UseVisualStyleBackColor = true;
            this.connectButton.Click += new System.EventHandler(this.buttonConnect_Click);
            // 
            // labelSerialPort
            // 
            this.labelSerialPort.AutoSize = true;
            this.labelSerialPort.Location = new System.Drawing.Point(12, 9);
            this.labelSerialPort.Name = "labelSerialPort";
            this.labelSerialPort.Size = new System.Drawing.Size(55, 13);
            this.labelSerialPort.TabIndex = 4;
            this.labelSerialPort.Text = "Serial Port";
            // 
            // manualControlButton
            // 
            this.manualControlButton.Location = new System.Drawing.Point(12, 334);
            this.manualControlButton.Name = "manualControlButton";
            this.manualControlButton.Size = new System.Drawing.Size(121, 27);
            this.manualControlButton.TabIndex = 5;
            this.manualControlButton.Text = "Manual Control";
            this.manualControlButton.UseVisualStyleBackColor = true;
            this.manualControlButton.Click += new System.EventHandler(this.buttonManualControl_Click);
            // 
            // textBoxTelemetry
            // 
            this.textBoxTelemetry.Location = new System.Drawing.Point(161, 9);
            this.textBoxTelemetry.Multiline = true;
            this.textBoxTelemetry.Name = "textBoxTelemetry";
            this.textBoxTelemetry.ReadOnly = true;
            this.textBoxTelemetry.Size = new System.Drawing.Size(291, 352);
            this.textBoxTelemetry.TabIndex = 6;
            // 
            // checkBoxCSVLogs
            // 
            this.checkBoxCSVLogs.AutoSize = true;
            this.checkBoxCSVLogs.Location = new System.Drawing.Point(15, 311);
            this.checkBoxCSVLogs.Name = "checkBoxCSVLogs";
            this.checkBoxCSVLogs.Size = new System.Drawing.Size(84, 17);
            this.checkBoxCSVLogs.TabIndex = 7;
            this.checkBoxCSVLogs.Text = "CSV logging";
            this.checkBoxCSVLogs.UseVisualStyleBackColor = true;
            this.checkBoxCSVLogs.CheckedChanged += new System.EventHandler(this.checkBoxCSVLogs_CheckedChanged);
            // 
            // checkBoxTCP
            // 
            this.checkBoxTCP.AutoSize = true;
            this.checkBoxTCP.Location = new System.Drawing.Point(15, 288);
            this.checkBoxTCP.Name = "checkBoxTCP";
            this.checkBoxTCP.Size = new System.Drawing.Size(82, 17);
            this.checkBoxTCP.TabIndex = 8;
            this.checkBoxTCP.Text = "TCP control";
            this.checkBoxTCP.UseVisualStyleBackColor = true;
            this.checkBoxTCP.CheckedChanged += new System.EventHandler(this.checkBoxTCP_CheckedChanged);
            // 
            // labelLinkDes1
            // 
            this.labelLinkDes1.AutoSize = true;
            this.labelLinkDes1.Location = new System.Drawing.Point(15, 235);
            this.labelLinkDes1.Name = "labelLinkDes1";
            this.labelLinkDes1.Size = new System.Drawing.Size(0, 13);
            this.labelLinkDes1.TabIndex = 9;
            // 
            // labelLinkDes2
            // 
            this.labelLinkDes2.AutoSize = true;
            this.labelLinkDes2.Location = new System.Drawing.Point(15, 248);
            this.labelLinkDes2.Name = "labelLinkDes2";
            this.labelLinkDes2.Size = new System.Drawing.Size(0, 13);
            this.labelLinkDes2.TabIndex = 10;
            // 
            // labelLinkDes3
            // 
            this.labelLinkDes3.AutoSize = true;
            this.labelLinkDes3.Location = new System.Drawing.Point(15, 261);
            this.labelLinkDes3.Name = "labelLinkDes3";
            this.labelLinkDes3.Size = new System.Drawing.Size(0, 13);
            this.labelLinkDes3.TabIndex = 10;
            // 
            // mainMenu
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(462, 371);
            this.Controls.Add(this.labelLinkDes3);
            this.Controls.Add(this.labelLinkDes2);
            this.Controls.Add(this.labelLinkDes1);
            this.Controls.Add(this.checkBoxTCP);
            this.Controls.Add(this.checkBoxCSVLogs);
            this.Controls.Add(this.textBoxTelemetry);
            this.Controls.Add(this.manualControlButton);
            this.Controls.Add(this.labelSerialPort);
            this.Controls.Add(this.connectButton);
            this.Controls.Add(this.comboBoxCOM);
            this.Name = "mainMenu";
            this.Text = "UWManipulator";
            this.FormClosed += new System.Windows.Forms.FormClosedEventHandler(this.mainMenu_FormClosed);
            this.Load += new System.EventHandler(this.FormMainMenu_Load);
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion
        private System.Windows.Forms.ComboBox comboBoxCOM;
        private System.Windows.Forms.Button connectButton;
        private System.Windows.Forms.Label labelSerialPort;
        private System.Windows.Forms.Button manualControlButton;
        private System.Windows.Forms.TextBox textBoxTelemetry;
        private System.Windows.Forms.CheckBox checkBoxCSVLogs;
        private System.Windows.Forms.CheckBox checkBoxTCP;
        private System.Windows.Forms.Label labelLinkDes1;
        private System.Windows.Forms.Label labelLinkDes2;
        private System.Windows.Forms.Label labelLinkDes3;
    }
}

