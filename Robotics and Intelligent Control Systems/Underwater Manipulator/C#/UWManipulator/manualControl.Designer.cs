namespace UWManipulator
{
    partial class manualControl
    {
        /// <summary>
        /// Required designer variable.
        /// </summary>
        private System.ComponentModel.IContainer components = null;

        /// <summary>
        /// Clean up any resources being used.
        /// </summary>
        /// <param name="disposing">true if managed resources should be disposed; otherwise, false.</param>
        protected override void Dispose(bool disposing)
        {
            if (disposing && (components != null))
            {
                components.Dispose();
            }
            base.Dispose(disposing);
        }

        #region Windows Form Designer generated code

        /// <summary>
        /// Required method for Designer support - do not modify
        /// the contents of this method with the code editor.
        /// </summary>
        private void InitializeComponent()
        {
            this.label3 = new System.Windows.Forms.Label();
            this.label2 = new System.Windows.Forms.Label();
            this.label1 = new System.Windows.Forms.Label();
            this.trackBarLink3 = new System.Windows.Forms.TrackBar();
            this.trackBarLink2 = new System.Windows.Forms.TrackBar();
            this.trackBarLink1 = new System.Windows.Forms.TrackBar();
            this.labelCoordinateLink1 = new System.Windows.Forms.Label();
            this.labelCoordinateLink2 = new System.Windows.Forms.Label();
            this.labelCoordinateLink3 = new System.Windows.Forms.Label();
            ((System.ComponentModel.ISupportInitialize)(this.trackBarLink3)).BeginInit();
            ((System.ComponentModel.ISupportInitialize)(this.trackBarLink2)).BeginInit();
            ((System.ComponentModel.ISupportInitialize)(this.trackBarLink1)).BeginInit();
            this.SuspendLayout();
            // 
            // label3
            // 
            this.label3.AutoSize = true;
            this.label3.Location = new System.Drawing.Point(15, 215);
            this.label3.Name = "label3";
            this.label3.Size = new System.Drawing.Size(33, 13);
            this.label3.TabIndex = 8;
            this.label3.Text = "Link3";
            // 
            // label2
            // 
            this.label2.AutoSize = true;
            this.label2.Location = new System.Drawing.Point(15, 115);
            this.label2.Name = "label2";
            this.label2.Size = new System.Drawing.Size(33, 13);
            this.label2.TabIndex = 9;
            this.label2.Text = "Link2";
            // 
            // label1
            // 
            this.label1.AutoSize = true;
            this.label1.Location = new System.Drawing.Point(15, 19);
            this.label1.Name = "label1";
            this.label1.Size = new System.Drawing.Size(33, 13);
            this.label1.TabIndex = 10;
            this.label1.Text = "Link1";
            // 
            // trackBarLink3
            // 
            this.trackBarLink3.Location = new System.Drawing.Point(18, 231);
            this.trackBarLink3.Maximum = 50;
            this.trackBarLink3.Minimum = -50;
            this.trackBarLink3.Name = "trackBarLink3";
            this.trackBarLink3.Size = new System.Drawing.Size(764, 45);
            this.trackBarLink3.TabIndex = 5;
            this.trackBarLink3.Scroll += new System.EventHandler(this.trackBarLink3_Scroll);
            // 
            // trackBarLink2
            // 
            this.trackBarLink2.Location = new System.Drawing.Point(18, 131);
            this.trackBarLink2.Maximum = 50;
            this.trackBarLink2.Minimum = -50;
            this.trackBarLink2.Name = "trackBarLink2";
            this.trackBarLink2.Size = new System.Drawing.Size(764, 45);
            this.trackBarLink2.TabIndex = 6;
            this.trackBarLink2.Scroll += new System.EventHandler(this.trackBarLink2_Scroll);
            // 
            // trackBarLink1
            // 
            this.trackBarLink1.Location = new System.Drawing.Point(18, 35);
            this.trackBarLink1.Maximum = 50;
            this.trackBarLink1.Minimum = -50;
            this.trackBarLink1.Name = "trackBarLink1";
            this.trackBarLink1.Size = new System.Drawing.Size(764, 45);
            this.trackBarLink1.TabIndex = 7;
            this.trackBarLink1.Scroll += new System.EventHandler(this.trackBarLink1_Scroll);
            // 
            // labelCoordinateLink1
            // 
            this.labelCoordinateLink1.AutoSize = true;
            this.labelCoordinateLink1.Location = new System.Drawing.Point(711, 19);
            this.labelCoordinateLink1.Name = "labelCoordinateLink1";
            this.labelCoordinateLink1.Size = new System.Drawing.Size(0, 13);
            this.labelCoordinateLink1.TabIndex = 12;
            // 
            // labelCoordinateLink2
            // 
            this.labelCoordinateLink2.AutoSize = true;
            this.labelCoordinateLink2.Location = new System.Drawing.Point(711, 115);
            this.labelCoordinateLink2.Name = "labelCoordinateLink2";
            this.labelCoordinateLink2.Size = new System.Drawing.Size(0, 13);
            this.labelCoordinateLink2.TabIndex = 12;
            // 
            // labelCoordinateLink3
            // 
            this.labelCoordinateLink3.AutoSize = true;
            this.labelCoordinateLink3.Location = new System.Drawing.Point(711, 215);
            this.labelCoordinateLink3.Name = "labelCoordinateLink3";
            this.labelCoordinateLink3.Size = new System.Drawing.Size(0, 13);
            this.labelCoordinateLink3.TabIndex = 12;
            // 
            // manualControl
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(795, 292);
            this.Controls.Add(this.labelCoordinateLink3);
            this.Controls.Add(this.labelCoordinateLink2);
            this.Controls.Add(this.labelCoordinateLink1);
            this.Controls.Add(this.label3);
            this.Controls.Add(this.label2);
            this.Controls.Add(this.label1);
            this.Controls.Add(this.trackBarLink3);
            this.Controls.Add(this.trackBarLink2);
            this.Controls.Add(this.trackBarLink1);
            this.Name = "manualControl";
            this.Text = "Manual Control";
            this.FormClosed += new System.Windows.Forms.FormClosedEventHandler(this.manualControl_FormClosed);
            this.Load += new System.EventHandler(this.manualControl_Load);
            ((System.ComponentModel.ISupportInitialize)(this.trackBarLink3)).EndInit();
            ((System.ComponentModel.ISupportInitialize)(this.trackBarLink2)).EndInit();
            ((System.ComponentModel.ISupportInitialize)(this.trackBarLink1)).EndInit();
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion

        private System.Windows.Forms.Label label3;
        private System.Windows.Forms.Label label2;
        private System.Windows.Forms.Label label1;
        private System.Windows.Forms.TrackBar trackBarLink3;
        private System.Windows.Forms.TrackBar trackBarLink2;
        private System.Windows.Forms.TrackBar trackBarLink1;
        private System.Windows.Forms.Label labelCoordinateLink1;
        private System.Windows.Forms.Label labelCoordinateLink2;
        private System.Windows.Forms.Label labelCoordinateLink3;
    }
}