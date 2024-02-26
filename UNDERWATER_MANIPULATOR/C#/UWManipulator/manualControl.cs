using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading;
using System.Threading.Tasks;
using System.Windows.Forms;
using VCI_CAN_DotNET;
using static System.Windows.Forms.VisualStyles.VisualStyleElement;

namespace UWManipulator
{
    public partial class manualControl : Form
    {
        public float q1_des = 0;
        public float q2_des = 0;
        public float q3_des = 0;

        CancellationTokenSource tokenTXRoutine;
        Task taskTXRoutine;

        public static int Clamp(int value, int min, int max)
        {
            return (value < min) ? min : (value > max) ? max : value;
        }

        public static float Clamp(float value, float min, float max)
        {
            return (value < min) ? min : (value > max) ? max : value;
        }

        void TXRoutine()
        {
            int Ret;
            byte CAN_No, Mode, RTR, DLC;
            byte[] Data = new byte[8];
            UInt32 CANID;

            CAN_No = 0;
            Mode = 0;
            RTR = 0;
            DLC = 8;
            CANID = 0;
            for (byte ChIdx = 1; ChIdx < 3; ChIdx++)
            {
                mainMenu.Unit1.cmd_servo_rad(ref CANID, Data, DLC, q1_des);
                Ret = VCI_CAN_DotNET.VCI_SDK.VCI_SendCANMsg_NoStruct(ChIdx, Mode, RTR, DLC, CANID, Data);
                mainMenu.Unit2.cmd_servo_rad(ref CANID, Data, DLC, q2_des);
                Ret = VCI_CAN_DotNET.VCI_SDK.VCI_SendCANMsg_NoStruct(ChIdx, Mode, RTR, DLC, CANID, Data);
                mainMenu.Unit3.cmd_servo_rad(ref CANID, Data, DLC, q3_des);
                Ret = VCI_CAN_DotNET.VCI_SDK.VCI_SendCANMsg_NoStruct(ChIdx, Mode, RTR, DLC, CANID, Data);
            }
        }

        public manualControl()
        {
            InitializeComponent();
        }

        private void trackBarLink1_Scroll(object sender, EventArgs e)
        {
            q1_des = (2 * ((float)Math.PI) * trackBarLink1.Value) / trackBarLink1.Maximum;
            labelCoordinateLink1.Text = q1_des.ToString("0.0000");
        }

        private void trackBarLink2_Scroll(object sender, EventArgs e)
        {
            q2_des = (2 * ((float)Math.PI) * trackBarLink2.Value) / trackBarLink2.Maximum;
            labelCoordinateLink2.Text = q2_des.ToString("0.0000");
        }
        private void trackBarLink3_Scroll(object sender, EventArgs e)
        {
            q3_des = (2 * ((float)Math.PI) * trackBarLink3.Value) / trackBarLink3.Maximum;
            labelCoordinateLink3.Text = q3_des.ToString("0.0000");
        }

        private void manualControl_Load(object sender, EventArgs e)
        {
            q1_des = Clamp(mainMenu.q1, -2 * ((float)Math.PI), 2 * ((float)Math.PI));
            q2_des = Clamp(mainMenu.q2, -2 * ((float)Math.PI), 2 * ((float)Math.PI));
            q3_des = Clamp(mainMenu.q3, -2 * ((float)Math.PI), 2 * ((float)Math.PI));

            int trackBarLink1_val = (int)((trackBarLink1.Maximum * q1_des) / (2 * ((float)Math.PI)));
            trackBarLink1.Value = Clamp(trackBarLink1_val, trackBarLink1.Minimum, trackBarLink1.Maximum);
            int trackBarLink2_val = (int)((trackBarLink2.Maximum * q2_des) / (2 * ((float)Math.PI)));
            trackBarLink2.Value = Clamp(trackBarLink2_val, trackBarLink2.Minimum, trackBarLink2.Maximum);
            int trackBarLink3_val = (int)((trackBarLink3.Maximum * q3_des) / (2 * ((float)Math.PI)));
            trackBarLink3.Value = Clamp(trackBarLink3_val, trackBarLink3.Minimum, trackBarLink3.Maximum);
            labelCoordinateLink1.Text = q1_des.ToString("0.0000");
            labelCoordinateLink2.Text = q2_des.ToString("0.0000");
            labelCoordinateLink3.Text = q3_des.ToString("0.0000");

            tokenTXRoutine = new CancellationTokenSource();
            taskTXRoutine = Task.Run(async () =>
            {
                while (true)
                {
                    TXRoutine();
                    await Task.Delay(500, tokenTXRoutine.Token);
                }
            }, tokenTXRoutine.Token);
        }

        private void manualControl_FormClosed(object sender, FormClosedEventArgs e)
        {
            tokenTXRoutine.Cancel();
            try
            {
                taskTXRoutine.Wait();
            }
            catch (AggregateException) { }
        }
    }
}
