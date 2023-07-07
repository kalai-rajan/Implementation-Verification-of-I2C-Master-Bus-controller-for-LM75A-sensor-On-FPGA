#  Design  Implementation & Verification-of-I2C-Master-Bus-controller-for-LM75A-sensor-On-FPGA
In this project a I2C master bus controller (is designed using Verilog HDL and the design is verified using System verilog)
for interfacing LM75A Sesnor with Altera DE1 FPGA.
## LM75A SENSOR

LM75A is a 11-bot digital temperature sensor based on I2C protocol, it has semiconductor based sensor which outputs analog 
values,the analog value is converted  into the 11 bit digital data using A2D Conveter which has a conversion time
of 100ms.The digital converted data  is stored in the temperature register of LM75A.

There are three registers in LM75A sensor, out of these three registers, we have 2 
registers read/write capability, whereas remaining one as only read access. The three 
registers are

![blockdia](https://github.com/kalai-rajan/Implementation-Verification-of-I2C-Master-Bus-controller-for-LM75A-sensor-On-FPGA/assets/127617640/91e63a10-be7f-43b9-880f-7e18c5ec11be)


1. Temperature Register. (Read only)
2. Tos Resgister.(Read/write)
3. Thyst Register. (Read/write)

All the above 3 registers are 16bit wide. Temperature register have the temperature data in 
2’s compliment form. The 1’st 11bit from 15th bit to 5th bit constitute the temperature data, 
whereas remaining bits are don’t cares. The way to calculate the actual temperature data from binary
data is given in the [LM75A Datasheet](https://www.nxp.com/docs/en/data-sheet/LM75A.pdf) (page no 7).
Thys and Tos registers are read and writeable. Default value of the Thys is 75 and TOS is 80.
Thys and Tos acts as upper and lower threshold values. So if value in Temperature register cross above 
or below the TOs or Thys value the OS pin of the Sensor is asserted low.(since it is active low pin).

### Timing diagram to read and write the registers

The timing diagram are taken from the [LM75A Datasheet](https://www.nxp.com/docs/en/data-sheet/LM75A.pdf) provided by 
NXP Semiconductors. The timing diagram is based upon the I2C Protocol, and this timing diagram is the basis to design 
of I2C master bus controller state machine and implement them in the FPGA using Verilog.

![image](https://github.com/kalai-rajan/Implementation-Verification-of-I2C-Master-Bus-controller-for-LM75A-sensor-On-FPGA/assets/127617640/97c9a81e-c28c-4a97-b4f8-3aef53a84c20)
_Timing diagram for reading 2 byte data from the Tos or Thys or Temp Register._

![image](https://github.com/kalai-rajan/Implementation-Verification-of-I2C-Master-Bus-controller-for-LM75A-sensor-On-FPGA/assets/127617640/5b20b788-e117-4550-a7e7-f5859c560a08)
_Timing diagram for write Tos or Thyst registers._









