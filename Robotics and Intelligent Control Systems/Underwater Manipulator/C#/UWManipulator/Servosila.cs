using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

static class Constants
{
    public const float MAX_FLOAT16 = (128.0f);
    public const float MIN_FLOAT16 = (-MAX_FLOAT16);

    public const System.UInt32 SERVOSILA_RPDO_COB_ID = (0x200);
    public const System.UInt32 SERVOSILA_CMD_ESC_FREQ = (0x20);
    public const System.UInt32 SERVOSILA_CMD_ESC_RPM = (0x24);
    public const System.UInt32 SERVOSILA_CMD_SERVO = (0x30);
    public const System.UInt32 SERVOSILA_CMD_SERVO_STEPPER = (0x38);
    public const System.UInt32 SERVOSILA_CMD_CURRENT = (0x10);
    public const System.UInt32 SERVOSILA_CMD_TORGUE = (0x14);

    public const System.UInt64 SERVOSILA_WORKZONE_COUNTS_PER_REVOLUTION = (131072UL);
}

namespace UWManipulator
{
    public class Servosila
    {
        public int unit_id;
        public struct telemetry_id18x
        {
            public System.UInt16 fault_bits;   /** Counts */
            public float voltage_dc;      /** V      */
            public float electrical_freq; /** Hz     */
        };
        public telemetry_id18x id18x_data;
        public struct telemetry_id28x
        {
            public float electrical_position; /** Rad */
            public float workzone_counts;     /** Counts */
        };
        public telemetry_id28x id28x_data;
        public struct telemetry_id38x
        {
            public float phase_a_current; /** A */
            public float phase_b_current; /** A */
        };
        public telemetry_id38x id38x_data;

        public Servosila(int id)
        {
            unit_id = id;
        }

        public void update_telemetry_id18x(byte[] data, int size)
        {
            if ((data != null) || (size != sizeof(System.UInt64)))
            {
                id18x_data.fault_bits = (ushort)(((System.UInt16)data[1] << 8) | data[0]);
                System.Int16 voltage_dc_bits = (short)(((System.Int16)data[3] << 8) | data[2]);
                id18x_data.voltage_dc = voltage_dc_bits * (Constants.MAX_FLOAT16 / 32767.0f);
                System.UInt32 electrical_freq_bits = ((System.UInt32)data[7] << 24) |
                    ((System.UInt32)data[6] << 16) |
                    ((System.UInt32)data[5] << 8) | data[4];
                id18x_data.electrical_freq = System.BitConverter.ToSingle(BitConverter.GetBytes(electrical_freq_bits), 0);
            }
        }

        public void update_telemetry_id28x(byte[] data, int size)
        {
            if ((data != null) || (size != sizeof(System.UInt64)))
            {
                System.UInt32 electrical_position_bits = ((System.UInt32)data[3] << 24) |
                    ((System.UInt32)data[2] << 16) |
                    ((System.UInt32)data[1] << 8) | data[0];
                id28x_data.electrical_position = System.BitConverter.ToSingle(BitConverter.GetBytes(electrical_position_bits), 0);
                System.UInt32 workzone_counts_bits = ((System.UInt32)data[7] << 24) |
                    ((System.UInt32)data[6] << 16) |
                    ((System.UInt32)data[5] << 8) | data[4];
                id28x_data.workzone_counts = System.BitConverter.ToSingle(BitConverter.GetBytes(workzone_counts_bits), 0);
            }
        }

        public void update_telemetry_id38x(byte[] data, int size)
        {
            if ((data != null) || (size != sizeof(System.UInt64)))
            {
                System.UInt32 phase_a_current_bits = ((System.UInt32)data[3] << 24) |
                    ((System.UInt32)data[2] << 16) |
                    ((System.UInt32)data[1] << 8) | data[0];
                id38x_data.phase_a_current = System.BitConverter.ToSingle(BitConverter.GetBytes(phase_a_current_bits), 0);
                System.UInt32 phase_b_current_bits = ((System.UInt32)data[7] << 24) |
                    ((System.UInt32)data[6] << 16) |
                    ((System.UInt32)data[5] << 8) | data[4];
                id38x_data.phase_b_current = System.BitConverter.ToSingle(BitConverter.GetBytes(phase_b_current_bits), 0);
            }
        }

        /** Command - Electronic Speed Control (ESC), Hz
         * To convert the electrical revolutions per second (Hz) to motor shaft's revolutions per second,
         * just divide it by the number of pole pairs. For example, assuming the speed is 20 Hz (electrical),
         * and Poles Number is 8, then the corresponding speed in motor shaft's revolutions per second is
         * 20 / (8/2) = 5.0 Hz (revolutions per second), which is 5 * 60 = 300 RPM.
         */
        public void cmd_freq(ref System.UInt32 id, byte[] data, int size, float freq)
        {
            if ((data != null) || (size != sizeof(System.UInt64)))
            {
                id = (uint)(Constants.SERVOSILA_RPDO_COB_ID | unit_id);
                Array.Clear(data, 0, data.Length);
                System.UInt32 freq_bits = 0;
                freq_bits = (uint)BitConverter.ToInt32(BitConverter.GetBytes(freq), 0);
                data[0] = (byte)Constants.SERVOSILA_CMD_ESC_FREQ;
                data[4] = (byte)(freq_bits & 0xFF);
                data[5] = (byte)((freq_bits >> 8) & 0xFF);
                data[6] = (byte)((freq_bits >> 16) & 0xFF);
                data[7] = (byte)((freq_bits >> 24) & 0xFF);
            }
        }

