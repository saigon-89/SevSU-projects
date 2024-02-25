using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Globalization;
using System.IO;
using System.IO.Ports;
using System.Linq;
using System.Net;
using System.Net.Sockets;
using System.Reflection;
using System.Text;
using System.Text.RegularExpressions;
using System.Threading;
using System.Threading.Tasks;
using System.Windows.Forms;
using VCI_CAN_DotNET;
using static System.Windows.Forms.VisualStyles.VisualStyleElement.ProgressBar;

namespace UWManipulator
{
    public partial class mainMenu : Form
    {
        private int COM = 0;

        static public Servosila Unit1 = new Servosila(1);
        static public Servosila Unit2 = new Servosila(2);
        static public Servosila Unit3 = new Servosila(3);

        private bool[] u1_DataFreshStatus = { false, false, false };
        private bool[] u2_DataFreshStatus = { false, false, false };
        private bool[] u3_DataFreshStatus = { false, false, false };

        VCI_SDK.PFN_UserDefISR pMyTestISR0, pMyTestISR1;

        CancellationTokenSource tokenRXRoutine;
        Task taskRXRoutine;

        public static float q1 = 0f;
        public static float q2 = 0f;
        public static float q3 = 0f;

        public float q1_des = 0f;
        public float q2_des = 0f;
        public float q3_des = 0f;

        StreamWriter sw;
        private bool CSVHeaderStatus = false;

        TcpListener server;
        CancellationTokenSource tokenTCPRoutine;
        Task taskTCPRoutine;

        string[] ErrMsg =
        {
            "No_Err",               "DEV_ModName_Err",          "DEV_ModNotExist_Err",
            "DEV_PortNotExist_Err", "DEV_PortInUse_Err",        "DEV_PortNotOpen_Err",
            "CAN_ConfigFail_Err",   "CAN_HARDWARE_Err",         "CAN_PortNo_Err",
            "CAN_FIDLength_Err",    "CAN_DevDisconnect_Err",    "CAN_TimeOut_Err",
            "CAN_ConfigCmd_Err",    "CAN_ConfigBusy_Err",       "CAN_RxBufEmpty",
            "CAN_TxBufFull",        "CAN_UserDefISRNo_Err" ,    "CAN_HWSendTimerNo_Err"
        };

        public void ShowErrMsg(int ErrNo)
        {
            MessageBox.Show(ErrMsg[ErrNo], "CAN Error!", MessageBoxButtons.OK, MessageBoxIcon.Error);
        }

        public UInt32 TPFLOATMS(double fVal)
        {
            return ((UInt32)(fVal * 10) + 100000000);
        }

        public mainMenu()
        {
            InitializeComponent();
        }

        private void FormMainMenu_Load(object sender, EventArgs e)
        {
            var ports = SerialPort.GetPortNames();
            comboBoxCOM.DataSource = ports;

            tokenRXRoutine = new CancellationTokenSource();
            taskRXRoutine = Task.Run(async () =>
            {
                while (true)
                {
                    RXRoutine();
                    await Task.Delay(10, tokenRXRoutine.Token);
                }
            }, tokenRXRoutine.Token);
        }

        private void mainMenu_FormClosed(object sender, FormClosedEventArgs e)
        {
            VCI_SDK.VCI_CloseCAN((byte)COM);
            tokenRXRoutine.Cancel();
            try
            {
                taskRXRoutine.Wait();
            }
            catch (AggregateException) { }
        }

        public void Show_CmdStatus(string Res)
        {
            textBoxTelemetry.Text = "Cmd_Status :  " + Res + Environment.NewLine;
        }

