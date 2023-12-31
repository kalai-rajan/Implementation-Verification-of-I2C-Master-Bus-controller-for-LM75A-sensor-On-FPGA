# Files Description
**i2c_read_write.v:** Contains the design module.   
**i2c_read_tb.v:** Contains Linear testbench to test read operations.   
**i2c_write_tb.v:** Contains linear testbench to test write operations.    
**i2c_read_write_tb2.sv:** Contains constrained random testbench based       
on SV TB architecture to test both  read and write operations.

#  Design  Implementation & Verification-of-I2C-Master-Bus-controller-for-LM75A-sensor-On-FPGA

In this project a I2C master bus controller (is designed using Verilog HDL and the design is verified using System verilog)
for interfacing LM75A Sesnor with Altera DE1 FPGA.

**Technical Skills**  
Hardware description Language    : Verilog.  
Hardware Verification Language   : System Verilog.  
Tools used                       : Modelsim, Questasim, Altera Quartus.  
Hardware Boards used             : Altera Cyclone series DE1 FPGA.  

# LM75A SENSOR

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

# Timing diagram to read and write the registers

The timing diagram are taken from the [LM75A Datasheet](https://www.nxp.com/docs/en/data-sheet/LM75A.pdf) provided by 
NXP Semiconductors. The timing diagram is based upon the I2C Protocol, and this timing diagram is the basis to design 
of I2C master bus controller state machine and implement them in the FPGA using Verilog.

The pointer bye's first 6 bits value will be 0, the remaing 2 bit value, has 
addreess of the register we are going to acess.

![image](https://github.com/kalai-rajan/Implementation-Verification-of-I2C-Master-Bus-controller-for-LM75A-sensor-On-FPGA/assets/127617640/751e684a-e904-4a69-870a-ffc176a7b8be)

**_Timing diagram for reading 2 byte data from the Tos or Thys or Temp Register._**

![image](https://github.com/kalai-rajan/Implementation-Verification-of-I2C-Master-Bus-controller-for-LM75A-sensor-On-FPGA/assets/127617640/97c9a81e-c28c-4a97-b4f8-3aef53a84c20)


**_Timing diagram for writting Tos or Thyst registers._**

![image](https://github.com/kalai-rajan/Implementation-Verification-of-I2C-Master-Bus-controller-for-LM75A-sensor-On-FPGA/assets/127617640/5b20b788-e117-4550-a7e7-f5859c560a08)

# State machine design

**Stae machine for reading 2 byte data from the Tos or Thys or Temp Register._**

![image](https://github.com/kalai-rajan/Implementation-Verification-of-I2C-Master-Bus-controller-for-LM75A-sensor-On-FPGA/assets/127617640/e15c9a13-7bbd-4322-8ab1-154d739cd9f2)

**_State machine for writting Tos or Thyst registers._**


![image](https://github.com/kalai-rajan/Implementation-Verification-of-I2C-Master-Bus-controller-for-LM75A-sensor-On-FPGA/assets/127617640/7991f9d7-e776-4f08-96a5-5cdb37b57980)

# Simulation 

![image](https://github.com/kalai-rajan/Implementation-Verification-of-I2C-Master-Bus-controller-for-LM75A-sensor-On-FPGA/assets/127617640/00b8ac9d-8308-430e-b380-d58f4922c4e3)

_**Simulation waveform for reading data**_



![image](https://github.com/kalai-rajan/Implementation-Verification-of-I2C-Master-Bus-controller-for-LM75A-sensor-On-FPGA/assets/127617640/b1ff8f97-92a7-4d58-8de1-0d9946c5f2e4)


_**Simulation waveform for writting data**_

# Verfication of the design using SV

![image](https://github.com/kalai-rajan/Implementation-Verification-of-I2C-Master-Bus-controller-for-LM75A-sensor-On-FPGA/assets/127617640/85e57cfb-3eed-49d3-ab20-e498f6223078)


_The testbench was devoloped using the System Verilog Testbench Architecture and it was executed in Questasim._


[click  here to execute  the Testebench code in EDA Playground](https://www.edaplayground.com/x/me93)

# Implementation in FPGA

The _**ALtera DE1 FPGA**_ is used to implement the I2C Master bus controller designed using Verilog, using 
**_Altera Quartus tool._**

![image](https://github.com/kalai-rajan/Implementation-Verification-of-I2C-Master-Bus-controller-for-LM75A-sensor-On-FPGA/assets/127617640/7d33fb20-5965-40dc-9af5-107d08034e29)


**READING TEMPERATURE DATA**

![image](https://github.com/kalai-rajan/Implementation-Verification-of-I2C-Master-Bus-controller-for-LM75A-sensor-On-FPGA/assets/127617640/11a492de-3d6a-481d-920c-afc866cfe790)

The pointer register inputs are configured as 00 also after releasing the reset we could get
to see the data of the temperature register in seven segment display which is encoded in
hexadecimal value. The actual value in degrees in given in below calculations.

Calculations:  
P 0 F E  
P- POSITIVE  
0FE- 0000 1111 1110.  
0000 1111 1110 = 254  
temp= resolution*254  
=0.125*254  
=31.75 degree C    

**READING Tos DATA**

![image](https://github.com/kalai-rajan/Implementation-Verification-of-I2C-Master-Bus-controller-for-LM75A-sensor-On-FPGA/assets/127617640/f717d6ea-da4f-4d32-a009-5610a565bbc0)

After changing the reset button, we obtain the data in the seven segment display and the
data is encoded in the hexadecimal format the following calculations get us the actual
values.  

Calculations   
P 0 A 0  
P- POSITIVE  
0FE-0000 1010 0000  
0000 1010 0000 = 160.   
temp= resolution*160.   
=0.5*160.    
=80 degree celsius.    

**READING Thys DATA**  

![image](https://github.com/kalai-rajan/Implementation-Verification-of-I2C-Master-Bus-controller-for-LM75A-sensor-On-FPGA/assets/127617640/03dda51a-85ed-4d92-b576-1cf4959ce751)  

The same procedure of changing the pointer register pins from 00 to 11 is done now and
then we need to press the reset button to get the data of Thys Register and its actual value
is calculated is as follows.

Calculations  
P 0 9 6  
P- POSITIVE  
0FE-0000 1001 0110  
0000 1001 0110 = 150  
temp= resolution*150  
=0.5*150  
=75 degree C  

**READING Tos DATA after writting some value**

![image](https://github.com/kalai-rajan/Implementation-Verification-of-I2C-Master-Bus-controller-for-LM75A-sensor-On-FPGA/assets/127617640/c561f8b9-ed70-4f0c-87fe-5687a4caa760)

Now the FPGA board is loaded with Write FSM design, we set the pointer register to 10 to
select the Tos register, and then we press reset to write the data which is already prefixed
in the code and then we read again using read FSM and we get the -ve new value in Tos
register. Written value here in this picture is -15A, i.e., -346 degree Celsius (for sample
purpose)





