        /** Command - Electronic Speed Control (ESC), RPM */
        public void cmd_rpm(ref System.UInt32 id, byte[] data, int size, float rpm)
        {
            if ((data != null) || (size != sizeof(System.UInt64)))
            {
                id = (uint)(Constants.SERVOSILA_RPDO_COB_ID | unit_id);
                Array.Clear(data, 0, data.Length);
                System.UInt32 rpm_bits = 0;
                rpm_bits = (uint)BitConverter.ToInt32(BitConverter.GetBytes(rpm), 0);
                data[0] = (byte)Constants.SERVOSILA_CMD_ESC_RPM;
                data[4] = (byte)(rpm_bits & 0xFF);
                data[5] = (byte)((rpm_bits >> 8) & 0xFF);
                data[6] = (byte)((rpm_bits >> 16) & 0xFF);
                data[7] = (byte)((rpm_bits >> 24) & 0xFF);
            }
        }

        /** Command - Servo */
        public void cmd_servo(ref System.UInt32 id, byte[] data, int size, float pose)
        {
            if ((data != null) || (size != sizeof(System.UInt64)))
            {
                id = (uint)(Constants.SERVOSILA_RPDO_COB_ID | unit_id);
                Array.Clear(data, 0, data.Length);
                System.UInt32 pose_bits = 0;
                pose_bits = (uint)BitConverter.ToInt32(BitConverter.GetBytes(pose), 0);
                data[0] = (byte)Constants.SERVOSILA_CMD_SERVO;
                data[4] = (byte)(pose_bits & 0xFF);
                data[5] = (byte)((pose_bits >> 8) & 0xFF);
                data[6] = (byte)((pose_bits >> 16) & 0xFF);
                data[7] = (byte)((pose_bits >> 24) & 0xFF);
            }
        }

        public void cmd_servo_rad(ref System.UInt32 id, byte[] data, int size, float rad)
        {
            float pose = (float)(rad / (2.0 * Math.PI)) * (float)(Constants.SERVOSILA_WORKZONE_COUNTS_PER_REVOLUTION);
            cmd_servo(ref id, data, size, pose);
        }

        /** Command - Servo Stepper */
        public void cmd_stepper(ref System.UInt32 id, byte[] data, int size, float step)
        {
            if ((data != null) || (size != sizeof(System.UInt64)))
            {
                id = (uint)(Constants.SERVOSILA_RPDO_COB_ID | unit_id);
                Array.Clear(data, 0, data.Length);
                System.UInt32 step_bits = 0;
                step_bits = (uint)BitConverter.ToInt32(BitConverter.GetBytes(step), 0);
                data[0] = (byte)Constants.SERVOSILA_CMD_SERVO_STEPPER;
                data[4] = (byte)(step_bits & 0xFF);
                data[5] = (byte)((step_bits >> 8) & 0xFF);
                data[6] = (byte)((step_bits >> 16) & 0xFF);
                data[7] = (byte)((step_bits >> 24) & 0xFF);
            }
        }

        public void cmd_stepper_rad(ref System.UInt32 id, byte[] data, int size, float step_rad)
        {
            float step = (float)(step_rad / (2.0 * Math.PI)) * (float)(Constants.SERVOSILA_WORKZONE_COUNTS_PER_REVOLUTION);
            cmd_stepper(ref id, data, size, step);
        }

        /** Command - Current Control / Field Oriented Control (FOC) */
        public void cmd_current(ref System.UInt32 id, byte[] data, int size, float current)
        {
            if ((data != null) || (size != sizeof(System.UInt64)))
            {
                id = (uint)(Constants.SERVOSILA_RPDO_COB_ID | unit_id);
                Array.Clear(data, 0, data.Length);
                System.UInt32 current_bits = 0;
                current_bits = (uint)BitConverter.ToInt32(BitConverter.GetBytes(current), 0);
                data[0] = (byte)Constants.SERVOSILA_CMD_CURRENT;
                data[4] = (byte)(current_bits & 0xFF);
                data[5] = (byte)((current_bits >> 8) & 0xFF);
                data[6] = (byte)((current_bits >> 16) & 0xFF);
                data[7] = (byte)((current_bits >> 24) & 0xFF);
            }
        }

        /** Command - Electronic Torque Control (ETC) */
        public void cmd_torque(ref System.UInt32 id, byte[] data, int size, float torque)
        {
            if ((data != null) || (size != sizeof(System.UInt64)))
            {
                id = (uint)(Constants.SERVOSILA_RPDO_COB_ID | unit_id);
                Array.Clear(data, 0, data.Length);
                System.UInt32 torque_bits = 0;
                torque_bits = (uint)BitConverter.ToInt32(BitConverter.GetBytes(torque), 0);
                data[0] = (byte)Constants.SERVOSILA_CMD_CURRENT;
                data[4] = (byte)(torque_bits & 0xFF);
                data[5] = (byte)((torque_bits >> 8) & 0xFF);
                data[6] = (byte)((torque_bits >> 16) & 0xFF);
                data[7] = (byte)((torque_bits >> 24) & 0xFF);
            }
        }
    }
}