        private void RXRoutine()
        {
            int Ret;
            byte Mode = 0, RTR = 0, DLC = 0;
            byte[] Data = new byte[8];
            UInt32 CANID = 0, TH = 0, TL = 0, DL, DH;
            uint RxMsgCnt = 0;
            for (byte ChIdx = 1; ChIdx < 3; ChIdx++)
            {
                VCI_SDK.VCI_Get_RxMsgCnt(ChIdx, ref RxMsgCnt);
                if (RxMsgCnt > 0)
                {
                    for (uint j = 0; j < RxMsgCnt; j++)
                    {
                        Ret = VCI_SDK.VCI_RecvCANMsg_NoStruct(ChIdx, ref Mode, ref RTR, ref DLC, ref CANID, ref TL, ref TH, Data);
                        if (Ret != 0)
                            ShowErrMsg(Ret);
                        else
                        {
                            unsafe
                            {
                                fixed (byte* pl = &Data[0], ph = &Data[4])
                                {
                                    DL = *(UInt32*)pl;
                                    DH = *(UInt32*)ph;
                                }
                            }
#if false
                            MessageBox.Show("Mode   => " + Mode + "\n" +
                                                "RTR    => " + RTR + "\n" +
                                                "DLC    => " + DLC + "\n" +
                                                "CANID  => 0x" + CANID.ToString("X") + "\n" +
                                                "Data_L => 0x" + string.Format("{0:X8}", DL) + "\n" +
                                                "Data_H => 0x" + string.Format("{0:X8}", DH) + "\n" +
                                                "Msg_Time => " + String.Format("{0:0.0000}", (double)((TH << 32) + TL) / 10000) + " (sec)");
#endif
                        }
                        if (RTR == 0)
                        {
                            if ((CANID & 0x180) == 0x180)
                            {
                                //Data[0] = 0x00; Data[1] = 0x00; Data[2] = 0xCE; Data[3] = 0x17; Data[4] = 0x00; Data[5] = 0x00; Data[6] = 0x00; Data[7] = 0x00;
                                if ((CANID & 0xF) == 1)
                                {
                                    Unit1.update_telemetry_id18x(Data, DLC);
                                    u1_DataFreshStatus[0] = true;
                                }
                                if ((CANID & 0xF) == 2)
                                {
                                    Unit2.update_telemetry_id18x(Data, DLC);
                                    u2_DataFreshStatus[0] = true;
                                }
                                if ((CANID & 0xF) == 3)
                                {
                                    Unit3.update_telemetry_id18x(Data, DLC);
                                    u3_DataFreshStatus[0] = true;
                                }
                            }
                            else if ((CANID & 0x280) == 0x280)
                            {
                                //Data[0] = 0xDB; Data[1] = 0x0F; Data[2] = 0x49; Data[3] = 0x40; Data[4] = 0x00; Data[5] = 0xC1; Data[6] = 0x71; Data[7] = 0x47;
                                if ((CANID & 0xF) == 1)
                                {
                                    Unit1.update_telemetry_id28x(Data, DLC);
                                    u1_DataFreshStatus[1] = true;
                                }
                                if ((CANID & 0xF) == 2)
                                {
                                    Unit2.update_telemetry_id28x(Data, DLC);
                                    u2_DataFreshStatus[1] = true;
                                }
                                if ((CANID & 0xF) == 3)
                                {
                                    Unit3.update_telemetry_id28x(Data, DLC);
                                    u3_DataFreshStatus[1] = true;
                                }
                            }
                            else if ((CANID & 0x380) == 0x380)
                            {
                                //Data[0] = 0x48; Data[1] = 0xCE; Data[2] = 0xCF; Data[3] = 0xBB; Data[4] = 0xC0; Data[5] = 0xB4; Data[6] = 0x77; Data[7] = 0x3D;
                                if ((CANID & 0xF) == 1)
                                {
                                    Unit1.update_telemetry_id38x(Data, DLC);
                                    u1_DataFreshStatus[2] = true;
                                }
                                if ((CANID & 0xF) == 2)
                                {
                                    Unit2.update_telemetry_id38x(Data, DLC);
                                    u2_DataFreshStatus[2] = true;
                                }
                                if ((CANID & 0xF) == 3)
                                {
                                    Unit3.update_telemetry_id38x(Data, DLC);
                                    u3_DataFreshStatus[2] = true;
                                }
                            }

                            if (u1_DataFreshStatus[0] && u1_DataFreshStatus[1] && u1_DataFreshStatus[2] &
                                u2_DataFreshStatus[0] && u2_DataFreshStatus[1] && u2_DataFreshStatus[2] &
                                u3_DataFreshStatus[0] && u3_DataFreshStatus[1] && u3_DataFreshStatus[2])
                            {
                                u1_DataFreshStatus[0] = false;
                                u1_DataFreshStatus[1] = false;
                                u1_DataFreshStatus[2] = false;
                                u2_DataFreshStatus[0] = false;
                                u2_DataFreshStatus[1] = false;
                                u2_DataFreshStatus[2] = false;
                                u3_DataFreshStatus[0] = false;
                                u3_DataFreshStatus[1] = false;
                                u3_DataFreshStatus[2] = false;
                                if (checkBoxCSVLogs.Checked && CSVHeaderStatus)
                                {
                                    sw.Write(DateTime.Now.ToFileTime() + ";");
                                    sw.Write(Unit1.id18x_data.fault_bits.ToString() + ";");
                                    sw.Write(Unit1.id18x_data.voltage_dc.ToString("0.0000") + ";");
                                    sw.Write(Unit1.id18x_data.electrical_freq.ToString() + ";");
                                    sw.Write(Unit1.id28x_data.electrical_position.ToString("0.0000") + ";");
                                    sw.Write(Unit1.id28x_data.workzone_counts.ToString("0") + ";");
                                    sw.Write(Unit1.id38x_data.phase_a_current.ToString("0.0000") + ";");
                                    sw.Write(Unit1.id38x_data.phase_b_current.ToString("0.0000") + ";");

                                    sw.Write(Unit2.id18x_data.fault_bits.ToString() + ";");
                                    sw.Write(Unit2.id18x_data.voltage_dc.ToString("0.0000") + ";");
                                    sw.Write(Unit2.id18x_data.electrical_freq.ToString() + ";");
                                    sw.Write(Unit2.id28x_data.electrical_position.ToString("0.0000") + ";");
                                    sw.Write(Unit2.id28x_data.workzone_counts.ToString("0") + ";");
                                    sw.Write(Unit2.id38x_data.phase_a_current.ToString("0.0000") + ";");
                                    sw.Write(Unit2.id38x_data.phase_b_current.ToString("0.0000") + ";");

                                    sw.Write(Unit3.id18x_data.fault_bits.ToString() + ";");
                                    sw.Write(Unit3.id18x_data.voltage_dc.ToString("0.0000") + ";");
                                    sw.Write(Unit3.id18x_data.electrical_freq.ToString() + ";");
                                    sw.Write(Unit3.id28x_data.electrical_position.ToString("0.0000") + ";");
                                    sw.Write(Unit3.id28x_data.workzone_counts.ToString("0") + ";");
                                    sw.Write(Unit3.id38x_data.phase_a_current.ToString("0.0000") + ";");
                                    sw.Write(Unit3.id38x_data.phase_b_current.ToString("0.0000") + "\n");
                                }
                            }

                            textBoxTelemetry.Text = "LINK[1]" + Environment.NewLine;
                            textBoxTelemetry.Text += "Fault Bits: " + Unit1.id18x_data.fault_bits.ToString() + Environment.NewLine;
                            textBoxTelemetry.Text += "Voltage: " + Unit1.id18x_data.voltage_dc.ToString("0.0000") + Environment.NewLine;
                            textBoxTelemetry.Text += "Speed: " + Unit1.id18x_data.electrical_freq.ToString() + Environment.NewLine;
                            textBoxTelemetry.Text += "Electrical Position: " + Unit1.id28x_data.electrical_position.ToString("0.0000") + Environment.NewLine;
                            textBoxTelemetry.Text += "Work Zone Count: " + Unit1.id28x_data.workzone_counts.ToString("0") + Environment.NewLine;
                            textBoxTelemetry.Text += "Current (Phase A): " + Unit1.id38x_data.phase_a_current.ToString("0.0000") + Environment.NewLine;
                            textBoxTelemetry.Text += "Current (Phase B): " + Unit1.id38x_data.phase_b_current.ToString("0.0000") + Environment.NewLine;
                            textBoxTelemetry.Text += Environment.NewLine + "LINK[2]" + Environment.NewLine;
                            textBoxTelemetry.Text += "Fault Bits: " + Unit2.id18x_data.fault_bits.ToString() + Environment.NewLine;
                            textBoxTelemetry.Text += "Voltage: " + Unit2.id18x_data.voltage_dc.ToString("0.0000") + Environment.NewLine;
                            textBoxTelemetry.Text += "Speed: " + Unit2.id18x_data.electrical_freq.ToString() + Environment.NewLine;
                            textBoxTelemetry.Text += "Electrical Position: " + Unit2.id28x_data.electrical_position.ToString("0.0000") + Environment.NewLine;
                            textBoxTelemetry.Text += "Work Zone Count: " + Unit2.id28x_data.workzone_counts.ToString("0") + Environment.NewLine;
                            textBoxTelemetry.Text += "Current (Phase A): " + Unit2.id38x_data.phase_a_current.ToString("0.0000") + Environment.NewLine;
                            textBoxTelemetry.Text += "Current (Phase B): " + Unit2.id38x_data.phase_b_current.ToString("0.0000") + Environment.NewLine;
                            textBoxTelemetry.Text += Environment.NewLine + "LINK[3]" + Environment.NewLine;
                            textBoxTelemetry.Text += "Fault Bits: " + Unit3.id18x_data.fault_bits.ToString() + Environment.NewLine;
                            textBoxTelemetry.Text += "Voltage: " + Unit3.id18x_data.voltage_dc.ToString("0.0000") + Environment.NewLine;
                            textBoxTelemetry.Text += "Speed: " + Unit3.id18x_data.electrical_freq.ToString() + Environment.NewLine;
                            textBoxTelemetry.Text += "Electrical Position: " + Unit3.id28x_data.electrical_position.ToString("0.0000") + Environment.NewLine;
                            textBoxTelemetry.Text += "Work Zone Count: " + Unit3.id28x_data.workzone_counts.ToString("0") + Environment.NewLine;
                            textBoxTelemetry.Text += "Current (Phase A): " + Unit3.id38x_data.phase_a_current.ToString("0.0000") + Environment.NewLine;
                            textBoxTelemetry.Text += "Current (Phase B): " + Unit3.id38x_data.phase_b_current.ToString("0.0000") + Environment.NewLine;
                        }
                    }
                }
            }
        }

