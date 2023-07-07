#  Design  Implementation & Verification-of-I2C-Master-Bus-controller-for-LM75A-sensor-On-FPGA

LM75A is a 11-bot digital temperature sensor based on I2C protocol, it has semiconductor based sensor which outputs analog 
values,the analog value is converted  into the 11 bit digital data using A2D Conveter which has a conversion time
of 100ms.The digital converted data  is stored in the temperature register of LM75A.

There are three registers in LM75A sensor, out of these three registers, we have 2 
registers read/write capability, whereas remaining one as only read access. The three 
registers are

1. Temperature Register. (Read only)
2. Tos Resgister.(Read/write)
3. Thyst Register. (Read/write)

All the above 3 registers are 16bit wide. Temperature register have the temperature data in 
2’s compliment form. The 1’st 11bit from 15th bit to 5th bit constitute the temperature data, 
whereas remaining bits are don’t cares. The way to calculate the actual temperature data from binary
data is given in the [LM75A Datasheet](https://www.nxp.com/docs/en/data-sheet/LM75A.pdf)