        private int SerialConnect(string portName)
        {
            COM = int.Parse(Regex.Match(portName, @"\d").Value, NumberFormatInfo.InvariantInfo);

            int Ret;
            byte[] Mod_CfgData = new byte[512];

            //Listen Only Mode
            Mod_CfgData[0] = 0;                     //CAN1 => 0:Disable, 1:Enable
            Mod_CfgData[1] = 0;                     //CAN2 => 0:Disable, 1:Enable
            VCI_SDK.VCI_Set_MOD_Ex(Mod_CfgData);

            Ret = VCI_SDK.VCI_OpenCAN_NoStruct((byte)COM, VCI_SDK.I7565H2, VCI_SDK.CANBaud_1000K, VCI_SDK.CANBaud_1000K);
            if (Ret != 0)
                ShowErrMsg(Ret);
            else
            {
                Show_CmdStatus("OpenCAN Success!");
            }
            return Ret;
        }

        private void buttonConnect_Click(object sender, EventArgs e)
        {
            if (connectButton.Text == "Disconnect")
            {
                tokenRXRoutine.Cancel();
                try
                {
                    taskRXRoutine.Wait();
                }
                catch (AggregateException) { }
                VCI_SDK.VCI_CloseCAN((byte)COM);
                Show_CmdStatus("CloseCAN Success!");
                connectButton.Text = "Connect";
            }
            else if (comboBoxCOM.SelectedIndex > -1)
            {
                //MessageBox.Show(String.Format("You selected port {0}", comboBoxCOM.SelectedItem), "Connection info");
                if (SerialConnect(comboBoxCOM.SelectedItem.ToString()) == 0)
                {
                    connectButton.Text = "Disconnect";
                }
            }
            else
            {
                MessageBox.Show("Please select a port first", "Error!");
            }
        }

        private void checkBoxCSVLogs_CheckedChanged(object sender, EventArgs e)
        {
            if (checkBoxCSVLogs.Checked)
            {
                if (File.Exists("logs.csv"))
                {
                    File.Delete("logs.csv");
                }

                sw = File.AppendText("logs.csv");
                sw.Write("timestamp;");
                sw.Write("u1_fault_bits;u1_voltage;u1_speed;u1_electrical_position;u1_workzone_counts;u1_current_phase_a;u1_current_phase_b;");
                sw.Write("u2_fault_bits;u2_voltage;u2_speed;u2_electrical_position;u2_workzone_counts;u2_current_phase_a;u2_current_phase_b;");
                sw.Write("u3_fault_bits;u3_voltage;u3_speed;u3_electrical_position;u3_workzone_counts;u3_current_phase_a;u3_current_phase_b\n");
                CSVHeaderStatus = true;
            }
            else
            {
                CSVHeaderStatus = false;
                sw.Close();
            }
        }

        private void TCPRoutine()
        {
            //textBoxTelemetry.Text += "TEST" + Environment.NewLine;
            //Console.WriteLine("Waiting for a connection...");
            TcpClient client = server.AcceptTcpClient();

            //Console.WriteLine("Connected to client " + ((IPEndPoint)client.Client.RemoteEndPoint).ToString());
            NetworkStream stream = client.GetStream();
            byte[] buffer = new byte[1024];
            int bytesRead = stream.Read(buffer, 0, buffer.Length);

            string data = Encoding.ASCII.GetString(buffer, 0, bytesRead);
            var subdata = data.Split(',');
            q1_des = float.Parse(subdata[0]);
            q2_des = float.Parse(subdata[1]);
            q3_des = float.Parse(subdata[2]);
            labelLinkDes1.Text = subdata[0];
            labelLinkDes2.Text = subdata[1];
            labelLinkDes3.Text = subdata[2];
            //MessageBox.Show("Received message: " + data);

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

            string response = q1.ToString() + "," + q2.ToString() + "," + q3.ToString() + "\n";
            byte[] responseBuffer = Encoding.ASCII.GetBytes(response);

            stream.Write(responseBuffer, 0, responseBuffer.Length);
            //Console.WriteLine("Response sent.");
            stream.Close();
            client.Close();
        }

        private void checkBoxTCP_CheckedChanged(object sender, EventArgs e)
        {
            IPAddress ip = IPAddress.Parse("127.0.0.1");
            server = new TcpListener(ip, 8080);
            if (connectButton.Text == "Connect")
            {
                MessageBox.Show("Please select a port first", "Error!");
                checkBoxTCP.CheckState = CheckState.Unchecked;
            } else
            {
                if (checkBoxTCP.Checked)
                {
                    server.Start();
                    MessageBox.Show("Server started on " + server.LocalEndpoint, "TCP status");
                    tokenTCPRoutine = new CancellationTokenSource();
                    taskTCPRoutine = Task.Run(async () =>
                    {
                        while (true)
                        {
                            TCPRoutine();
                            await Task.Delay(250, tokenTCPRoutine.Token);
                        }
                    }, tokenTCPRoutine.Token);
                }
                else
                {
                    server.Stop();
                    labelLinkDes1.Text = "";
                    labelLinkDes2.Text = "";
                    labelLinkDes3.Text = "";
                    tokenTCPRoutine.Cancel();
                    try
                    {
                        taskTCPRoutine.Wait();
                    }
                    catch (AggregateException) { }
                }
            }
        }

        private void buttonManualControl_Click(object sender, EventArgs e)
        {
            if (connectButton.Text == "Connect")
            {
                MessageBox.Show("Please select a port first", "Error!");
            }
            else if (checkBoxTCP.Checked)
            {
                MessageBox.Show("TCP control is active", "Error!");
            }
            else
            {
                manualControl form = new manualControl();
                form.ShowDialog();
            }
        }
    }
}
